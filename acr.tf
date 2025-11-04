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
      name           = source_trigger.value.name
      events         = source_trigger.value.events
      repository_url = source_trigger.value.repository_url
      source_type    = source_trigger.value.source_type   # "Github" or "AzureRepos"
      branch         = source_trigger.value.branch
      enabled        = coalesce(lookup(source_trigger.value, "enabled", null), true)

      dynamic "authentication" {
        for_each = source_trigger.value.authentication != null ? [source_trigger.value.authentication] : []
        content {
          token             = authentication.value.token
          token_type        = authentication.value.token_type
          expire_in_seconds = try(authentication.value.expire_in_seconds, null)
          refresh_token     = try(authentication.value.refresh_token, null)
          scope             = try(authentication.value.scope, null)
        }
      }
    }
  }

  tags = { Purpose = "dockerfile-build", Service = "acr-task", Env = "dev" }
}

acr_task = {
  agent_pool_name      = "acr-agent-pool"
  platform_os          = "Linux"
  dockerfile_path      = "Dockerfile"
  context_path         = "https://github.com/yourorg/private-repo.git#main"
  context_access_token = null
  image_repo           = "myapp"
  use_run_id_tag       = true
  source_triggers = [
    { name = "on-commit", events = ["commit"], branch = "main",
      repository_url = "https://github.com/yourorg/private-repo.git", source_type = "Github",
      authentication = { token = "ghp_xxx", token_type = "PAT" } }
  ]
  initial_run_now = true
}

