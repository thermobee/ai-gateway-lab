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
