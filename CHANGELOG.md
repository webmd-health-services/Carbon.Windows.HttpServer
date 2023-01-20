
# 1.0.0

The `Carbon.Windows.HttpServer` module moves the following functions from the `Carbon` module:

* Get-CSslCertificateBinding
* Remove-CSslCertificateBinding
* Set-CSslCertificateBinding
* Test-CSslCertificateBinding

## Upgrade Instructions

All functions now require the `C` prefix and the `Ssl` noun in the name is now `Https`:

* Rename usages of `Get-SslCertificateBinding`, `Get-CSslCertificateBinding`, and `Get-SslCertificateBindings` to
`Set-CHttpsCertificateBinding`.
* Rename usages of `Remove-SslCertificateBinding` and `Remove-CSslCertificateBinding` to
`Remove-CHttpsCertificateBinding`.
* Rename usages of `Set-SslCertificateBinding` and `Set-CSslCertificateBinding` to
`Set-CHttpsCertificateBinding`.
* Rename usages of `Test-SslCertificateBinding` and `Test-CSslCertificateBinding` to
`Test-CHttpsCertificateBinding`.

Update usages of `Get-CHttpsCertificateBinding` that use the `IPAddress` or `Port` parameter with `-ErrorAction Ignore`.
The `Get-CHttpsCertificateBinding` function now writes an error if searching for a binding and it doesn't exist.

Update usages of `Remove-HttpsCertificateBinding` to include parameters `-IPAddress '0.0.0.0'` and `-Port 443`. The
function now deletes *all* bindings when called with no arguments, but prompts for confirmation first.

Update usages of `Remove-HttpsCertificateBinding` with `-ErrorAction Ignore`. The function now writes an error if the
binding to delete doesn't exist.

## Additions

* `Get-HttpsCertificateBinding` can now find bindings by certificate thumbprint and application id using the new
`Thumbprint` and `ApplicationID` parameters, respectively.
* `Remove-CHttpsCertificateBinding` can now delete all bindings that use a specific certificate and/or application using
the new `Thumbprint` and `ApplicationID` parameters.
* Added parameter `StoreName` to `Set-CHttpsCertificateBinding` to control the store where a binding's certificate can be
found.
* `Test-CHttpsCertificateBinding` can now test if any certificates exist that use a specific certificate or are for a
specific application using the new `Thumbprint` and `ApplicationID` parameters.

## Changes

* `Get-CHttpsCertificateBinding` now writes an error if a binding doesn't exist on the IP address and/or port passed as
`-ErrorAction Ignore` if you don't want to see the error.
* `Remove-CHttpsCertificateBinding` no longer deletes bindings to IP address `0.0.0.0` and port `443` be default. When
passed no arguments, the function will delete *all* bindings, but prompts for confirmation first.
* `Remove-CHttpsCertificateBinding` now writes an error if it doesn't delete any bindings. Add `-ErrorAction Ignore` to
hide the error.
* `Remove-CHttpsCertificateBinding` now deletes _all_ binding that matches _all_ parameters that are passed in. If only
one parameter is passed, all bindings that match that single parameter will be deleted.
* `Set-CHttpsCertificateBinding` no longer always deletes and re-creates a binding. It now only deletes a binding if it
exists but its thumbprint and/or application id don't match the values passed to the `Thumbprint` and `ApplicationID`
parameters, respectively.

## Renamed

Functions and function aliases:

* `Get-SslCertificateBinding`, `Get-SslCertificateBindings`, and `Get-CSslCertificateBinding`: use
`Set-CHttpsCertificateBinding` instead.
* `Remove-SslCertificateBinding` and `Remove-CSslCertificateBinding`: use `Remove-CHttpsCertificateBinding` instead.
* `Set-SslCertificateBinding` and `Set-CSslCertificateBinding`: use `Set-CHttpsCertificateBinding` instead.
* `Test-SslCertificateBinding` and `Test-CSslCertificateBinding`: use `Test-CHttpsCertificateBinding` instead.
