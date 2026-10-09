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
