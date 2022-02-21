sync_local:
	ruby sync.rb

sync_artifactory:
	jfrog rt u '*' terraform-local --url http://192.168.199.51:8082/artifactory --user admin --password artifactory --quiet --recursive=true --sync-deletes="terraform-registry-local"

clean:
	rm -rf artifactory/*
