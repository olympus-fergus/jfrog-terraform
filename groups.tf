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

resource "artifactory_group" "ci_bot_group" {
  name             = "ci-bot"
  description      = "CI bot access group, for uploading new binaries"
  admin_privileges = false
}

resource "artifactory_permission_target" "developer_permission" {
  name = "developer-permission"

  repo = {
    includes_pattern = ["foo/**"]
    excludes_pattern = ["bar/**"]
    repositories     = ["${artifactory_local_repository.mvn_local.key}"]

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

resource "artifactory_permission_target" "ci_bot_group_permission" {
  name = "ci-bot-permission"

  repo = {
    repositories     = ["${artifactory_local_repository.mvn_local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.ci_bot_group.name}"
          permissions = ["read", "write"]
        },
      ]
    }
  }
}