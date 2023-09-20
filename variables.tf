variable "project_id" {
  type        = string
  description = "Project ID where the jobs will be created"
}

variable "region" {
  type        = string
  description = "Region where the scheduler job resides. If it is not provided, Terraform will use the provider default"
  default     = "europe-west1"
}

variable "scheduled_jobs" {
  type = list(object(
    {
      name             = string
      description      = optional(string)
      schedule         = optional(string)
      time_zone        = optional(string)
      attempt_deadline = optional(string)

      pubsub_target = optional(object({
        topic_name = optional(string)
        data       = optional(string)
        attributes = optional(map(string))
      }))

      retry_config = optional(object({
        retry_count          = optional(number)
        max_retry_duration   = optional(string)
        min_backoff_duration = optional(string)
        max_backoff_duration = optional(string)
        max_doublings        = optional(number)
      }))

      http_target = optional(object({
        http_method = optional(string)
        uri         = optional(string)
        body        = optional(string)
        headers     = optional(map(string))
        oauth_token = optional(object({
          service_account_email = optional(string)
          scope                 = optional(string)
        }))
        oidc_token = optional(object({
          service_account_email = optional(string)
          audience              = optional(string)
        }))
      }))

  }))
  description = "The list of the jobs to be created"
  default     = []
}

variable "app_engine_region" {
  type        = string
  description = "Region to serve the app from"
  default     = "europe-west"
}
