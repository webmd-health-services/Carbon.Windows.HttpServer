
function Invoke-Netsh
{
    <#
    .SYNOPSIS
    INTERNAL.

    .DESCRIPTION
    INTERNAL.

    .EXAMPLE
    INTERNAL.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The target of the action.
        [Parameter(Mandatory)]
        [String] $Target,

        # The action/command being performed.
        [Parameter(Mandatory)]
        [String] $Action,

        # The command to run.
        [Parameter(Mandatory, ValueFromRemainingArguments, Position=0)]
        [String[]] $ArgumentList
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if (-not $PSCmdlet.ShouldProcess($Target, $Action))
    {
        return
    }

    Write-Information "netsh $($ArgumentList -join ' ')"
    $output = netsh $ArgumentList
    if( $LASTEXITCODE )
    {
        $output = $output -join [Environment]::NewLine
        $msg = "Netsh command ""$($Action)"" on ""$($Target)"" exited with code $($LASTEXITCODE): $($output)"
        Write-Error -Message $msg -ErrorAction $ErrorActionPreference
        return
    }

    $output | Where-Object { $null -ne $_ } | Write-Verbose
}
