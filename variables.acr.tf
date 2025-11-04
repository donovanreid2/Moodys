variable "acr_task" {
  type = object({
    agent_pool_name       = string
    platform_os           = string
    dockerfile_path       = string
    context_path          = string
    context_access_token  = optional(string)
    image_repo            = string
    use_run_id_tag        = bool

    source_triggers = optional(list(object({
      name           = string
      events         = list(string)              # e.g. ["commit"] or ["commit","pullrequest"]
      branch         = string                    # e.g. "main"
      repository_url = string                    # e.g. "https://github.com/org/repo.git"
      source_type    = string                    # "Github" or "AzureRepos"
      enabled        = optional(bool, true)
      authentication = optional(object({         # only for private repos
        token             = string               # PAT/token
        token_type        = string               # e.g. "PAT"
        expire_in_seconds = optional(number)
        refresh_token     = optional(string)
        scope             = optional(string)
      }))
    })), [])

    initial_run_now = optional(bool, true)
  })
}

