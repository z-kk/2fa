import
  std / [os, strutils, sequtils, parsecsv],
  db_connector / db_mysql

type
  TfaValuesCol* {.pure.} = enum
    title, value
  TfaValuesTable* = object
    primKey: int
    title*: string
    value*: string

proc setDataTfaValuesTable*(data: var TfaValuesTable, colName, value: string) =
  case colName
  of "title":
    try:
      data.title = value
    except: discard
  of "value":
    try:
      data.value = value
    except: discard

proc createTfaValuesTable*(db: DbConn) =
  let sql = """
    create table if not exists tfa_values(
      title varchar(255) not null primary key comment 'title',
      value varchar(255) not null comment 'hashed value'
    )
  """.sql
  db.exec(sql)

proc tryInsertTfaValuesTable*(db: DbConn, rowData: TfaValuesTable): int64 =
  var vals: seq[string]
  var sql = "insert into tfa_values("
  sql.add "value,"
  vals.add rowData.value
  sql[^1] = ')'
  sql.add " values ("
  sql.add sequtils.repeat("?", vals.len).join(",")
  sql.add ')'
  return db.tryInsertID(sql.sql, vals)
proc insertTfaValuesTable*(db: DbConn, rowData: TfaValuesTable) =
  let res = tryInsertTfaValuesTable(db, rowData)
  if res < 0: db.dbError
proc insertTfaValuesTable*(db: DbConn, rowDataList: seq[TfaValuesTable]) =
  for rowData in rowDataList:
    db.insertTfaValuesTable(rowData)

proc selectTfaValuesTable*(db: DbConn, whereStr = "", orderBy: seq[string], whereVals: varargs[string, `$`]): seq[TfaValuesTable] =
  var sql = "select * from tfa_values"
  if whereStr != "":
    sql.add " where " & whereStr
  if orderBy.len > 0:
    sql.add " order by " & orderBy.join(",")
  let rows = db.getAllRows(sql.sql, whereVals)
  for row in rows:
    var res: TfaValuesTable
    res.setDataTfaValuesTable("title", row[TfaValuesCol.title.ord])
    res.setDataTfaValuesTable("value", row[TfaValuesCol.value.ord])
    result.add res
proc selectTfaValuesTable*(db: DbConn, whereStr = "", whereVals: varargs[string, `$`]): seq[TfaValuesTable] =
  selectTfaValuesTable(db, whereStr, @[], whereVals)

proc updateTfaValuesTable*(db: DbConn, rowData: TfaValuesTable) =
  if rowData.primKey < 1:
    return
  var
    vals: seq[string]
    sql = "update tfa_values set "
  sql.add "value = ?,"
  vals.add rowData.value
  sql[^1] = ' '
  sql.add "where title = " & $rowData.primKey
  db.exec(sql.sql, vals)
proc updateTfaValuesTable*(db: DbConn, rowDataList: seq[TfaValuesTable]) =
  for rowData in rowDataList:
    db.updateTfaValuesTable(rowData)

proc dumpTfaValuesTable*(db: DbConn, dirName = ".") =
  dirName.createDir
  let
    fileName = dirName / "tfa_values.csv"
    f = fileName.open(fmWrite)
  f.writeLine "title,value"
  for row in db.selectTfaValuesTable:
    f.write "\"$#\"," % [$row.title]
    f.write "\"$#\"," % [$row.value]
    f.setFilePos(f.getFilePos - 1)
    f.writeLine ""
  f.close

proc insertCsvTfaValuesTable*(db: DbConn, fileName: string) =
  var parser: CsvParser
  defer: parser.close
  parser.open(fileName)
  parser.readHeaderRow
  while parser.readRow:
    var data: TfaValuesTable
    data.setDataTfaValuesTable("title", parser.rowEntry("title"))
    data.setDataTfaValuesTable("value", parser.rowEntry("value"))
    db.insertTfaValuesTable(data)

proc restoreTfaValuesTable*(db: DbConn, dirName = ".") =
  let fileName = dirName / "tfa_values.csv"
  db.exec("delete from tfa_values".sql)
  db.insertCsvTfaValuesTable(fileName)
