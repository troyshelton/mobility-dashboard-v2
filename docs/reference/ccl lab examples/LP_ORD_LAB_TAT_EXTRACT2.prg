/*************************************************************************
 
	Script Name:	LP_ORD_LAB_TAT_EXTRACT2.PRG
	Description:	Lab Turnaround Time Report
 
	Date Written:	January 30, 2008
	Written by:	Nestor Llerena
 
 *************************************************************************
			    Special Instructions
 *************************************************************************
 None
 *************************************************************************
			    Revision Information
 *************************************************************************
 Rev	Date	 By		Comments
 ------	-------- --------------	------------------------------------------
 001	01/30/08 N. Llerena	copy LP_ORD_LAB_TAT_EXTRACT.PRG and modify
 				for extract.
 002	02/05/08 J. Simpson	Cleaned out record structure and removed
 				layout code for optimal execution.
 003	02/26/09 B. King	Add Script Audit Tool
 *************************************************************************/
DROP PROGRAM LP_ORD_LAB_TAT_EXTRACT2:DBA GO
CREATE PROGRAM LP_ORD_LAB_TAT_EXTRACT2:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "From Order Date Time :" = "SYSDATE"
	, "Thru Order Date Time :" = "SYSDATE"
 
with OUTDEV, FROM_DT_TM, THRU_DT_TM
 
%INCLUDE CUST_WH:LP_SCRIPT_AUDIT.INC
%INCLUDE CUST_WH:LP_GET_CODE_VALUE.INC
 
; Collect code values
SET cvGENLAB 		= GET_CODE_VALUE(6000,"GENERAL LAB","LABORATORY")
SET cvINPROC 		= GET_CODE_VALUE(6004,"INPROCESS","INPROCESS")
SET cvORDERED 		= GET_CODE_VALUE(6004,"ORDERED","ORDERED")
SET cvCOMPLETE 		= GET_CODE_VALUE(6004,"COMPLETED","COMPLETED")
SET cvINPATIENT 	= GET_CODE_VALUE(69,"INPATIENT","INPATIENT")
SET cvEMERGENCY 	= GET_CODE_VALUE(69,"EMERGENCY","EMERGENCY")
SET cvOUTPATIENT	= GET_CODE_VALUE(69,"OUTPATIENT","OUTPATIENT")
SET cvOBSERVATION	= GET_CODE_VALUE(69,"OBSERVATION","OBSERVATION")
SET cvRECURRING		= GET_CODE_VALUE(69,"RECURRING","RECURRING")
SET cvONCE		= GET_CODE_VALUE(4003,"ONETIME","ONCE")
SET cvCBN		= GET_CODE_VALUE(16449,"DETAIL","COLLECTBYNURSE")
SET cvFIN		= GET_CODE_VALUE(319,"FIN NBR","FINNBR")
SET cvAUTH		= GET_CODE_VALUE(8,"AUTH","AUTHVERIFIED")
 
DECLARE INPRO_DT_TM	= dq8
DECLARE COMPL_DT_TM	= dq8
 
; Define output filename
SET FROM_DT = FORMAT(CNVTDATETIME($FROM_DT_TM),"YYYYMMDD;;Q")
SET THRU_DT = FORMAT(CNVTDATETIME($THRU_DT_TM),"YYYYMMDD;;Q")
SET SEND_NAME = CONCAT("LAB_TAT_",FROM_DT,"_THRU_",THRU_DT,".CSV")
 
; Force Min Range Error Message if run from Explorer Menu
IF ($OUTDEV != "BATCH")
	IF (DATETIMEDIFF(CNVTDATETIME($THRU_DT_TM),CNVTDATETIME($FROM_DT_TM)) < 8)
		SELECT INTO VALUE($OUTDEV)
		FROM	DUMMYT		D
		DETAIL
			COL 0, "Your report has been executed. The output file can be found on the network and is called ",
				SEND_NAME, ".", ROW + 1
		WITH COUNTER
	ELSE
		SELECT INTO VALUE($OUTDEV)
		FROM	DUMMYT		D
		DETAIL
			COL 0, "You have selected a date range greater than 7 days. Please submit a smaller date range ",
				"and run the report again.", ROW + 1
		WITH COUNTER
 
		GO TO END_PROGRAM
	ENDIF
ENDIF
 
