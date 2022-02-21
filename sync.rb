require 'typhoeus'
require 'json'
require 'yaml'
require 'pry'
require 'semantic'
require 'fileutils'

ARTIFACTORY_URL = "https://artifactory.example.com/artifactory"
TERRAFORM_REGISTRY_REMOTE = "#{ARTIFACTORY_URL}/terraform-remote-generic"
TERRAFORM_RELEASES_REMOTE = "#{ARTIFACTORY_URL}/terraform-releases-remote-generic"
TERRAFORM_REGISTRY_LOCAL = "#{ARTIFACTORY_URL}/terraform-local"
GITHUB_REMOTE = "#{ARTIFACTORY_URL}/github-remote"
REQUIRED_OS = ["darwin", "linux"]
HOSTNAME = "registry.terraform.io"

def fetch_versions_json(provider)
   request = Typhoeus::Request.new(
       "#{TERRAFORM_REGISTRY_REMOTE}/v1/providers/#{provider}/versions",
        method: :get,
        ssl_verifypeer: false
   )
   response = request.run
   JSON.parse(response.body)
end

def fetch_version_metadata(provider, version, os, arch)
   request = Typhoeus::Request.new(
       "#{TERRAFORM_REGISTRY_REMOTE}/v1/providers/#{provider}/#{version}/download/#{os}/#{arch}",
        method: :get,
        ssl_verifypeer: false
   )
   response = request.run
   JSON.parse(response.body)
end

def artifactory_download_url(download_url)
    download_url = download_url.gsub("https://releases.hashicorp.com", TERRAFORM_RELEASES_REMOTE)
    download_url = download_url.gsub("https://github.com", GITHUB_REMOTE)
    download_url
end

def create_directory_structure(provider)
    FileUtils.mkdir_p("./artifactory/#{HOSTNAME}/#{provider}")
end

providers_yaml = YAML.load_file("./providers.yaml")
providers = providers_yaml.keys
providers.each do |provider|
    create_directory_structure(provider)
    versions_json = fetch_versions_json(provider)
    filtered_versions_json = versions_json["versions"].select do |h|
        semantic_version = Semantic::Version.new(h["version"])
        semantic_version.satisfies?(providers_yaml[provider])
    end

    registry_index_json = {"versions" => {}}
    filtered_versions_json.each do |filtered_version_map|
        version = filtered_version_map["version"]
        registry_index_json["versions"].merge!(version => {})
    end
    File.write("./artifactory/registry.terraform.io/#{provider}/index.json", JSON.pretty_generate(registry_index_json))

    filtered_versions_json.each do |filtered_version_map|
        version = filtered_version_map["version"]
        registry_version_json = {"archives" => {}}
        filtered_version_map["platforms"].each do |platform|
            os = platform["os"]
            arch = platform["arch"]
            next unless REQUIRED_OS.include?(platform["os"])
            metdata_json = fetch_version_metadata(provider, version, os, arch)
            download_url = metdata_json["download_url"]
            registry_version_json["archives"].merge!("#{os}_#{arch}" => {"url" => artifactory_download_url(download_url)})
        end
        File.write("./artifactory/registry.terraform.io/#{provider}/#{version}.json", JSON.pretty_generate(registry_version_json))
    end
end