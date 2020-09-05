resource "artifactory_user" "circle_ci_user" {
  name              = "circle-ci-write"
  email             = "fergus.macdermot@gmail.com"
  groups            = ["${artifactory_group.ci_bot_group.name}"]
  admin             = false
  profile_updatable = false
  disable_ui_access = true
}