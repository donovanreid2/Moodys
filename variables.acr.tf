variable "acr_task" {
  type = object({
    agent_pool_name       = string
    platform_os           = string
    dockerfile_path       = string
    context_path          = string           # e.g., "https://github.com/org/repo.git#main" or "."
    context_access_token  = optional(string) # optional, for docker_step context if git is private
    image_repo            = string
    use_run_id_tag        = bool

    # Build on commit / PR
    source_triggers = optional(list(object({
      name           = string
      events         = list(string)          # ["commit"] or ["commit","pullrequest"]
      branch         = string                # e.g., "main"
      repository_url = string                # e.g., "https://github.com/org/repo.git"
      enabled        = optional(bool, true)

      # NEW: matches provider schema (only needed for private repos)
      authentication = optional(object({
        token             = string           # PAT / token value
        token_type        = string           # e.g., "PAT"
        expire_in_seconds = optional(number) # optional
        refresh_token     = optional(string) # optional
        scope             = optional(string) # optional
      }))
    })), [])

    # Fire a one-time build right after task creation
    initial_run_now = optional(bool, true)
  })
}
