locals {
  # Concatenates the image names and tags dynamically
  agent_container_image      = "${var.agent_image_name}:${var.agent_image_tag}"
  mcp_server_container_image = "${var.mcp_server_image_name}:${var.mcp_server_image_tag}"
}