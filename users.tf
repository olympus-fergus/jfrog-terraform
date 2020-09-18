resource "artifactory_user" "developer_read_docker_all" {
  name              = "developer-read-docker-all"
  email             = "fergus.macdermot@gmail.com"
  groups            = ["${artifactory_group.developer_read_docker_all.name}"]
  admin             = false
  profile_updatable = false
  disable_ui_access = true
}

resource "artifactory_user" "bot_deploy_docker_dev_local" {
  name              = "bot-deploy-docker-dev-local"
  email             = "fergus.macdermot@gmail.com"
  groups            = ["${artifactory_group.bot_deploy_docker_dev_local.name}"]
  admin             = false
  profile_updatable = false
  disable_ui_access = true
}

resource "artifactory_user" "bot_download_docker_remote" {
  name              = "bot-download-docker-remote"
  email             = "fergus.macdermot@gmail.com"
  groups            = ["${artifactory_group.bot_download_docker_remote.name}"]
  admin             = false
  profile_updatable = false
  disable_ui_access = true
}

resource "artifactory_user" "bot_read_docker_dev_local" {
  name              = "bot-read-docker-dev-local"
  email             = "fergus.macdermot@gmail.com"
  groups            = ["${artifactory_group.bot_read_docker_dev_local.name}"]
  admin             = false
  profile_updatable = false
  disable_ui_access = true
}

resource "artifactory_user" "bot_read_docker_stg_local" {
  name              = "bot-read-docker-stg-local"
  email             = "fergus.macdermot@gmail.com"
  groups            = ["${artifactory_group.bot_read_docker_stg_local.name}"]
  admin             = false
  profile_updatable = false
  disable_ui_access = true
}

resource "artifactory_user" "bot_read_docker_prod_local" {
  name              = "bot-read-docker-prod-local"
  email             = "fergus.macdermot@gmail.com"
  groups            = ["${artifactory_group.bot_read_docker_prod_local.name}"]
  admin             = false
  profile_updatable = false
  disable_ui_access = true
}

resource "artifactory_user" "bot_promote_docker_to_stg_local" {
  name              = "bot-promote-docker-to-stg-local"
  email             = "fergus.macdermot@gmail.com"
  groups            = ["${artifactory_group.bot_promote_docker_to_stg_local.name}"]
  admin             = false
  profile_updatable = false
  disable_ui_access = true
}

resource "artifactory_user" "bot_promote_docker_to_prod_local" {
  name              = "bot-promote-docker-to-prod-local"
  email             = "fergus.macdermot@gmail.com"
  groups            = ["${artifactory_group.bot_promote_docker_to_prod_local.name}"]
  admin             = false
  profile_updatable = false
  disable_ui_access = true
}
