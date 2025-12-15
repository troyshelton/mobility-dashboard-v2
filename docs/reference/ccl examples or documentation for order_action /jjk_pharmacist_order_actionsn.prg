;set trace backdoor p30ins go	; 001 - commented out since it errs when compiled as DBA
drop program jjk_pharmacist_order_actionsn go
create program jjk_pharmacist_order_actionsn
 
prompt
	"Output to File/Printer/MINE" = "MINE"                  ;* Enter or select the printer or file name to send this report to.
	, "Order Actions on or After" = "CURDATE"
	, "Order Actions  Before:" = "CURDATE"
	, "Facility" = 0
	, "Report Type" = ""
	, "Report Output" = ""
	, "Email .csv file" = 0
	, "Send email to (Seperate emails with a space)" = ""
	, "Time Frame" = "X"
 
with pOUTDEV, pSTART_DATE, pEND_DATE, FAC, pREPORTY_TYPE, pREPORT_OUTPUT,
	SENDEMAIL, EMAILLIST, TIME
 
/**********************************************************************
*                  PROGRAM HEADER
***********************************************************************
 Program Title:   Pharmacist Order Actions
 Object name:     9_PHARMACIST_ORDER_ACTIONS4
 Source file:     9_PHARMACIST_ORDER_ACTIONS4.prg
 Purpose:         return the actions performed by Pharmacy staff.
                  This program was "created" by a consultant and appears to have been taken from Mission Health.
                  It runs very slowly and needs to be re-written.
 NOTE: OPS Jobs uses a driver program named "9_order_action_ops_driver.prg" to execute this CCL.
************************************************************************
*                                 MODIFICATION CONTROL LOG
************************************************************************
Mod	Date		Analyst			OPAS			 Comment
---	----------	---------------	----------		 ------------------------
001	10/05/2017	DMA	 		    R2:000057537349  added header since none existed and
                                                 commented out disclaimer referencing Mission Health's privacy officer and
                                                 added a new $TIME parameter named "Undefined" with its value set as 'X',
                                                 made it the default for $TIME, and changed the order of the IF Statement
                                                 below to test for 'X' first and if not 'X' then use specified date criteria.
                                                 This way ensure that the user date input values get used.
                                                 Also added NOTE referencing the driver program's name.
---	----------	---------------	----------		 ------------------------
002 02/08/23 Jennifer King - fix nursing unit truncating in display output; Performance improvement
******************END OF ALL MODCONTROL BLOCKS* ***********************/
 
SET GVC_RPT_HEADER1 = "Daily Order Actions Report"
 
 
 
DECLARE MVC_EMAIL_SUBJECT = VC WITH PROTECTED,CONSTANT(NULLTERM(build2(trim(uar_get_code_display($FAC),3)," Order Actions Report"
,"(",trim(curnode,3),")")))
 
 
call echo(build("Facility:",uar_get_code_display($FAC)))
 
 
DECLARE MVC_EMAIL_ADDRESSES = VC WITH PROTECTED,CONSTANT(CONCAT(" ",TRIM($EMAILLIST,3)))
DECLARE MI2_EMAILIND = I2 WITH PROTECTED,NOCONSTANT(0)
DECLARE MVC_EMAIL_BODY = VC WITH PROTECTED,NOCONSTANT("")
DECLARE MVC_UNICODE = VC WITH PROTECTED,NOCONSTANT("")
 
DECLARE MVC_AIX_COMMAND	  = VC WITH PROTECTED,NOCONSTANT("")
DECLARE MI4_AIX_CMDLEN	  = I4 WITH PROTECTED,NOCONSTANT(0)
DECLARE MI4_AIX_CMDSTATUS = I4 WITH PROTECTED,NOCONSTANT(0)
SET MI2_EMAILIND = VALUE($SENDEMAIL)
/***************************************************************************************
* Gather Prompt Information															   *
***************************************************************************************/
;Format the dates for explorermenu and ops
;DECLARE START_DATE 	= DQ8
;DECLARE END_DATE 	= DQ8
 
;IF (ISNUMERIC($pSTART_DATE) > 0) ;input was in curdate/curtime format
;
;	SET START_DATE = cnvtdatetime($pSTART_DATE,0)
;ELSE ;input was in DD-MMM-YYYY string format
;
;	SET START_DATE = cnvtdatetime(curdate-1,0);CNVTDATETIME($pSTART_DATE)
;ENDIF
;
;IF (ISNUMERIC($pEND_DATE) > 0) ;input was in curdate/curtime format
;	SET END_DATE = cnvtdatetime($pEND_DATE,2359)
;ELSE ;input was in MM/DD/YYYY string format
;	SET END_DATE = cnvtdatetime(curdate-1,2359);= CNVTDATETIME($pEND_DATE)
;ENDIF
 
; 001 - Adding '1=1' with $TIME's default set to "M" caused report to always run a month's data. I'm hesitant to
; remove David Smith's 01-23-2017 change though since doing so could break the OPS Jobs. However, simply changing the
; default value to $TIME to "D" or not changing it at all causes the report to ignore the input date parameters selected
; by the user. So I added a new $TIME parameter named "Undefined" with its value set as 'X', made it the default for $TIME,
; and changed the order of the IF Statement below to test for 'X' first and if not 'X' then use the specific date criteria
; that David wants. This way ensures that the user's date input values get used without affecting David's change.
IF ($TIME = "X")
  SET START_DATE = CNVTDATETIME($pSTART_DATE)
  SET END_DATE = CNVTDATETIME($pEND_DATE)
ELSE
	IF ($TIME = "M")
	  SET START_DATE = CNVTDATETIME(curdate-42,0);cnvtlookbehind("1 M",cnvtdatetime(curdate,0))
	  SET END_DATE =CNVTDATETIME(curdate-12,2359); CNVTDATETIME(CURDATE-1,2359)
	ELSEIF($TIME = "D")
	 SET START_DATE = CNVTDATETIME(curdate-1,0)
	  SET END_DATE = CNVTDATETIME(curdate-1,2359)
	ELSEIF($TIME = "W")
	 SET START_DATE = cnvtlookbehind("1 W",cnvtdatetime(curdate,0))
	  SET END_DATE = CNVTDATETIME(CURDATE-1,2359)
	endif
ENDIF
;;;if (validate(request->batch_selection) = 1 or 1=1);1/23/17 - Adding "or 1=1" to fix how time is passed from wrapper prg)
;;;	IF ($TIME = "M")
;;;	  SET START_DATE = CNVTDATETIME(curdate-42,0);cnvtlookbehind("1 M",cnvtdatetime(curdate,0))
;;;	  SET END_DATE =CNVTDATETIME(curdate-12,2359); CNVTDATETIME(CURDATE-1,2359)
;;;	ELSEIF($TIME = "D")
;;;	 SET START_DATE = CNVTDATETIME(curdate-1,0)
;;;	  SET END_DATE = CNVTDATETIME(curdate-1,2359)
;;;	ELSEIF($TIME = "W")
;;;	 SET START_DATE = cnvtlookbehind("1 W",cnvtdatetime(curdate,0))
;;;	  SET END_DATE = CNVTDATETIME(CURDATE-1,2359)
;;;	endif
;;;ELSE
;;;  SET START_DATE = CNVTDATETIME($pSTART_DATE)
;;;  SET END_DATE = CNVTDATETIME($pEND_DATE)
;;;ENDIF
 
 
 
 
call echo(build("START_DATE:",format(START_DATE,"mm/dd/yyyy hh:mm;;d")))
 
 
call echo(build("END_DATE:",format(END_DATE,"mm/dd/yyyy hh:mm;;d")))
 
DECLARE MI4_DAY_RANGE = I4 WITH CONSTANT(abs(DATETIMEDIFF(START_DATE,END_DATE))),PROTECT
 
 
IF (MI4_DAY_RANGE > 31)
	SELECT INTO $POUTDEV
		ERROR = 'Date range cannot exceed 1 month.'
	WITH nocounter, format, separator = ' '
else
 
 
;Get the username of the person running the rpt
DECLARE USER_NAME = VC
DECLARE USER = VC
SELECT INTO "NL:"
FROM PRSNL PR
PLAN PR
	WHERE PR.PERSON_ID = REQINFO->UPDT_ID
	AND PR.ACTIVE_IND = 1
	AND PR.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME)
DETAIL
	USER_NAME = PR.NAME_FULL_FORMATTED
	USER = PR.USERNAME
WITH COUNTER
 
DECLARE FACILITY_DISP = VC
 
 
 
set date_range_disp = CONCAT("Order Actions Between ",FORMAT((START_DATE),"MM/DD/YY HH:MM;;D")," through ",
			FORMAT((END_DATE),"MM/DD/YY HH:MM;;D"))
 
 
;;;set disclaimer = CONCAT("This document is the property of the Mission Health System and may contain Protected Health Information.",
;;;					  "Follow applicable Mission policies for use, disclosure, and disposal of this document. If you received this",
;;;					  " document in error, please contact the Mission Health System Privacy Officer at 828-213-1634.")
 
 
declare discActionCnt = i4 with noconstant(0)
declare reschActionCnt = i4 with noconstant(0)
declare resumeActionCnt = i4 with noconstant(0)
declare suspendActionCnt =  i4 with noconstant(0)
declare refillActionCnt =  i4 with noconstant(0)
declare verifiedActionCnt =  i4 with noconstant(0)
declare rejectActionCnt =  i4 with noconstant(0)
 
declare pharmInd =  i4 with noconstant(0)
declare posInd =  i4 with noconstant(0)
declare actionInd = i4 with noconstant(0)
declare orgInd = i4 with noconstant(0)
 
 
if(0.0 in ($FAC))
	set orgInd = 0
else
	set orgInd = 1
endif
 
 
/*if(0 in ($pORDER_ACTION))
	set actionInd = 0
elseif ($pORDER_ACTION >0)
	set actionInd = 1
 
elseif ($pORDER_ACTION = -1);verify
	set actionInd = -1
elseif ($pORDER_ACTION -2);RXPRODASSIGN
	set actionInd = -2
elseif ($pORDER_ACTION -3);clin review
	set actionInd = -3
else
	set actionInd = 0
endif
 
 
if(0 in($pPHARMACIST))
 	set pharmInd=0
else
	set pharmInd=1
endif
 
 
if(0 in($pPosition))
 	set posInd=0
else
	set posInd=1
endif
*/
free record actionInfo
record actionInfo
(
 	1 actionCnt = i4
 	1 hr[24]
 		2 hrItrv = I4
	1 facility[*]
		2 hr[24]
			3 hrItrv = i4
		2 facility = vc
		2 actionCnt = i4
		2 actions[*]
			3 action = vc
			3 action_type_cd = f8
			3 hr[24]
				4 hrItrv = I4
			3 actionCnt = i4
		2 personnel[*]
			3 prsnl_Id = f8
			3 name_full_formatted = vc
			3 position = vc
 
			3 actions[*]
				4 orderId = f8
				4 action = vc
				4 actionDt = vc
				4 actionTm = vc
				4 unit = vc
				4 facility  = vc
				4 orderName = vc
 
			3 actions2[*]
				4 action = vc
				4 actionCnt = i4
				4 action_type_cd = f8
				4 hrInterval = vc
				4 action_seq = i4
				4 order_id = f8
				4 hr[24]
					5 hrItrv = i4
			3 actionCnt = i4
			3 hr[24]
				4 hrItrv = i4
			3 actionTypes[*]
				4 display = vc
 	1 actions[*]
 		2 action = vc
 		2 action_type_cd = f8
 		2 actionCnt = i4
 		2 hr[24]
 			3 hrItrv = i4
)
free record outputDisplay
record outputDisplay
(
	1 row[*]
		2 colA = vc ;Pharmacist;
		2 colB = vc ;Action
		2 colC = vc ;1 Hr
		2 colD = vc ;2 Hr
		2 colE = vc ;3 Hr
		2 colF = vc ;4 Hr
		2 colG = vc ;5 Hr
		2 colH = vc ;6 Hr
		2 colI = vc ;7 Hr
		2 colJ = vc ;8 Hr
		2 colK = vc ;9 Hr
		2 colL = vc ;10 Hr
		2 colM = vc ;11 Hr
		2 colN = vc ;12 Hr
		2 colO = vc ;13 Hr
		2 colP = vc ;14 Hr
		2 colQ = vc ;15 Hr
		2 colR = vc ;16 Hr
		2 colS = vc ;17 Hr
		2 colT = vc ;18 Hr
		2 colU = vc ;19 Hr
		2 colV = vc ;20 Hr
		2 colW = vc ;21 Hr
		2 colX = vc ;22 Hr
		2 colY = vc ;23 Hr
		2 colZ= vc ;24 Hr
		2 colAA = vc;Total
		2 colAB = vc
		2 colAC = vc;Facility
		2 sortInd = vc
		2 section = vc
 
 
)
 
