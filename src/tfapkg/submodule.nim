import
  std / [terminal],
  libsha / sha256,
  nauthy,
  dbtables

var
  dbPass* = ""

proc initial*() =
  ## Read DB password and create tables.
  dbPass = readPasswordFromStdin()
  createTables(password=dbPass)

proc getKey*(title: string): string =
  let db = openDb(password=dbPass)
  defer: db.close

  let sql = """
    SELECT AES_DECRYPT(UNHEX(value), UNHEX(?))
    FROM tfa_values
    WHERE title = ?
  """

  return db.getValue(sql.sql, dbPass.sha256hexdigest, title)

proc setKey*(title: string, val: string) =
  let db = openDb(password=dbPass)
  defer: db.close

  let sql = """
    INSERT INTO tfa_values(title, value)
    VALUES (?, HEX(AES_ENCRYPT(?, UNHEX(?))))
  """

  db.exec(sql.sql, title, val, dbPass.sha256hexdigest)

proc getTotpValue*(key: string): string =
  return key.initTotp.now
