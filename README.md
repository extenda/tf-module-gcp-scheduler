# tf-module-gcp-scheduler
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.4.6 |
| google | ~> 4.62.0 |
| google-beta | ~> 4.62.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_engine\_region | Region to serve the app from | `string` | `"europe-west"` | no |
| project\_id | Project ID where the jobs will be created | `string` | n/a | yes |
| region | Region where the scheduler job resides. If it is not provided, Terraform will use the provider default | `string` | `"europe-west1"` | no |
| scheduled\_jobs | The list of the jobs to be created | <pre>list(object(<br>    {<br>      name             = string<br>      description      = optional(string)<br>      schedule         = optional(string)<br>      time_zone        = optional(string)<br>      attempt_deadline = optional(string)<br><br>      pubsub_target = optional(object({<br>        topic_name = optional(string)<br>        data       = optional(string)<br>        attributes = optional(map(string))<br>      }))<br><br>      retry_config = optional(object({<br>        retry_count          = optional(number)<br>        max_retry_duration   = optional(string)<br>        min_backoff_duration = optional(string)<br>        max_backoff_duration = optional(string)<br>        max_doublings        = optional(number)<br>      }))<br><br>      http_target = optional(object({<br>        http_method = optional(string)<br>        uri         = optional(string)<br>        body        = optional(string)<br>        headers     = optional(map(string))<br>        oauth_token = optional(object({<br>          service_account_email = optional(string)<br>          scope                 = optional(string)<br>        }))<br>        oidc_token = optional(object({<br>          service_account_email = optional(string)<br>          audience              = optional(string)<br>        }))<br>      }))<br><br>    }))</pre> | `[]` | yes |

## Outputs

| Name | Description |
|------|-------------|
| app\_engine\_default\_service\_account\_email | The email address of the default App Engine service account |
| google\_app\_engine\_application\_id | Id of App Engine application |

## Usage

A scheduled job that can publish a pubsub message or a http request every X interval of time, using crontab format string.

The variable *`scheduled_jobs`* supports the following arguments:
- `name`: The name of the job.
- `job_description`: A human-readable description for the job. This string must not contain more than 500 characters.
- `job_schedule`: Describes the schedule on which the job will be executed.
- `time_zone`: Specifies the time zone to be used in interpreting schedule. The value of this field must be a time zone name from the tz database.
- `attempt_deadline`: The deadline for job attempts. If the request handler does not respond by this deadline then the request is cancelled and the attempt is marked as a DEADLINE_EXCEEDED failure. The failed attempt can be viewed in execution logs. Cloud Scheduler will retry the job according to the RetryConfig.
```
retry_config = {}
```
The allowed duration for this deadline is:
  For HTTP targets, between 15 seconds and 30 minutes.
  For App Engine HTTP targets, between 15 seconds and 24 hours. A duration in seconds with up to nine fractional digits, terminated by 's'. Example: "3.5s"
- `min_backoff_duration`: The minimum amount of time to wait before retrying a job after it fails
- `max_backoff_duration`: The maximum amount of time to wait before retrying a job after it fails

By default, if a job does not complete successfully, meaning that an acknowledgement is not received from the handler, then it will be retried with exponential backoff according to the settings Structure is documented below.
- `retry_count`: The number of attempts that the system will make to run a job using the exponential backoff procedure described by maxDoublings. Values greater than 5 and negative values are not allowed.
- `max_retry_duration`: The time limit for retrying a failed job, measured from time when an execution was first attempted. If specified with retryCount, the job will be retried until both limits are reached. A duration in seconds with up to nine fractional digits, terminated by 's'.
- `max_doublings` - The time between retries will double maxDoublings times. A job's retry interval starts at minBackoffDuration, then doubles maxDoublings times, then increases linearly, and finally retries retries at intervals of maxBackoffDuration up to retryCount times.

If the job provides a Pub/Sub target the cron will publish a message to the provided topic Structure is documented below.
```
pubsub_target = {}
```
- `topic_name`: The full resource name for the Cloud Pub/Sub topic to which messages will be published when a job is delivered. ~>NOTE: The topic name must be in the same format as required by PubSub's PublishRequest.name, e.g. projects/my-project/topics/my-topic.
- `data`: The message payload for PubsubMessage. Pubsub message must contain non-empty data.
- `attributes`: Attributes for PubsubMessage. Pubsub message must contain either non-empty data, or at least one attribute.

If the job provides a http_target the cron will send a request to the targeted url Structure is documented below.
```
http_target = {}
```
- `uri`: The full URI path that the request will be sent to.
- `http_method`: Which HTTP method to use for the request.
- `body`: HTTP request body. A request body is allowed only if the HTTP method is POST, PUT, or PATCH. It is an error to set body on a job with an incompatible HttpMethod.
- `headers`: This map contains the header field names and values. Repeated headers are not supported, but a header value can contain commas.

Contains information needed for generating an OAuth token. This type of authorization should be used when sending requests to a GCP endpoint. Structure is documented below.
```
http_target = {
  oauth_token = {}
}
```
- `service_account_email`: Service account email to be used for generating OAuth token. The service account must be within the same project as the job.
- `scope`: OAuth scope to be used for generating OAuth access token. If not specified, "https://www.googleapis.com/auth/cloud-platform" will be used.

Contains information needed for generating an OpenID Connect token. This type of authorization should be used when sending requests to third party endpoints or Cloud Run. Structure is documented below.
```
http_target = {
  oidc_token = {}
}
```
- `service_account_email`: Service account email to be used for generating OAuth token. The service account must be within the same project as the job.
- `audience`: - Audience to be used when generating OIDC token. If not specified, the URI specified in target will be used.

Example:

```
scheduled_jobs = [
       {
          name = "my-test-job-1"
          job_description = "description of the job"
          job_schedule = "0 9 * * 1"
          retry_config = {
            retry_count = 1
          }
          pubsub_target = {
            topic_name = "projects/PROJECT_ID/topics/TOPIC_NAME"
            data = "${base64encode("test")}"
          }
        },
        {
          name = "my-test-job-2"
          ...
        }
      ]
```