SELECT INTO VALUE(SEND_NAME)
	; Sort Fields
	ENCNTR_ID			= O.ENCNTR_ID,
	ORDER_ID			= O.ORDER_ID,
	EVENT_ID			= CE.EVENT_ID,
	ORDER_ACTION_ID			= OA.ORDER_ACTION_ID,
	ACTION_SEQUENCE			= OA.ACTION_SEQUENCE,
 
	; Data Fields
	START_DT_TM			= O.CURRENT_START_DT_TM,
	ORDERED_AS			= O.ORDERED_AS_MNEMONIC,
 
	ORDER_DESC			= UAR_GET_CODE_DISPLAY(O.CATALOG_CD),
	STATUS				= UAR_GET_CODE_DISPLAY(O.ORDER_STATUS_CD),
	ACTION_STATUS			= UAR_GET_CODE_DISPLAY(OA.ORDER_STATUS_CD),
	ACTION_DT_TM			= OA.ACTION_DT_TM,
	FIN				= EA.ALIAS,
	LOC_NURSE_UNIT_CD		= E.LOC_NURSE_UNIT_CD,
	OE_FIELD_MEANING		= OD.OE_FIELD_MEANING,
	OE_FIELD_DISPLAY_VALUE		= OD.OE_FIELD_DISPLAY_VALUE,
	IS_CBN				= IF (OD.OE_FIELD_ID = cvCBN)
						1
					  ELSE
					  	0
					  ENDIF,
	CHILD_ORDER			= IF (CE.PARENT_EVENT_ID != CE.EVENT_ID)
						"CHILD"
					  ELSE
					  	"     "
					  ENDIF,
	CHILD_TEST			= IF (CE.PARENT_EVENT_ID != CE.EVENT_ID)
						UAR_GET_CODE_DISPLAY(CE.EVENT_CD)
					  ELSE
					  	FILLSTRING(75," ")
					  ENDIF,
	CHILD_COMPLETE_DT_TM		= IF (CE.PARENT_EVENT_ID != CE.EVENT_ID)
						CE.CLINSIG_UPDT_DT_TM
					  ENDIF
 
FROM	ORDERS				O,
	ENCOUNTER			E,
	FREQUENCY_SCHEDULE		FS,
	ORDER_ACTION			OA,
	ENCNTR_ALIAS			EA,
	DUMMYT				D1,
	ORDER_DETAIL			OD,
	DUMMYT				D2,
	CLINICAL_EVENT			CE
PLAN	O
	WHERE O.ORIG_ORDER_DT_TM BETWEEN CNVTDATETIME($FROM_DT_TM)
				     AND CNVTDATETIME($THRU_DT_TM)
	AND   O.CATALOG_TYPE_CD = cvGENLAB
	AND   O.ORDER_STATUS_CD+0 IN (cvORDERED, cvINPROC, cvCOMPLETE)
	AND   O.ACTIVE_IND = 1
JOIN	E
	WHERE E.ENCNTR_ID = O.ENCNTR_ID
	AND   E.ENCNTR_TYPE_CLASS_CD IN (cvINPATIENT, cvEMERGENCY, cvOUTPATIENT, cvOBSERVATION, cvRECURRING)
	AND   E.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE, CURTIME3)
	AND   E.ACTIVE_IND = 1
JOIN	EA
	WHERE EA.ENCNTR_ID = E.ENCNTR_ID
	AND   EA.ENCNTR_ALIAS_TYPE_CD = cvFIN
	AND   EA.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE, CURTIME3)
	AND   EA.ACTIVE_IND = 1
JOIN	FS
	WHERE FS.FREQUENCY_ID = O.FREQUENCY_ID
	AND   FS.FREQUENCY_CD = cvONCE
	AND   FS.ACTIVE_IND = 1
JOIN	OA
	WHERE OA.ORDER_ID = O.ORDER_ID
JOIN	D1
JOIN	OD
	WHERE OD.ORDER_ID = O.ORDER_ID
	AND   (
	      OD.OE_FIELD_MEANING = "COLLPRI" OR
	      OD.OE_FIELD_ID = cvCBN
	      )
JOIN	D2
JOIN	CE
	WHERE CE.ORDER_ID = OD.ORDER_ID
	AND   CE.VALID_UNTIL_DT_TM > CNVTDATETIME(CURDATE, CURTIME3)
	AND   CE.RESULT_STATUS_CD = cvAUTH
	AND   CE.VIEW_LEVEL = 1
ORDER ENCNTR_ID, ORDER_ID, EVENT_ID, ORDER_ACTION_ID, ACTION_SEQUENCE
HEAD REPORT
	cLINE = FILLSTRING(999," ")
 
	COL 0, '"FIN#","ORDER_ID","ORDER_DESCRIPTION","CBN","PRIORITY","PATIENT LOCATION","ORDERED AS",'
		'"REQUEST_DATE","REQUEST TIME","INPROCESS DATE","INPROCESS TIME","RESULT DATE","RESULT TIME","DELTA"'
	ROW + 1
 
