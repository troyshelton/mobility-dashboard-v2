drop program 1_dwh_lab go
create program 1_dwh_lab
 
record rData(
  1 qual[*]
    2 bKeep = i4
    2 personId = f8
    2 encntrId = f8
    2 dFirstChildEventId = f8
    2 dPEId = f8
    2 PEventCd = f8
    2 PEventCd_string = vc
    2 PEventDisp = vc
    2 PEventTitleText = vc
    2 dOId = f8
    2 sOId = vc
    2 patientMRN = vc
    2 visitNum = vc
    2 recordedOn = vc
    2 orderedDate = vc
    2 performedDate = vc
    2 dOrderCatalogCd = f8
    2 cpt4Code = vc
    2 orderName = vc
 
    2 resultValue = vc
    2 units = vc
 
    ; for blob data
    2 sR6_res_val = vc ;Result Value
    2 sPEId = vc
 
    2 detailType = vc
    2 resultName = vc
    2 nomenclatureType = vc
    2 nomenclatureValue = vc
    2 admitDtTm = vc
    2 dischDtTm = vc
    2 dtUpdtDtTm = dq8
    2 sUpdtDtTm = vc
    2 errorField = vc
    2 res[*]
      3 isAbnormalFlag = vc
      3 abnormalType = vc
      3 res_disp = vc ;Result Display
      3 sR6_res_val = vc ;Result Value
      3 sR7_res_unit = vc ;Units of result
      3 valueRange = vc
      3 dOrderCatalogCd = f8
)
 
;Record for storing child clinical_result ids
record clinical_results(
  1 results[*]
    2 clinical_result_id = f8
    2 parent_clinical_result_id = f8
    2 qual_idx = i4
    2 res_idx = i4
)
 
;Record for storing appropriate code values to select against
record cds(
  1 cd[*]
    2 dCd = f8
    2 vCd = vc
    2 section = c2
)
 
declare n = i4 with Protect
set n = 0
declare n2 = i4 with Protect
set n2 = 0
declare nCds = i4 with Protect
set nCds = 0
declare nCnt = i4 with Protect
set nCnt = 0
declare LOOP_SIZE = i4 with Constant(200),Protect
 
set MICROBIOLOGY =      3995514.00	;Microbiology
set BLOODBANK =     3995558.00	; Blood Bank
set LABORATORY = 3994979.0 ;     3994979.00	Laboratory
 
/*
From Core Event Manager
Under Laboratory
 
SET BLOOD_GASES = 3994980.00
SET GENERAL_HEMATOLOGY = 3995017.00
SET MANUAL_DIFFERENTIAL = 3995034.00
SET MORPHOLOGY = 3995051.00
SET OTHER_HEMATOLOGY = 3995069.00
SET COAGULATION = 3995076.00
 
*/
 
declare max_results = i4
 
; get Lab cds
select into "nl:"
  disp = uar_get_code_display(ese_child.event_cd)
from
  v500_event_set_canon ese_parent,
  v500_event_set_explode ese_child
plan ese_parent where
  ese_parent.parent_event_set_cd = 3994979.00	;Laboratory
join ese_child where
  ese_child.event_set_cd = ese_parent.event_set_cd
order ese_child.event_cd
head ese_child.event_cd
;  if (ese_child.event_set_cd != 3995514.00)	;Microbiology
;	  nCds = nCds + 1
;	  stat = alterlist(cds->cd, nCds)
;	  cds->cd[nCds].dCd = ese_child.event_cd
;	  cds->cd[nCds].vCd = disp
;	  if (ese_child.event_set_cd = 3995558.00	); Blood Bank
;	    cds->cd[nCds].section = "BB"
;	  else
;	    cds->cd[nCds].section = "CH"
;	  endif
;  endif
 
    nCds = nCds + 1
	  stat = alterlist(cds->cd, nCds)
	  cds->cd[nCds].dCd = ese_child.event_cd
	  cds->cd[nCds].vCd = disp
 
with nocounter
 
;call echorecord(cds)
 
select into "nl:"
  ce.parent_event_id
  ,ce.event_id
  ,event_disp = uar_get_code_display(ce.event_cd)
  ,PEventCd_string = trim(cnvtstring(ce.event_cd))
  ,resource_string = uar_get_code_display(ce2.resource_cd)
  ,ce2.contributor_system_cd
  ,ce2_contributor_system_disp = uar_get_code_display(ce2.contributor_system_cd)
