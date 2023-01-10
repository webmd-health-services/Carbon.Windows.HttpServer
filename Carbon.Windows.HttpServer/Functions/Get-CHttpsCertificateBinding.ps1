
function Get-CHttpsCertificateBinding
{
    <#
    .SYNOPSIS
    Gets the HTTPS certificate bindings on this computer.

    .DESCRIPTION
    Windows binds HTTPS certificates to an IP addresses/port combination.  This function gets all the HTTPS bindings on this computer, or a binding for a specific IP/port, or $null if one doesn't exist.  The bindings are returned as `Carbon.Certificates.HttpsCertificateBinding` objects.

    .OUTPUTS
    Carbon.Certificates.HTTPSCertificateBinding.

    .EXAMPLE
    > Get-CHttpsCertificateBinding

    Gets all the HTTPS certificate bindings on the local computer.

    .EXAMPLE
    > Get-CHttpsCertificateBinding -IPAddress 42.37.80.47 -Port 443

    Gets the HTTPS certificate bound to 42.37.80.47, port 443.

    .EXAMPLE
    > Get-CHttpsCertificateBinding -Port 443

    Gets the default HTTPS certificate bound to ALL the computer's IP addresses on port 443.
    #>
    [CmdletBinding()]
    [OutputType([Carbon.Certificates.HttpsCertificateBinding])]
    param(
        [IPAddress]
        # The IP address whose certificate(s) to get.  Should be in the form IP:port. Optional.
        $IPAddress,

        [UInt16]
        # The port whose certificate(s) to get. Optional.
        $Port
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    [Carbon.Certificates.HttpsCertificateBinding]::GetHttpsCertificateBindings() |
        Where-Object {
            if( $IPAddress )
            {
                $_.IPAddress -eq $IPAddress
            }
            else
            {
                return $true
            }
        } |
        Where-Object {
            if( $Port )
            {
                $_.Port -eq $Port
            }
            else
            {
                return $true
            }
        }

}

Set-Alias -Name 'Get-CHttpsCertificateBindings' -Value 'Get-CHttpsCertificateBinding'
