# RouterOS System Status & Security Check Script - FIXED VERSION
# Copy/paste this entire script into RouterOS terminal or save as a script
# Usage: Just run it to get a comprehensive system overview

# ===============================================================================
# SYSTEM OVERVIEW
# ===============================================================================

:put "==================================================================================="
:put "                    ROUTEROS SYSTEM STATUS & SECURITY REPORT"
:put "==================================================================================="
:put ""

# Get current date/time for report header
:put ("Report Generated: " . [/system clock get date] . " " . [/system clock get time])
:put ""

# ===============================================================================
# SYSTEM INFORMATION
# ===============================================================================
:put "=== SYSTEM INFORMATION ==="
:put ("RouterOS Version: " . [/system resource get version])
:put ("Board Name: " . [/system resource get board-name])
:put ("Architecture: " . [/system resource get architecture-name])
:put ("Uptime: " . [/system resource get uptime])
:put ""

# ===============================================================================
# RESOURCE USAGE
# ===============================================================================
:put "=== RESOURCE USAGE ==="
:local cpuLoad [/system resource get cpu-load]
:local freeMemory [/system resource get free-memory]
:local totalMemory [/system resource get total-memory]
:local usedMemory ($totalMemory - $freeMemory)
:local memoryPercent (($usedMemory * 100) / $totalMemory)

:put ("CPU Load: " . $cpuLoad . "%")
:put ("Memory Used: " . $usedMemory . " / " . $totalMemory . " (" . $memoryPercent . "%)")
:put ("Free HDD Space: " . [/system resource get free-hdd-space])
:put ""

# ===============================================================================
# SOFTWARE UPDATE CHECK
# ===============================================================================
:put "=== SOFTWARE UPDATE STATUS ==="
/system package update check-for-updates
:delay 3
:local channel [/system package update get channel]
:local installedVersion [/system package update get installed-version]
:local latestVersion [/system package update get latest-version]

:put ("Update Channel: " . $channel)
:put ("Installed Version: " . $installedVersion)
:put ("Latest Version: " . $latestVersion)

:if ($installedVersion != $latestVersion) do={
    :put "*** UPDATE AVAILABLE! ***"
} else={
    :put "System is up to date"
}
:put ""

# ===============================================================================
# INTERFACE STATUS
# ===============================================================================
:put "=== INTERFACE STATUS ==="
:foreach i in=[/interface find] do={
    :local ifName [/interface get $i name]
    :local ifStatus [/interface get $i running]
    :local ifType [/interface get $i type]

    :if ($ifStatus = "true") do={
        :put ($ifName . " (" . $ifType . "): UP")
    } else={
        :put ($ifName . " (" . $ifType . "): DOWN")
    }
}
:put ""

# ===============================================================================
# RECENT FIREWALL DROPS (Security Incidents)
# ===============================================================================
:put "=== RECENT FIREWALL DROPS (Last 20 entries) ==="
:put "Recent attempts blocked by firewall:"
/log print where message~"DROP"
:put ""

# ===============================================================================
# ACTIVE CONNECTIONS
# ===============================================================================
:put "=== ACTIVE CONNECTION SUMMARY ==="
:local totalConnections [/ip firewall connection print count-only]
:local tcpConnections [/ip firewall connection print count-only where protocol="tcp"]
:local udpConnections [/ip firewall connection print count-only where protocol="udp"]

:put ("Total Active Connections: " . $totalConnections)
:put ("TCP Connections: " . $tcpConnections)
:put ("UDP Connections: " . $udpConnections)
:put ""

# ===============================================================================
# DHCP LEASE STATUS
# ===============================================================================
:put "=== ACTIVE DHCP LEASES ==="
:local activeLeases [/ip dhcp-server lease print count-only where status="bound"]
:put ("Active DHCP Leases: " . $activeLeases)
:put ""
:put "Recently active devices:"
/ip dhcp-server lease print where status="bound"
:put ""

# ===============================================================================
# WIRELESS STATUS (if applicable)
# ===============================================================================
:if ([/interface wireless print count-only] > 0) do={
    :put "=== WIRELESS INTERFACE STATUS ==="
    :foreach w in=[/interface wireless find] do={
        :local wName [/interface wireless get $w name]
        :local wStatus [/interface wireless get $w running]

        :if ($wStatus = "true") do={
            :put ($wName . ": UP")
            :local clientCount [/interface wireless registration-table print count-only where interface=$wName]
            :put ("  Connected Clients: " . $clientCount)
        } else={
            :put ($wName . ": DOWN")
        }
    }
    :put ""
}

# ===============================================================================
# NAT RULES STATUS
# ===============================================================================
:put "=== NAT RULES STATUS ==="
:local enabledNatRules [/ip firewall nat print count-only where disabled="false"]
:local disabledNatRules [/ip firewall nat print count-only where disabled="true"]
:put ("Enabled NAT Rules: " . $enabledNatRules)
:put ("Disabled NAT Rules: " . $disabledNatRules)
:put ""

# ===============================================================================
# SECURITY RECOMMENDATIONS
# ===============================================================================
:put "=== SECURITY RECOMMENDATIONS ==="

# Check if SSH is enabled
:local sshEnabled [/ip service get ssh disabled]
:if ($sshEnabled = "false") do={
    :put "WARNING: SSH service is enabled - consider disabling if not needed"
} else={
    :put "GOOD: SSH service is disabled"
}

# Check if telnet is enabled
:local telnetEnabled [/ip service get telnet disabled]
:if ($telnetEnabled = "false") do={
    :put "WARNING: Telnet service is enabled - consider disabling (insecure)"
} else={
    :put "GOOD: Telnet service is disabled"
}

# Check web interface restriction
:local webAddress [/ip service get www address]
:if ([:len $webAddress] = 0) do={
    :put "WARNING: Web interface accessible from anywhere - consider restricting to LAN"
} else={
    :put ("GOOD: Web interface restricted to: " . $webAddress)
}

:put ""

# ===============================================================================
# QUICK COMMANDS REFERENCE
# ===============================================================================
:put "=== QUICK REFERENCE COMMANDS ==="
:put "View recent firewall drops: /log print where message~\"DROP\""
:put "Check system resources: /system resource print"
:put "View active connections: /ip firewall connection print"
:put "Check for updates: /system package update check-for-updates"
:put "View interface stats: /interface print stats"
:put "Monitor logs live: /log print follow"
:put ""

:put "==================================================================================="
:put "                              REPORT COMPLETE"
:put "==================================================================================="
