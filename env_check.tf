data "external" "env_check" {
  program = ["bash", "${path.module}/env_check.sh"]
}

locals {
  env_errors = compact([
    lookup(data.external.env_check.result, "error_calculation", ""),
    lookup(data.external.env_check.result, "error_validation", "")
  ])
}

resource "null_resource" "env_validation" {
  count = length(local.env_errors) > 0 ? 1 : 0
  provisioner "local-exec" {
    command = <<EOT
    echo "Environment variable errors detected:"
    %{for err in local.env_errors~}
    echo "${err}"
    %{endfor}
    exit 1
    EOT
  }
}

