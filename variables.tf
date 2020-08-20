variable create_job {
  type        = bool
  description = "Specify true if you want to create a job"
  default     = true
}

variable project_id {
  description = "Project ID where the secrets are stored"
  type        = string
}

variable region {
  type    = string
  default = "europe-west-1"
}

variable scheduled_jobs {
  type        = list(map(string))
  description = "The list of the jobs to be created"
  default     = []
}
