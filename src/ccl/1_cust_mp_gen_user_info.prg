;===============================================================================
; Program: 1_cust_mp_sep_user_info.prg
; Version: v0.5.0
; Build Date: 2025-09-06
; Git Branch: main
; Git Commit: 3f0b4b7
; 
; Features: user-environment-info, authentication-context, position-verification
; 
; Last Modified: 2025-09-06 by Template
; Description: Get user environment and authentication info (copied from respiratory MPage v2.0.0)
; Source: 1_mhn_mp_user_env_info_02.prg from resp-ther-mpage v2.0.0
;===============================================================================
drop program 1_cust_mp_gen_user_info go
create program 1_cust_mp_gen_user_info

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "User ID:" = ""
	, "Data Type:" = 0 

with OUTDEV, USERID, DATATYPE

; Version tracking constants (CLAUDE.md standards)
DECLARE PROGRAM_VERSION = vc WITH CONSTANT("v0.5.0"), PROTECT
DECLARE BUILD_DATE = vc WITH CONSTANT("2025-09-06"), PROTECT  
DECLARE GIT_BRANCH = vc WITH CONSTANT("main"), PROTECT
DECLARE PROGRAM_FEATURES = vc WITH CONSTANT("user-environment-info,authentication-context,position-verification"), PROTECT

FREE RECORD REC
RECORD REC(
	1 user_id = f8
	1 user_name = vc
	1 user_position = vc
	1 cur_node = vc
	1 cur_user = vc
	1 cur_server = vc
)

declare resp = vc with protect, noconstant("")
declare full_name = vc with protect, noconstant("")

if($USERID = "")
  set REC->user_id = reqinfo->updt_id
else
  set REC->user_id = cnvtreal($USERID)
endif

call echo(REC->user_id)

call echo("get position")
select into "nl:"
	cv.code_value
From
	code_value cv,
	prsnl p 
plan cv 
join p
where 
	p.position_cd = cv.code_value
	and cv.code_set= 88
	and cv.active_ind= 1
	and p.person_id = REC->user_id
detail
	REC->user_id = p.person_id
  REC->user_position = cv.display
with nocounter

call echo("get username and env info")
select into "nl:"
	p.name_full_formatted
from prsnl p
where p.person_id = REC->user_id
detail
	REC->user_name = substring(1, 20, p.name_full_formatted)
	REC->cur_node = TRIM(CURNODE)
	REC->cur_user = TRIM(CURUSER)
	REC->cur_server = TRIM(cnvtstring(CURSERVER))
with nocounter

call echorecord(REC)

; send back recordset data as JSON or XML
free set strReply
declare strReply = vc
if (cnvtint($datatype) = 0)
	call echojson(REC) ;for debugging
	set strReply = cnvtrectojson(REC)
	set _MEMORY_REPLY_STRING = strReply
else
	call echoxml(REC) ;for debugging
	set strReply = cnvtrectoxml(REC)
	set _MEMORY_REPLY_STRING = strReply
endif

end
go