 
/***************************** Program Header ********************************
 
Report Name: 		3791_PATH_COLLECTED_ORDERS
Program Name: 		3791_PATH_COLLECTED_ORDERS
 
Development Date: 	January 15, 2011
 
Author:  		Brad Weaver
 
Requestor/ Site: 	Renee Landis @ DSM
Request #:		ARR-924
 
Report Description: Audit of orders that are in a collected status
 
/*********************************************************************
*                       MODIFICATION CONTROL LOG		             *
**********************************************************************
*                                                                    *
Mod Date       Worker        Comment                                 *
--- ---------- ------------- ----------------------------------------*
001 01/15/2011 Brad Weaver   Initial Development
002 06/09/2011 Brad Weaver   Don't display labs in MMC Cntrl Proc (ARR-1078)
003 08/15/2012 Edgar Head    Include INTRANSIT status (ARR-1324)
**********************************************************************/
 
DROP PROGRAM 3791_PATH_COLLECTED_ORDERS GO
CREATE PROGRAM 3791_PATH_COLLECTED_ORDERS
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Enter a Start Date:" = "CURDATE"
	, "Enter an End Date:" = "CURDATE"
	, "Select a MBO:" = ""
	, "Select an Output Type:" = "" 

with pOUTDEV, pSTART_DATE, pEND_DATE, pMBO, pOUTPUT
 
 
/***************************************************************************************
* Gather Prompt Information															   *
***************************************************************************************/
 
 
;Format the dates for explorermenu and ops
DECLARE START_DATE 	= DQ8
DECLARE END_DATE 	= DQ8
DECLARE vBegin_Date = DQ8 WITH PUBLIC, NOCONSTANT
DECLARE vEnd_Date = DQ8 WITH PUBLIC, NOCONSTANT
DECLARE strBegin_Date = vc WITH PUBLIC, NOCONSTANT
DECLARE strEnd_Date = vc WITH PUBLIC, NOCONSTANT
DECLARE Temp_Date_DQ8 = DQ8 WITH PUBLIC, NOCONSTANT
 
;Get Begin and End Dates from Prompt
EXECUTE chi_process_date $pSTART_DATE, "BOD"
SET START_DATE = Temp_Date_DQ8
;SET vBegin_Date = Temp_Date_DQ8
;SET strBegin_Date = format(vBegin_Date,"mm/dd/yyyy;;d")
;SET START_DATE = CNVTDATETIME(strBegin_Date,0)
 
EXECUTE chi_process_date $pEND_DATE, "EOD"
SET END_DATE = Temp_Date_DQ8
 
SET DATE_RANGE_DISP = CONCAT(format(start_date,"mm/dd/yyyy;;d")," through ",format(end_date,"mm/dd/yyyy;;d"))
;SET vEnd_Date = Temp_Date_DQ8
;SET strEnd_Date = format(vEnd_Date,"mm/dd/yyyy;;d")
;SET END_DATE = CNVTDATETIME(strEnd_Date,0)
/*
IF (ISNUMERIC(strBegin_Date) > 0) ;input was in curdate/curtime format
	SET START_DATE = CNVTDATETIME(strBegin_Date,0)
ELSE ;input was in MM/DD/YYYY string format
	SET START_DATE = CNVTDATETIME(CNVTDATE2(strBegin_Date,"MM/DD/YYYY"),0)
ENDIF
 
IF (ISNUMERIC(strEnd_Date) > 0) ;input was in curdate/curtime format
	SET END_DATE = CNVTDATETIME(strEnd_Date,2359)
ELSE ;input was in MM/DD/YYYY string format
	SET END_DATE = CNVTDATETIME(CNVTDATE2(strEnd_Date,"MM/DD/YYYY"),2359)
ENDIF
SET DATE_RANGE_DISP = CONCAT(strBegin_Date," through ",strEnd_Date)
*/
 
;Check the max date range
IF (ABS(DATETIMEDIFF(CNVTDATETIME(START_DATE),CNVTDATETIME(END_DATE),1)) > 31)
	SELECT INTO $pOUTDEV
	FROM DUMMYT D
	PLAN D
	DETAIL
		COL 0, ROW 1,
		"Date range greater than thirty-one days not allowed."
	WITH FORMAT
 
	GO TO EXIT_SCRIPT
ENDIF
 
 
 
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
 
DECLARE RPT_TITLE = VC
SET RPT_TITLE = CONCAT("Outreach Collected Status Audit")
 
CALL ECHO(RPT_TITLE)
/***************************************************************************************
* Variable and Record Definition													   *
***************************************************************************************/
 