from
  clinical_event ce
  ,clinical_event ce2
  ,orders o
  ,person_alias pa
 
plan  ce2
;  where ce2.clinsig_updt_dt_tm >= cnvtdatetime("01-JUN-2014 00:00:00") ; cnvtdatetime(dRec->s_date)
;  and ce2.clinsig_updt_dt_tm <= cnvtdatetime("07-JUN-2014 23:59:59")
 
  where ce2.clinsig_updt_dt_tm between cnvtdatetime(dtBeg) and cnvtdatetime(dtEnd)
 
  and expand(n2, 1, size(cds->cd, 5), ce2.event_cd, cds->cd[n2].dCd)
;  and ce2.person_id > 0
;  and ce2.event_end_dt_tm >= cnvtdatetime("01-JUN-2014 00:00:00") ; cnvtdatetime(dRec->s_date)
;  and ce2.event_end_dt_tm <= cnvtdatetime("02-JUN-2014 23:59:59")
  and ce2.result_status_cd in (25,34,35) ;(AUTH, MODIFIED)
  and ce2.view_level = 1
  and ce2.publish_flag = 1
  and ce2.valid_until_dt_tm >= cnvtdatetime(sysdate)
 
join ce
  where ce.event_id = ce2.parent_event_id
  and ce2.valid_until_dt_tm = CNVTDATETIME ( CNVTDATE ( 12312100 ),  00000 )
  and ce.view_level+0 = 0
join pa where
  pa.person_id = outerjoin(ce.person_id)
join o where
  o.order_id = outerjoin(ce.order_id)
order ce.event_id
 
head report
  nCnt = 0
 
head ce.event_id
  nCnt = nCnt + 1
  stat = alterlist(rData->qual, nCnt)
 
  rData->qual[nCnt].dPEId = ce.event_id
  rData->qual[nCnt].sPEId = trim(cnvtstring(ce.event_id),3)
  rData->qual[nCnt].detailType = uar_get_code_display(o.catalog_cd)
  rData->qual[nCnt].PEventCd = ce.event_cd
  rData->qual[nCnt].PEventCd_string = PEventCd_string
  rData->qual[nCnt].PEventDisp = event_disp
  rData->qual[nCnt].PEventTitleText = ce.event_title_text
  rData->qual[nCnt].encntrId = ce.encntr_id
  rData->qual[nCnt].personId = ce.person_id
  if(ce.order_id > 0)
    rData->qual[nCnt].dOId = ce.order_id
    rData->qual[nCnt].sOId = trim(cnvtstring(ce.order_id), 3)
  else
    rData->qual[nCnt].sOId = substring(0,findstring("-HNAC",ce.series_ref_nbr,0,0)-1,ce.series_ref_nbr)
  endif

  rData->qual[nCnt].recordedOn = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
  rData->qual[nCnt].performedDate = format(ce.performed_dt_tm, "MM/DD/YYYY HH:MM;;Q")
  rData->qual[nCnt].orderedDate = format(o.orig_order_dt_tm, "MM/DD/YYYY HH:MM;;Q") 
  rData->qual[nCnt].dOrderCatalogCd = o.catalog_cd ; this will be used for cpt code 
  rData->qual[nCnt].sUpdtDtTm = format(o.updt_dt_tm, "MM/DD/YYYY HH:MM;;Q") 
  rData->qual[nCnt].errorField = uar_get_code_display(ce.result_status_cd)
 
with time = 400, expand = 1;, orahintcbo("index (ce2 xie18clinical_event)") ; testing

; if no records qualify, get out
if(nCnt = 0)
  go to EXIT_SCRIPT
endif
 
; don't qualify on extra multi-expand records
for(n = nCnt + 1 to size(rData->qual, 5))
  set rData->qual[d1.seq].dPEId = rData->qual[nCnt].dPEId
  set rData->qual[d1.seq].bKeep = -1 ; changed this to speed it up.  Misses on event_id's were killing performance
endfor
 
call echo("Getting child results")
 
/************************************ get child results*************************************/
 
;Initializing it to be as big as the qual list
set stat = alterlist(clinical_results->results, size(rData->qual, 5))
set clinical_result_idx = 0
 
SELECT into "nl:"
	QUAL_DPEID = rData->qual[D1.SEQ].dPEId
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(rData->qual, 5)))
 , clinical_event ce
 
