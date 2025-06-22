module "kms_key_module" {
  source                  = "git::https://github.com/jaydipd/kms-module.git?ref=master"
  description             = "KMS key for encrypting DEKs used in the app"
  is_rotataion_enabled    = true
  deletion_window_in_days = 30
  alias_name = "employee-kms-key"
}
