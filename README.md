# private-terraform-registry

A POC setup for deploying a private terraform registry in an air-gap environment

## Pre-requisites

1. Artifactory deployed in vagrant. 
2. Host entry for artifactory.example.com 
3. Following configured repositories in artifactory with anonymous access
    a. Generic remote repo named 'github-remote' pointing to https://github.com 
    b. Generic remote repo named 'terraform-releases-remote-generic' pointing to https://releases.hashicorp.com
    c. Generic remote repo named 'terraform-remote-generic' pointing to https://registry.terraform.io
    d. Local repo named 'terraform-local'
3. ruby,terraform
4. typhoeus, sematic gems

## Steps

1. Configure the providers you need in providers.yaml. Providers versions has to be configured in semver.
2. Run make sync_local. This generates the folder & file structure as per https://www.terraform.io/internals/provider-network-mirror-protocol.
3. Run make sync_artifactory. This syncs the folder structure to artifactory.

#### Running the example

1. Copy .terraformrc to home directory
2. In example-terraform folder, execute terraform init.