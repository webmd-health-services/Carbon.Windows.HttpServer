
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

## Renamed

Functions and function aliases:

* `Get-SslCertificateBinding`, `Get-SslCertificateBindings`, and `Get-CSslCertificateBinding`: use
`Set-CHttpsCertificateBinding` instead.
* `Remove-SslCertificateBinding` and `Remove-CSslCertificateBinding`: use `Remove-CHttpsCertificateBinding` instead.
* `Set-SslCertificateBinding` and `Set-CSslCertificateBinding`: use `Set-CHttpsCertificateBinding` instead.
* `Test-SslCertificateBinding` and `Test-CSslCertificateBinding`: use `Test-CHttpsCertificateBinding` instead.
