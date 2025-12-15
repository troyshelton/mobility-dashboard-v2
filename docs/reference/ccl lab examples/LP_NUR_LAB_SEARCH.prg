/*************************************************************************
 
        Script Name:    LP_NUR_LAB_SEARCH.PRG
        Description:    monitor the Transfusion Service orders
 
        Date Written:  	Sept 20, 2005
        Written by:     Nabeel Parwez
 
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 None
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    09/20/05 N. Parwez      Initial Development
 002	02/26/09 B. King	Add Script Audit Tool
 *************************************************************************/
 
DROP PROGRAM lp_nur_lab_search:DBA GO
CREATE PROGRAM lp_nur_lab_search:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"     ;* Enter or select the printer or file name to send this report to.
	, "From Date:" = "CURDATE"
	, "From Time (##:##):" = "00:00"
	, "To Date (Limit 7 Days) :" = "CURDATE"
	, "To Time (##:##):" = "23:59"
 
with OUTDEV, FromDate, FROM_TIME, ToDate, TO_TIME
 
%INCLUDE CUST_WH:LP_SCRIPT_AUDIT.INC
 
%INCLUDE CUST_WH:LP_PM_GET_CENSUS_DATA.INC
 
RECORD rREPORT (
	1 COUNT				= i4
	1 DATA[*]
		2 ENCNTR_ID		= f8
		2 ORDER_ID		= f8
		2 ORD_DISP		= c30
		2 CLIN_DISP		= c70
 
)
 
 
 
; Include custom code value retrieval library
%INCLUDE CUST_WH:LP_GET_CODE_VALUE.INC
 
; Collect Required Code Values
SET cvBLD = GET_CODE_VALUE(200,"","BLDDRAWFORTRANSFUSION") ;    3712858
SET cvHOLD = GET_CODE_VALUE(200,"","HOLDPURPLETOPPOSSIBLETX") ;   3805535
SET cvSAVE = GET_CODE_VALUE(200,"","SAVE") ;    3805533
 
 
SET OUTDEV = $1
SET FROM_DATE = CNVTALPHANUM($2)
SET FROM_TIME = CNVTALPHANUM($3)
SET TO_DATE = CNVTALPHANUM($4)
SET TO_TIME = CNVTALPHANUM($5)
 
IF (DATETIMEDIFF(CNVTDATETIME(CNVTDATE2(TO_DATE,"MMDDYYYY"),0),
	CNVTDATETIME(CNVTDATE2(FROM_DATE,"MMDDYYYY"),0)) > 7)
	GO TO END_PROGRAM
ENDIF
 
;gather order information
 
SELECT INTO "NL:"
	ORD_DISP = UAR_GET_CODE_DISPLAY( O.CATALOG_CD ),
	CLIN_DISP = O.CLINICAL_DISPLAY_LINE,
	ENCNTR_ID = O.ENCNTR_ID,
	ORDER_ID = O.ORDER_ID
 
FROM
	ORDERS  O
 
	;where o.order_id = 1995857
 
 
WHERE O.ORIG_ORDER_DT_TM
   		; BETWEEN CNVTDATETIME(CNVTDATE2("09142005","MMDDYYYY"),0000)
   		; AND CNVTDATETIME(CNVTDATE2("09162005","MMDDYYYY"),2359)
      	;BETWEEN (cnvtdatetime(curdate-15,curtime3))
      	BETWEEN CNVTDATETIME(CNVTDATE2(CNVTALPHANUM(FROM_DATE),"MMDDYY"),0000)
      	;CNVTINT(FROM_TIME))
        ;AND (cnvtdatetime(curdate,curtime3))
        AND CNVTDATETIME(CNVTDATE2(CNVTALPHANUM(TO_DATE),"MMDDYY"),2359)
        ;CNVTINT(TO_TIME))
 
		AND O.CATALOG_CD+0 IN(cvBLD, cvHOLD, cvSAVE)
