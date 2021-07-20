output "repositories_local" {
  description = "Output for all local repos"
  value = merge(
    { for key, obj in artifactory_local_repository.mvn_local : key => obj.id },
    { for key, obj in artifactory_local_repository.docker_local : key => obj.id }
  )
}

output "repositories_remote" {
  description = "Output for all remote repos"
  value = merge(
    { for key, obj in artifactory_remote_repository.mvn_remote : key => obj.id },
    { for key, obj in artifactory_remote_repository.docker_remote : key => obj.id }
  )
}

output "repositories_virtual" {
  description = "Output for all virtual repos"
  value = concat(
    [for key in artifactory_virtual_repository.mvn_virtual : key.key],
    [for key in artifactory_virtual_repository.docker_virtual : key.key]
  )
}

output "artifactory_groups" {
  value = [for name in artifactory_group.groups : name.name]
}