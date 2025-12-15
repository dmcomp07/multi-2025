# IAM and service accounts configuration
# Add custom IAM roles and service accounts as needed

# Example service account for application
# resource "google_service_account" "app_sa" {
#   account_id   = "${var.environment}-app-sa"
#   display_name = "Application Service Account"
# }

# Example custom role
# resource "google_project_iam_custom_role" "custom_role" {
#   role_id     = "${var.environment}_custom_role"
#   title       = "Custom Role"
#   description = "Custom application role"
#   permissions = [
#     "compute.instances.list",
#   ]
# }