%i cust_script:0_ccl_rpt_info.inc
 
IF (VALIDATE(REQUEST->BATCH_SELECTION) = 1)
  SET MVC_STARTDT = CNVTDATETIME(CURDATE-1,0)
  SET MVC_ENDDT = CNVTDATETIME(CURDATE-1,2359)
ELSE
  SET MVC_STARTDT = CNVTDATETIME($pSTART_DATE)
  SET MVC_ENDDT = CNVTDATETIME($pEND_DATE)
ENDIF
DECLARE MVC_FAC = VC WITH PROTECTED,NOCONSTANT("")
iF (0 IN ($FAC))
	SET MI4_FAC_IND = 1
	SET MVC_FAC = "All Facilities"
ELSE
	SET MI4_FAC_IND = 0
 
	SELECT INTO "NL:"
		cv.display
	FROM
		code_value cv
	WHERE cv.code_value IN ($FAC)
		AND cv.code_value > 0
		AND cv.active_ind =1
	ORDER BY cv.display
	HEAD REPORT
		MI4_FAC_CNT = 0
 
	DETAIL
		MI4_FAC_CNT = MI4_FAC_CNT +1
 
		IF(MI4_FAC_CNT = 1)
			MVC_FAC = cv.display
		ELSE
			MVC_FAC = BUILD2(MVC_FAC,", ", cv.display)
		ENDIF
	WITH NOCOUNTER
 
ENDIF
 
 
 
declare sortInd = i2
declare personRow = i2
declare rowcnt = i2
dECLARE GVC_START_DT = VC WITH CONSTANT(FORMAT(MVC_STARTDT,"MM/DD/YY HH:MM;;D")),PROTECT
DECLARE GVC_END_DT = VC WITH CONSTANT(FORMAT(MVC_ENDDT,"MM/DD/YY HH:MM;;D")),PROTECT
 
/*SET MVC_EMAIL_BODY = BUILD2("Auto generated email of the Pharmacy Order Action report for the follwing prompt selection:"
				     ,CHAR(13),"Email Sent By: ",GVC_USER_NAME
					 ,CHAR(13),"Facility: ",MVC_FAC
                     ,CHAR(13),"Order Actions on or After: ", GVC_START_DT
                     ,CHAR(13),"Order Actions Before: ",GVC_END_DT)
 
 */
DECLARE  UTCDATETIME (( DDATETIME = VC ), ( LINDEX = I4 ), ( BSHOWTZ = I2 ), ( SFORMAT = VC )) = VC
DECLARE  SUTCDATETIME  =  VC  WITH  PROTECT , NOCONSTANT (" " )
DECLARE  UTCSHORTTZ (( LINDEX = I4 )) =  VC
 
DECLARE  SUTCDATETIME  =  VC  WITH  PROTECT , NOCONSTANT (" " )
 
DECLARE  DUTCDATETIME  =  F8  WITH  PROTECT , NOCONSTANT (0.0 )
 
DECLARE  CUTC  =  I2  WITH  PROTECT , CONSTANT ( CURUTC )
 
 
SUBROUTINE   UTCDATETIME  ( SDATETIME ,  LINDEX ,  BSHOWTZ ,  SFORMAT  )
 
DECLARE  OFFSET  =  I2  WITH  PROTECT , NOCONSTANT (0 )
DECLARE  DAYLIGHT  =  I2  WITH  PROTECT , NOCONSTANT (0 )
DECLARE  LNEWINDEX  =  I4  WITH  PROTECT , NOCONSTANT ( CURTIMEZONEAPP )
DECLARE  SNEWDATETIME  =  VC  WITH  PROTECT , NOCONSTANT (" " )
DECLARE  CTIME_ZONE_FORMAT  =  VC  WITH  PROTECT , CONSTANT ("ZZZ" )
IF ( ( LINDEX >0 ) )
SET  LNEWINDEX  =  LINDEX
ENDIF
 
SET  SNEWDATETIME  =  DATETIMEZONEFORMAT ( SDATETIME ,  LNEWINDEX ,  SFORMAT )
IF ( ( CUTC =1 ) AND ( BSHOWTZ =1 ) )
IF ( ( SIZE ( TRIM ( SNEWDATETIME ))>0 ) )
SET  SNEWDATETIME  =  CONCAT ( SNEWDATETIME , " " ,  DATETIMEZONEFORMAT ( SDATETIME ,  LNEWINDEX ,
 CTIME_ZONE_FORMAT ))
ENDIF
 
ENDIF
 
SET  SNEWDATETIME  =  TRIM ( SNEWDATETIME ) RETURN ( SNEWDATETIME )
 
 
END ;Subroutine
 
 
;Find order actions performed between prompt date time per pharmacist
select  into $pOUTDEV
 pharmacistName = cnvtupper(p.name_full_formatted)
 ,orderAction = if (oa.action_qualifier_cd >0 )
					if (o.protocol_order_id >0  and oa.action_qualifier_cd in (60300376.00,60300379.00 ,60300382.00))
						uar_get_code_display (oa.action_type_cd)
					else
						uar_get_code_display (oa.action_qualifier_cd)
					endif
 
				elseif (oa.needs_verify_ind =3  )
					"Verify"
 
 
				elseif (oa.need_clin_review_flag=2  and ore.reviewed_status_flag=1  and ore.review_type_flag=5  )
					"Clinically Reviewed "
				else
					uar_get_code_display (oa.action_type_cd)
				endif
 
 
,actionDt = if(oa.needs_verify_ind = 3)
				SUBSTRING (1,8 ,UTCDATETIME (OA.UPDT_DT_TM, 0 , 0 , "MM/DD/YY HHmm" ))
			  else
			  	SUBSTRING (1 ,8 ,UTCDATETIME (OA.ACTION_DT_TM, OA.ACTION_TZ, 0 , "MM/DD/YY HHmm" ))
			  endif
 
,actionTm =if(oa.needs_verify_ind = 3)
				SUBSTRING (10 ,5 ,UTCDATETIME (OA.UPDT_DT_TM, 0 , 0 , "MM/DD/YY HH:mm" ))
			  else
			  	SUBSTRING (10, 5 ,UTCDATETIME (OA.ACTION_DT_TM, OA.ACTION_TZ, 0 , "MM/DD/YY HH:mm" ))
			  endif
 
,hrInterval = if(oa.needs_verify_ind = 3)
				SUBSTRING (10 , 2 ,UTCDATETIME (OA.UPDT_DT_TM, 0 , 0 , "MM/DD/YY HHmm" ))
			  else
			  	SUBSTRING (10 , 2 ,UTCDATETIME (OA.ACTION_DT_TM, OA.ACTION_TZ, 0 , "MM/DD/YY HHmm" ))
			  endif
 
,p.person_id
,sortInd = build2(uar_get_code_display(oa.action_type_cd),oa.action_dt_tm,oa.action_personnel_id)
,facility = if(od.future_loc_facility_cd>0)
				uar_get_code_display(od.future_loc_facility_cd)
			else
				uar_get_code_display(elh.loc_facility_cd)
			endif
from order_action oa
	,prsnl p
	,orders o
	,order_review ore
	,order_dispense od
	,encntr_loc_hist elh
	;,prsnl p2 ;002 added
 	;,dummyt d
 
plan oa
	where /*(pharmInd = 0 or evaluate(oa.needs_verify_ind,3,oa.updt_id,oa.action_personnel_id) in($pPHARMACIST ))
		and ((actionInd = 0 or (oa.action_type_cd in ($pORDER_ACTION)) and oa.needs_verify_ind != 3 and oa.need_clin_review_flag !
		= 2)
		 or (actionInd = -1 and oa.needs_verify_ind =3)
		 or (actionInd = -3 and oa.need_clin_review_flag = 2))
 
		and */
		oa.action_dt_tm between cnvtdatetime(start_date) and cnvtdatetime(end_date)
;
;join p2 ;002 added
;	where (p2.person_id = oa.updt_id or p2.person_id = oa.action_personnel_id)
join p
	where p.person_id = evaluate(oa.needs_verify_ind,3,oa.updt_id,oa.action_personnel_id)
			and p.position_cd in (     637037.00,
  101750711.00,
  101749888.00,
  101750003.00,
  132590464.00,
  101749891.00,
  101750007.00,
  132589096.00,
    4529568.00,
   58305979.00,
    4529704.00,
     637053.00,
   58304824.00,
     637054.00
)
		;and (posInd = 0 or p.position_cd in ($pPosition))
 		;and (pharmInd = 1 or (pharmInd = 0 and p.position_cd in (14412605.00,14426100.00,35171957.00,35171978.00)));Pharmacist Positions
join o
	where o.order_id = oa.order_id
		and o.activity_type_cd = 705;Pharmacy
		and o.orig_ord_as_flag = 0;Normal Order
		and o.template_order_flag in (0,1)
join elh
	where elh.encntr_id = o.encntr_id
		and elh.beg_effective_dt_tm <= o.orig_order_dt_tm
		and elh.end_effective_dt_tm +0 > o.orig_order_dt_tm
		and elh.loc_facility_cd = $FAC
		;and (orgInd = 0 or elh.organization_id in ($pORG))
join ore
	where ore.order_id= outerjoin (oa.order_id)
		and ore.action_sequence= outerjoin (oa.action_sequence)
		;and (actionInd != -4 or (ore.reviewed_status_flag = 1 and ore.review_type_flag = 5))
 
join od
	where od.order_id = o.order_id
		;and (od.future_loc_facility_cd in ($pORG) or od.future_loc_facility_cd = 0)
 
 
 
order by facility,p.person_id,orderAction,actionDt,actionTm,o.protocol_order_id,oa.source_protocol_action_seq
,oa.order_id,oa.action_sequence,ore.review_sequence  desc
 
head report
	facCnt = 0
	rowCnt = 0
	totalActionCnt = 0
 
 	rowCnt = rowCnt+1
	pharmCnt = 0
 
 
	stat = alterlist(outputDisplay->row,rowCnt)
 
	outputDisplay->row[rowCnt].colAC = date_range_disp
	outputDisplay->row[rowCnt].sortInd = ""
	outputDisplay->row[rowcnt].section = "DATE RANGE"
 
 
 
head facility
	facCnt = facCnt + 1
	facperPrsnl = 0
	stat = alterlist(actionInfo->facility,facCnt)
 
	actionInfo->facility[facCnt].facility = facility
 
 	fachr1Total = 0
 	fachr2Total = 0
 	fachr3Total = 0
 	fachr4Total = 0
 	fachr5Total = 0
 	fachr6Total = 0
 	fachr7Total = 0
 	fachr8Total = 0
 	fachr9Total = 0
 	fachr10Total = 0
 	fachr11Total = 0
 	fachr12Total = 0
 	fachr13Total = 0
 	fachr14Total = 0
 	fachr15Total = 0
 	fachr16Total = 0
 	fachr17Total = 0
 	fachr18Total = 0
 	fachr19Total = 0
 	fachr20Total = 0
 	fachr21Total = 0
 	fachr22Total = 0
 	fachr23Total = 0
 	fachr24Total = 0
 	facilityActonTotal = 0
 	facilityActionCnt = 0
 
 
 
