locals {
  mvn_local_repos = {
    mvn_non_prod = {
      key         = "mvn-local-non-prod"
      description = "Dev repo for mirroring and uploading from build server"
      notes       = "Used for the first stage before promoting to prod repo"
    }
    mvn_prod = {
      key         = "mvn-local-prod"
      description = "Prod repo for mirroring and uploading from build server"
      notes       = "Used for the first stage before promoting to prod repo"
    }
  }
  docker_local_repos = {
    docker_dev = {
      key                = "docker-local-dev"
      description        = "Repo for uploading images to for dev (non-prod environments)"
      notes              = "This repo should be pruned to avoid maintaining old images."
      docker_api_version = "V2"
      max_unique_tags    = 10
    }
    docker_stg = {
      key             = "docker-local-stg"
      description     = "Repo for uploading images to for stg (non-prod environments)"
      notes           = "This repo should be pruned to avoid maintaining old images."
      max_unique_tags = 10
    }
    docker_prod = {
      key             = "docker-local-prod"
      description     = "Repo for uploading images to for prod (prod environments)"
      notes           = "This repo should not be pruned as we want to keep old images for audit"
      max_unique_tags = 0
    }

  }
}

resource "artifactory_local_repository" "mvn_local" {
  for_each        = local.mvn_local_repos
  key             = each.value.key
  package_type    = "maven"
  repo_layout_ref = "maven-2-default"
  description     = each.value.description
  notes           = each.value.notes
}

resource "artifactory_local_repository" "docker_local" {
  for_each           = local.docker_local_repos
  key                = each.value.key
  package_type       = "docker"
  description        = each.value.description
  notes              = each.value.notes
  docker_api_version = "V2"
  max_unique_tags    = each.value.max_unique_tags
}
