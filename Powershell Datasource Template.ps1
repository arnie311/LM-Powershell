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
$collectorName = hostname

# Insert additional variables here


$scriptBlock = {

    # Insert Active Discovery script block here

}
#------------------------------------------------------------------------------------------------------------

function Invoke-Discovery {
    param (
        [Parameter(position = 0, Mandatory = $true)]
        [ScriptBlock]$scriptblock,
        [Parameter(position = 1, Mandatory = $true)]
        $wmi_user,
        [Parameter(position = 2, Mandatory = $true)]
        $wmi_pass,
        [Parameter(position = 3, Mandatory = $true)]
        $hostname,
        [Parameter(position = 4, Mandatory = $true)]
        $collectorName
    )
    try {
        #-----Determin the type of query to make-----
        # check to see if this is monitoring the collector
        if ($hostname -like $collectorName) {
            $response = Invoke-Command -ScriptBlock $scriptBlock
        }
        # are wmi user/pass set -- e.g. are these device props either not substiuted or blank
        elseif (([string]::IsNullOrWhiteSpace($wmi_user) -or $wmi_user -like "WMI" -or !$wmi_user) -and `
            ([string]::IsNullOrWhiteSpace($wmi_pass)) -or $wmi_pass -like "WMI" -or !$wmi_pass) {
            # no
            $response = Invoke-Command -ComputerName $hostname -ScriptBlock $scriptBlock
        }
        else {
            # yes. convert user/password into a credential string
            $remote_pass = ConvertTo-SecureString -String $wmi_pass -AsPlainText -Force;
            $remote_credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $wmi_user, $remote_pass;
            $response = Invoke-Command -ComputerName $hostname -Credential $remote_credential -ScriptBlock $scriptBlock
        }
    }
    catch {
        # exit code of non 0 will mean the script failed and not overwrite the instances that have already been found
        throw $Error[0].Exception
        exit 1
    }
    return $response
}

Invoke-Discovery $scriptBlock $wmi_user $wmi_pass $hostname $collectorName
exit 0




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
$collectorName = hostname
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
        [Parameter(position = 1, Mandatory = $true)]
        $wmi_user,
        [Parameter(position = 2, Mandatory = $true)]
        $wmi_pass,
        [Parameter(position = 3, Mandatory = $true)]
        $hostname,
        [Parameter(position = 4, Mandatory = $true)]
        $collectorName
    )
    try {
        #-----Determin the type of query to make-----
        # check to see if this is monitoring the collector
        if ($hostname -like $collectorName) {
            $response = Invoke-Command -ScriptBlock $scriptBlock
        }
        # are wmi user/pass set -- e.g. are these device props either not substiuted or blank
        elseif (([string]::IsNullOrWhiteSpace($wmi_user) -or $wmi_user -like "WMI" -or !$wmi_user) -and `
            ([string]::IsNullOrWhiteSpace($wmi_pass)) -or $wmi_pass -like "WMI" -or !$wmi_pass) {
            # no
            $response = Invoke-Command -ComputerName $hostname -ScriptBlock $scriptBlock
        }
        else {
            # yes. convert user/password into a credential string
            $remote_pass = ConvertTo-SecureString -String $wmi_pass -AsPlainText -Force;
            $remote_credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $wmi_user, $remote_pass;
            $response = Invoke-Command -ComputerName $hostname -Credential $remote_credential -ScriptBlock $scriptBlock
        }
    }
    catch {
        # exit code of non 0 will mean the script failed and not overwrite the instances that have already been found
        throw $Error[0].Exception
        exit 1
    }
    return $response
}

Invoke-DataCollection $scriptBlock $wmi_user $wmi_pass $hostname $collectorName
exit 0