HEAD ORDER_ID
	INPRO_DT_TM = 0
	COMPL_DT_TM = 0
	ORD_LOCATION = "n/a                 "
	PRIORITY = "            "
	CBN = "No "
DETAIL
	; Store the first occurrence of InProcess and Completed Dates
	IF (ACTION_STATUS = "InProcess" AND INPRO_DT_TM = 0)
		INPRO_DT_TM = ACTION_DT_TM
	ELSEIF (ACTION_STATUS = "Completed" AND COMPL_DT_TM = 0)
		COMPL_DT_TM = ACTION_DT_TM
	ENDIF
 
	; Store first occurrence of a Patient Location
	IF (LOC_NURSE_UNIT_CD > 0 AND ORD_LOCATION = "n/a")
		ORD_LOCATION = UAR_GET_CODE_DISPLAY(E.LOC_NURSE_UNIT_CD)
	ENDIF
 
	; Store the priority
	IF (OE_FIELD_MEANING = "COLLPRI")
		PRIORITY = OE_FIELD_DISPLAY_VALUE
	ENDIF
 
	; Check CBN
	IF (IS_CBN = 1)
		CBN = OE_FIELD_DISPLAY_VALUE
	ENDIF
FOOT EVENT_ID
	IF (CHILD_ORDER = "CHILD")
		IF (COMPL_DT_TM > 0)
			DELTA = DATETIMEDIFF(CHILD_COMPLETE_DT_TM, START_DT_TM, 3)
		ELSE
			DELTA = 0.0
		ENDIF
 
		; Print the Child Order
		cLINE = BUILD(	'"', FIN, '"',
				',"', ORDER_ID, '"',
				',"', ORDER_DESC, ':', CHILD_TEST, '"',
				',"","",""',		; CBN, PRIORITY, LOCATION
				',"CHILD"',		; ORDERED AS
				',"', FORMAT(START_DT_TM,"MM/DD/YYYY;;Q"), '"',
				',"', FORMAT(START_DT_TM,"HH:MM;;Q"), '"',
				',"', FORMAT(INPRO_DT_TM,"MM/DD/YYYY;;Q"), '"',
				',"', FORMAT(INPRO_DT_TM,"HH:MM;;Q"), '"',
				',"', FORMAT(CHILD_COMPLETE_DT_TM,"MM/DD/YYYY;;Q"), '"',
				',"', FORMAT(CHILD_COMPLETE_DT_TM,"HH:MM;;Q"), '"',
				',"', DELTA, '"'
			     )
		COL 0, cLINE, ROW + 1
	ENDIF
FOOT ORDER_ID
	IF (COMPL_DT_TM > 0)
		DELTA = DATETIMEDIFF(COMPL_DT_TM, START_DT_TM, 3)
	ELSE
		DELTA = 0.0
	ENDIF
 
	; Print the Order
	cLINE = BUILD(	'"', FIN, '"',
			',"', ORDER_ID, '"',
			',"', ORDER_DESC, '"',
			',"', CBN, '"',
			',"', PRIORITY, '"',
			',"', ORD_LOCATION, '"',
			',"', ORDERED_AS, '"',
			',"', FORMAT(START_DT_TM,"MM/DD/YYYY;;Q"), '"',
			',"', FORMAT(START_DT_TM,"HH:MM;;Q"), '"',
			',"', FORMAT(INPRO_DT_TM,"MM/DD/YYYY;;Q"), '"',
			',"', FORMAT(INPRO_DT_TM,"HH:MM;;Q"), '"',
			',"', FORMAT(COMPL_DT_TM,"MM/DD/YYYY;;Q"), '"',
			',"', FORMAT(COMPL_DT_TM,"HH:MM;;Q"), '"',
			',"', DELTA, '"'
		     )
	COL 0, cLINE, ROW + 1
 
 
WITH COUNTER, MAXCOL=1000, FORMFEED=NONE, FORMAT=VARIABLE, OUTERJOIN=D1, OUTERJOIN=D2
 
%INCLUDE CUST_WH:LP_IT_FTP_SUBMIT.INC
CALL SUBMIT_FTP ("MDR","CCLUSERDIR:",SEND_NAME,"/Cerner/Lab",SEND_NAME,3,"nllerena@lpch.org",1)
 
#END_PROGRAM
 
CALL STORE_AUDIT_DETAIL(0)
 
END GO
