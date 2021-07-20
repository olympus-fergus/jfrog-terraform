locals {
  mvn_remote_repos = {
    mvn_non_prod = {
      key         = "mvn-remote-non-prod"
      description = "Repo for mirroring maven repos"
      notes       = "Used for the first stage before adding to prod repo. Permissions are more permissive"
      url         = "https://repo1.maven.org/maven2/"

    }
    mvn_prod = {
      key         = "mvn-remote-prod"
      description = "Prod repo for mirroring maven repos"
      notes       = "Prod repo"
      url         = "https://repo1.maven.org/maven2/"
    }
  }
  docker_remote_repos = {
    docker_prod = {
      key         = "docker-remote-prod"
      url         = "https://registry-1.docker.io/"
      description = "Repo for uploading images to for dev (non-prod environments)"
      notes       = "This repo should be pruned to avoid maintaining old images."
    }
  }
}

resource "artifactory_remote_repository" "mvn_remote" {
  for_each        = local.mvn_remote_repos
  key             = each.value.key
  url             = each.value.url
  package_type    = "maven"
  repo_layout_ref = "maven-2-default"
  description     = each.value.description
  notes           = each.value.notes
}

resource "artifactory_remote_repository" "docker_remote" {
  for_each                    = local.docker_remote_repos
  key                         = each.value.key
  url                         = each.value.url
  package_type                = "docker"
  description                 = each.value.description
  notes                       = each.value.notes
  enable_token_authentication = true

}
