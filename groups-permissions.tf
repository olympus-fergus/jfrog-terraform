resource "artifactory_group" "read_docker_all" {
  name             = "read-docker-all"
  description      = "Read only access to all docker repos, meant to be used by developers to pull down images from all docker repos."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_group" "upload_docker_dev_local" {
  name             = "upload-docker-dev-local"
  description      = "Access group for upload access to docker-dev-local, used by the build server to upload docker builds to dev-local."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_group" "download_docker_remote" {
  name             = "download-docker-remote"
  description      = "Download group for caching objects in the remote repo, used by a build server and a way to control what images are used."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_group" "read_docker_dev_virtual" {
  name             = "read-docker-dev-virtual"
  description      = "Access group for read only access to the docker-dev-virtual repo, used by the cluster to ensure images are downloaded from the correct repo."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_group" "read_docker_stg_virtual" {
  name             = "read-docker-stg-virtual"
  description      = "Access group for read only access to the docker-stg-virtual repo, used by the cluster to ensure images are downloaded from the correct repo."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_group" "read_docker_prod_virtual" {
  name             = "read-docker-prod-virtual"
  description      = "Access group for read only access to the docker-prod-virtual repo, used by the cluster to ensure images are downloaded from the correct repo."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_group" "promote_docker_to_stg_local" {
  name             = "promote-to-docker-stg-local"
  description      = "Access group for promoting images from dev to stg, used by whatever promotion mechanism is decided."
  admin_privileges = false
  auto_join        = false
}

resource "artifactory_group" "promote_docker_to_prod_local" {
  name             = "promote-to-docker-prod-local"
  description      = "Access group for promoting images from stg to prod, used by whatever promotion mechanism is decided."
  admin_privileges = false
  auto_join        = false
}

# https://github.com/atlassian/terraform-provider-artifactory/blob/master/website/docs/r/artifactory_permission_target.html.markdown
resource "artifactory_permission_target" "read_docker_all" {
  name = "read-docker-all"

  repo = {
    repositories = ["${artifactory_local_repository.mvn_local.key}",
      "${artifactory_local_repository.docker_dev_local.key}",
      "${artifactory_local_repository.docker_stg_local.key}",
      "${artifactory_local_repository.docker_prod_local.key}",
      "${artifactory_remote_repository.docker_remote.key}",
    "${artifactory_virtual_repository.docker_all_virtual.key}", ]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.read_docker_all.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}

resource "artifactory_permission_target" "deploy_docker_dev_local" {
  name = "deploy-docker-dev-local"

  repo = {
    repositories = ["${artifactory_local_repository.docker_dev_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.upload_docker_dev_local.name}"
          permissions = ["read", "write", "annotate"]
        },
      ]
    }
  }
}

resource "artifactory_permission_target" "download_docker_remote" {
  name = "download-docker-remote"

  repo = {
    repositories = ["${artifactory_remote_repository.docker_remote.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.download_docker_remote.name}"
          permissions = ["read", "write", "annotate"]
        },
      ]
    }
  }
}

resource "artifactory_permission_target" "read_docker_dev_local" {
  name = "read-docker-dev-local"

  repo = {
    repositories = ["${artifactory_local_repository.docker_dev_local.key}"]

    actions = {

      groups = [
        //        {
        //          name        = "${artifactory_group.read_docker_dev_local.name}"
        //          permissions = ["read"]
        //        },
        {
          name        = "${artifactory_group.promote_docker_to_stg_local.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}

resource "artifactory_permission_target" "read_docker_stg_local" {
  name = "read-docker-stg-local"

  repo = {
    repositories = ["${artifactory_local_repository.docker_stg_local.key}"]

    actions = {

      groups = [
        //        {
        //          name        = "${artifactory_group.read_docker_stg_local.name}"
        //          permissions = ["read"]
        //        },
        {
          name        = "${artifactory_group.promote_docker_to_prod_local.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}

# read only to docker-dev-local and virtual
resource "artifactory_permission_target" "read_docker_dev_virtual" {
  name = "read-docker-dev-virtual"

  repo = {
    repositories = ["${artifactory_virtual_repository.docker_dev_virtual.key}",
    "${artifactory_local_repository.docker_dev_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.read_docker_dev_virtual.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}

# read only to docker-stg-local and virtual
resource "artifactory_permission_target" "read_docker_stg_virtual" {
  name = "read-docker-stg-virtual"

  repo = {
    repositories = ["${artifactory_virtual_repository.docker_stg_virtual.key}",
    "${artifactory_local_repository.docker_stg_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.read_docker_stg_virtual.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}

# read only to docker-prod-local and virtual
resource "artifactory_permission_target" "read_docker_prod_virtual" {
  name = "read-docker-prod-virtual"

  repo = {
    repositories = ["${artifactory_virtual_repository.docker_prod_virtual.key}",
    "${artifactory_local_repository.docker_prod_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.read_docker_prod_virtual.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}

resource "artifactory_permission_target" "bot_promote_docker_to_stg_local" {
  name = "promote-docker-to-stg-local"

  repo = {
    repositories = ["${artifactory_local_repository.docker_stg_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.promote_docker_to_stg_local.name}"
          permissions = ["read", "write", "annotate"]
        },
      ]
    }
  }
}

resource "artifactory_permission_target" "promote_docker_to_prod_local" {
  name = "promote-docker-to-prod-local"

  repo = {
    repositories = ["${artifactory_local_repository.docker_prod_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.promote_docker_to_prod_local.name}"
          permissions = ["read", "write", "annotate"]
        },
      ]
    }
  }
}
