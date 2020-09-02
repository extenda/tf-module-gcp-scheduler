variable create_job {
  type        = bool
  description = "Specify true if you want to create a job"
  default     = true
}

variable project_id {
  type        = string
  description = "Project ID where the jobs will be created"
}

 variable region {
   type    = string
   description = "Region where the scheduler job resides. If it is not provided, Terraform will use the provider default"
   default     = "europe-west1"
 }

variable scheduled_jobs {
  type        = list(map(string))
  description = "The list of the jobs to be created"
  default     = []
}


variable app_engine_region {
   type        = string
   description = "Region to serve the app from"
   default     = "europe-west"
}
