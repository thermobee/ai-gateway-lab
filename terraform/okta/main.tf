# Gateway model access tiers
# Okta group         -> models allowed
# gateway-user-tier1 -> claude-haiku-5-5, claude-sonnet-5-5
# gateway-user-tier2 -> everything in tier1, plus claude-opus-5-5
# gateway-user-tier3 -> everything in tier2, plus claude-fable-5-1
#
# Rules
# - Tiers stack: each tier includes all lower tiers.
# - A user in several tier groups gets the highest tier.
# - A user in no tier group is denied.
# - Older model versions: not allowed
# - New models are added by Admin, after confirmation with management and cost checks.
resource "okta_group" "gateway_user_tier1" {
  name        = "gateway-user-tier1"
  description = "Base Tier models available, Haiku, Sonnet"
}

resource "okta_group" "gateway_user_tier2" {
  name        = "gateway-user-tier2"
  description = "Mid Tier models available, Opus plus the T1 models."
}

resource "okta_group" "gateway_user_tier3" {
  name        = "gateway-user-tier3"
  description = "High Tier models available, Fable plus T1 and T2 models"
}

# Test users for the different groups and a negative test
resource "okta_user" "tier1_user" {
  first_name = "John"
  last_name  = "Smith"
  login      = "${var.TEST_EMAIL_USER}+tier1@${var.TEST_EMAIL_DOMAIN}"
  email      = "${var.TEST_EMAIL_USER}+tier1@${var.TEST_EMAIL_DOMAIN}"
}

resource "okta_user" "tier2_user" {
  first_name = "James"
  last_name  = "Smith"
  login      = "${var.TEST_EMAIL_USER}+tier2@${var.TEST_EMAIL_DOMAIN}"
  email      = "${var.TEST_EMAIL_USER}+tier2@${var.TEST_EMAIL_DOMAIN}"
}

resource "okta_user" "tier3_user" {
  first_name = "Jimmy"
  last_name  = "Smith"
  login      = "${var.TEST_EMAIL_USER}+tier3@${var.TEST_EMAIL_DOMAIN}"
  email      = "${var.TEST_EMAIL_USER}+tier3@${var.TEST_EMAIL_DOMAIN}"
}

resource "okta_user" "unassigned_user" {
  first_name = "Jobe"
  last_name  = "Smith"
  login      = "${var.TEST_EMAIL_USER}+unassigned@${var.TEST_EMAIL_DOMAIN}"
  email      = "${var.TEST_EMAIL_USER}+unassigned@${var.TEST_EMAIL_DOMAIN}"
}

# Assign the users in the correct groups
resource "okta_group_memberships" "tier1_members" {
  group_id = okta_group.gateway_user_tier1.id
  users = [
    okta_user.tier1_user.id
  ]
  track_all_users = true
}

resource "okta_group_memberships" "tier2_members" {
  group_id = okta_group.gateway_user_tier2.id
  users = [
    okta_user.tier2_user.id
  ]
  track_all_users = true
}

resource "okta_group_memberships" "tier3_members" {
  group_id = okta_group.gateway_user_tier3.id
  users = [
    okta_user.tier3_user.id
  ]
  track_all_users = true
}

# Assign the OIDC app to the 3 tier groups
resource "okta_app_group_assignments" "gateway_group_assignments" {
  app_id = okta_app_oauth.gateway_ai.id
  group {
    id = okta_group.gateway_user_tier1.id
  }
  group {
    id = okta_group.gateway_user_tier2.id
  }
  group {
    id = okta_group.gateway_user_tier3.id
  }
}

# OIDC gateway application 
resource "okta_app_oauth" "gateway_ai" {
  label                      = "gateway-ai"
  type                       = "web"
  response_types             = ["code"]
  grant_types                = ["authorization_code"]
  token_endpoint_auth_method = "private_key_jwt"
  redirect_uris              = ["http://localhost:8000/auth/callback"]
  pkce_required              = true
  post_logout_redirect_uris  = ["http://localhost:8000"]
  consent_method             = "TRUSTED"
  omit_secret                = true
  authentication_policy      = okta_app_signon_policy.gateway_ai_signon_policy.id
  jwks {
    kid = "gateway-2026-10"
    kty = "RSA"
    e   = "AQAB"
    n   = "1_TQqXvfv4Y84XGhPuzOZeFaRAMgRBhoAX0DtQK-uETgaFf8S_Ys0NkUvgCzYoHWZQUhSWxiG93HLK5aeq2x86clEB6dXyX4BGcVMqjl7BE4Ows-VnQmnGkgmq0XWCHyNsweFFZlEdcWPwVlBqcQJW-qZ1tnLsTIs-pUW4Yl-bHgnZbrXYCjd3p_cGV1igMn90LTcKWcqAGDQUuQAV3tIyCW2v3nUvEJr5qONAjk_a_PRUMvNJEgFXuMXg8Ziee3i1combEuz8ZFZVYvRmpkrzv5id8S81XFm_jTnPFTuH7QbWJS71Oz4k4FO3_qnWRIqlr5lDYU99Ou98oetNSFdw"
  }
}

# Sign on policy for gateway-ai app
# LAB ONLY: password, single factor.
# Production: factor_mode = "2FA" with phishing-resistant constraints
# (Okta FastPass / FIDO2 WebAuthn) plus a device assurance policy.
resource "okta_app_signon_policy" "gateway_ai_signon_policy" {
  name        = "Gateway-AI SignOn Policy"
  description = "This policy will be used for the Gateway AI app only. Testing in Lab environment."
}
resource "okta_app_signon_policy_rule" "gateway_ai_signon_policy_rule" {
  policy_id   = okta_app_signon_policy.gateway_ai_signon_policy.id
  name        = "Gateway-AI SignOn Policy rule"
  factor_mode = "1FA"
  priority    = 1
  access      = "ALLOW"
  constraints = [
    jsonencode({
      "knowledge" : {
        "types" : ["password"]
      },
    })
  ]
}

# Data source for the default authorization server. Used in the groups claim
data "okta_auth_server" "default" {
  name = "default"
}

# Default authorization groups claim
resource "okta_auth_server_claim" "groups" {
  auth_server_id          = data.okta_auth_server.default.id
  name                    = "groups"
  value                   = "gateway-"
  group_filter_type       = "STARTS_WITH"
  claim_type              = "IDENTITY"
  always_include_in_token = true
  value_type              = "GROUPS"
}


