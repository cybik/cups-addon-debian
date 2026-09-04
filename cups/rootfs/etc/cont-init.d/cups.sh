#!/usr/bin/env bashio
# shellcheck shell=bash
set -e

# ─────────────────────────────────────────────────────────────
# Write a fresh cupsd.conf (hass static config)
# ─────────────────────────────────────────────────────────────

ROOT_URL="$(bashio::addon.hass_instance_rooturl)"
ROOT_INTERFACE="$(bashio::addon.ip_address)"

export ALLOW_BLOCK_BASE="  Allow localhost\n  Allow 10.0.0.0/8\n  Allow 172.16.0.0/12\n  Allow 192.168.0.0/16"
export ALLOW_BLOCK_GENERAL="${ALLOW_BLOCK_BASE}"
export ALLOW_BLOCK_LIMITED="${ALLOW_BLOCK_BASE}"

if [ -n "${ROOT_URL}" ]; then
#export ALLOW_BLOCK_LIMITED="${ALLOW_BLOCK_LIMITED}\n  Allow ${ROOT_URL}"
export ALLOW_BLOCK_GENERAL="${ALLOW_BLOCK_GENERAL}\n  Allow ${ROOT_URL}"
fi

if [ -n "${ROOT_INTERFACE}" ]; then
export ALLOW_BLOCK_LIMITED="${ALLOW_BLOCK_LIMITED}\n  Allow ${ROOT_INTERFACE}"
export ALLOW_BLOCK_GENERAL="${ALLOW_BLOCK_GENERAL}\n  Allow ${ROOT_INTERFACE}"
fi

TARGET_FILE="/etc/cups/cupsd.conf"

cat > "${TARGET_FILE}.in" << 'EOL'
# Listen on all interfaces
Listen 0.0.0.0:631

# Allow access from local network
<Location />
  Order allow,deny
  %%ALLOW_BLOCK_GENERAL%%
</Location>

# Admin access (no authentication)
<Location /admin>
  Order allow,deny
  %%ALLOW_BLOCK_LIMITED%%
</Location>

# Job management permissions
<Location /jobs>
  Order allow,deny
  %%ALLOW_BLOCK_LIMITED%%
</Location>

<Policy default>
  # Job/subscription privacy...
  JobPrivateAccess default
  JobPrivateValues default
  SubscriptionPrivateAccess default
  SubscriptionPrivateValues default
  <Limit Send-Document Send-URI Hold-Job Release-Job Restart-Job Purge-Jobs Set-Job-Attributes Create-Job-Subscription Renew-Subscription Cancel-Subscription Get-Notifications Reprocess-Job Cancel-Current-Job Suspend-Current-Job Resume-Job Cancel-My-Jobs Close-Job CUPS-Move-Job CUPS-Get-Document Cancel-Jobs Validate-Job>
    Order allow,deny
    %%ALLOW_BLOCK_LIMITED%%
  </Limit>
</Policy>

# Enable web interface
WebInterface Yes

# Default settings
DefaultAuthType None
PreserveJobHistory No
EOL

sed "s|%%ALLOW_BLOCK_LIMITED%%|${ALLOW_BLOCK_LIMITED}|g" "${TARGET_FILE}.in" | \
  sed "s|%%ALLOW_BLOCK_GENERAL%%|${ALLOW_BLOCK_GENERAL}|g" \
> "${TARGET_FILE}"

# Start CUPS service
/usr/sbin/cupsd -f