head p.person_id
	actionCnt = 0
 	pharmRow = 0
 	prsnlActionCnt = 0
	pharmCnt = pharmCnt + 1
	facperPrsnl = facperPrsnl +1
 
	stat = alterlist(actionInfo->facility[facCnt].personnel,pharmCnt)
 
	actionInfo->facility[facCnt].personnel[pharmCnt].name_full_formatted = CNVTUPPER(pharmacistName)
 
 	actionInfo->facility[facCnt].personnel[pharmCnt].position = uar_get_code_display(p.position_cd)
 
 
 
	rowCnt = rowCnt + 1
 	stat = alterlist(outputDisplay->row,rowCnt)
	outputDisplay->row[rowCnt].colAC = "Facility"
 
 
 	outputDisplay->row[rowCnt].colA = "Pharmacist"
	outputDisplay->row[rowCnt].colB = "Action Type"
	outputDisplay->row[rowCnt].colC = "0000-0059"
	outputDisplay->row[rowCnt].colD = "0100-0159"
	outputDisplay->row[rowCnt].colE = "0200-0259"
	outputDisplay->row[rowCnt].colF = "0300-0359"
	outputDisplay->row[rowCnt].colG = "0400-0459"
	outputDisplay->row[rowCnt].colH = "0500-0559"
	outputDisplay->row[rowCnt].colI = "0600-0659"
	outputDisplay->row[rowCnt].colJ = "0700-0759"
	outputDisplay->row[rowCnt].colK = "0800-0859"
	outputDisplay->row[rowCnt].colL = "0900-0959"
	outputDisplay->row[rowCnt].colM = "1000-1059"
	outputDisplay->row[rowCnt].colN = "1100-1159"
	outputDisplay->row[rowCnt].colO = "1200-1259"
	outputDisplay->row[rowCnt].colP = "1300-1359"
	outputDisplay->row[rowCnt].colQ = "1400-1459"
	outputDisplay->row[rowCnt].colR = "1500-1559"
	outputDisplay->row[rowCnt].colS = "1600-1659"
	outputDisplay->row[rowCnt].colT = "1700-1759"
	outputDisplay->row[rowCnt].colU = "1800-1859"
	outputDisplay->row[rowCnt].colV = "1900-1959"
	outputDisplay->row[rowCnt].colW = "2000-2059"
	outputDisplay->row[rowCnt].colX = "2100-2159"
	outputDisplay->row[rowCnt].colY = "2200-2259"
	outputDisplay->row[rowCnt].colZ = "2300-2359"
	outputDisplay->row[rowCnt].colAA = "TOTAL"
 	outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"a")
 	outputDisplay->row[rowcnt].section = "HEADER"
 
 
	rowCnt = rowCnt + 1
	stat = alterlist(outputDisplay->row,rowCnt)
 
 	;only show facillity one time
 	;if(facperPrsnl = 1)
 		outputDisplay->row[rowCnt].colAC = facility
 	;endif
 
	outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"A")
	outputDisplay->row[rowCnt].colA = pharmacistName
	outputDisplay->row[rowcnt].section = "PHARMACIST"
	;outputDisplay->row[rowCnt].colAC = 2
 
 	actionRowCnt = 0
 
 	prsnlhr1Total = 0
 	prsnlhr2Total = 0
 	prsnlhr3Total = 0
 	prsnlhr4Total = 0
 	prsnlhr5Total = 0
 	prsnlhr6Total = 0
 	prsnlhr7Total = 0
 	prsnlhr8Total = 0
 	prsnlhr9Total = 0
 	prsnlhr10Total = 0
 	prsnlhr11Total = 0
 	prsnlhr12Total = 0
 	prsnlhr13Total = 0
 	prsnlhr14Total = 0
 	prsnlhr15Total = 0
 	prsnlhr16Total = 0
 	prsnlhr17Total = 0
 	prsnlhr18Total = 0
 	prsnlhr19Total = 0
 	prsnlhr20Total = 0
 	prsnlhr21Total = 0
 	prsnlhr22Total = 0
 	prsnlhr23Total = 0
 	prsnlhr24Total = 0
 
head orderAction
	personOrderActionCnt = 0;
 
 	actionRowCnt = actionRowCnt + 1
	facilityActonTotal = facilityActonTotal + 1
 
	;personnel action list
	if (oa.action_qualifier_cd >0 )
		if (o.protocol_order_id >0  and oa.action_qualifier_cd in (60300376.00,60300379.00 ,60300382.00))
			idx = 0
			pos3 = 0
			;find if action already added to action list
			pos3 = locateval(idx,1,size(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,5)
			,oa.action_type_cd,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[idx].action_type_cd)
			if (pos3 = 0);new order action
 
				a_cnt3 = size(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,5)
				a_cnt3 = a_cnt3 + 1
				stat = alterlist(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,a_cnt3)
 
				actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].action_type_cd = oa.action_type_cd
				actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].action = orderAction
 
			else
				 ;if it does exist, use the index location
				 a_cnt3 = pos3
			endif
		else
 
			idx = 0
			pos3 = 0
			;find if action already added to action list
			pos3 = locateval(idx,1,size(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,5)
			,oa.action_qualifier_cd,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[idx].action_type_cd)
			if (pos3 = 0);new order action
 
				a_cnt3 = size(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,5)
				a_cnt3 = a_cnt3 + 1
				stat = alterlist(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,a_cnt3)
 
				actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].action_type_cd = oa.action_qualifier_cd
				actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].action = orderAction
 
			else
				 ;if it does exist, use the index location
				 a_cnt3 = pos3
			endif
		endif
 
	elseif (oa.needs_verify_ind =3  )
			idx = 0
			pos3 = 0
			;find if action already added to action list
			pos3 = locateval(idx,1,size(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,5)
			,-1.00,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[idx].action_type_cd)
			if (pos3 = 0);new order action
 
				a_cnt3 = size(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,5)
				a_cnt3 = a_cnt3 + 1
				stat = alterlist(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,a_cnt3)
 
				actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].action_type_cd =-1.00
				actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].action = orderAction
 
			else
				 ;if it does exist, use the index location
				 a_cnt3 = pos3
			endif
 
 	elseif (oa.need_clin_review_flag=2  and ore.reviewed_status_flag=1  and ore.review_type_flag=5  )
			idx = 0
			pos3 = 0
			;find if action already added to action list
			pos3 = locateval(idx,1,size(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,5)
			,-3.00,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[idx].action_type_cd)
			if (pos3 = 0);new order action
 
				a_cnt3 = size(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,5)
				a_cnt3 = a_cnt3 + 1
				stat = alterlist(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,a_cnt3)
 
				actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].action_type_cd =-3.00
				actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].action = orderAction
 
			else
				 ;if it does exist, use the index location
				 a_cnt3 = pos3
			endif
	else
		idx = 0
		pos3 = 0
		;find if action already added to action list
		pos3 = locateval(idx,1,size(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,5)
		,oa.action_type_cd,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[idx].action_type_cd)
		if (pos3 = 0);new order action
 
			a_cnt3 = size(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,5)
			a_cnt3 = a_cnt3 + 1
			stat = alterlist(actionInfo->facility[facCnt].personnel[pharmCnt].actions2,a_cnt3)
 
			actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].action_type_cd = oa.action_type_cd
			actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].action = orderAction
 
		else
			 ;if it does exist, use the index location
			 a_cnt3 = pos3
		endif
	endif
 
 
 
	;facility action list
	if (oa.action_qualifier_cd >0 )
		if (o.protocol_order_id >0  and oa.action_qualifier_cd in (60300376.00,60300379.00 ,60300382.00))
			idx = 0
			pos = 0
			;find if action already added to action list
			pos = locateval(idx,1,size(actionInfo->facility[facCnt].actions,5)
			,oa.action_type_cd,actionInfo->facility[facCnt].actions[idx].action_type_cd)
			if (pos = 0);new order action
 
				a_cnt = size(actionInfo->facility[facCnt].actions,5)
				a_cnt = a_cnt + 1
				stat = alterlist(actionInfo->facility[facCnt].actions,a_cnt)
 
				actionInfo->facility[facCnt].actions[a_cnt].action_type_cd = oa.action_type_cd
				actionInfo->facility[facCnt].actions[a_cnt].action = orderAction
 
			else
				 ;if it does exist, use the index location
				 a_cnt = pos
			endif
		else
 
			idx = 0
			pos = 0
			;find if action already added to action list
			pos = locateval(idx,1,size(actionInfo->facility[facCnt].actions,5)
			,oa.action_qualifier_cd,actionInfo->facility[facCnt].actions[idx].action_type_cd)
			if (pos = 0);new order action
 
				a_cnt = size(actionInfo->facility[facCnt].actions,5)
				a_cnt = a_cnt + 1
				stat = alterlist(actionInfo->facility[facCnt].actions,a_cnt)
 
				actionInfo->facility[facCnt].actions[a_cnt].action_type_cd = oa.action_qualifier_cd
				actionInfo->facility[facCnt].actions[a_cnt].action = orderAction
 
			else
				 ;if it does exist, use the index location
				 a_cnt = pos
			endif
		endif
 
	elseif (oa.needs_verify_ind =3  )
			idx = 0
			pos = 0
			;find if action already added to action list
			pos = locateval(idx,1,size(actionInfo->facility[facCnt].actions,5)
			,-1.00,actionInfo->facility[facCnt].actions[idx].action_type_cd)
			if (pos = 0);new order action
 
				a_cnt = size(actionInfo->facility[facCnt].actions,5)
				a_cnt = a_cnt + 1
				stat = alterlist(actionInfo->facility[facCnt].actions,a_cnt)
 
				actionInfo->facility[facCnt].actions[a_cnt].action_type_cd =-1.00
				actionInfo->facility[facCnt].actions[a_cnt].action = orderAction
 
			else
				 ;if it does exist, use the index location
				 a_cnt = pos
			endif
 
 	elseif (oa.need_clin_review_flag=2  and ore.reviewed_status_flag=1  and ore.review_type_flag=5  )
			idx = 0
			pos = 0
			;find if action already added to action list
			pos = locateval(idx,1,size(actionInfo->facility[facCnt].actions,5)
			,-3.00,actionInfo->facility[facCnt].actions[idx].action_type_cd)
			if (pos = 0);new order action
 
				a_cnt = size(actionInfo->facility[facCnt].actions,5)
				a_cnt = a_cnt + 1
				stat = alterlist(actionInfo->facility[facCnt].actions,a_cnt)
 
				actionInfo->facility[facCnt].actions[a_cnt].action_type_cd =-3.00
				actionInfo->facility[facCnt].actions[a_cnt].action = orderAction
 
			else
				 ;if it does exist, use the index location
				 a_cnt = pos
			endif
	else
		idx = 0
		pos = 0
		;find if action already added to action list
		pos = locateval(idx,1,size(actionInfo->facility[facCnt].actions,5)
		,oa.action_type_cd,actionInfo->facility[facCnt].actions[idx].action_type_cd)
		if (pos = 0);new order action
 
			a_cnt = size(actionInfo->facility[facCnt].actions,5)
			a_cnt = a_cnt + 1
			stat = alterlist(actionInfo->facility[facCnt].actions,a_cnt)
 
			actionInfo->facility[facCnt].actions[a_cnt].action_type_cd = oa.action_type_cd
			actionInfo->facility[facCnt].actions[a_cnt].action = orderAction
 
		else
			 ;if it does exist, use the index location
			 a_cnt = pos
		endif
	endif
 
 
	;all action list
	if (oa.action_qualifier_cd >0 )
		if (o.protocol_order_id >0  and oa.action_qualifier_cd in (60300376.00,60300379.00 ,60300382.00))
			idx = 0
			pos2 = 0
			;find if action already added to action list
			pos2 = locateval(idx,1,size(actionInfo->actions,5)
			,oa.action_type_cd,actionInfo->actions[idx].action_type_cd)
			if (pos2 = 0);new order action
 
				a_cnt2 = size(actionInfo->actions,5)
				a_cnt2 = a_cnt2 + 1
				stat = alterlist(actionInfo->actions,a_cnt2)
 
				actionInfo->actions[a_cnt2].action_type_cd = oa.action_type_cd
				actionInfo->actions[a_cnt2].action = orderAction
 
			else
				 ;if it does exist, use the index location
				 a_cnt2 = pos2
			endif
		else
 
			idx = 0
			pos2 = 0
			;find if action already added to action list
			pos2 = locateval(idx,1,size(actionInfo->actions,5)
			,oa.action_qualifier_cd,actionInfo->actions[idx].action_type_cd)
			if (pos2 = 0);new order action
 
				a_cnt2 = size(actionInfo->actions,5)
				a_cnt2 = a_cnt2 + 1
				stat = alterlist(actionInfo->actions,a_cnt2)
 
				actionInfo->actions[a_cnt2].action_type_cd = oa.action_qualifier_cd
				actionInfo->actions[a_cnt2].action = orderAction
 
			else
				 ;if it does exist, use the index location
				 a_cnt2 = pos2
			endif
		endif
 
	elseif (oa.needs_verify_ind =3  )
			idx = 0
			pos2 = 0
			;find if action already added to action list
			pos2 = locateval(idx,1,size(actionInfo->actions,5)
			,-1.00,actionInfo->actions[idx].action_type_cd)
			if (pos2 = 0);new order action
 
				a_cnt2 = size(actionInfo->actions,5)
				a_cnt2 = a_cnt2 + 1
				stat = alterlist(actionInfo->actions,a_cnt2)
 
				actionInfo->actions[a_cnt2].action_type_cd =-1.00
				actionInfo->actions[a_cnt2].action = orderAction
 
			else
				 ;if it does exist, use the index location
				 a_cnt2 = pos2
			endif
 
 	elseif (oa.need_clin_review_flag=2  and ore.reviewed_status_flag=1  and ore.review_type_flag=5  )
			idx = 0
			pos2 = 0
			;find if action already added to action list
			pos2 = locateval(idx,1,size(actionInfo->actions,5)
			,-3.00,actionInfo->actions[idx].action_type_cd)
			if (pos2 = 0);new order action
 
				a_cnt2 = size(actionInfo->actions,5)
				a_cnt2 = a_cnt2 + 1
				stat = alterlist(actionInfo->actions,a_cnt2)
 
				actionInfo->actions[a_cnt2].action_type_cd =-3.00
				actionInfo->actions[a_cnt2].action = orderAction
 
			else
				 ;if it does exist, use the index location
				 a_cnt2 = pos2
			endif
	else
		idx = 0
		pos2 = 0
		;find if action already added to action list
		pos2 = locateval(idx,1,size(actionInfo->actions,5)
		,oa.action_type_cd,actionInfo->actions[idx].action_type_cd)
		if (pos2 = 0);new order action
 
			a_cnt2 = size(actionInfo->actions,5)
			a_cnt2= a_cnt2 + 1
			stat = alterlist(actionInfo->actions,a_cnt2)
 
			actionInfo->actions[a_cnt2].action_type_cd = oa.action_type_cd
			actionInfo->actions[a_cnt2].action = orderAction
 
		else
			 ;if it does exist, use the index location
			 a_cnt2 = pos2
		endif
	endif
 
	;only inc rows for action after one row added
	if(actionRowCnt = 1)
 
		outputDisplay->row[rowCnt].colB = orderAction
 		outputDisplay->row[rowCnt].colA = pharmacistName
 		;outputDisplay->row[rowCnt].colAC = facility
		outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"B")
 
	else
		rowCnt = rowCnt + 1
		stat = alterlist(outputDisplay->row,rowCnt)
 
		outputDisplay->row[rowCnt].colB = orderAction
 		;outputDisplay->row[rowCnt].colA = pharmacistName
 		;outputDisplay->row[rowCnt].colAC = facility
		outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"B")
 
 
	endif
 
 
 	hr1Total = 0
 	hr2Total = 0
 	hr3Total = 0
 	hr4Total = 0
 	hr5Total = 0
 	hr6Total = 0
 	hr7Total = 0
 	hr8Total = 0
 	hr9Total = 0
 	hr10Total = 0
 	hr11Total = 0
 	hr12Total = 0
 	hr13Total = 0
 	hr14Total = 0
 	hr15Total = 0
 	hr16Total = 0
 	hr17Total = 0
 	hr18Total = 0
 	hr19Total = 0
 	hr20Total = 0
 	hr21Total = 0
 	hr22Total = 0
 	hr23Total = 0
 	hr24Total = 0
