resource "azurerm_container_registry_task" "docker_build" {
  name                  = "build-dockerfile-task"
  container_registry_id = module.acr.acr_id
  agent_pool_name       = var.acr_task.agent_pool_name

  platform { os = var.acr_task.platform_os }

  docker_step {
    dockerfile_path      = var.acr_task.dockerfile_path
    context_path         = var.acr_task.context_path
    context_access_token = var.acr_task.context_access_token

    image_names = var.acr_task.use_run_id_tag ? [
      "${var.acr_task.image_repo}:{{.Run.ID}}",
      "${var.acr_task.image_repo}:latest"
    ] : ["${var.acr_task.image_repo}:latest"]
  }

  dynamic "source_trigger" {
    for_each = try(var.acr_task.source_triggers, [])
    content {
      name   = source_trigger.value.name
      events = source_trigger.value.events

      source_repository {
        repository_url      = source_trigger.value.repository_url
        branch              = source_trigger.value.branch
        source_control_type = "Github"
        source_control_authentication {
          token = try(source_trigger.value.token, null)
        }
      }

      enabled = coalesce(lookup(source_trigger.value, "enabled", null), true)
    }
  }
}
