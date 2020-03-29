clear

discard

.xlx = .stataxlx.new

local xlxname "$maindir/ado/test.xlsx"
.sheets = .statalist.new
.sheets.append "sheet 1"
.sheets.append "sheet 2"

.title = .statalist.new
.title.append "My spreadsheet"
.title.append "Author: Brian Livingston"

.xlx.set "`xlxname'" .title .sheets
// .xlx.create .sheets
