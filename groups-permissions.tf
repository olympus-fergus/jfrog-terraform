locals {
  all_docker_repos = concat(
    [for key in artifactory_virtual_repository.docker_virtual : key.key],
    [for key in artifactory_remote_repository.docker_remote : key.key],
    [for key in artifactory_local_repository.docker_local : key.key]
  )
  artifactory_groups = {
    read_docker_all = {
      name        = "read-docker-all"
      description = "Read only access to all docker repos, meant to be used by developers to pull down images from all docker repos."
    }
    upload_docker_dev_local = {
      name        = "upload-docker-dev-local"
      description = "Access group for upload access to docker-dev-local, used by the build server to upload docker builds to dev-local."
    }
    download_docker_remote = {
      name        = "download-docker-remote"
      description = "Download group for caching objects in the remote repo, used by a build server and a way to control what images are used."
    }
    read_docker_dev_virtual = {
      name        = "read-docker-dev-virtual"
      description = "Access group for read only access to the docker-dev-virtual repo, used by the cluster to ensure images are downloaded from the correct repo."
    }
    read_docker_stg_virtual = {
      name        = "read-docker-stg-virtual"
      description = "Access group for read only access to the docker-stg-virtual repo, used by the cluster to ensure images are downloaded from the correct repo."
    }
    read_docker_prod_virtual = {
      name        = "read-docker-prod-virtual"
      description = "Access group for read only access to the docker-prod-virtual repo, used by the cluster to ensure images are downloaded from the correct repo."
    }
    promote_docker_to_stg_local = {
      name        = "promote-to-docker-stg-local"
      description = "Access group for promoting images from dev to stg, used by whatever promotion mechanism is decided."
    }
    promote_docker_to_prod_local = {
      name        = "promote-to-docker-prod-local"
      description = "Access group for promoting images from stg to prod, used by whatever promotion mechanism is decided."

    }
  }
  artifactory_permission_targets = {
    read_docker_all = {
      name         = "read-docker-all"
      repositories = [for key in local.all_docker_repos : key]
      groups_name  = artifactory_group.groups["read_docker_all"].name
      permissions  = ["read"]
    }
    deploy_docker_dev_local = {
      name         = "deploy-docker-dev-local"
      repositories = [artifactory_local_repository.docker_local["docker_dev"].key]
      groups_name  = artifactory_group.groups["upload_docker_dev_local"].name
      permissions  = ["read", "write", "annotate"]
    }
    download_docker_remote = {
      name         = "download-docker-remote"
      repositories = [artifactory_remote_repository.docker_remote["docker_prod"].key]
      groups_name  = artifactory_group.groups["download_docker_remote"].name
      permissions  = ["read", "write", "annotate"]
    }
    read_docker_dev_local = {
      name         = "read-docker-dev-local"
      repositories = [artifactory_local_repository.docker_local["docker_dev"].key]
      groups_name  = artifactory_group.groups["promote_docker_to_stg_local"].name
      permissions  = ["read"]
    }
    read_docker_stg_local = {
      name         = "read-docker-stg-local"
      repositories = [artifactory_local_repository.docker_local["docker_stg"].key]
      groups_name  = artifactory_group.groups["promote_docker_to_prod_local"].name
      permissions  = ["read"]
    }
    read_docker_dev_virtual = {
      name = "read-docker-dev-virtual"
      repositories = [artifactory_virtual_repository.docker_virtual["docker_dev"].key,
      artifactory_local_repository.docker_local["docker_dev"].key]
      groups_name = artifactory_group.groups["read_docker_dev_virtual"].name
      permissions = ["read"]
    }
    read_docker_stg_virtual = {
      name = "read-docker-stg-virtual"
      repositories = [artifactory_virtual_repository.docker_virtual["docker_stg"].key,
      artifactory_local_repository.docker_local["docker_stg"].key]
      groups_name = artifactory_group.groups["read_docker_stg_virtual"].name
      permissions = ["read"]
    }
    read_docker_prod_virtual = {
      name = "read-docker-prod-virtual"
      repositories = [artifactory_virtual_repository.docker_virtual["docker_prod"].key,
      artifactory_local_repository.docker_local["docker_prod"].key]
      groups_name = artifactory_group.groups["read_docker_prod_virtual"].name
      permissions = ["read"]
    }
    bot_promote_docker_to_stg_local = {
      name         = "promote-docker-to-stg-local"
      repositories = [artifactory_local_repository.docker_local["docker_stg"].key]
      groups_name  = artifactory_group.groups["promote_docker_to_stg_local"].name
      permissions  = ["read", "write", "annotate"]

    }
    promote_docker_to_prod_local = {
      name         = "promote-docker-to-prod-local"
      repositories = [artifactory_local_repository.docker_local["docker_prod"].key]
      groups_name  = artifactory_group.groups["promote_docker_to_prod_local"].name
      permissions  = ["read", "write", "annotate"]
    }
  }
}

resource "artifactory_group" "groups" {
  for_each         = local.artifactory_groups
  name             = each.value.name
  description      = each.value.description
  admin_privileges = false
  auto_join        = false
}

# https://github.com/atlassian/terraform-provider-artifactory/blob/master/website/docs/r/artifactory_permission_target.html.markdown
resource "artifactory_permission_target" "permission_targets" {
  for_each = local.artifactory_permission_targets
  name     = each.value.name
  repo {
    repositories = each.value.repositories
    actions {

      groups {
        name        = each.value.groups_name
        permissions = each.value.permissions
      }
    }
  }
}