RECORD rDATA(
	1 PAT[*]
		2 FACILITY		= C100
		2 ORGANIZATION  = C100
		2 PERSON_ID 	= F8
		2 ENCNTR_ID		= F8
		2 NURSE_UNIT	= C100
		2 NAME			= C200
		2 LAB[*]
			3 ORDER_DISP	= C100
			3 DRAWN_DATE	= VC
			3 ACCESSION		= VC
			3 COLL_STATUS	= C100
			3 ORDER_ID		= F8
)WITH PROTECT
 
 
DECLARE cvGENLAB 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",6000,"LABORATORY"));2513
DECLARE cvCOLLECTED		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",14281,"COLLECTED"));9311.00
DECLARE cvINTRANSIT     = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",14281,"INTRANSIT"));653073.00 
;cvINTRANSIT declare added by Edgar Head 8/15/2011
DECLARE cvAP	 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",106,"ANATOMIC_PATHOLOGY"));671.0
DECLARE cvMICRO	 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",106,"MICRO"));696.0
DECLARE cvGENLAB_ACT	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",106,"GENERALLAB"));692.0
DECLARE cvBB_PRODUCT	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",106,"BLOODBANKPRODUCT"));677.0
DECLARE cvBB		 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",106,"BLOODBANK"));674.0
DECLARE cvDEPT 			= F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",19189,"DEPARTMENT"))
DECLARE cvATLAS_DSM	 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",89,"DSMATLASORMORU"));  165483625.00	DSM_ATLAS_ORMORU
DECLARE cvMMCCNTRLPROC 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",220,"MMCCNTRLPROC "))
 
DECLARE ORG_STRING = VC 
/***************************************************************************************
* Main Select Queries																   *
***************************************************************************************/
 
IF ($pMBO = "DSM")
	SET ORG_STRING = "os.name in ('DSM*', '10*')"
ELSEIF ($pMBO = "SV")
	SET ORG_STRING = "os.name in ('SV*', '20*')"
ELSE
	SET ORG_STRING = CONCAT("os.name = '", $pMBO , "*'")
ENDIF

call echo(org_string)

SELECT DISTINCT INTO "NL:"
FROM
	ORDERS   O
	, ENCOUNTER   E
	, ACCESSION_ORDER_R   AOR
	, ORDER_CONTAINER_R   OCR
	, CONTAINER   C

PLAN O
	WHERE O.CATALOG_TYPE_CD = cvGENLAB
	AND O.ACTIVITY_TYPE_CD IN (cvAP,cvMICRO,cvGENLAB_ACT,cvBB_PRODUCT,cvBB)
	AND O.DEPT_STATUS_CD IN (cvCOLLECTED, cvINTRANSIT);altered to include INTRANSIT status per ARR-1324 (E. Head 8/15/2012)
	;AND O.DEPT_STATUS_CD = cvCOLLECTED ;removed by E. Head 8/15/2012
	;AND O.CONTRIBUTOR_SYSTEM_CD+0 = cvATLAS_DSM
	AND O.CURRENT_START_DT_TM BETWEEN CNVTDATETIME(START_DATE) AND CNVTDATETIME(END_DATE)
	AND O.PROJECTED_STOP_DT_TM > CNVTDATETIME(START_DATE)
	AND O.TEMPLATE_ORDER_ID = 0.0

JOIN E
	WHERE E.encntr_id = O.encntr_id
		AND E.organization_id in (
			SELECT
              OSOR.organization_id
			FROM
              ORG_SET_ORG_R  OSOR
              , ORG_SET OS
			WHERE PARSER(ORG_STRING) ;OS.name IN PARSER(ORG_STRING)
			    AND OSOR.ACTIVE_IND = 1
			    AND OSOR.BEG_EFFECTIVE_DT_TM <= CNVTDATETIME(CURDATE,CURTIME3)
			    AND (OSOR.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)
			    OR OSOR.END_EFFECTIVE_DT_TM = NULL)
            	AND OS.org_set_id = OSOR.org_set_id
			    AND OS.ACTIVE_IND = 1
			    AND OS.BEG_EFFECTIVE_DT_TM <= CNVTDATETIME(CURDATE,CURTIME3)
			    AND (OS.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)
			    OR OS.END_EFFECTIVE_DT_TM = NULL)
            	)
 
JOIN AOR
	WHERE AOR.ORDER_ID = O.ORDER_ID
 
JOIN OCR
	WHERE OCR.ORDER_ID = O.ORDER_ID
 
JOIN C
	WHERE C.CONTAINER_ID = OCR.CONTAINER_ID
 	AND C.CURRENT_LOCATION_CD != cvMMCCNTRLPROC ;bw1

