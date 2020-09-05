# Create a new Artifactory group called terraform
resource "artifactory_group" "bot-group" {
  name             = "bots"
  description      = "Bot access groups"
  admin_privileges = false
}