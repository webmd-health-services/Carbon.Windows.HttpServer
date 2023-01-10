
function Remove-CHttpsCertificateBinding
{
    <#
    .SYNOPSIS
    Removes an HTTPS certificate binding.

    .DESCRIPTION
    Uses the netsh command line application to remove an HTTPS certificate binding for an IP/port combination.  If the binding doesn't exist, nothing is changed.

    .EXAMPLE
    > Remove-CHttpsCertificateBinding -IPAddress '45.72.89.57' -Port 443

    Removes the HTTPS certificate bound to IP 45.72.89.57 on port 443.

    .EXAMPLE
    > Remove-CHttpsCertificateBinding

    Removes the default HTTPS certificate from port 443.  The default certificate is bound to all IP addresses.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The IP address whose binding to remove.  Default is all IP addresses.
        [ipaddress] $IPAddress = '0.0.0.0',

        # The port of the binding to remove.  Default is port 443.
        [UInt16] $Port = 443
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if( -not (Test-CHttpsCertificateBinding -IPAddress $IPAddress -Port $Port) )
    {
        return
    }

    if( $IPAddress.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetworkV6 )
    {
        $ipPort = '[{0}]:{1}' -f $IPAddress,$Port
    }
    else
    {
        $ipPort = '{0}:{1}' -f $IPAddress,$Port
    }

    Invoke-Netsh http delete sslcert ipPort=$ipPort `
                 -Target $ipPort `
                 -Action "removing HTTPS certificate binding"
}

