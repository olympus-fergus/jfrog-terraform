resource "artifactory_group" "admin_bot_group" {
  name             = "bots"
  description      = "Admin bot access group, for configuring Artifactory."
  admin_privileges = true
}

resource "artifactory_group" "developer_read_docker_all" {
  name             = "developer-read-docker-all"
  description      = "Developer access group for read only access to all docker repos, used by developers to pull down images from all docker repos."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_group" "bot_deploy_docker_dev_local" {
  name             = "bot-deploy-docker-dev-local"
  description      = "Bot access group for deploy access to docker-dev-local, used by the build server to upload docker builds to dev-local."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_group" "bot_download_docker_remote" {
  name             = "bot-download-docker-remote"
  description      = "Bot download group for caching objects in the remote repo, used by a build server and a way to control what images are used."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_group" "bot_read_docker_dev_local" {
  name             = "bot-read-docker-dev-local"
  description      = "Bot access group for read only access to the docker-dev-local repo, used by the cluster to ensure images are downloaded from the correct repo."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_group" "bot_read_docker_stg_local" {
  name             = "bot-read-docker-stg-local"
  description      = "Bot access group for read only access to the docker-stg-local repo, used by the cluster to ensure images are downloaded from the correct repo."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_group" "bot_read_docker_prod_local" {
  name             = "bot-read-docker-prod-local"
  description      = "Bot access group for read only access to the docker-prod-local repo, used by the cluster to ensure images are downloaded from the correct repo."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_group" "bot_promote_docker_to_stg_local" {
  name             = "bot-promote-to-docker-stg-local"
  description      = "Bot access group for promoting images from dev to stg, used by whatever promotion mechanism is decided."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_group" "bot_promote_docker_to_prod_local" {
  name             = "bot-promote-to-docker-prod-local"
  description      = "Bot access group for promoting images from stg to prod, used by whatever promotion mechanism is decided."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_permission_target" "developer_read_docker_all" {
  name = "developer-read-docker-all"

  repo = {
    repositories = ["${artifactory_local_repository.mvn_local.key}",
      "${artifactory_local_repository.docker_dev_local.key}",
      "${artifactory_local_repository.docker_stg_local.key}",
      "${artifactory_local_repository.docker_prod_local.key}",
      "${artifactory_remote_repository.docker_remote.key}",
    "${artifactory_virtual_repository.docker_virtual.key}", ]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.developer_read_docker_all.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}

resource "artifactory_permission_target" "bot_deploy_docker_dev_local" {
  name = "bot-deploy-docker-dev-local"

  repo = {
    repositories = ["${artifactory_local_repository.docker_dev_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.bot_deploy_docker_dev_local.name}"
          permissions = ["read", "write"]
        },
      ]
    }
  }
}

resource "artifactory_permission_target" "bot_download_docker_remote" {
  name = "bot-download-docker-remote"

  repo = {
    repositories = ["${artifactory_remote_repository.docker_remote.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.bot_download_docker_remote.name}"
          permissions = ["read", "write"]
        },
      ]
    }
  }
}

resource "artifactory_permission_target" "bot_read_docker_dev_local" {
  name = "bot-read-docker-dev-local"

  repo = {
    repositories = ["${artifactory_local_repository.docker_dev_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.bot_read_docker_dev_local.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}

resource "artifactory_permission_target" "bot_read_docker_stg_local" {
  name = "bot-read-docker-stg-local"

  repo = {
    repositories = ["${artifactory_local_repository.docker_stg_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.bot_read_docker_stg_local.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}

resource "artifactory_permission_target" "bot_read_docker_prod_local" {
  name = "bot-read-docker-prod-local"

  repo = {
    repositories = ["${artifactory_local_repository.docker_prod_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.bot_read_docker_prod_local.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}

resource "artifactory_permission_target" "bot_promote_docker_to_stg_local" {
  name = "bot-promote-docker-to-stg-local"

  repo = {
    repositories = ["${artifactory_local_repository.docker_stg_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.bot_promote_docker_to_stg_local.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}

resource "artifactory_permission_target" "bot_promote_docker_to_prod_local" {
  name = "bot-promote-docker-to-prod-local"

  repo = {
    repositories = ["${artifactory_local_repository.docker_prod_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.bot_promote_docker_to_prod_local.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}
