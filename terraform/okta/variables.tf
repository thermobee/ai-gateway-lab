variable "TEST_EMAIL_USER" {
  type        = string
  description = "Mailbox name for all test users, the part before +alias@ (e.g. jane.doe). Set in Doppler as TF_VAR_TEST_EMAIL_USER."
}

variable "TEST_EMAIL_DOMAIN" {
  type        = string
  description = "Email domain for all test users (e.g. gmail.com). Set in Doppler as TF_VAR_TEST_EMAIL_DOMAIN."
}
