# Package

version       = "0.1.0"
author        = "z-kk"
description   = "Manage and display Two-Factor Authentication (2FA) keys."
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["tfa"]
binDir        = "bin"


# Dependencies

requires "nim >= 2.0.0"
requires "db_connector"
requires "docopt"
requires "libsha"
requires "nauthy"


# Before / After

import std / [os, strutils]
before build:
  let infoFile = srcDir / bin[0] & "pkg" / "nimbleInfo.nim"
  infoFile.parentDir.mkDir
  infoFile.writeFile("""
    const
      AppName* = "$#"
      Version* = "$#"
  """.dedent % [bin[0], version])

after build:
  let infoFile = srcDir / bin[0] & "pkg" / "nimbleInfo.nim"
  infoFile.writeFile("""
    const
      AppName* = ""
      Version* = ""
  """.dedent)
