#!/usr/bin/with-contenv bash

# ─────────────────────────────────────────────────────────────
# Write a fresh cupsd.conf (hass static config)
# ─────────────────────────────────────────────────────────────
cat > /etc/cups/cupsd.conf << 'EOL'
# Listen on all interfaces
Listen 0.0.0.0:631

# Allow access from local network
<Location />
  Order allow,deny
  Allow localhost
  Allow 10.0.0.0/8
  Allow 172.16.0.0/12
  Allow 192.168.0.0/16
</Location>

# Admin access (no authentication)
<Location /admin>
  Order allow,deny
  Allow localhost
  Allow 10.0.0.0/8
  Allow 172.16.0.0/12
  Allow 192.168.0.0/16
</Location>

# Job management permissions
<Location /jobs>
  Order allow,deny
  Allow localhost
  Allow 10.0.0.0/8
  Allow 172.16.0.0/12
  Allow 192.168.0.0/16
</Location>

<Policy default>
    # Job/subscription privacy...
    JobPrivateAccess default
    JobPrivateValues default
    SubscriptionPrivateAccess default
    SubscriptionPrivateValues default
    <Limit Send-Document Send-URI Hold-Job Release-Job Restart-Job Purge-Jobs Set-Job-Attributes Create-Job-Subscription Renew-Subscription Cancel-Subscription Get-Notifications Reprocess-Job Cancel-Current-Job Suspend-Current-Job Resume-Job Cancel-My-Jobs Close-Job CUPS-Move-Job CUPS-Get-Document Cancel-Jobs Validate-Job>
        Order allow,deny
        Allow localhost
        Allow 10.0.0.0/8
        Allow 172.16.0.0/12
        Allow 192.168.0.0/16
    </Limit>
</Policy>

# Enable web interface
WebInterface Yes

# Default settings
DefaultAuthType None
PreserveJobHistory No
EOL

# Start CUPS service
/usr/sbin/cupsd -f
