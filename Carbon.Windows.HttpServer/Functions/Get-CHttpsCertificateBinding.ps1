
function Get-CHttpsCertificateBinding
{
    <#
    .SYNOPSIS
    Gets the HTTPS certificate bindings on this computer.

    .DESCRIPTION
    Windows binds HTTPS certificates to an IP addresses/port combination.  This function gets all the HTTPS bindings on this computer, or a binding for a specific IP/port, or $null if one doesn't exist.  The bindings are returned as `Carbon.Windows.HttpServer.HttpsCertificateBinding` objects.

    .OUTPUTS
    Carbon.Windows.HttpServer.HttpsCertificateBinding.

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
    [OutputType([Carbon.Windows.HttpServer.HttpsCertificateBinding])]
    param(
        # The IP address whose certificate(s) to get.  Should be in the form IP:port. Optional.
        [ipaddress] $IPAddress,

        # The port whose certificate(s) to get. Optional.
        [UInt16] $Port
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $searching = $IPAddress -or $Port
    $bindings = @()
    [Carbon.Windows.HttpServer.HttpsCertificateBinding]::GetHttpsCertificateBindings() |
        Where-Object {
            if( $IPAddress )
            {
                return $_.IPAddress -eq $IPAddress
            }
            return $true
        } |
        Where-Object {
            if( $Port )
            {
                return $_.Port -eq $Port
            }
            return $true
        } |
        Tee-Object -Variable 'bindings' |
        Write-Output

    if (-not $searching -or $bindings)
    {
        return
    }

    $searchDesc = ''
    if (-not $IPAddress)
    {
        $IPAddress = [ipaddress]'0.0.0.0'
    }

    $searchDesc = $IPAddress.IPAddressToString
    if ($IPAddress.AddressFamily -eq 'InterNetworkV6')
    {
        $searchDesc = "[$($searchDesc)]"
    }

    if ($Port)
    {
        $searchDesc = "$($searchDesc):$($Port)"
    }

    $msg = "HTTPS certificate binding $($searchDesc) does not exist."
    Write-Error -Message $msg -ErrorAction $ErrorActionPreference
}
