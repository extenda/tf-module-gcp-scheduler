resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = var.app_engine_region
}

resource "google_cloud_scheduler_job" "job" {
  count = var.create_job ? length(var.scheduled_jobs) : 0

  name             = var.scheduled_jobs[count.index].name
  project          = var.project_id
  region           = var.region
  description      = lookup(var.scheduled_jobs[count.index], "job_description", null)
  schedule         = lookup(var.scheduled_jobs[count.index], "job_schedule", null)
  time_zone        = lookup(var.scheduled_jobs[count.index], "time_zone", null)
  attempt_deadline = lookup(var.scheduled_jobs[count.index], "attempt_deadline", null)

  dynamic "pubsub_target" {
    for_each = (lookup(var.scheduled_jobs[count.index], "pubsub_topic_name", "") != "") ? [var.scheduled_jobs[count.index].pubsub_topic_name] : []
    content {
      topic_name = lookup(var.scheduled_jobs[count.index], "pubsub_topic_name", "")
      data       = lookup(var.scheduled_jobs[count.index], "data", null)
      attributes = lookup(var.scheduled_jobs[count.index], "attributes", null)
    }
  }
  dynamic "retry_config" {
    for_each = (lookup(var.scheduled_jobs[count.index], "retry_count", "") != "") ? [var.scheduled_jobs[count.index].retry_count] : []
    content {
      retry_count          = lookup(var.scheduled_jobs[count.index], "retry_count", "")
      max_retry_duration   = lookup(var.scheduled_jobs[count.index], "max_retry_duration", null)
      min_backoff_duration = lookup(var.scheduled_jobs[count.index], "min_backoff_duration", null)
      max_backoff_duration = lookup(var.scheduled_jobs[count.index], "max_backoff_duration", null)
      max_doublings        = lookup(var.scheduled_jobs[count.index], "max_doublings", null)
    }
  }

  dynamic "http_target" {
    for_each = (lookup(var.scheduled_jobs[count.index], "uri", "") != "") ? [var.scheduled_jobs[count.index].uri] : []
    content {
      http_method = lookup(var.scheduled_jobs[count.index], "http_method", "")
      uri         = lookup(var.scheduled_jobs[count.index], "uri", "")
      body        = lookup(var.scheduled_jobs[count.index], "body", "")
      headers     = lookup(var.scheduled_jobs[count.index], "headers", null)

      dynamic "oauth_token" {
        for_each = (lookup(var.scheduled_jobs[count.index], "oauth_service_account_email", "") != "") ? [var.scheduled_jobs[count.index].oauth_service_account_email] : []
        content {
          service_account_email = lookup(var.scheduled_jobs[count.index], "oauth_service_account_email", "")
          scope                 = lookup(var.scheduled_jobs[count.index], "scope", "https://www.googleapis.com/auth/cloud-platform")
        }
      }

      dynamic "oidc_token" {
        for_each = (lookup(var.scheduled_jobs[count.index], "oidc_service_account_email", "") != "") ? [var.scheduled_jobs[count.index].oidc_service_account_email] : []
        content {
          service_account_email = lookup(var.scheduled_jobs[count.index], "oidc_service_account_email", "")
          audience              = lookup(var.scheduled_jobs[count.index], "audience", "")
        }
      }
    }
  }
}
