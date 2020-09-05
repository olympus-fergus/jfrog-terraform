# Create a new Artifactory local repository called my-local
resource "artifactory_local_repository" "mvn-local" {
  key             = "mvn-local"
  package_type    = "maven"
  repo_layout_ref = "maven-2-default"
}