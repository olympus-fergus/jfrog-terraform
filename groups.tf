resource "artifactory_group" "admin_bot_group" {
  name             = "bots"
  description      = "Admin bot access group, for configuring Artifactory"
  admin_privileges = true
}

resource "artifactory_group" "developers_group" {
  name             = "developers"
  description      = "Developers access groups, for read only access"
  admin_privileges = false
  auto_join        = true
}

resource "artifactory_permission_target" "developers_permission" {
  name = "developers-permission"

  repo = {
    repositories     = ["${artifactory_virtual_repository.docker_virtual.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.developers_group.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}

resource "artifactory_group" "ci_build_group" {
  name             = "ci-build"
  description      = "CI build bot access group, for uploading new binaries"
  admin_privileges = false
}

resource "artifactory_permission_target" "ci_build_group_permission" {
  name = "ci-deploy-permission"

  repo = {
    repositories = ["${artifactory_local_repository.docker_dev_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.ci_build_group.name}"
          permissions = ["read", "write"]
        },
      ]
    }
  }
}

resource "artifactory_group" "ci_promote_group" {
  name             = "ci-promote"
  description      = "CI promote bot access group, for promoting between environments"
  admin_privileges = false
}

resource "artifactory_permission_target" "ci_promote_group_permission" {
  name = "ci-promote-permission"

  repo = {
    repositories = ["${artifactory_local_repository.docker_prod_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.ci_promote_group.name}"
          permissions = ["read", "write"]
        },
      ]
    }
  }
}

resource "artifactory_group" "ci_download_group" {
  name             = "ci-download"
  description      = "CI downlaod bot access group, for downloading and caching to remote repos"
  admin_privileges = false
}

resource "artifactory_permission_target" "ci_download_group_permission" {
  name = "ci-download-permission"

  repo = {
    repositories = ["${artifactory_remote_repository.docker_remote.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.ci_download_group.name}"
          permissions = ["read", "write"]
        },
      ]
    }
  }
}

resource "artifactory_group" "dev_cluster_read_group" {
  name             = "dev-cluster-read"
  description      = "Group that contains the dev cluster readers"
  admin_privileges = false
}

resource "artifactory_permission_target" "dev_cluster_read_group_permission" {
  name = "dev-cluster-read-permission"

  repo = {
    repositories = ["${artifactory_local_repository.docker_dev_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.dev_cluster_read_group.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}

resource "artifactory_group" "prod_cluster_read_group" {
  name             = "prod-cluster-read-permission"
  description      = "Group that contains the prod cluster readers"
  admin_privileges = false
}

resource "artifactory_permission_target" "prod_cluster_read_group_permission" {
  name = "prod-cluster-read-permission"

  repo = {
    repositories = ["${artifactory_local_repository.docker_prod_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.prod_cluster_read_group.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}
