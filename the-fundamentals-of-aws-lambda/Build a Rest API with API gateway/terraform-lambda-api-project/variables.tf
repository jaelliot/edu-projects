variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}
variable "lambda_runtime" {
  description = "Runtime for Lambda function"
  default     = "python3.9"
}
