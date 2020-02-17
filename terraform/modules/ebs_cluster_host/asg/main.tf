module "security_groups" {
  source = "./security_groups"

  name   = var.name
  vpc_id = var.vpc_id

  controlled_access_cidr_ingress    = []
  controlled_access_security_groups = []
  custom_security_groups            = []
}
