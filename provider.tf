terraform {
  required_providers {
    artifactory = {
      source  = "jfrog/artifactory"
      version = "2.2.15"
    }
  }
}

# Access token set by exporting ARTIFACTORY_ACCESS_TOKEN
# URL set by exporting ARTIFACTORY_URL (should be something like https://accountname.jfrog.io/accountname
provider "artifactory" {
}