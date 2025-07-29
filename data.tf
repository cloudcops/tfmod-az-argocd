data "azuread_group" "rbac4groups" {
  count            = try(length(var.rbac4groups), 0)
  display_name     = var.rbac4groups[count.index].name
  security_enabled = true
}

locals {
  grantGroupIds = [for index, id in data.azuread_group.rbac4groups :
    {
      "name" : id.object_id,
      "role" : var.rbac4groups[index].role
    }
  ]
}