PLAN D1
join ce where
  ce.parent_event_id = rData->qual[d1.seq].dPEId and
  ce.valid_until_dt_tm > sysdate and
  ce.view_level = 1

order ce.parent_event_id, ce.collating_seq,ce.event_id;, cva.code_value
 
head ce.parent_event_id
  nResultcount = 0
;  n = locateval(n, (d.seq - 1) * LOOP_SIZE + 1, d.seq * LOOP_SIZE, ce.parent_event_id, rData->qual[d1.seq].dPEId)
  rData->qual[d1.seq].bKeep = rData->qual[d1.seq].bKeep + 1
 
head ce.event_id
    nResultcount = nResultcount + 1
    stat = alterlist(rData->qual[d1.seq].res, nResultcount)
 
    clinical_result_idx = clinical_result_idx + 1
    if (clinical_result_idx > size(clinical_results->results, 5))
      stat = alterlist(clinical_results->results, clinical_result_idx + 50)
    endif
    clinical_results->results[clinical_result_idx].clinical_result_id = ce.event_id
    clinical_results->results[clinical_result_idx].parent_clinical_result_id = ce.parent_event_id
    clinical_results->results[clinical_result_idx].qual_idx = n
    clinical_results->results[clinical_result_idx].res_idx = nResultCount
 
 
    rData->qual[d1.seq].dFirstChildEventId = ce.event_id
    rData->qual[d1.seq].res[nResultcount].abnormalType = uar_get_code_display(ce.normalcy_cd)
 
    if (ce.normalcy_cd = 201.00) ;201.00	ABN	ABNORMAL
      rData->qual[d1.seq].res[nResultcount].isAbnormalFlag = "True"
    endif
    rData->qual[d1.seq].res[nResultcount].res_disp = uar_get_code_display(ce.event_cd)
    rData->qual[d1.seq].res[nResultcount].sR6_res_val = replace(trim(ce.result_val), concat(char(13), char(10)), " ")
    rData->qual[d1.seq].res[nResultcount].sR6_res_val = replace(rData->qual[d1.seq].res[nResultcount].sR6_res_val, char(10), " ")
 
    ;add HL7 character removal
    rData->qual[d1.seq].res[nResultcount].sR6_res_val = replace(rData->qual[d1.seq].res[nResultcount].sR6_res_val, "\", "\E\")
    rData->qual[d1.seq].res[nResultcount].sR6_res_val = replace(rData->qual[d1.seq].res[nResultcount].sR6_res_val, "|", "\F\")
    rData->qual[d1.seq].res[nResultcount].sR6_res_val = replace(rData->qual[d1.seq].res[nResultcount].sR6_res_val, "^", "\S\")
    rData->qual[d1.seq].res[nResultcount].sR6_res_val = replace(rData->qual[d1.seq].res[nResultcount].sR6_res_val, "&", "\T\")
    rData->qual[d1.seq].res[nResultcount].sR6_res_val = replace(rData->qual[d1.seq].res[nResultcount].sR6_res_val, "~", "\R\")
 
    rData->qual[d1.seq].res[nResultcount].sR7_res_unit = uar_get_code_display(ce.result_units_cd)
 
    if (trim(ce.normal_low) > "")
      if (trim(ce.normal_high) > "")
        rData->qual[d1.seq].res[nResultcount].valueRange = concat(trim(ce.normal_low), " - ", trim(ce.normal_high))
      endif
    endif
 
    rData->qual[d1.seq].res[nResultcount].dOrderCatalogCd = ce.catalog_cd
 
  if (max_results < nResultcount)
    max_results = nResultcount
  endif

with nocounter

call echo("get pt demographics")
 
; get mrn
select into "nl:"
from
	(dummyt   d1  with seq = value(size(rData->qual, 5)))
	, person_alias   pa
plan d1
join pa
where pa.person_id = rData->qual[d1.seq].personId
and pa.alias_pool_cd = 683996.00
detail
	rData->qual[d1.seq].patientMRN = CNVTALIAS(pa.alias,"########")
with nocounter
 
; get fin
select into "nl:"
from
	(dummyt   d1  with seq = value(size(rData->qual, 5)))
, encntr_alias ea
plan d1
join ea where ea.encntr_id = rData->qual[d1.seq].encntrId
 and ea.encntr_alias_type_cd = 1077.00
order by d1.seq
detail
rData->qual[d1.seq].visitNum = ea.alias
with nocounter
 
; get admit and discharge date/time
SELECT into "nl:"
	QUAL_ENCNTRID = rData->qual[D1.SEQ].encntrId
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(rData->qual, 5)))
, encounter e
PLAN D1
join e where e.encntr_id = rData->qual[D1.SEQ].encntrId

order by d1.seq

detail

  rData->qual[d1.seq].admitDtTm = format(e.reg_dt_tm, "MM/DD/YYYY HH:MM;;Q")
  rData->qual[d1.seq].dischDtTm = format(e.disch_dt_tm, "MM/DD/YYYY HH:MM;;Q")
 
with nocounter
 
 
 
; get blob data
SELECT into "nl:"
	QUAL_DPEID = RDATA->qual[D1.SEQ].dPEId
	, CE.PARENT_EVENT_ID
	, CB.EVENT_ID
	, cb_exists = evaluate(nullind(cb.event_id), 0, 1, 0)
	, CBE.EVENT_ID
 
 
FROM
 
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(RDATA->qual, 5)))
	, dummyt d2
	, CLINICAL_EVENT   CE
	, CE_BLOB_RESULT   CBR
	, CE_BLOB   CB
 
PLAN D1
 
join ce where
  ce.parent_event_id = rData->qual[d1.seq].dPEId and
  ce.valid_until_dt_tm > sysdate ;and
 
  ;------------------------------------------------------
  ; Commented out due to EEG result found in powerchart,
  ; but BLOB not displaying in extract.
  ; Ex: FIN 65640849, EEG document, 14 FEB 2015 0952
  ;------------------------------------------------------
  ;ce.view_level = 0
 
join cbr where
  cbr.event_id = ce.event_id and
  cbr.valid_until_dt_tm > sysdate
join (d2
  join cb where
    cb.event_id = ce.event_id and
    cb.valid_until_dt_tm > sysdate
)

order d1.seq, ce.parent_event_id, ce.collating_seq
 
head ce.parent_event_id
 
  sRet = trim(" ")
 
head ce.collating_seq
  sBlob = fillstring(700000, " ") ; originally set to 60,000. Changed to 700,000 to give more space.
  if(cb.compression_cd = 728.0) ; if compressed
    call uar_ocf_uncompress(cb.blob_contents, cb.blob_length, sBlob, 700000, 0)
  else
    sBlob = replace(trim(cb.blob_contents), "ocf_blob", trim(" "))
  endif
  if(substring(1, 5, sBlob)= "{\rtf")
    n2 = findstring("{\delete", sBlob)
    if(n2 > 0)
      sBlob = concat(substring(1, n2 - 1, sBlob), "}")
    endif
    call uar_rtf2(sBlob, 700000, sBlob, 700000, 0, 0)
  endif
 
  if (findstring("|", sBlob) > 0)
  	sBlob = replace(sBlob,"|","\F\")
  endif

  rData->qual[d1.seq].sR6_res_val = concat(rData->qual[d1.seq].sR6_res_val, trim(sBlob), char(10))
 
foot ce.parent_event_id
 
  rData->qual[d1.seq].sR6_res_val = replace(rData->qual[d1.seq].sR6_res_val, char(10), trim(" "), 2)
  rData->qual[d1.seq].sR6_res_val = replace(rData->qual[d1.seq].sR6_res_val, concat(char(13), char(10)), char(10))
  rData->qual[d1.seq].sR6_res_val = replace(rData->qual[d1.seq].sR6_res_val, char(13), "\.br\")
  rData->qual[d1.seq].sR6_res_val = replace(rData->qual[d1.seq].sR6_res_val, char(10), "\.br\")
 
  if (trim(sBlob) = "")
    rData->qual[d1.seq].sR6_res_val = concat(
      "No BLOB data found. Result format = ", trim(UAR_GET_CODE_DISPLAY(CBR.FORMAT_CD),3), "."
    )
  endif
 
with nocounter, outerjoin = d2
 
; no blob data found
SELECT into "nl:"
	QUAL_DPEID = RDATA->qual[D1.SEQ].dPEId
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(RDATA->qual, 5)))
 
PLAN D1 where rData->qual[d1.seq].dPEId > 0 and rData->qual[d1.seq].sR6_res_val = ""
 
detail
  rData->qual[d1.seq].sR6_res_val = "No BLOB data found."
 
WITH NOCOUNTER;, SEPARATOR=" ", FORMAT
 
;--------------------------------------------------------------------------------------------------------------------------------
; Get nomenclature types (Outbound alias and LOINC code)
;--------------------------------------------------------------------------------------------------------------------------------
; 08.02.2016:
; Per Anthony, look for both types. Precedence is LOINC then Outbound alias.
; Logic to use: Use LOINC if found, else Outbound alias.
;--------------------------------------------------------------------------------------------------------------------------------
select into "nl:"
from
	(dummyt   d1  with seq = value(size(rData->qual, 5)))
, code_value_outbound cvo
plan d1
join cvo
  where cvo.code_value = rData->qual[d1.seq].PEventCd
    and cvo.contributor_source_cd in (
        61522616.00	; LOINC
      , 4328378.00	; HL7STDSRC (outbound alias)
    )
order by
  d1.seq
  , cvo.contributor_source_cd desc ; sort LOINC first, then HL7STDSRC
head report
  null
head d1.seq
  isFound = 0
detail
  if(isFound = 0)
    rData->qual[d1.seq].nomenclatureType = uar_get_code_display(cvo.contributor_source_cd)
    rData->qual[d1.seq].nomenclatureValue = trim(cvo.alias,3)
    isFound = 1
  endif
with nocounter
 
;call echorecord(rData)
 
select
if(bNewFile = 1)
  with maxrow = 1, maxcol = 32000, format = variable
endif
into value(sFile)
	RES_RES_DISP = SUBSTRING(1, 30, rData->qual[D1.SEQ].res[D2.SEQ].res_disp)
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(rData->qual, 5)))
	, (DUMMYT   D2  WITH SEQ = 1)
 
