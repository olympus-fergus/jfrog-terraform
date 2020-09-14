resource "artifactory_user" "ci_build_bot_user" {
  name                       = "ci-build-bot"
  email                      = "fergus.macdermot@gmail.com"
  groups                     = ["${artifactory_group.ci_build_group.name}"]
  admin                      = false
  profile_updatable          = false
  disable_ui_access          = true
  internal_password_disabled = true
}

resource "artifactory_user" "ci_promote_bot_user" {
  name                       = "ci-promote-bot"
  email                      = "fergus.macdermot@gmail.com"
  groups                     = ["${artifactory_group.ci_promote_group.name}"]
  admin                      = false
  profile_updatable          = false
  disable_ui_access          = true
  internal_password_disabled = true
}

resource "artifactory_user" "ci_download_bot_user" {
  name                       = "ci-download-bot"
  email                      = "fergus.macdermot@gmail.com"
  groups                     = ["${artifactory_group.ci_promote_group.name}"]
  admin                      = false
  profile_updatable          = false
  disable_ui_access          = true
  internal_password_disabled = true
}

resource "artifactory_user" "dev_cluster_read_user" {
  name                       = "dev-cluster-read-bot"
  email                      = "fergus.macdermot@gmail.com"
  groups                     = ["${artifactory_group.dev_cluster_read_group.name}"]
  admin                      = false
  profile_updatable          = false
  disable_ui_access          = true
  internal_password_disabled = true
}

resource "artifactory_user" "prod_cluster_read_user" {
  name                       = "prod-cluster-read-bot"
  email                      = "fergus.macdermot@gmail.com"
  groups                     = ["${artifactory_group.prod_cluster_read_group.name}"]
  admin                      = false
  profile_updatable          = false
  disable_ui_access          = true
  internal_password_disabled = true
}