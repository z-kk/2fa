import
  std / [strutils, rdstdin],
  docopt,
  tfapkg / [submodule, nimbleInfo]

type
  CmdOpt = object
    target: string
    isList: bool

proc readCmdOpt(): CmdOpt =
  ## Read command line options.
  let doc = """
    $1

    Usage:
      $1 <target>
      $1 [-l]

    Options:
      -h --help   Show this screen.
      --version   Show version.
      -l --list   Show title list.
      <target>    Target title.
  """ % [AppName]
  let args = doc.dedent.docopt(version = Version)

  if args["<target>"]:
    result.target = $args["<target>"]
  if args["--list"] or result.target == "":
    result.isList = true

when isMainModule:
  let cmdopt = readCmdOpt()
  initial()
  if cmdopt.isList:
    echo "Usage titles:"
    for title in getTitleList():
      echo "  - ", title
  else:
    var key = cmdopt.target.getKey
    if key == "":
      key = readLineFromStdin("TOTP key: ")
      cmdopt.target.setKey(key)
    else:
      echo key.getTotpValue