ORDER ORDER_ID
 
	HEAD REPORT
		nCOUNT = rREPORT->COUNT
	HEAD ORDER_ID;DETAIL ;
		nCOUNT = nCOUNT + 1
		STAT = ALTERLIST(rREPORT->DATA, nCOUNT)
		rREPORT->DATA[nCOUNT].ORDER_ID = ORDER_ID
		rREPORT->DATA[nCOUNT].ORD_DISP = ORD_DISP
		rREPORT->DATA[nCOUNT].CLIN_DISP = CLIN_DISP
		rREPORT->DATA[nCOUNT].ENCNTR_ID = ENCNTR_ID
	FOOT REPORT
        rREPORT->COUNT = nCOUNT
 
 
WITH COUNTER
 
;CALL ECHORECORD(rREPORT)
 
; Set the parameters required to collect census
SET PROCESS_ENCNTR = 1
SET IGNORE_ENC_DATE = 1
 
;FOR (X = 1 TO rREPORT->COUNT)
 SET nENCDUMMY = rREPORT->COUNT
 SET ENC_ENCOUNTER = "E.ENCNTR_ID = rREPORT->DATA[D.SEQ].ENCNTR_ID"
 CALL RUN_REPORT(1)
;ENDFOR ;X
 
;call echorecord(rDATA)
 
; Execute the Data Collection
 
; Collect the Orders and Generate the Report
EXECUTE ReportRtl
 
%i CUST_WH:lp_nur_lab_search.dvl
 
SELECT INTO "NL:"
	NURSE_UNIT		= UAR_GET_CODE_DISPLAY(rDATA->DATA[D.SEQ].LOC_NURSE_UNIT_CD),
	ROOM			= UAR_GET_CODE_DISPLAY(rDATA->DATA[D.SEQ].LOC_ROOM_CD),
	BED				= UAR_GET_CODE_DISPLAY(rDATA->DATA[D.SEQ].LOC_BED_CD),
	NAME			= rDATA->DATA[D.SEQ].NAME_FULL_FORMATTED,
	FIN_NBR			= rDATA->DATA[D.SEQ].FIN_NBR,
	MRN             = rDATA->DATA[D.SEQ].MRN,
	ENCNTR_TYPE     = rDATA->DATA[D.SEQ].ENCNTR_TYPE_MT,
	DISCH_DATE		= rDATA->DATA[D.SEQ].DISCHARGE_DATE,
	ORD_DISP 		= rREPORT->DATA[D1.SEQ].ORD_DISP,
	CLIN_DISP 		= rREPORT->DATA[D1.SEQ].CLIN_DISP,
	ORDER_ID 		= CNVTSTRING(rREPORT->DATA[D1.SEQ].ORDER_ID)
 
 
 
FROM	(DUMMYT			D WITH SEQ=VALUE(rDATA->COUNT)),
		(DUMMYT			D1 WITH SEQ=VALUE(rREPORT->COUNT))
 PLAN D
 JOIN D1
   WHERE rREPORT->DATA[D1.SEQ].ENCNTR_ID = rDATA->DATA[D.SEQ].ENCNTR_ID
 
 
ORDER NURSE_UNIT, ROOM, BED
HEAD REPORT
	CALL InitializeReport(0)
	_fEndDetail=RptReport->m_pageWidth-RptReport->m_marginRight
 
	cPRODUCED = FORMAT(CNVTDATETIME(CURDATE, CURTIME3),"MM/DD/YY HH:MM;;Q")
 	nPAGE = 1
 	X = Header(0)
 
 	;SHADER = 1
DETAIL
	;IF (SHADER = 1)
		SHADER = 0
	;ELSE
	;	SHADER = 1
	;ENDIF
 
	IF (_YOffset+Body(1)>_fEndDetail)
		CALL PageBreak(0)
		nPAGE = nPAGE + 1
		X = Header(0)
	ENDIF
	X = Body(0)
 
WITH COUNTER, NULLREPORT
 
; Print the Report
CALL FinalizeReport(OUTDEV)
 
#END_PROGRAM
 
CALL STORE_AUDIT_DETAIL(0)
 
END GO
