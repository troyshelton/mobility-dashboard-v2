drop program 1ih_custmp_azure_dev go
create program 1ih_custmp_azure_dev

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Parameters" = ""
	, "Parameters" = "" 

with OUTDEV, PARAM, PARAM2


free set str1
declare str1 = vc
free set str2
declare str2 = vc
free set strHTML
declare strHTML = vc
 
set strHTML = concat(strHTML, ~<html>~)
set strHTML = concat(strHTML, ~<head>~)
set strHTML = concat(strHTML, ~<meta http-equiv="pragma" content="no-cache"/>~)
set strHTML = concat(strHTML, ~<meta http-equiv="expires" content="-1"/>~)
 

set strhtml = concat(strhtml, ~<script>function redirect() { window.location = "~)
set str1 = build2("https://ihazurestoragedev.z13.web.core.windows.net/",$PARAM,"/",$PARAM2)
call echo(str1)
set strhtml = concat(strhtml, str1)

set strhtml = concat(strhtml, ~" }</script></head><body onload="javascript:redirect();">~)

set strHTML = concat(strHTML, ~</body>~)
set strHTML = concat(strHTML, ~</html>~)
 
set _MEMORY_REPLY_STRING = strHTML

call echo(strHTML)
 
;execute 1ih_custmp_azure_dev "MINE", "tailwind-preline-handsontable-starter", "dist/index.html" go

end
go



 