ORDER BY
	O.ENCNTR_ID
	, C.DRAWN_DT_TM
	, C.CONTAINER_ID

HEAD REPORT
	P_CNT = 0
 
HEAD O.ENCNTR_ID
	L_CNT = 0
	P_CNT = P_CNT + 1
	STAT = ALTERLIST(rDATA->PAT,P_CNT)
 
	rDATA->PAT[P_CNT].ENCNTR_ID		= O.ENCNTR_ID
 
DETAIL
	L_CNT = L_CNT + 1
	STAT = ALTERLIST(rDATA->PAT[P_CNT]->LAB,L_CNT)
 
 	rDATA->PAT[P_CNT]->LAB[L_CNT].ACCESSION 	= CNVTACC(AOR.ACCESSION)
 	rDATA->PAT[P_CNT]->LAB[L_CNT].ORDER_ID	 	= O.ORDER_ID
 	rDATA->PAT[P_CNT]->LAB[L_CNT].COLL_STATUS	= UAR_GET_CODE_DISPLAY(O.DEPT_STATUS_CD)
 	rDATA->PAT[P_CNT]->LAB[L_CNT].DRAWN_DATE	= FORMAT(C.DRAWN_DT_TM,"MM/DD/YY HH:MM")
 	rDATA->PAT[P_CNT]->LAB[L_CNT].ORDER_DISP	= O.ORDER_MNEMONIC

WITH COUNTER, TIME = 500, ORAHINT("INDEX(O XIE9ORDERS)")
 
 
 
SELECT INTO "NL:"
 
FROM (DUMMYT D1 WITH SEQ = SIZE(rDATA->PAT,5))
	,ENCOUNTER E
	,ORGANIZATION ORG
	,PERSON P
 
PLAN D1
 
JOIN E
	WHERE E.ENCNTR_ID = rDATA->PAT[D1.SEQ].ENCNTR_ID
	;EXPAND(E_IDX,1,SIZE(rDATA->PAT,5),E.ENCNTR_ID,rDATA->PAT[E_IDX].ENCNTR_ID)
 
JOIN P
	WHERE P.PERSON_ID = E.PERSON_ID
 
JOIN ORG
	WHERE ORG.ORGANIZATION_ID = E.ORGANIZATION_ID
 
ORDER BY D1.SEQ
 
DETAIL
	rDATA->PAT[D1.SEQ].FACILITY 	= UAR_GET_CODE_DISPLAY(E.LOC_FACILITY_CD)
	rDATA->PAT[D1.SEQ].ORGANIZATION = ORG.ORG_NAME
	rDATA->PAT[D1.SEQ].NAME			= P.NAME_FULL_FORMATTED
	rDATA->PAT[D1.SEQ].PERSON_ID	= P.PERSON_ID
 
WITH COUNTER, TIME = 700
 
/***************************************************************************************
* Output the Results																   *
***************************************************************************************/
 
;Display the results
CALL ECHORECORD(rDATA)
 
IF ($pOUTPUT = "S")
	SELECT INTO $pOUTDEV
	FACILITY = RDATA->PAT[D1.SEQ].FACILITY
	,ORGANIZATION = RDATA->PAT[D1.SEQ].ORGANIZATION
	, PAT_NAME = RDATA->PAT[D1.SEQ].NAME
	, ORDER_DISP = RDATA->PAT[D1.SEQ].LAB[D2.SEQ].ORDER_DISP
	, DRAWN_DATE = RDATA->PAT[D1.SEQ].LAB[D2.SEQ].DRAWN_DATE
	, ACCESSION = RDATA->PAT[D1.SEQ].LAB[D2.SEQ].ACCESSION
	, COLL_STATUS = RDATA->PAT[D1.SEQ].LAB[D2.SEQ].COLL_STATUS
 
	FROM
		(DUMMYT   D1  WITH SEQ = VALUE(SIZE(RDATA->PAT, 5)))
		, (DUMMYT   D2  WITH SEQ = 1)
 
	PLAN D1 WHERE MAXREC(D2, SIZE(RDATA->PAT[D1.SEQ].LAB, 5))
	JOIN D2
 
	ORDER BY
		FACILITY
		, ORGANIZATION
		, RDATA->PAT[D1.SEQ].ENCNTR_ID
		, DRAWN_DATE
 
	WITH COUNTER, FORMAT, SEPARATOR = " ",TIME = 200
ELSE
	EXECUTE REPORTRTL
%i CCLUSERDIR:3791_PATH_COLLECTED_ORDERS.dvl
 
	SET _SENDTO = $pOUTDEV
	CALL LAYOUTQUERY(0)
ENDIF
 
#EXIT_SCRIPT
 
 
END GO
