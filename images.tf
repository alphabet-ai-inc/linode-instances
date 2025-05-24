# doc: 
# https://registry.terraform.io/providers/linode/linode/latest/docs/data-sources/images
# images: 
# https://api.linode.com/v4/images

data "linode_images" "available_images" {
  filter {
    name = "deprecated"
    values = [false]
  }

  filter {
    name = "is_public"
    values = [true]
  }

  filter {
    name = "status"
    values = ["available"]
  }

}


output "image_ids" {
  description = "List of IDs for available public images"
  # all
#   value       = [for image in data.linode_images.available_images.images : image.id]

  # only with cloud-init support:
  value = [
    for image in data.linode_images.available_images.images : image.id
    if contains(image.capabilities, "cloud-init")
  ]

}