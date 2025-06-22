module "aws_kms" {
  source                  = "git::https://github.com/jaydipd/kms-module.git?ref=master"
  description             = "KMS key for encrypting DEKs used in the app"
  is_rotataion_enabled    = true
  deletion_window_in_days = 1
  alias_name = "employee-kms-key"
}
output "kms_key_Arn" {
  value = module.aws_kms.key_arn
}