resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = var.app_engine_region
  lifecycle {
    ignore_changes = [
      location_id
    ]
  }
}

resource "google_cloud_scheduler_job" "job" {
  for_each = google_app_engine_application.app.id != "" ? { for i in toset(var.scheduled_jobs) : i.name => i } : {}

  name             = each.value.name
  project          = var.project_id
  region           = var.region
  description      = try(each.value.job_description, null)
  schedule         = try(each.value.job_schedule, null)
  time_zone        = try(each.value.time_zone, null)
  attempt_deadline = try(each.value.attempt_deadline, null)

  dynamic "pubsub_target" {
    for_each = lookup(each.value, "pubsub_target", null) != null ? [each.value.pubsub_target] : []
    content {
      topic_name = try(pubsub_target.value.pubsub_topic_name, "")
      data       = try(pubsub_target.value.data, null)
      attributes = try(pubsub_target.value.attributes, null)
    }
  }
  dynamic "retry_config" {
    for_each = lookup(each.value, "retry_config", null) != null ? [each.value.retry_config] : []
    content {
      retry_count          = try(retry_config.value.retry_count, null)
      max_retry_duration   = try(retry_config.value.max_retry_duration, null)
      min_backoff_duration = try(retry_config.value.min_backoff_duration, null)
      max_backoff_duration = try(retry_config.value.max_backoff_duration, null)
      max_doublings        = try(retry_config.value.max_doublings, null)
    }
  }

  dynamic "http_target" {
    for_each = lookup(each.value, "http_target", null) != null ? [each.value.http_target] : []
    content {
      http_method = try(http_target.value.http_method, null)
      uri         = try(http_target.value.uri, null)
      body        = try(http_target.value.body, null)
      headers     = try(http_target.value.headers, null)

      dynamic "oauth_token" {
        for_each = lookup(http_target.value, "oauth_token", null) != null ? [http_target.value.oauth_token] : []
        content {
          service_account_email = try(oauth_token.value.service_account_email, null)
          scope                 = try(oauth_token.value.scope, null)
        }
      }

      dynamic "oidc_token" {
        for_each = lookup(http_target.value, "oidc_token", null) != null ? [http_target.value.oidc_token] : []
        content {
          service_account_email = try(oidc_token.value.service_account_email, null)
          audience              = try(oidc_token.value.audience, null)
        }
      }
    }
  }
  depends_on = [google_app_engine_application.app]
}
