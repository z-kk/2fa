import
  db_connector / db_mysql,
  csvDir / [tfaValues]
export
  db_mysql,
  tfaValues

const
  DbHost = "maria"
  DbUser = "tfauser"
  DbPass = ""
  DbName = "tfa"

proc openDb*(host = DbHost, user = DbUser, password = DbPass, database = DbName): DbConn =
  let db = open(host, user, password, database)
  discard db.setEncoding("utf8")
  return db

proc createTables*(host = DbHost, user = DbUser, password = DbPass, database = DbName) =
  let db = openDb(host, user, password, database)
  db.createTfaValuesTable
  db.close
