<!-- markdownlint-disable -->

# Overview

The Carbon.Windows.HttpServer module contains functions for configuring HTTPS/TLS/SSL certificate bindings on IP
addresses and ports. In order for processes to use an HTTPS certificate from the Windows certificate store on a specific
IP address/port combination, that certificate has been to be bound to that IP address and port. Use this module's
`Get-CHttpsCertificateBinding`, `Remove-CHttpsCertificateBinding`, `Set-CHttpsCertificateBinding`, and
`Test-CHttpsCertificateBinding` functions to configure HTTPS certificate bindings.

# System Requirements

* Windows PowerShell 5.1 and .NET 4.6.2+
* PowerShell Core 6+
* Windows Server 2012R2 or later
* Windows 10 or later

# Installing

To install globally:

```powershell
Install-Module -Name 'Carbon.Windows.HttpServer'
Import-Module -Name 'Carbon.Windows.HttpServer'
```

To install privately:

```powershell
Save-Module -Name 'Carbon.Windows.HttpServer' -Path '.'
Import-Module -Name '.\Carbon.Windows.HttpServer'
```

# Commands

## Get-CHttpsCertifiateBinding

Gets all the HTTPS certificate bindings. Allows searching by IP address and/or port.

## Remove-CHttpsCertificateBinding

Removes a specific HTTPS certificate binding.

## Set-CHttpsCertificateBinding

Creates a binding that uses a specific certificate.

## Test-CHttpsCertificateBinding

Tests that a binding on a give IP address and/or port exists.
