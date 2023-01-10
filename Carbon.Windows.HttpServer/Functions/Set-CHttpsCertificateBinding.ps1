
function Set-CHttpsCertificateBinding
{
    <#
    .SYNOPSIS
    Sets an HTTPS certificate binding for a given IP/port.

    .DESCRIPTION
    Uses the netsh command line application to set the certificate for an IP address and port.  If a binding already exists for the IP/port, it is removed, and the new binding is created.

    Beginning with Carbon 2.0, returns a `Carbon.Windows.HttpServer.HttpsCertificateBinding` object for the binding that was set.

    .OUTPUTS
    Carbon.Windows.HttpServer.HttpsCertificateBinding.

    .EXAMPLE
    Set-CHttpsCertificateBinding -IPAddress 43.27.89.54 -Port 443 -ApplicationID 88d1f8da-aeb5-40a2-a5e5-0e6107825df7 -Thumbprint 4789073458907345907434789073458907345907

    Configures the computer to use the 478907345890734590743 certificate on IP 43.27.89.54, port 443.

    .EXAMPLE
    Set-CHttpsCertificateBinding -ApplicationID 88d1f8da-aeb5-40a2-a5e5-0e6107825df7 -Thumbprint 4789073458907345907434789073458907345907

    Configures the compute to use the 478907345890734590743 certificate as the default certificate on all IP addresses, port 443.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([Carbon.Windows.HttpServer.HttpsCertificateBinding])]
    param(
        [ipaddress]
        # The IP address for the binding.  Defaults to all IP addresses.
        $IPAddress = '0.0.0.0',

        [UInt16]
        # The port for the binding.  Defaults to 443.
        $Port = 443,

        [Parameter(Mandatory)]
        [Guid]
        # A unique ID representing the application using the binding.  Create your own.
        $ApplicationID,

        [Parameter(Mandatory)]
        [ValidatePattern("^[0-9a-f]{40}$")]
        [String]
        # The thumbprint of the certificate to use.  The certificate must be installed.
        $Thumbprint,

        [switch]
        # Return a `Carbon.Windows.HttpServer.HttpsCertificateBinding` for the configured binding.
        $PassThru
    )

    Set-StrictMode -Version 'Latest'

    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if( $IPAddress.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetworkV6 )
    {
        $ipPort = '[{0}]:{1}' -f $IPAddress,$Port
    }
    else
    {
        $ipPort = '{0}:{1}' -f $IPAddress,$Port
    }

    Remove-CHttpsCertificateBinding -IPAddress $IPAddress -Port $Port

    $action = 'creating HTTPS certificate binding'
    if( $PSCmdlet.ShouldProcess( $IPPort, $action ) )
    {
        $appID = $ApplicationID.ToString('B')
        Invoke-Netsh http add sslcert ipport=$ipPort certhash=$Thumbprint appid=$appID `
                     -Target $ipPort `
                     -Action $action

        if( $PassThru )
        {
            Get-CHttpsCertificateBinding -IPAddress $IPAddress -Port $Port
        }
    }
}

