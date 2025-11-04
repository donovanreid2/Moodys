resource "azurerm_container_registry_task" "docker_build" {
  name                  = "build-dockerfile-task"
  container_registry_id = module.acr.acr_id
  agent_pool_name       = var.acr_task.agent_pool_name

  platform { os = var.acr_task.platform_os }

  docker_step {
    dockerfile_path      = var.acr_task.dockerfile_path
    context_path         = var.acr_task.context_path          # git URL (with #branch) or "."
    context_access_token = var.acr_task.context_access_token  # only if that git context is private

    image_names = var.acr_task.use_run_id_tag ? [
      "${var.acr_task.image_repo}:{{.Run.ID}}",
      "${var.acr_task.image_repo}:latest"
    ] : ["${var.acr_task.image_repo}:latest"]
  }

  # Source-triggered builds (commit/pullrequest)
  dynamic "source_trigger" {
    for_each = try(var.acr_task.source_triggers, [])
    content {
      name   = source_trigger.value.name
      events = source_trigger.value.events

      source_repository {
        repository_url      = source_trigger.value.repository_url
        branch              = source_trigger.value.branch
        source_control_type = "Github"  # Valid values include "Github" and "AzureRepos"

        # <-- THIS is the correct auth block name & fields
        dynamic "authentication" {
          for_each = source_trigger.value.authentication != null ? [source_trigger.value.authentication] : []
          content {
            token             = authentication.value.token
            token_type        = authentication.value.token_type  # e.g., "PAT"
            expire_in_seconds = try(authentication.value.expire_in_seconds, null)
            refresh_token     = try(authentication.value.refresh_token, null)
            scope             = try(authentication.value.scope, null)
          }
        }
      }

      enabled = coalesce(lookup(source_trigger.value, "enabled", null), true)
    }
  }

  tags = {
    Purpose = "dockerfile-build"
    Service = "acr-task"
    Env     = "dev"
  }
}

error:
Required attribute "repository_url" not specified: An attribute named "repository_url" is required hereTerraform
Required attribute "source_type" not specified: An attribute named "source_type" is required hereTerraform
Unexpected block: Blocks of type "source_repository" are not expected hereTerraform
: ()