PLAN D1 WHERE MAXREC(D2, SIZE(rData->qual[D1.SEQ].res, 5))
JOIN D2
 
head report
if(bNewFile = 1)
  "hospital" , "|",
  "patientMRN" , "|",
  "admitDtTm" , "|",
  "dischDtTm" , "|",
  "updtDtTm" , "|",
  "visitNum" , "|",
  "recordedOn" , "|",
  "orderedDate" , "|",
  "orderedId" , "|",
  "performedDate" , "|",
  "cpt4Code" , "|",
  "orderName" , "|",
  "isAbnormalFlag" , "|",
  "abnormalType" , "|",
  "resultValue" , "|",
  "units" , "|",
  "valueRange" , "|",
  "detailType" , "|",
  "resultName" , "|",
  "nomenclatureType" , "|",
  "nomenclatureValue" , "|",
  "errorField" , "|",
  "eventId" , "|",
  "blobData"
  row + 1
endif
 
detail
  nTotRecCnt = nTotRecCnt + 1
  "CHH" , "|",
  rData->qual[d1.seq].patientMRN , "|",
  rData->qual[d1.seq].admitDtTm , "|",
  rData->qual[d1.seq].dischDtTm , "|",
  rData->qual[d1.seq].sUpdtDtTm , "|",
  rData->qual[d1.seq].visitNum , "|",
  rData->qual[d1.seq].recordedOn , "|",
  rData->qual[d1.seq].orderedDate , "|",
  rData->qual[d1.seq].sOId , "|",
  rData->qual[d1.seq].performedDate , "|",
  rData->qual[d1.seq].cpt4Code , "|",
  rData->qual[d1.seq].PEVENTDISP , "|",
  rData->qual[d1.seq].res[d2.seq].isAbnormalFlag , "|",
  rData->qual[d1.seq].res[d2.seq].abnormalType , "|",
  rData->qual[d1.seq].res[d2.seq].sR6_res_val , "|",
  rData->qual[d1.seq].res[d2.seq].sR7_res_unit , "|",
  rData->qual[d1.seq].res[d2.seq].valueRange , "|",
  rData->qual[d1.seq].detailType , "|",
  rData->qual[d1.seq].res[d2.seq].res_disp , "|",
  rData->qual[d1.seq].nomenclatureType , "|",
  rData->qual[d1.seq].nomenclatureValue , "|",
  rData->qual[d1.seq].errorField , "|",
  rData->qual[d1.seq].sPEId , "|",
  rData->qual[d1.seq].sR6_res_val
  row + 1
with maxrow = 1, maxcol = 32000, format = variable, append
 
#EXIT_SCRIPT
free record rData
end go
 
 
