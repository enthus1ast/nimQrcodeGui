# Package

version       = "0.2.0"
author        = "David Krause (enthus1ast)"
description   = "A gui and cli application for QR code generation."
license       = "MIT"
srcDir        = "src"
bin           = @["nimQrcodeGui"]


# Dependencies

requires "nim >= 2.0.0"
requires "pixie"
requires "QRgen"
requires "nigui"
requires "cligen"
