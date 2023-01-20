
function Set-CHttpsCertificateBinding
{
    <#
    .SYNOPSIS
    Creates or updates an HTTPS certificate binding.

    .DESCRIPTION
    The `Set-CHttpsCertificateBinding` creates an HTTPS certificate binding. Pass the IP address of the binding to the
    `IPAddress` parameter. Pass the port number of the binding to the `Port` parameter. Pass the certificate thumbprint
    for the binding to the `Thumbprint` parameter. Pass the application ID of the binding to the `ApplicationID`
    parameter. Only one binding is allowed per IP address and port. If a binding exists on the given IP address and
    port that doesn't match the given application ID and certificate, the existing binding is removed, and a new
    binding is created.

    If you want an object representing the binding to be returned, use the `PassThru` switch.

    Uses the `netsh http add sslcert` command.

    .OUTPUTS
    Carbon.Windows.HttpServer.HttpsCertificateBinding.

    .EXAMPLE
    Set-CHttpsCertificateBinding -IPAddress 43.27.89.54 -Port 443 -ApplicationID 88d1f8da-aeb5-40a2-a5e5-0e6107825df7 -Thumbprint 4789073458907345907434789073458907345907

    Configures the computer to use the 478907345890734590743 certificate on IP 43.27.89.54, port 443.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessage('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([Carbon.Windows.HttpServer.HttpsCertificateBinding])]
    param(
        # The IP address for the binding.
        [Parameter(Mandatory)]
        [ipaddress] $IPAddress,

        # The port for the binding.
        [Parameter(Mandatory)]
        [UInt16] $Port,

        # The thumbprint of the certificate to use.  The certificate must be installed.
        [Parameter(Mandatory)]
        [ValidatePattern("^[0-9a-f]{40}$")]
        [String] $Thumbprint,

        # A unique ID representing the application using the binding.  Create your own.
        [Parameter(Mandatory)]
        [Guid] $ApplicationID,

        # The name of the store where the certificate can be found. Defaults to `My`. Certificates must be stored in
        # the LocalMachine location/context.
        [String] $StoreName = 'My',

        # Return a `Carbon.Windows.HttpServer.HttpsCertificateBinding` for the configured binding.
        [switch] $PassThru
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    # Only one binding can exist on an IP address and port.
    $bindingExists = Test-CHttpsCertificateBinding -IPAddress $IPAddress -Port $Port
    if ($bindingExists)
    {
        # If the existing binding is for the same application using the same thumbprint, we don't need to do anything.
        $bindingExists = Test-CHttpsCertificateBinding -IPAddress $IPAddress `
                                                     -Port $Port `
                                                     -Thumbprint $Thumbprint `
                                                     -ApplicationID $ApplicationID
        if ($bindingExists)
        {
            return
        }

        Remove-CHttpsCertificateBinding -IPAddress $IPAddress -Port $Port
    }

    if( $IPAddress.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetworkV6 )
    {
        $ipPort = '[{0}]:{1}' -f $IPAddress,$Port
    }
    else
    {
        $ipPort = '{0}:{1}' -f $IPAddress,$Port
    }

    $appID = $ApplicationID.ToString('B')

    Invoke-Netsh http add sslcert ipport=$ipPort certhash=$Thumbprint appid=$appID certstore=$StoreName `
                 -Target $ipPort `
                 -Action 'creating HTTPS certificate binding'

    if( $PassThru )
    {
        $errorActionArg = @{}
        if ($WhatIfPreference)
        {
            $errorActionArg['ErrorAction'] = 'Ignore'
        }
        Get-CHttpsCertificateBinding -IPAddress $IPAddress -Port $Port @errorActionArg
    }
}

