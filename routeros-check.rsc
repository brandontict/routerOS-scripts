# Universal RouterOS Security Analysis Script
# Simplified version that works on ANY RouterOS setup
# No complex logic - just basic commands that always work

:put "==================================================================================="
:put "                    UNIVERSAL ROUTEROS SECURITY ANALYSIS"
:put "==================================================================================="
:put ""

:put ("Report Generated: " . [/system clock get date] . " " . [/system clock get time])
:put ("RouterOS Version: " . [/system resource get version])
:put ""

# ===============================================================================
# SYSTEM INFORMATION
# ===============================================================================
:put "=== SYSTEM INFORMATION ==="
:put ("Board: " . [/system resource get board-name])
:put ("CPU Load: " . [/system resource get cpu-load] . "%")
:put ("Uptime: " . [/system resource get uptime])
:put ""

# ===============================================================================
# FIREWALL RULES COUNT
# ===============================================================================
:put "=== FIREWALL CONFIGURATION ==="
:local filterCount [/ip firewall filter print count-only]
:local natCount [/ip firewall nat print count-only]
:put ("Filter Rules: " . $filterCount)
:put ("NAT Rules: " . $natCount)
:put ""

# ===============================================================================
# LOG ANALYSIS - SIMPLE APPROACH
# ===============================================================================
:put "=== LOG ANALYSIS ==="

:local dropCount [/log print count-only where message~"DROP"]
:local denyCount [/log print count-only where message~"drop"]
:local totalBlocked ($dropCount + $denyCount)

:put ("Uppercase DROP messages: " . $dropCount)
:put ("Lowercase drop messages: " . $denyCount) 
:put ("Total blocked attempts: " . $totalBlocked)

:if ($totalBlocked > 0) do={
    :put ""
    :put "=== RECENT BLOCKED ATTEMPTS ==="
    :put "Showing recent DROP messages:"
    /log print where message~"DROP" last 10
    :put ""
    :put "Showing recent drop messages:"
    /log print where message~"drop" last 10
} else={
    :put "No blocked packets found in current logs"
}
:put ""

# ===============================================================================
# CURRENT FIREWALL RULES
# ===============================================================================
:put "=== CURRENT FIREWALL FILTER RULES ==="
/ip firewall filter print
:put ""

# ===============================================================================
# ACTIVE NAT RULES
# ===============================================================================
:put "=== ACTIVE NAT RULES ==="
/ip firewall nat print where disabled=no
:put ""

# ===============================================================================
# ENABLED SERVICES
# ===============================================================================
:put "=== ENABLED SERVICES ==="
/ip service print where disabled=no
:put ""

# ===============================================================================
# BASIC SECURITY CHECKS
# ===============================================================================
:put "=== BASIC SECURITY ANALYSIS ==="

# Count enabled services
:local enabledServices [/ip service print count-only where disabled=no]
:put ("Total Enabled Services: " . $enabledServices)

# Check for risky services
:local telnetFound [/ip service find where name="telnet" and disabled=no]
:local ftpFound [/ip service find where name="ftp" and disabled=no]
:local sshFound [/ip service find where name="ssh" and disabled=no]

:if ([:len $telnetFound] > 0) do={
    :put "WARNING: Telnet is enabled (insecure!)"
}

:if ([:len $ftpFound] > 0) do={
    :put "WARNING: FTP is enabled (insecure!)"
}

:if ([:len $sshFound] > 0) do={
    :put "INFO: SSH is enabled"
}

# Check firewall protection
:local inputDropRules [/ip firewall filter find where chain="input" and action="drop"]
:local forwardDropRules [/ip firewall filter find where chain="forward" and action="drop"]

:put ("Input DROP rules: " . [:len $inputDropRules])
:put ("Forward DROP rules: " . [:len $forwardDropRules])

:if ([:len $inputDropRules] = 0) do={
    :put "WARNING: No input DROP rules found - router may be exposed!"
}

:if ([:len $forwardDropRules] = 0) do={
    :put "WARNING: No forward DROP rules found - network may be exposed!"
}

:put ""

# ===============================================================================
# RECOMMENDATIONS
# ===============================================================================
:put "=== SECURITY RECOMMENDATIONS ==="

:if ($totalBlocked > 20) do={
    :put "High attack volume detected - monitor logs regularly"
} else={
    :put "Attack volume appears normal"
}

:put ""
:put "Basic security checklist:"
:put "1. Disable telnet service: /ip service disable telnet"
:put "2. Restrict web access to LAN only"
:put "3. Enable firewall logging on drop rules"
:put "4. Keep RouterOS updated"
:put "5. Use strong passwords"
:put ""

# ===============================================================================
# USEFUL COMMANDS
# ===============================================================================
:put "=== USEFUL COMMANDS ==="
:put "/log print where message~\"DROP\" - View blocked attempts"
:put "/ip firewall filter print - View firewall rules"
:put "/ip service print - View all services"
:put "/system package update check-for-updates - Check for updates"
:put "/export file=backup - Export configuration"
:put ""

:put "==================================================================================="
:put "                         ANALYSIS COMPLETE - WORKS EVERYWHERE!"
:put "==================================================================================="
