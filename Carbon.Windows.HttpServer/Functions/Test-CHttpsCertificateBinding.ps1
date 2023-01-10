
function Test-CHttpsCertificateBinding
{
    <#
    .SYNOPSIS
    Tests if an HTTPS certificate binding exists.

	.DESCRIPTION
	HTTPS certificates are bound to IP addresses and ports.  This function tests if one exists on a given IP address/port.

	.EXAMPLE
	Test-CHttpsCertificateBinding -Port 443

	Tests if there is a default HTTPS certificate bound to all a machine's IP addresses on port 443.

	.EXAMPLE
	Test-CHttpsCertificateBinding -IPAddress 10.0.1.1 -Port 443

	Tests if there is an HTTPS certificate bound to IP address 10.0.1.1 on port 443.

	.EXAMPLE
	Test-CHttpsCertificateBinding

	Tests if there are any HTTPS certificates bound to any IP address/port on the machine.
    #>
    [CmdletBinding()]
    param(
        [ipaddress]
        # The IP address to test for an HTTPS certificate.
        $IPAddress,

        [Uint16]
        # The port to test for an HTTPS certificate.
        $Port
    )

    Set-StrictMode -Version 'Latest'

    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $getArgs = @{ }
    if( $IPAddress )
    {
        $getArgs.IPAddress = $IPAddress
    }

    if( $Port )
    {
        $getArgs.Port = $Port
    }

    $binding = Get-CHttpsCertificateBinding @getArgs
    if( $binding )
    {
        return $True
    }
    else
    {
        return $False
    }
}