head oa.order_id
	actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].order_id = oa.order_id
 
head oa.action_sequence
 
 	actionCnt = actionCnt + 1
 	personOrderActionCnt = personOrderActionCnt + 1
 	facilityActionCnt = facilityActionCnt + 1
 	prsnlActionCnt = prsnlActionCnt + 1
 	totalActionCnt = totalActionCnt + 1
 
 	actionInfo->actionCnt = actionInfo->actionCnt + 1
 
 
 	actionInfo->facility[facCnt].actionCnt = actionInfo->facility[facCnt].actionCnt + 1
 	actionInfo->facility[facCnt].actions[a_cnt].actionCnt = actionInfo->facility[facCnt].actions[a_cnt].actionCnt + 1
 	actionInfo->actions[a_cnt2].actionCnt = actionInfo->actions[a_cnt2].actionCnt + 1
 	actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].actionCnt =  actionInfo->facility[facCnt].personnel[pharmCnt
 	].actions2[a_cnt3].actionCnt  + 1
 
 	actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].action_seq = oa.action_sequence
 	actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hrInterval =  hrInterval
 	actionInfo->facility[facCnt].personnel[pharmCnt].actionCnt = actionInfo->facility[facCnt].personnel[pharmCnt].actionCnt +1
 
 	case(hrInterval)
 		of 	"00":hr1Total = hr1Total + 1,fachr1Total = fachr1Total + 1,prsnlhr1Total = prsnlhr1Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[1].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[1].hrItrv + 1,actionInfo->actions[a_cnt2].hr[1].hrItrv = actionInfo->actions[a_cnt2].hr[1].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[1].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[1].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[1].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[1].hrItrv + 1,actionInfo->facility[facCnt].hr[1].hrItrv = actionInfo->facility[facCnt
 			].hr[1].hrItrv + 1,actionInfo->hr[1].hrItrv = actionInfo->hr[1].hrItrv + 1
 
 		of 	"01":hr2Total = hr2Total + 1,fachr2Total = fachr2Total + 1,prsnlhr2Total = prsnlhr2Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[2].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[2].hrItrv + 1,actionInfo->actions[a_cnt2].hr[2].hrItrv = actionInfo->actions[a_cnt2].hr[2].hrItrv +1
  			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[2].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[2].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[2].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[2].hrItrv + 1,actionInfo->facility[facCnt].hr[2].hrItrv = actionInfo->facility[facCnt
 			].hr[2].hrItrv + 1,actionInfo->hr[2].hrItrv = actionInfo->hr[2].hrItrv + 1
 
 
 		of 	"02":hr3Total = hr3Total + 1,fachr3Total = fachr3Total + 1,prsnlhr3Total = prsnlhr3Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[3].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[3].hrItrv + 1,actionInfo->actions[a_cnt2].hr[3].hrItrv = actionInfo->actions[a_cnt2].hr[3].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[3].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[3].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[3].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[3].hrItrv + 1,actionInfo->facility[facCnt].hr[3].hrItrv = actionInfo->facility[facCnt
 			].hr[3].hrItrv + 1,actionInfo->hr[3].hrItrv = actionInfo->hr[3].hrItrv + 1
 
 
 		of 	"03":hr4Total = hr4Total + 1,fachr4Total = fachr4Total + 1,prsnlhr4Total = prsnlhr4Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[4].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[4].hrItrv + 1,actionInfo->actions[a_cnt2].hr[4].hrItrv = actionInfo->actions[a_cnt2].hr[4].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[4].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[4].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[4].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[4].hrItrv + 1,actionInfo->facility[facCnt].hr[4].hrItrv = actionInfo->facility[facCnt
 			].hr[4].hrItrv + 1,actionInfo->hr[4].hrItrv = actionInfo->hr[4].hrItrv + 1
 
 
 		of 	"04":hr5Total = hr5Total + 1,fachr5Total = fachr5Total + 1,prsnlhr5Total = prsnlhr5Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[5].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[5].hrItrv + 1,actionInfo->actions[a_cnt2].hr[5].hrItrv = actionInfo->actions[a_cnt2].hr[5].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[5].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[5].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[5].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[5].hrItrv + 1,actionInfo->facility[facCnt].hr[5].hrItrv = actionInfo->facility[facCnt
 			].hr[5].hrItrv + 1,actionInfo->hr[5].hrItrv = actionInfo->hr[5].hrItrv + 1
 
 
 		of 	"05":hr6Total = hr6Total + 1,fachr6Total = fachr6Total + 1,prsnlhr6Total = prsnlhr6Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[6].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[6].hrItrv + 1,actionInfo->actions[a_cnt2].hr[6].hrItrv = actionInfo->actions[a_cnt2].hr[6].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[6].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[6].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[6].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[6].hrItrv + 1,actionInfo->facility[facCnt].hr[6].hrItrv = actionInfo->facility[facCnt
 			].hr[6].hrItrv + 1,actionInfo->hr[6].hrItrv = actionInfo->hr[6].hrItrv + 1
 
 
 		of 	"06":hr7Total = hr7Total + 1,fachr7Total = fachr7Total + 1,prsnlhr7Total = prsnlhr7Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[7].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[7].hrItrv + 1,actionInfo->actions[a_cnt2].hr[7].hrItrv = actionInfo->actions[a_cnt2].hr[7].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[7].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[7].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[7].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[7].hrItrv + 1,actionInfo->facility[facCnt].hr[7].hrItrv = actionInfo->facility[facCnt
 			].hr[7].hrItrv + 1,actionInfo->hr[7].hrItrv = actionInfo->hr[7].hrItrv + 1
 
 
 		of 	"07":hr8Total = hr8Total + 1,fachr8Total = fachr8Total + 1,prsnlhr8Total = prsnlhr8Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[8].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[8].hrItrv + 1,actionInfo->actions[a_cnt2].hr[8].hrItrv = actionInfo->actions[a_cnt2].hr[8].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[8].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[8].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[8].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[8].hrItrv + 1,actionInfo->facility[facCnt].hr[8].hrItrv = actionInfo->facility[facCnt
 			].hr[8].hrItrv + 1,actionInfo->hr[8].hrItrv = actionInfo->hr[8].hrItrv + 1
 
 
 		of 	"08":hr9Total = hr9Total + 1,fachr9Total = fachr9Total + 1,prsnlhr9Total = prsnlhr9Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[9].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[9].hrItrv + 1,actionInfo->actions[a_cnt2].hr[9].hrItrv = actionInfo->actions[a_cnt2].hr[9].hrItrv +1
  			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[9].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[9].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[9].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[9].hrItrv + 1,actionInfo->facility[facCnt].hr[9].hrItrv = actionInfo->facility[facCnt
 			].hr[9].hrItrv + 1,actionInfo->hr[9].hrItrv = actionInfo->hr[9].hrItrv + 1
 
 
 		of 	"09":hr10Total = hr10Total + 1,fachr10Total = fachr10Total + 1,prsnlhr10Total = prsnlhr10Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[10].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[10].hrItrv + 1,actionInfo->actions[a_cnt2].hr[10].hrItrv = actionInfo->actions[a_cnt2].hr[10].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[10].hrItrv =
 			actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[10].hrItrv + 1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].hr[10].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[10].hrItrv + 1,actionInfo->facility[facCnt].hr[10].hrItrv = actionInfo->facility[facCnt
 			].hr[10].hrItrv + 1,actionInfo->hr[10].hrItrv = actionInfo->hr[10].hrItrv + 1
 
 
 		of 	"10":hr11Total = hr11Total + 1,fachr11Total = fachr11Total + 1,prsnlhr11Total = prsnlhr11Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[11].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[11].hrItrv + 1,actionInfo->actions[a_cnt2].hr[11].hrItrv = actionInfo->actions[a_cnt2].hr[11].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[11].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[11].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[11].hrItrv=
 			actionInfo->facility[facCnt].personnel[pharmCnt].hr[11].hrItrv + 1,actionInfo->facility[facCnt].hr[11].hrItrv = actionInfo->facility[facCnt
 			].hr[11].hrItrv + 1,actionInfo->hr[11].hrItrv = actionInfo->hr[11].hrItrv + 1
 
 
 		of 	"11":hr12Total = hr12Total + 1,fachr12Total = fachr12Total + 1,prsnlhr12Total = prsnlhr12Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[12].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[12].hrItrv + 1,actionInfo->actions[a_cnt2].hr[12].hrItrv = actionInfo->actions[a_cnt2].hr[12].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[12].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[12].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[12].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[12].hrItrv + 1,actionInfo->facility[facCnt].hr[12].hrItrv = actionInfo->facility[facCnt
 			].hr[12].hrItrv + 1,actionInfo->hr[12].hrItrv = actionInfo->hr[12].hrItrv + 1
 
 
 		of 	"12":hr13Total = hr13Total + 1,fachr13Total = fachr13Total + 1,prsnlhr13Total = prsnlhr13Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[13].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[13].hrItrv + 1,actionInfo->actions[a_cnt2].hr[13].hrItrv = actionInfo->actions[a_cnt2].hr[13].hrItrv +1
  			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[13].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[13].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[13].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[13].hrItrv + 1,actionInfo->facility[facCnt].hr[13].hrItrv = actionInfo->facility[facCnt
 			].hr[13].hrItrv + 1,actionInfo->hr[13].hrItrv = actionInfo->hr[13].hrItrv + 1
 
 
 		of 	"13":hr14Total = hr14Total + 1,fachr14Total = fachr14Total + 1,prsnlhr14Total = prsnlhr14Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[14].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[14].hrItrv + 1,actionInfo->actions[a_cnt2].hr[14].hrItrv = actionInfo->actions[a_cnt2].hr[14].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[14].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[14].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[14].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[14].hrItrv + 1,actionInfo->facility[facCnt].hr[14].hrItrv = actionInfo->facility[facCnt
 			].hr[14].hrItrv + 1,actionInfo->hr[14].hrItrv = actionInfo->hr[14].hrItrv + 1
 
 
 		of 	"14":hr15Total = hr15Total + 1,fachr15Total = fachr15Total + 1,prsnlhr15Total = prsnlhr15Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[15].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[15].hrItrv + 1,actionInfo->actions[a_cnt2].hr[15].hrItrv = actionInfo->actions[a_cnt2].hr[15].hrItrv +1
  			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[15].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[15].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[15].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[15].hrItrv + 1,actionInfo->facility[facCnt].hr[15].hrItrv = actionInfo->facility[facCnt
 			].hr[15].hrItrv + 1,actionInfo->hr[15].hrItrv = actionInfo->hr[15].hrItrv + 1
 
 
 		of 	"15":hr16Total = hr16Total + 1,fachr16Total = fachr16Total + 1,prsnlhr16Total = prsnlhr16Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[16].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[16].hrItrv + 1,actionInfo->actions[a_cnt2].hr[16].hrItrv = actionInfo->actions[a_cnt2].hr[16].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[16].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[16].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[16].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[16].hrItrv + 1,actionInfo->facility[facCnt].hr[16].hrItrv = actionInfo->facility[facCnt
 			].hr[16].hrItrv + 1,actionInfo->hr[16].hrItrv = actionInfo->hr[16].hrItrv + 1
 
 
 		of 	"16":hr17Total = hr17Total + 1,fachr17Total = fachr17Total + 1,prsnlhr17Total = prsnlhr17Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[17].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[17].hrItrv + 1,actionInfo->actions[a_cnt2].hr[17].hrItrv = actionInfo->actions[a_cnt2].hr[17].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[17].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[17].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[17].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[17].hrItrv + 1,actionInfo->facility[facCnt].hr[17].hrItrv = actionInfo->facility[facCnt
 			].hr[17].hrItrv + 1,actionInfo->hr[17].hrItrv = actionInfo->hr[17].hrItrv + 1
 
 
 		of 	"17":hr18Total = hr18Total + 1,fachr18Total = fachr18Total + 1,prsnlhr18Total = prsnlhr18Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[18].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[18].hrItrv + 1,actionInfo->actions[a_cnt2].hr[18].hrItrv = actionInfo->actions[a_cnt2].hr[18].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[18].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[18].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[18].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[18].hrItrv + 1,actionInfo->facility[facCnt].hr[18].hrItrv = actionInfo->facility[facCnt
 			].hr[18].hrItrv + 1,actionInfo->hr[18].hrItrv = actionInfo->hr[18].hrItrv + 1
 
 
 		of 	"18":hr19Total = hr19Total + 1,fachr19Total = fachr19Total + 1,prsnlhr19Total = prsnlhr19Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[19].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[19].hrItrv + 1,actionInfo->actions[a_cnt2].hr[19].hrItrv = actionInfo->actions[a_cnt2].hr[19].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[19].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[19].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[19].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[19].hrItrv + 1,actionInfo->facility[facCnt].hr[19].hrItrv = actionInfo->facility[facCnt
 			].hr[19].hrItrv + 1,actionInfo->hr[19].hrItrv = actionInfo->hr[19].hrItrv + 1
 
 
 		of 	"19":hr20Total = hr20Total + 1,fachr20Total = fachr20Total + 1,prsnlhr20Total = prsnlhr20Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[20].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[20].hrItrv + 1,actionInfo->actions[a_cnt2].hr[20].hrItrv = actionInfo->actions[a_cnt2].hr[20].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[20].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[20].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[20].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[20].hrItrv + 1,actionInfo->facility[facCnt].hr[20].hrItrv = actionInfo->facility[facCnt
 			].hr[20].hrItrv + 1,actionInfo->hr[20].hrItrv = actionInfo->hr[20].hrItrv + 1
 
 
 		of 	"20":hr21Total = hr21Total + 1,fachr21Total = fachr21Total + 1,prsnlhr21Total = prsnlhr21Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[21].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[21].hrItrv + 1,actionInfo->actions[a_cnt2].hr[21].hrItrv = actionInfo->actions[a_cnt2].hr[21].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[21].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[21].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[21].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[21].hrItrv + 1,actionInfo->facility[facCnt].hr[21].hrItrv = actionInfo->facility[facCnt
 			].hr[21].hrItrv + 1,actionInfo->hr[21].hrItrv = actionInfo->hr[21].hrItrv + 1
 
 
 		of 	"21":hr22Total = hr22Total + 1,fachr22Total = fachr22Total + 1,prsnlhr22Total = prsnlhr22Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[22].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[22].hrItrv + 1,actionInfo->actions[a_cnt2].hr[22].hrItrv = actionInfo->actions[a_cnt2].hr[22].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[22].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[22].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[22].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[22].hrItrv + 1,actionInfo->facility[facCnt].hr[22].hrItrv = actionInfo->facility[facCnt
 			].hr[22].hrItrv + 1,actionInfo->hr[22].hrItrv = actionInfo->hr[22].hrItrv + 1
 
 
 
 		of 	"22":hr23Total = hr23Total + 1,fachr23Total = fachr23Total + 1,prsnlhr23Total = prsnlhr23Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[23].hrItrv = actionInfo->facility[facCnt].actions[
 			a_cnt].hr[23].hrItrv + 1,actionInfo->actions[a_cnt2].hr[23].hrItrv = actionInfo->actions[a_cnt2].hr[23].hrItrv +1
 			,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[23].hrItrv = actionInfo->facility[facCnt].personnel[
 			pharmCnt].actions2[a_cnt3].hr[23].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[23].hrItrv=actionInfo->facility[
 			facCnt].personnel[pharmCnt].hr[23].hrItrv + 1,actionInfo->facility[facCnt].hr[23].hrItrv = actionInfo->facility[facCnt
 			].hr[23].hrItrv + 1,actionInfo->hr[23].hrItrv = actionInfo->hr[23].hrItrv + 1
 
 
 		of 	"23":hr24Total = hr24Total + 1,fachr24Total = fachr24Total + 1,prsnlhr24Total = prsnlhr24Total + 1
 			,actionInfo->facility[facCnt].actions[a_cnt].hr[24].hrItrv = actionInfo->facility[facCnt].actions[a_cnt].hr[24].hrItrv
 			 + 1,actionInfo->actions[a_cnt2].hr[24].hrItrv = actionInfo->actions[a_cnt2].hr[24].hrItrv +1
,actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[24].hrItrv = actionInfo->facility[facCnt].personnel[pharmCnt].actions2[a_cnt3].hr[24].hrItrv + 1,actionInfo->facility[facCnt].personnel[pharmCnt].hr[24].hrItrv=actionInfo->facility[facCnt].personnel[pharmCnt].hr[24].hrItrv + 1,actionInfo->facility[facCnt].hr[24].hrItrv = actionInfo->facility[facCnt].hr[24].hrItrv + 1,actionInfo->hr[24].hrItrv = actionInfo->hr[24].hrItrv + 1
 
 
 	endcase
 
 
 
 
 	stat = alterlist(actionInfo->facility[facCnt].personnel[pharmCnt].actions,actionCnt)
 	actionInfo->facility[facCnt].personnel[pharmCnt].actions[actionCnt].unit = uar_get_code_display(elh.loc_nurse_unit_cd)
	actionInfo->facility[facCnt].personnel[pharmCnt].actions[actionCnt].facility = uar_get_code_display(elh.loc_facility_cd)
 	actionInfo->facility[facCnt].personnel[pharmCnt].actions[actionCnt].action = orderAction
 	actionInfo->facility[facCnt].personnel[pharmCnt].actions[actionCnt].actionDt = actionDt
 	actionInfo->facility[facCnt].personnel[pharmCnt].actions[actionCnt].orderId = o.order_id
 	actionInfo->facility[facCnt].personnel[pharmCnt].actions[actionCnt].actionTm = actionTm
    actionInfo->facility[facCnt].personnel[pharmCnt].actions[actionCnt].orderName = uar_get_code_display(o.catalog_cd)
 
foot orderAction
	outputDisplay->row[rowCnt].colC = cnvtstring(hr1Total)
	outputDisplay->row[rowCnt].colD = cnvtstring(hr2Total)
	outputDisplay->row[rowCnt].colE = cnvtstring(hr3Total)
	outputDisplay->row[rowCnt].colF = cnvtstring(hr4Total)
	outputDisplay->row[rowCnt].colG = cnvtstring(hr5Total)
	outputDisplay->row[rowCnt].colH = cnvtstring(hr6Total)
	outputDisplay->row[rowCnt].colI = cnvtstring(hr7Total)
	outputDisplay->row[rowCnt].colJ = cnvtstring(hr8Total)
	outputDisplay->row[rowCnt].colK = cnvtstring(hr9Total)
	outputDisplay->row[rowCnt].colL = cnvtstring(hr10Total)
	outputDisplay->row[rowCnt].colM = cnvtstring(hr11Total)
	outputDisplay->row[rowCnt].colN = cnvtstring(hr12Total)
	outputDisplay->row[rowCnt].colO = cnvtstring(hr13Total)
	outputDisplay->row[rowCnt].colP = cnvtstring(hr14Total)
	outputDisplay->row[rowCnt].colQ = cnvtstring(hr15Total)
	outputDisplay->row[rowCnt].colR = cnvtstring(hr16Total)
	outputDisplay->row[rowCnt].colS = cnvtstring(hr17Total)
	outputDisplay->row[rowCnt].colT = cnvtstring(hr18Total)
	outputDisplay->row[rowCnt].colU = cnvtstring(hr19Total)
	outputDisplay->row[rowCnt].colV = cnvtstring(hr20Total)
	outputDisplay->row[rowCnt].colW = cnvtstring(hr21Total)
	outputDisplay->row[rowCnt].colX = cnvtstring(hr22Total)
	outputDisplay->row[rowCnt].colY = cnvtstring(hr23Total)
	outputDisplay->row[rowCnt].colZ = cnvtstring(hr24Total)
	outputDisplay->row[rowCnt].colAA = cnvtstring(personOrderActionCnt)
 
