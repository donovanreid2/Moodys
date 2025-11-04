variable "acr_task" {
  type = object({
    agent_pool_name       = string
    platform_os           = string
    dockerfile_path       = string
    context_path          = string  # e.g. "https://github.com/org/repo.git#main"
    context_access_token  = optional(string)
    image_repo            = string
    use_run_id_tag        = bool

    # Build on commits / PRs
    source_triggers = optional(list(object({
      name           = string
      events         = list(string) # ["commit"] or ["commit","pullrequest"]
      branch         = string
      repository_url = string
      token          = optional(string)
      enabled        = optional(bool, true)
    })), [])

    # NEW: fire a build immediately after task creation (set to false after first run)
    initial_run_now = optional(bool, true)
  })
}
