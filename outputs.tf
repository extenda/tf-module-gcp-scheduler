output "google_app_engine_application_id" {
  value       = try(google_app_engine_application.app[0].id, null)
  description = "Id of App Engine application"
}

output "app_engine_default_service_account_email" {
  value       = data.google_app_engine_default_service_account.default.email
  description = "The email address of the default App Engine service account."
}