foot p.person_id
	rowCnt = rowCnt + 1
	stat = alterlist(outputDisplay->row,rowCnt)
 
	outputDisplay->row[rowCnt].colB = build2(trim(pharmacistName,3)," TOTAL ACTIONS:")
 
	outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"C")
 
 
	outputDisplay->row[rowCnt].colC = cnvtstring(prsnlhr1Total)
	outputDisplay->row[rowCnt].colD = cnvtstring(prsnlhr2Total)
	outputDisplay->row[rowCnt].colE = cnvtstring(prsnlhr3Total)
	outputDisplay->row[rowCnt].colF = cnvtstring(prsnlhr4Total)
	outputDisplay->row[rowCnt].colG = cnvtstring(prsnlhr5Total)
	outputDisplay->row[rowCnt].colH = cnvtstring(prsnlhr6Total)
	outputDisplay->row[rowCnt].colI = cnvtstring(prsnlhr7Total)
	outputDisplay->row[rowCnt].colJ = cnvtstring(prsnlhr8Total)
	outputDisplay->row[rowCnt].colK = cnvtstring(prsnlhr9Total)
	outputDisplay->row[rowCnt].colL = cnvtstring(prsnlhr10Total)
	outputDisplay->row[rowCnt].colM = cnvtstring(prsnlhr11Total)
	outputDisplay->row[rowCnt].colN = cnvtstring(prsnlhr12Total)
	outputDisplay->row[rowCnt].colO = cnvtstring(prsnlhr13Total)
	outputDisplay->row[rowCnt].colP = cnvtstring(prsnlhr14Total)
	outputDisplay->row[rowCnt].colQ = cnvtstring(prsnlhr15Total)
	outputDisplay->row[rowCnt].colR = cnvtstring(prsnlhr16Total)
	outputDisplay->row[rowCnt].colS = cnvtstring(prsnlhr17Total)
	outputDisplay->row[rowCnt].colT = cnvtstring(prsnlhr18Total)
	outputDisplay->row[rowCnt].colU = cnvtstring(prsnlhr19Total)
	outputDisplay->row[rowCnt].colV = cnvtstring(prsnlhr20Total)
	outputDisplay->row[rowCnt].colW = cnvtstring(prsnlhr21Total)
	outputDisplay->row[rowCnt].colX = cnvtstring(prsnlhr22Total)
	outputDisplay->row[rowCnt].colY = cnvtstring(prsnlhr23Total)
	outputDisplay->row[rowCnt].colZ = cnvtstring(prsnlhr24Total)
	outputDisplay->row[rowCnt].colAA = cnvtstring(prsnlActionCnt)
 
 	;add blank row after facility totals
	rowCnt = rowCnt + 1
	stat = alterlist(outputDisplay->row,rowCnt)
	outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"G")
 
 
foot facility
 
	;add blank row after personnel totals
	rowCnt = rowCnt + 1
	stat = alterlist(outputDisplay->row,rowCnt)
	outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"D")
 
	rowCnt = rowCnt + 1
	stat = alterlist(outputDisplay->row,rowCnt)
 
 
	outputDisplay->row[rowCnt].colAC = build2(trim(facility,3)," ACTIONS:")
 
 
	actionsize = size(actionInfo->facility[facCnt].actions,5)
 
	for(idx=1 to actionsize)
		if(idx = 1)
			outputDisplay->row[rowCnt].colB = actionInfo->facility[facCnt].actions[idx].action
 
			outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"E")
 
			outputDisplay->row[rowCnt].colC = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[1].hrItrv)
			outputDisplay->row[rowCnt].colD = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[2].hrItrv)
			outputDisplay->row[rowCnt].colE = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[3].hrItrv)
			outputDisplay->row[rowCnt].colF = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[4].hrItrv)
			outputDisplay->row[rowCnt].colG = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[5].hrItrv)
			outputDisplay->row[rowCnt].colH = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[6].hrItrv)
			outputDisplay->row[rowCnt].colI = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[7].hrItrv)
			outputDisplay->row[rowCnt].colJ = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[8].hrItrv)
			outputDisplay->row[rowCnt].colK = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[9].hrItrv)
			outputDisplay->row[rowCnt].colL = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[10].hrItrv)
			outputDisplay->row[rowCnt].colM = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[11].hrItrv)
			outputDisplay->row[rowCnt].colN = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[12].hrItrv)
			outputDisplay->row[rowCnt].colO = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[13].hrItrv)
			outputDisplay->row[rowCnt].colP = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[14].hrItrv)
			outputDisplay->row[rowCnt].colQ = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[15].hrItrv)
			outputDisplay->row[rowCnt].colR = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[16].hrItrv)
			outputDisplay->row[rowCnt].colS = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[17].hrItrv)
			outputDisplay->row[rowCnt].colT = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[18].hrItrv)
			outputDisplay->row[rowCnt].colU = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[19].hrItrv)
			outputDisplay->row[rowCnt].colV = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[20].hrItrv)
			outputDisplay->row[rowCnt].colW = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[21].hrItrv)
			outputDisplay->row[rowCnt].colX = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[22].hrItrv)
			outputDisplay->row[rowCnt].colY = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[23].hrItrv)
			outputDisplay->row[rowCnt].colZ = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[24].hrItrv)
			outputDisplay->row[rowCnt].colAA = cnvtstring(actionInfo->facility[facCnt].actions[idx].actionCnt)
		else
			rowCnt = rowCnt + 1
			stat = alterlist(outputDisplay->row,rowCnt)
 
			outputDisplay->row[rowCnt].colB = actionInfo->facility[facCnt].actions[idx].action
			outputDisplay->row[rowCnt].colC = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[1].hrItrv)
			outputDisplay->row[rowCnt].colD = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[2].hrItrv)
			outputDisplay->row[rowCnt].colE = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[3].hrItrv)
			outputDisplay->row[rowCnt].colF = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[4].hrItrv)
			outputDisplay->row[rowCnt].colG = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[5].hrItrv)
			outputDisplay->row[rowCnt].colH = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[6].hrItrv)
			outputDisplay->row[rowCnt].colI = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[7].hrItrv)
			outputDisplay->row[rowCnt].colJ = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[8].hrItrv)
			outputDisplay->row[rowCnt].colK = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[9].hrItrv)
			outputDisplay->row[rowCnt].colL = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[10].hrItrv)
			outputDisplay->row[rowCnt].colM = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[11].hrItrv)
			outputDisplay->row[rowCnt].colN = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[12].hrItrv)
			outputDisplay->row[rowCnt].colO = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[13].hrItrv)
			outputDisplay->row[rowCnt].colP = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[14].hrItrv)
			outputDisplay->row[rowCnt].colQ = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[15].hrItrv)
			outputDisplay->row[rowCnt].colR = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[16].hrItrv)
			outputDisplay->row[rowCnt].colS = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[17].hrItrv)
			outputDisplay->row[rowCnt].colT = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[18].hrItrv)
			outputDisplay->row[rowCnt].colU = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[19].hrItrv)
			outputDisplay->row[rowCnt].colV = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[20].hrItrv)
			outputDisplay->row[rowCnt].colW = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[21].hrItrv)
			outputDisplay->row[rowCnt].colX = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[22].hrItrv)
			outputDisplay->row[rowCnt].colY = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[23].hrItrv)
			outputDisplay->row[rowCnt].colZ = cnvtstring(actionInfo->facility[facCnt].actions[idx].hr[24].hrItrv)
	 		outputDisplay->row[rowCnt].colAA = cnvtstring(actionInfo->facility[facCnt].actions[idx].actionCnt)
 
			outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"E")
 
		endif
	endfor
 
 
 
	;add blank row after facility totals
	rowCnt = rowCnt + 1
	stat = alterlist(outputDisplay->row,rowCnt)
 
 
	outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"F")
 	outputDisplay->row[rowCnt].colB = build2(trim(facility,3)," TOTAL ACTIONS:")
 
	outputDisplay->row[rowCnt].colC = cnvtstring(fachr1Total)
	outputDisplay->row[rowCnt].colD = cnvtstring(fachr2Total)
	outputDisplay->row[rowCnt].colE = cnvtstring(fachr3Total)
	outputDisplay->row[rowCnt].colF = cnvtstring(fachr4Total)
	outputDisplay->row[rowCnt].colG = cnvtstring(fachr5Total)
	outputDisplay->row[rowCnt].colH = cnvtstring(fachr6Total)
	outputDisplay->row[rowCnt].colI = cnvtstring(fachr7Total)
	outputDisplay->row[rowCnt].colJ = cnvtstring(fachr8Total)
	outputDisplay->row[rowCnt].colK = cnvtstring(fachr9Total)
	outputDisplay->row[rowCnt].colL = cnvtstring(fachr10Total)
	outputDisplay->row[rowCnt].colM = cnvtstring(fachr11Total)
	outputDisplay->row[rowCnt].colN = cnvtstring(fachr12Total)
	outputDisplay->row[rowCnt].colO = cnvtstring(fachr13Total)
	outputDisplay->row[rowCnt].colP = cnvtstring(fachr14Total)
	outputDisplay->row[rowCnt].colQ = cnvtstring(fachr15Total)
	outputDisplay->row[rowCnt].colR = cnvtstring(fachr16Total)
	outputDisplay->row[rowCnt].colS = cnvtstring(fachr17Total)
	outputDisplay->row[rowCnt].colT = cnvtstring(fachr18Total)
	outputDisplay->row[rowCnt].colU = cnvtstring(fachr19Total)
	outputDisplay->row[rowCnt].colV = cnvtstring(fachr20Total)
	outputDisplay->row[rowCnt].colW = cnvtstring(fachr21Total)
	outputDisplay->row[rowCnt].colX = cnvtstring(fachr22Total)
	outputDisplay->row[rowCnt].colY = cnvtstring(fachr23Total)
	outputDisplay->row[rowCnt].colZ = cnvtstring(fachr24Total)
	outputDisplay->row[rowCnt].colAA = cnvtstring(facilityActionCnt)
 
 
	;add blank row after facility totals
	rowCnt = rowCnt + 1
	stat = alterlist(outputDisplay->row,rowCnt)
	outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"G")
 
