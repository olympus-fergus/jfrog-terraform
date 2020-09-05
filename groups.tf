resource "artifactory_group" "admin-bot-group" {
  name             = "bots"
  description      = "Admin bot access group, for configuring Artifactory"
  admin_privileges = true
}

resource "artifactory_group" "developers-group" {
  name             = "developers"
  description      = "Developers access groups, for read only access"
  admin_privileges = false
  auto_join = true
}

resource "artifactory_group" "ci-bot-group" {
  name             = "ci-bot"
  description      = "CI bot access group, for uploading new binaries"
  admin_privileges = false
}

# Create a new Artifactory user called terraform
resource "artifactory_user" "test-user" {
  name     = "terraform"
  email    = "fergus.macdermot@gmail.com"
  groups   = ["${artifactory_group.developers-group.name}"]
  password = "my super secret password"
  admin = false
  profile_updatable = false
  disable_ui_access = true
}

# Create a new Artifactory permission target called testpermission
resource "artifactory_permission_target" "developer-permission" {
  name = "developer-permission"

  repo = {
    includes_pattern = ["foo/**"]
    excludes_pattern = ["bar/**"]
    repositories     = ["${artifactory_local_repository.mvn-local.key}"]

    actions = {

      groups = [
        {
          name        = "${artifactory_group.developers-group.name}"
          permissions = ["read"]
        },
      ]
    }
  }
}