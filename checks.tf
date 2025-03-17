# check "assertions" {
#   data "kubernetes_namespace" "argocd" {
#     metadata {
#       name = "argocd"
#     }
#   }
#   assert {
#     condition     = data.kubernetes_namespace.argocd.metadata[0].name == "argocd"
#     error_message = "Namespace returned an invalid name."
#   }
# }
