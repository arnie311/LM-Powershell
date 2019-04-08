#######################      Active Discovery      #########################
# Purpose:
# Author:
# © 2007-2019 - LogicMonitor, Inc.  All rights reserved.
#------------------------------------------------------------------------------------------------------------
# Prerequisites:
#
#
#Requires -Version 4
#------------------------------------------------------------------------------------------------------------
# Clears the CLI of any text
Clear-Host
# Clears memory of all previous variables
Remove-Variable * -ErrorAction SilentlyContinue
#------------------------------------------------------------------------------------------------------------
# Initialize Variables
$wmi_pass = "##WMI.PASS##"
$wmi_user = "##WMI.USER##"
$hostname = "##SYSTEM.SYSNAME##"
$collectorName = hostname.exe

# Insert additional variables here


$scriptBlock = {

    # Insert Active Discovery script block here

}
#------------------------------------------------------------------------------------------------------------

function Invoke-Discovery {
    param (
        [Parameter(position = 0, Mandatory = $true)]
        [ScriptBlock]$scriptblock,
        [Parameter(position = 0, Mandatory = $true)]
        $wmi_user,
        [Parameter(position = 0, Mandatory = $true)]
        $wmi_pass,
        [Parameter(position = 0, Mandatory = $true)]
        $hostname,
        [Parameter(position = 0, Mandatory = $true)]
        $collectorName
    )

    #-----Determin the type of query to make-----
    # check to see if this is monitoring the collector
    if ($hostname -eq $collectorName) {
        $response = Invoke-Command -ScriptBlock $scriptBlock
    }
    # are wmi user/pass set -- e.g. are these device props either not substiuted or blank
    elseif ([string]::IsNullOrWhiteSpace($wmi_user) -and [string]::IsNullOrWhiteSpace($wmi_pass)) {
        # no
        $response = Invoke-Command -ComputerName $hostname -ScriptBlock $scriptBlock
    }
    else {
        # yes. convert user/password into a credential string
        $remote_pass = ConvertTo-SecureString -String $wmi_pass -AsPlainText -Force;
        $remote_credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $wmi_user, $remote_pass;
        $response = Invoke-Command -ComputerName $hostname -Credential $remote_credential -ScriptBlock $scriptBlock
    }
    return $response
}

try {
    Invoke-Discovery -scriptblock $scriptBlock -wmi_user $wmi_user -wmi_pass $wmi_pass -hostname $hostname -collectorName $collectorName
    exit 0
}
catch {
    # exit code of non 0 will mean the script failed and not overwrite the instances that have already been found
    exit 1
}



#######################      Data Collection      #########################
# Purpose:
# Author:
# © 2007-2019 - LogicMonitor, Inc.  All rights reserved.
#------------------------------------------------------------------------------------------------------------
# Prerequisites:
#
#
#Requires -Version 4
#------------------------------------------------------------------------------------------------------------
# Clears the CLI of any text
Clear-Host
# Clears memory of all previous variables
Remove-Variable * -ErrorAction SilentlyContinue
#------------------------------------------------------------------------------------------------------------
# Initialize Variables
$wmi_pass = "##WMI.PASS##"
$wmi_user = "##WMI.USER##"
$hostname = "##SYSTEM.SYSNAME##"
$collectorName = hostname.exe
$wildValue = "##WILDVALUE##"

# Insert additional variables here


$scriptBlock = {

    # Insert Data Collection script block here

}
#------------------------------------------------------------------------------------------------------------

function Invoke-DataCollection {
    param (
        [Parameter(position = 0, Mandatory = $true)]
        [ScriptBlock]$scriptblock,
        [Parameter(position = 0, Mandatory = $true)]
        $wmi_user,
        [Parameter(position = 0, Mandatory = $true)]
        $wmi_pass,
        [Parameter(position = 0, Mandatory = $true)]
        $hostname,
        [Parameter(position = 0, Mandatory = $true)]
        $collectorName
    )

    #-----Determin the type of query to make-----
    # check to see if this is monitoring the collector
    if ($hostname -eq $collectorName) {
        $response = Invoke-Command -ScriptBlock $scriptBlock
    }
    # are wmi user/pass set -- e.g. are these device props either not substiuted or blank
    elseif ([string]::IsNullOrWhiteSpace($wmi_user) -and [string]::IsNullOrWhiteSpace($wmi_pass)) {
        # no
        $response = Invoke-Command -ComputerName $hostname -ScriptBlock $scriptBlock
    }
    else {
        # yes. convert user/password into a credential string
        $remote_pass = ConvertTo-SecureString -String $wmi_pass -AsPlainText -Force;
        $remote_credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $wmi_user, $remote_pass;
        $response = Invoke-Command -ComputerName $hostname -Credential $remote_credential -ScriptBlock $scriptBlock
    }
    return $response
}

try {
    Invoke-DataCollection -scriptblock $scriptBlock -wmi_user $wmi_user -wmi_pass $wmi_pass -hostname $hostname -collectorName $collectorName
    exit 0
}
catch {
    # exit code of non 0 will mean the script failed and all datapoints will show as NaN
    exit 1
}