foot report
	;only show all facilities dada if more than one facility has been selected.
 
	if(size(actionInfo->facility,5)>1)
		;add blank row after facility totals
		rowCnt = rowCnt + 1
		stat = alterlist(outputDisplay->row,rowCnt)
		outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"H")
 
		;add blank row after facility totals
		rowCnt = rowCnt + 1
		stat = alterlist(outputDisplay->row,rowCnt)
		outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"I")
 
		totalActionsize = size(actionInfo->actions,5)
 
	 	outputDisplay->row[rowCnt].colAC = "ALL FACILITIES TOTAL ACTIONS:"
 
		for(idx=1 to totalActionsize)
			if(idx = 1)
				outputDisplay->row[rowCnt].colB = actionInfo->actions[idx].action
 
				outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"J")
 
				outputDisplay->row[rowCnt].colC = cnvtstring(actionInfo->actions[idx].hr[1].hrItrv)
				outputDisplay->row[rowCnt].colD = cnvtstring(actionInfo->actions[idx].hr[2].hrItrv)
				outputDisplay->row[rowCnt].colE = cnvtstring(actionInfo->actions[idx].hr[3].hrItrv)
				outputDisplay->row[rowCnt].colF = cnvtstring(actionInfo->actions[idx].hr[4].hrItrv)
				outputDisplay->row[rowCnt].colG = cnvtstring(actionInfo->actions[idx].hr[5].hrItrv)
				outputDisplay->row[rowCnt].colH = cnvtstring(actionInfo->actions[idx].hr[6].hrItrv)
				outputDisplay->row[rowCnt].colI = cnvtstring(actionInfo->actions[idx].hr[7].hrItrv)
				outputDisplay->row[rowCnt].colJ = cnvtstring(actionInfo->actions[idx].hr[8].hrItrv)
				outputDisplay->row[rowCnt].colK = cnvtstring(actionInfo->actions[idx].hr[9].hrItrv)
				outputDisplay->row[rowCnt].colL = cnvtstring(actionInfo->actions[idx].hr[10].hrItrv)
				outputDisplay->row[rowCnt].colM = cnvtstring(actionInfo->actions[idx].hr[11].hrItrv)
				outputDisplay->row[rowCnt].colN = cnvtstring(actionInfo->actions[idx].hr[12].hrItrv)
				outputDisplay->row[rowCnt].colO = cnvtstring(actionInfo->actions[idx].hr[13].hrItrv)
				outputDisplay->row[rowCnt].colP = cnvtstring(actionInfo->actions[idx].hr[14].hrItrv)
				outputDisplay->row[rowCnt].colQ = cnvtstring(actionInfo->actions[idx].hr[15].hrItrv)
				outputDisplay->row[rowCnt].colR = cnvtstring(actionInfo->actions[idx].hr[16].hrItrv)
				outputDisplay->row[rowCnt].colS = cnvtstring(actionInfo->actions[idx].hr[17].hrItrv)
				outputDisplay->row[rowCnt].colT = cnvtstring(actionInfo->actions[idx].hr[18].hrItrv)
				outputDisplay->row[rowCnt].colU = cnvtstring(actionInfo->actions[idx].hr[19].hrItrv)
				outputDisplay->row[rowCnt].colV = cnvtstring(actionInfo->actions[idx].hr[20].hrItrv)
				outputDisplay->row[rowCnt].colW = cnvtstring(actionInfo->actions[idx].hr[21].hrItrv)
				outputDisplay->row[rowCnt].colX = cnvtstring(actionInfo->actions[idx].hr[22].hrItrv)
				outputDisplay->row[rowCnt].colY = cnvtstring(actionInfo->actions[idx].hr[23].hrItrv)
				outputDisplay->row[rowCnt].colZ = cnvtstring(actionInfo->actions[idx].hr[24].hrItrv)
				outputDisplay->row[rowCnt].colAA = cnvtstring(actionInfo->actions[idx].actionCnt)
			else
				rowCnt = rowCnt + 1
				stat = alterlist(outputDisplay->row,rowCnt)
 
				outputDisplay->row[rowCnt].colB = actionInfo->actions[idx].action
				outputDisplay->row[rowCnt].colC = cnvtstring(actionInfo->actions[idx].hr[1].hrItrv)
				outputDisplay->row[rowCnt].colD = cnvtstring(actionInfo->actions[idx].hr[2].hrItrv)
				outputDisplay->row[rowCnt].colE = cnvtstring(actionInfo->actions[idx].hr[3].hrItrv)
				outputDisplay->row[rowCnt].colF = cnvtstring(actionInfo->actions[idx].hr[4].hrItrv)
				outputDisplay->row[rowCnt].colG = cnvtstring(actionInfo->actions[idx].hr[5].hrItrv)
				outputDisplay->row[rowCnt].colH = cnvtstring(actionInfo->actions[idx].hr[6].hrItrv)
				outputDisplay->row[rowCnt].colI = cnvtstring(actionInfo->actions[idx].hr[7].hrItrv)
				outputDisplay->row[rowCnt].colJ = cnvtstring(actionInfo->actions[idx].hr[8].hrItrv)
				outputDisplay->row[rowCnt].colK = cnvtstring(actionInfo->actions[idx].hr[9].hrItrv)
				outputDisplay->row[rowCnt].colL = cnvtstring(actionInfo->actions[idx].hr[10].hrItrv)
				outputDisplay->row[rowCnt].colM = cnvtstring(actionInfo->actions[idx].hr[11].hrItrv)
				outputDisplay->row[rowCnt].colN = cnvtstring(actionInfo->actions[idx].hr[12].hrItrv)
				outputDisplay->row[rowCnt].colO = cnvtstring(actionInfo->actions[idx].hr[13].hrItrv)
				outputDisplay->row[rowCnt].colP = cnvtstring(actionInfo->actions[idx].hr[14].hrItrv)
				outputDisplay->row[rowCnt].colQ = cnvtstring(actionInfo->actions[idx].hr[15].hrItrv)
				outputDisplay->row[rowCnt].colR = cnvtstring(actionInfo->actions[idx].hr[16].hrItrv)
				outputDisplay->row[rowCnt].colS = cnvtstring(actionInfo->actions[idx].hr[17].hrItrv)
				outputDisplay->row[rowCnt].colT = cnvtstring(actionInfo->actions[idx].hr[18].hrItrv)
				outputDisplay->row[rowCnt].colU = cnvtstring(actionInfo->actions[idx].hr[19].hrItrv)
				outputDisplay->row[rowCnt].colV = cnvtstring(actionInfo->actions[idx].hr[20].hrItrv)
				outputDisplay->row[rowCnt].colW = cnvtstring(actionInfo->actions[idx].hr[21].hrItrv)
				outputDisplay->row[rowCnt].colX = cnvtstring(actionInfo->actions[idx].hr[22].hrItrv)
				outputDisplay->row[rowCnt].colY = cnvtstring(actionInfo->actions[idx].hr[23].hrItrv)
				outputDisplay->row[rowCnt].colZ = cnvtstring(actionInfo->actions[idx].hr[24].hrItrv)
		 		outputDisplay->row[rowCnt].colAA = cnvtstring(actionInfo->actions[idx].actionCnt)
 
				outputDisplay->row[rowCnt].sortInd = build2(facility,pharmacistName,"J")
 
			endif
		endfor
	endif
;with nocounter,orahintcbo("INDEX(p xpkprsnl)"),orahintcbo("INDEX(o xpkorders)") ;002 - removed
with nocounter, time=300, ORAHINTCBO("LEADING(OA, P)"), ORAHINTCBO("INDEX(OA XIE1ORDER_ACTION, P XPKPRSNL)") ;002 - added
 
if(curqual>0)
 
	declare facFileAbrev = vc
 
		if($FAC = 633867.00)
			set facFileAbrev = "fsh"
		elseif($FAC = 4363058.00)
			set	facFileAbrev = "hhc"
		elseif($FAC = 4363216.00)
			set	facFileAbrev = "whc"
		elseif($FAC = 4363210.00)
			set	facFileAbrev = "guh"
		elseif($FAC = 4362818.00)
			set	facFileAbrev = "gsh"
		elseif($FAC = 4363156.00)
			set	facFileAbrev = "umh"
		elseif($FAC = 4364516.00)
			set facFileAbrev = "nrh"
		endif
 
 
if($pREPORTY_TYPE = "S")
 
	if($pREPORT_OUTPUT = "D")
		if (mi2_emailind = 1 and mvc_email_addresses = "*@*.*")
 
;			declare mvc_filename = vc with protected,constant(concat("9_order_actions_detail_",format(cnvtdatetime(curdate,curtime),"yyyymmddhhmmss;;d"),".csv"))
; 			DECLARE TEMP_FILENAME = VC WITH PROTECTED,CONSTANT("9_order_actions_detail_temp.csv")
;			declare mvc_filepath = vc with protected,constant(concat("/cerner/d_p41/print/",mvc_filename))
; 			DECLARE TEMP_FILEPATH = VC WITH PROTECTED,CONSTANT(CONCAT("/cerner/d_p41/print/",TEMP_FILENAME))
 
 
 
 
		set attachmentName = build2(facFileAbrev,"_pharmacist_order_actions_detail"
													,format(cnvtdatetime(curdate,curtime),"_yyyymmdd;;d"),".csv")
 
		call echo(build("attachmentName: ",attachmentName))
 
 
 
/*SET MVC_EMAIL_BODY = BUILD2("Auto generated email of the Pharmacy Order Action report for the follwing prompt selection:"
				     ,CHAR(13),"Email Sent By: ",GVC_USER_NAME
					 ,CHAR(13),"Facility: ",MVC_FAC
                     ,CHAR(13),"Order Actions on or After: ", GVC_START_DT
                     ,CHAR(13),"Order Actions Before: ",GVC_END_DT)
 
 
 
 
	set tempemailrequest->sendAttachment = 1
	set tempemailrequest->emailAddresses = $EMAILLIST
	set tempemailrequest->emailBody = build2("Auto generated email of the Pharmacist Order Action report for the follwing prompt selection: "
									,char(13),"Email Sent By: ",GVC_USER_NAME
									 ,char(13),"Facility: ",MVC_FAC
									  ,CHAR(13),"Order Actions on or After: ", GVC_START_DT
                     ,CHAR(13),"Order Actions Before: ",GVC_END_DT
									 ,char(13),char(13)
,"For questions regarding this email please contact the Service Desk MedConnect Custom Development Assignee Group"
 
									 )
 
 
	set tempemailrequest->emailSubject = MVC_EMAIL_SUBJECT
	set tempemailrequest->attachmentName =	concat("9_pharmacist_order_actions_detail",format(cnvtdatetime(curdate,curtime),"_yyyymmdd;;d"),".csv")
 
	set tempemailrequest->emailBodyFile concat("/cerner/d_",trim(cnvtlower(CURDOMAIN),3),"/print/"
	,"9_pharmacist_order_actions_body_",format(cnvtdatetime(curdate,curtime)
	,"yyyymmdd;;d"),".txt")
 
	set tempemailrequest->sourcePath = concat("/cerner/d_",trim(cnvtlower(CURDOMAIN),3),"/print/",tempemailrequest-> )
	set tempemailrequest->bodysourcePath = concat("/cerner/d_",trim(cnvtlower(CURDOMAIN),3),"/print/",tempemailrequest->emailBodyFile)
 */
			select INTO concat(attachmentName)
			facility = substring(1,100,actionInfo->facility[d1.seq].facility)
			,Personell = substring(1,100,actionInfo->facility[d1.seq].personnel[d2.seq].name_full_formatted)
			;,Position = substring(1,100,actionInfo->facility[d1.seq].personnel[d2.seq].position)
			,Order_Name =  substring(1,100,actionInfo->facility[d1.seq].personnel[d2.seq].actions[d3.seq].orderName)
			,Action = substring(1,100,actionInfo->facility[d1.seq].personnel[d2.seq].actions[d3.seq].action)
			,Action_Date = substring(1,100,actionInfo->facility[d1.seq].personnel[d2.seq].actions[d3.seq].actionDt)
			,Action_Time = substring(1,100,actionInfo->facility[d1.seq].personnel[d2.seq].actions[d3.seq].actionTm)
			,Unit = actionInfo->facility[d1.seq].personnel[d2.seq].actions[d3.seq].unit 
 			,Facility = actionInfo->facility[d1.seq].personnel[d2.seq].actions[d3.seq].facility
 
		from (dummyt d1 with seq = size(actionInfo->facility,5))
			,(dummyt d2 with seq = size(actionInfo->facility[d1.seq].personnel,5))
			,(dummyt d3 with seq = 1)
		plan d1
			where maxrec(d2,size(actionInfo->facility[d1.seq].personnel,5))
		join d2
			where maxrec(d3,size(actionInfo->facility[d1.seq].personnel[d2.seq].actions,5))
		join d3
		order by d1.seq,d2.seq,d3.seq
		with nocounter,pcformat('"',','), format
 
 
 
			;SEND EMAIL
