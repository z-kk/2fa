import
  std / [strutils, rdstdin],
  docopt,
  tfapkg / [submodule, nimbleInfo]

var
  target* = ""

proc readCmdOpt() =
  ## Read command line options.
  let doc = """
    $1

    Usage:
      $1 <target>

    Options:
      -h --help   Show this screen.
      --version   Show version.
      <target>    Target title.
  """ % [AppName]
  let args = doc.dedent.docopt(version = Version)

  target = $args["<target>"]

when isMainModule:
  readCmdOpt()
  initial()
  var key = target.getKey
  if key == "":
    key = readLineFromStdin("TOTP key: ")
    target.setKey(key)
  else:
    echo key.getTotpValue
