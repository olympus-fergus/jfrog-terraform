resource "artifactory_user" "developer_read_docker_all" {
  name              = "developer-read-docker-all"
  email             = "fergus.macdermot@gmail.com"
  groups            = [artifactory_group.groups["read_docker_all"].name]
  admin             = false
  profile_updatable = false
  disable_ui_access = true
}