/*			IF(FINDFILE(tempemailrequest->sourcePath))
 
 
 
			execute 0_linux_send_email with replace("EMAILREQUEST","TEMPEMAILREQUEST"),replace("EMAILREPLY","TEMPEMAILREPLY")
 
 
 	if(tempEMAILREPLY->status = "S")
			select into $pOUTDEV
			message = "Email Sent"
			from dummyt
			with nocounter,format,seperator =" "
 	else
 		select into  $poutdev
 		message = "Error Seding email"
 		from dummyt d
 		with format,separator=" "
 	endif
 
;			else
;			select into $pOUTDEV
;			message = mvc_filename
;			from dummyt
;			with nocounter,format,seperator =" "
			endif*/
 
		else
 
 
			select distinct into $pOUTDEV
				facility = substring(1,100,actionInfo->facility[d1.seq].facility)
				,Personell = substring(1,100,actionInfo->facility[d1.seq].personnel[d2.seq].name_full_formatted)
				;,Position = substring(1,100,actionInfo->facility[d1.seq].personnel[d2.seq].position)
				,Order_Name =  substring(1,100,actionInfo->facility[d1.seq].personnel[d2.seq].actions[d3.seq].orderName)
				,Action = substring(1,100,actionInfo->facility[d1.seq].personnel[d2.seq].actions[d3.seq].action)
				,Action_Date = substring(1,100,actionInfo->facility[d1.seq].personnel[d2.seq].actions[d3.seq].actionDt)
				,Action_Time = substring(1,100,actionInfo->facility[d1.seq].personnel[d2.seq].actions[d3.seq].actionTm)
				;,Unit = actionInfo->facility[d1.seq].personnel[d2.seq].actions[d3.seq].unit ;002 - removed
				,Unit = trim(substring(1,25,actionInfo->facility[d1.seq].personnel[d2.seq].actions[d3.seq].unit),3) ;002 - added
	 			,Facility = actionInfo->facility[d1.seq].personnel[d2.seq].actions[d3.seq].facility
 
			from (dummyt d1 with seq = size(actionInfo->facility,5))
				,(dummyt d2 with seq = size(actionInfo->facility[d1.seq].personnel,5))
				,(dummyt d3 with seq = 1)
			plan d1
				where maxrec(d2,size(actionInfo->facility[d1.seq].personnel,5))
			join d2
				where maxrec(d3,size(actionInfo->facility[d1.seq].personnel[d2.seq].actions,5))
			join d3
			order by d1.seq,d2.seq,d3.seq
			with nocounter, separator=" ",format
		endif
 	else
		if (mi2_emailind = 1 and mvc_email_addresses = "*@*.*")
 
			declare mvc_filename = vc with protected,constant(concat("_pharmacist_order_actions_rollup_"
													,format(cnvtdatetime(curdate,curtime),"yyyymmdd hhmmss;;d"),".csv"))
 
			declare mvc_filepath = vc with protected,constant(concat("/cerner/d_p41/print/",mvc_filename))
 
 
/*SET MVC_EMAIL_BODY = BUILD2("Auto generated email of the Pharmacy Order Action report for the follwing prompt selection:"
				     ,CHAR(13),"Email Sent By: ",GVC_USER_NAME
					 ,CHAR(13),"Facility: ",MVC_FAC
                     ,CHAR(13),"Order Actions on or After: ", GVC_START_DT
                     ,CHAR(13),"Order Actions Before: ",GVC_END_DT)
 
 
 
 
	set tempemailrequest->sendAttachment = 1
	set tempemailrequest->emailAddresses = $EMAILLIST
	set tempemailrequest->emailBody = build2("Auto generated email of the Pharmacist Order Action report for the follwing prompt selection: "
									,char(13),"Email Sent By: ",GVC_USER_NAME
									 ,char(13),"Facility: ",MVC_FAC
									  ,CHAR(13),"Order Actions on or After: ", GVC_START_DT
                     ,CHAR(13),"Order Actions Before: ",GVC_END_DT
									 ,char(13),char(13)
,"For questions regarding this email please contact the Service Desk MedConnect Custom Development Assignee Group"
 
									 )
 
	set tempemailrequest->emailSubject = MVC_EMAIL_SUBJECT
	set tempemailrequest->attachmentName =	concat("9_pharmacist_order_actions_summary",format(cnvtdatetime(curdate,curtime),"_yyyymmdd;;d"),".csv")
 
	set tempemailrequest->emailBodyFile concat("/cerner/d_",trim(cnvtlower(CURDOMAIN),3),"/print/"
	,"9_pharmacist_order_actions_body_",format(cnvtdatetime(curdate,curtime)
	,"yyyymmdd;;d"),".txt")
 
	set tempemailrequest->sourcePath = concat("/cerner/d_",trim(cnvtlower(CURDOMAIN),3),"/print/",tempemailrequest->attachmentName)
	set tempemailrequest->bodysourcePath = concat("/cerner/d_",trim(cnvtlower(CURDOMAIN),3),"/print/",tempemailrequest->emailBodyFile)
 
  */
  	set attachmentName =	build2(facFileAbrev,"_pharmacist_order_actions_rollup"
												,format(cnvtdatetime(curdate,curtime),"_yyyymmdd;;d"),".csv")
 
	call echo(build("attachmentName: ",attachmentName))
 
 
			select distinct INTO CONCAT(attachmentName)
 
			A = substring(1,100,outputDisplay->row[d1.seq].colAC )
			,B =substring(1,100,outputDisplay->row[d1.seq].colA)
			,C =substring(1,100,outputDisplay->row[d1.seq].colB)
			,D =substring(1,100,outputDisplay->row[d1.seq].colC)
			,E =substring(1,100,outputDisplay->row[d1.seq].colD)
			,F =substring(1,100,outputDisplay->row[d1.seq].colE)
			,G =substring(1,100,outputDisplay->row[d1.seq].colF)
			,H =substring(1,100,outputDisplay->row[d1.seq].colG)
			,I =substring(1,100,outputDisplay->row[d1.seq].colH)
			,J =substring(1,100,outputDisplay->row[d1.seq].colI)
			,K =substring(1,100,outputDisplay->row[d1.seq].colJ)
			,L =substring(1,100,outputDisplay->row[d1.seq].colK)
			,M =substring(1,100,outputDisplay->row[d1.seq].colL)
			,N =substring(1,100,outputDisplay->row[d1.seq].colM)
			,O =substring(1,100,outputDisplay->row[d1.seq].colN)
			,P =substring(1,100,outputDisplay->row[d1.seq].colO)
			,Q =substring(1,100,outputDisplay->row[d1.seq].colP)
			,R =substring(1,100,outputDisplay->row[d1.seq].colQ)
			,S =substring(1,100,outputDisplay->row[d1.seq].colR)
			,T =substring(1,100,outputDisplay->row[d1.seq].colS)
			,U =substring(1,100,outputDisplay->row[d1.seq].colT)
			,V =substring(1,100,outputDisplay->row[d1.seq].colU)
			,W =substring(1,100,outputDisplay->row[d1.seq].colV)
			,X =substring(1,100,outputDisplay->row[d1.seq].colW)
			,Y =substring(1,100,outputDisplay->row[d1.seq].colX)
			,Z =substring(1,100,outputDisplay->row[d1.seq].colY)
			,AA =substring(1,100,outputDisplay->row[d1.seq].colZ)
			,AB =substring(1,100,outputDisplay->row[d1.seq].colAA)
 
		from (dummyt d1 with seq = size(outputDisplay->row,5))
		order by outputDisplay->row[d1.seq].sortInd,d1.seq
		with nocounter,pcformat('"',','), format
 
 
					;SEND EMAIL
			/*IF(FINDFILE(tempemailrequest->sourcePath))
 
 
	set tempemailrequest->emailSubject = MVC_EMAIL_SUBJECT
	set tempemailrequest->attachmentName =	concat("9_pharmacist_order_actions",format(cnvtdatetime(curdate,curtime),"_yyyymmdd;;d"),".csv")
 			execute 0_linux_send_email with replace("EMAILREQUEST","TEMPEMAILREQUEST"),replace("EMAILREPLY","TEMPEMAILREPLY")
 
 
 	if(tempEMAILREPLY->status = "S")
			select into $pOUTDEV
			message = "Email Sent"
			from dummyt
			with nocounter,format,seperator =" "
 	else
 		select into  $poutdev
 		message = build2(curnode,"-",tempemailrequest->attachmentName)
 		from dummyt d
 		with format,separator=" "
 	endif
 
;			else
;			select into $pOUTDEV
;			message = mvc_filename
;			from dummyt
;			with nocounter,format,seperator =" "
			endif*/
		else
 
		select into $pOUTDEV
			A = substring(1,100,outputDisplay->row[d1.seq].colAC )
			,B =substring(1,100,outputDisplay->row[d1.seq].colA)
			,C =substring(1,100,outputDisplay->row[d1.seq].colB)
			,D =substring(1,100,outputDisplay->row[d1.seq].colC)
			,E =substring(1,100,outputDisplay->row[d1.seq].colD)
			,F =substring(1,100,outputDisplay->row[d1.seq].colE)
			,G =substring(1,100,outputDisplay->row[d1.seq].colF)
			,H =substring(1,100,outputDisplay->row[d1.seq].colG)
			,I =substring(1,100,outputDisplay->row[d1.seq].colH)
			,J =substring(1,100,outputDisplay->row[d1.seq].colI)
			,K =substring(1,100,outputDisplay->row[d1.seq].colJ)
			,L =substring(1,100,outputDisplay->row[d1.seq].colK)
			,M =substring(1,100,outputDisplay->row[d1.seq].colL)
			,N =substring(1,100,outputDisplay->row[d1.seq].colM)
			,O =substring(1,100,outputDisplay->row[d1.seq].colN)
			,P =substring(1,100,outputDisplay->row[d1.seq].colO)
			,Q =substring(1,100,outputDisplay->row[d1.seq].colP)
			,R =substring(1,100,outputDisplay->row[d1.seq].colQ)
			,S =substring(1,100,outputDisplay->row[d1.seq].colR)
			,T =substring(1,100,outputDisplay->row[d1.seq].colS)
			,U =substring(1,100,outputDisplay->row[d1.seq].colT)
			,V =substring(1,100,outputDisplay->row[d1.seq].colU)
			,W =substring(1,100,outputDisplay->row[d1.seq].colV)
			,X =substring(1,100,outputDisplay->row[d1.seq].colW)
			,Y =substring(1,100,outputDisplay->row[d1.seq].colX)
			,Z =substring(1,100,outputDisplay->row[d1.seq].colY)
			,AA =substring(1,100,outputDisplay->row[d1.seq].colZ)
			,AB =substring(1,100,outputDisplay->row[d1.seq].colAA)
 
		from (dummyt d1 with seq = size(outputDisplay->row,5))
		order by outputDisplay->row[d1.seq].sortInd
		with nocounter,format,seperator=""
 		endif
 	endif
 
 
else
	if (mi2_emailind = 1 and mvc_email_addresses = "*@*.*")
  	set attachmentName =	build2(facFileAbrev,"_pharmacist_order_actions"
												,format(cnvtdatetime(curdate,curtime),"_yyyymmdd;;d"),".pdf")
 
		execute reportrtl
%i cust_script:jjk_pharmacist_order_actionsn.dvl
 
		set _sendto = attachmentName
		call layoutquery(0)
 
	else
		execute reportrtl
%i cust_script:9_PHARMACIST_ORDER_ACTIONS4.dvl
 
		set _sendto = $poutdev
		call layoutquery(0)
 
 	endif
 
endif
else
	select into $pOUTDEV
		Message = "No Data"
		from dummyt d1
		with nocounter, separator=" ",format
endif
endif
 
#EXIT_REPORT
end
 
 
 
 
go
 
