terraform {
  required_version = ">= 1.15"
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 7.0"
    }
  }
}

# Credentials come from Doppler as OKTA_* env vars (run via `doppler run --`):
# OKTA_ORG_NAME, OKTA_BASE_URL, OKTA_API_CLIENT_ID, OKTA_API_PRIVATE_KEY_ID,
# OKTA_API_PRIVATE_KEY, OKTA_API_SCOPES. Nothing secret lives in this folder.
provider "okta" {}
