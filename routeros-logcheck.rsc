# RouterOS Firewall Drops Analysis Script
# Shows all the digital miscreants trying to break into your network
# Save as: firewall-drops.rsc

:put "==================================================================================="
:put "                         FIREWALL DROPS ANALYSIS REPORT"
:put "==================================================================================="
:put ""

# Get current date/time for report header
:put ("Report Generated: " . [/system clock get date] . " " . [/system clock get time])
:put ""

# ===============================================================================
# SUMMARY STATISTICS
# ===============================================================================
:put "=== SUMMARY STATISTICS ==="

:local totalDrops [/log print count-only where message~"DROP"]
:local inputDrops [/log print count-only where message~"INPUT-DROP"]
:local forwardDrops [/log print count-only where message~"FORWARD-DROP"]

:put ("Total Dropped Packets (all time): " . $totalDrops)
:put ("Input Chain Drops: " . $inputDrops)
:put ("Forward Chain Drops: " . $forwardDrops)
:put ""

# ===============================================================================
# RECENT DROPS (Last 50 entries)
# ===============================================================================
:put "=== RECENT FIREWALL DROPS (Last 50 entries) ==="
:if ($totalDrops > 0) do={
    /log print where message~"DROP" last 50
} else={
    :put "No dropped packets found in logs"
}
:put ""

# ===============================================================================
# INPUT CHAIN DROPS (Attempts to access router directly)
# ===============================================================================
:put "=== INPUT CHAIN DROPS (Direct router access attempts) ==="
:if ($inputDrops > 0) do={
    :put "These are attempts to access your router services directly:"
    /log print where message~"INPUT-DROP"
} else={
    :put "No direct router access attempts logged"
}
:put ""

# ===============================================================================
# FORWARD CHAIN DROPS (Attempts to access internal network)
# ===============================================================================
:put "=== FORWARD CHAIN DROPS (Internal network access attempts) ==="
:if ($forwardDrops > 0) do={
    :put "These are attempts to access your internal network devices:"
    /log print where message~"FORWARD-DROP"
} else={
    :put "No internal network access attempts logged"
}
:put ""

# ===============================================================================
# LAST 10 DROPS (Most Recent Activity)
# ===============================================================================
:put "=== LAST 10 DROPPED PACKETS (Most Recent) ==="
:if ($totalDrops > 0) do={
    /log print where message~"DROP" last 10
} else={
    :put "No dropped packets found in logs"
}
:put ""

# ===============================================================================
# SECURITY ANALYSIS
# ===============================================================================
:put "=== SECURITY ANALYSIS ==="

:if ($totalDrops > 50) do={
    :put ("WARNING: High volume of attacks detected (" . $totalDrops . " total)")
    :put "Consider implementing additional security measures"
} else={
    :if ($totalDrops > 10) do={
        :put ("MODERATE: Normal scanning activity detected (" . $totalDrops . " total)")
        :put "This is typical internet background noise"
    } else={
        :put ("GOOD: Low attack volume (" . $totalDrops . " total)")
        :put "Your network appears quiet and secure"
    }
}

:if ($inputDrops > 0) do={
    :put ""
    :put "NOTE: Input drops indicate attempts to access router services"
    :put "Make sure only necessary services are enabled"
}

:if ($forwardDrops > 0) do={
    :put ""
    :put "NOTE: Forward drops indicate scanning of internal network"
    :put "Your firewall is successfully blocking these attempts"
}
:put ""

# ===============================================================================
# QUICK ANALYSIS COMMANDS
# ===============================================================================
:put "=== MANUAL ANALYSIS COMMANDS ==="
:put "Show all drops: /log print where message~\"DROP\""
:put "Show only INPUT drops: /log print where message~\"INPUT-DROP\""
:put "Show only FORWARD drops: /log print where message~\"FORWARD-DROP\""
:put "Monitor live: /log print follow where message~\"DROP\""
:put "Show recent activity: /log print where message~\"DROP\" last 20"
:put ""

# ===============================================================================
# SECURITY RECOMMENDATIONS
# ===============================================================================
:put "=== SECURITY RECOMMENDATIONS ==="

# Check if unnecessary services are still enabled
:local ftpEnabled [/ip service get ftp disabled]
:local telnetEnabled [/ip service get telnet disabled]
:local sshEnabled [/ip service get ssh disabled]

:if ($ftpEnabled = "false") do={
    :put "WARNING: FTP service is enabled - consider disabling (insecure)"
}

:if ($telnetEnabled = "false") do={
    :put "WARNING: Telnet service is enabled - consider disabling (insecure)"
}

:if ($sshEnabled = "false") do={
    :put "INFO: SSH service is enabled - ensure it is properly secured"
}

:put ""
:put "If you see repeated attacks from the same IPs, consider:"
:put "1. Adding rate limiting rules"
:put "2. Creating IP blacklists for persistent attackers"
:put "3. Reviewing which services need to be exposed"
:put ""

:put "==================================================================================="
:put "                              ANALYSIS COMPLETE"
:put "==================================================================================="
