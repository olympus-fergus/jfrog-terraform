# Create a new Artifactory local repository called my-local
resource "artifactory_local_repository" "mvn_local" {
  key             = "mvn-local"
  package_type    = "maven"
  repo_layout_ref = "maven-2-default"
  description     = "Main repo for mirroring and uploading from build server"
  notes           = "Note to see what they do"
}