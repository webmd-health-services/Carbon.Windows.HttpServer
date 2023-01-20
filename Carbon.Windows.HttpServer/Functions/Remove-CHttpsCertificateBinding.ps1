
function Remove-CHttpsCertificateBinding
{
    <#
    .SYNOPSIS
    Removes HTTPS certificate bindings.

    .DESCRIPTION
    Uses the netsh command line application to remove HTTPS certificate bindings. Pass any combination of IP address,
    port, thumbprint, or application ID to the `IPAddress`, `Port`, `Thumbprint`, and `ApplicationID` parmeters,
    respectively. All bindings that match all of the parameters you pass will be deleted. You must pass at least one.

    .EXAMPLE
    > Remove-CHttpsCertificateBinding -IPAddress '45.72.89.57'

    Demonstrates how to remove all HTTPS certificate bindings on a specific IP address. In this example, all bindings
    to IP address `45.72.89.57` will be removed.

    .EXAMPLE
    > Remove-CHttpsCertificateBinding -Port 443

    Demonstrates how to remove all HTTPS certificate bindings on a specific port. In this example, all bindings to port
    `44444` will be removed.

    .EXAMPLE
    Remove-CHttpsCertificateBinding -Thumbprint '7d5ce4a8a5ec059b829ed135e9ad8607977691cc'

    Demonstrates how to remove all HTTPS certificate bindings using a specific certificate by passing its thumbprint to
    the `Thumbprint` parameter.. In this example, all bindings to certificate with thumbprint
    `7d5ce4a8a5ec059b829ed135e9ad8607977691cc` are deleted.

    .EXAMPLE
    Remove-CHttpsCertificateBinding -ApplicationID 'd27985ca-2fa5-4794-9a87-76de4ed7d3e8'

    Demonstrates how to remove all HTTPS certificate bindings for a specific application by passing the application ID
    to the `ApplicationID` parameter. In this example, all bindings for application
    `d27985ca-2fa5-4794-9a87-76de4ed7d3e8` will be removed.

    .EXAMPLE
    Get-CHttpsCertificateBinding -ApplicationID 'd27985ca-2fa5-4794-9a87-76de4ed7d3e8' | Remove-CHttpsCertificateBinding

    Demonstrates that you can pipe the output of `Get-CHttpsCertificateBinding` to `Remove-CHttpsCertificateBinding` to
    remove bindings.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessage('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The IP address whose bindings to remove.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ipaddress] $IPAddress,

        # The port of the bindings to remove.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [UInt16] $Port,

        # The thumbprint whose bindings to remove.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('CertificateHash')]
        [String] $Thumbprint,

        # The application whose bindings to remove.
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Guid] $ApplicationID,

        # If calling `Remove-CHttpsCertificateBinding` with no arguments, the function prompts for confirmation to delete
        # all bindings. Use this switch to skip the confirmation prompt.
        [switch] $Force
    )

    process
    {
        Set-StrictMode -Version 'Latest'
        Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

        if (-not $Force -and (-not $IPAddress -and -not $Port -and -not $Thumbprint -and -not $ApplicationID))
        {
            $query = 'Delete all HTTPS certificate bindings on this computer?'
            $caption = 'If you choose Yes, *all* HTTPS certificates will be deleted on this computer. This will ' +
                       'break any HTTPS applications. If you choose No, no changes will be made. To delete all ' +
                       'bindings without being prompted to confirm, use the Force (switch).'
            if (-not $PSCmdlet.ShouldContinue($query, $caption))
            {
                return
            }
        }

        $getArgs = @{}
        if ($IPAddress)
        {
            $getArgs['IPAddress'] = $IPAddress
        }

        if ($Port)
        {
            $getArgs['Port'] = $Port
        }

        if ($Thumbprint)
        {
            $getArgs['Thumbprint'] = $Thumbprint
        }

        if ($ApplicationID)
        {
            $getArgs['ApplicationID'] = $ApplicationID
        }

        $foundOne = $false
        foreach ($binding in (Get-CHttpsCertificateBinding @getArgs -ErrorAction Ignore))
        {
            $foundOne = $true
            if( $binding.IPAddress.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetworkV6 )
            {
                $ipPort = '[{0}]:{1}' -f $binding.IPAddress,$binding.Port
            }
            else
            {
                $ipPort = '{0}:{1}' -f $binding.IPAddress,$binding.Port
            }

            $target = "$($ipPort) that uses certificate $($binding.CertificateHash) for application " +
                    "$($binding.ApplicationID.ToString('B'))."
            Invoke-Netsh http delete sslcert "ipPort=$($ipPort)" `
                         -Comment "certhash=$($binding.CertificateHash) appid=$($binding.ApplicationID.ToSTring('B'))" `
                         -Target $target `
                         -Action "removing HTTPS certificate binding"
        }

        if ($foundOne)
        {
            return
        }

        $ipMsg = '0.0.0.0'
        if ($IPAddress)
        {
            $ipMsg = "$($IPAddress.IPAddressToString)"
            if ($IPAddress.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetworkV6)
            {
                $ipMsg = "[$($ipMsg)]"
            }
        }

        $portMsg = '*'
        if ($Port)
        {
            $portMsg = $Port
        }
        $ipMsg = "$($ipMsg):$($portMsg)"

        $thumbprintMsg = ''
        if ($Thumbprint)
        {
            $thumbprintMsg = " that uses certificate with thumbprint $($Thumbprint)"
        }

        $appIdMsg = ''
        if ($ApplicationID)
        {
            $appIdMsg = " for application $($ApplicationID.ToString('B'))"
        }

        "Unable to delete HTTPS certificate binding $($ipMsg)$($thumbprintMsg)$($appIdMsg) because it does not exist." |
            Write-Error -ErrorAction $ErrorActionPreference
    }
}

