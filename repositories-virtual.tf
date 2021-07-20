locals {
  mvn_virtual_repos = {
    mvn_non_prod = {
      key = "mvn-virtual-non-prod"
      repositories = [artifactory_local_repository.mvn_local["mvn_non_prod"].key,
        artifactory_remote_repository.mvn_remote["mvn_non_prod"].key
      ]
    }
    mvn_prod = {
      key = "mvn-virtual-prod"
      repositories = [artifactory_local_repository.mvn_local["mvn_prod"].key,
        artifactory_remote_repository.mvn_remote["mvn_prod"].key
      ]
    }
  }
  docker_virtual_repos = {
    docker_dev = {
      key = "docker-virtual-dev"
      repositories = [artifactory_local_repository.docker_local["docker_dev"].key,
        artifactory_remote_repository.docker_remote["docker_prod"].key
      ]
    }
    docker_stg = {
      key = "docker-virtual-stg"
      repositories = [artifactory_local_repository.docker_local["docker_stg"].key,
        artifactory_remote_repository.docker_remote["docker_prod"].key
      ]
    }
    docker_prod = {
      key = "docker-virtual-prod"
      repositories = [artifactory_local_repository.docker_local["docker_prod"].key,
        artifactory_remote_repository.docker_remote["docker_prod"].key
      ]
    }
  }

}

resource "artifactory_virtual_repository" "mvn_virtual" {
  for_each     = local.mvn_virtual_repos
  key          = each.value.key
  package_type = "maven"
  repositories = each.value.repositories
}

resource "artifactory_virtual_repository" "docker_virtual" {
  for_each     = local.docker_virtual_repos
  key          = each.value.key
  package_type = "docker"
  repositories = each.value.repositories
}
