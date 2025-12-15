 
;***************************************************************************
; WORKER FILE PROPERTY VARIABLE DECLARATIONS
;***************************************************************************
declare WRK_FILE_TS		  = vc with protect, noconstant("")
declare WRK_FILE_TS1	  = vc with protect, noconstant("")
declare WRK_FILE_TS2	  = vc with protect, noconstant("")
declare WRK_FILE_EXT1	  = vc with protect, noconstant("")
declare WRK_FILE_EXT2	  = vc with protect, noconstant("")
declare WRK_FILE_NAME1	  = vc with protect, noconstant("")
declare WRK_FILE_NAME2	  = vc with protect, noconstant("")
declare WRK_FILE_PATH1	  = vc with protect, noconstant("")
declare WRK_FILE_PATH2	  = vc with protect, noconstant("")
declare WRK_FILE_PREFIX	  = vc with protect, noconstant("")
declare WRK_FILE_SUFFIX	  = vc with protect, noconstant("")
declare WRK_TEMP_PATH1	  = vc with protect, noconstant("")
declare WRK_TEMP_PATH2	  = vc with protect, noconstant("")
declare WRK_TEMP_LOG	  = vc with protect, noconstant("")
declare WRK_CERN_PATH	  = vc with protect, noconstant("")
declare WRK_CERN_DOMAIN	  = vc with protect, noconstant("")
declare WRK_CERN_PREFIX	  = vc with protect, noconstant("")
 
;***************************************************************************
; WORKER OS COMMAND VARIABLE DECLARATIONS
;***************************************************************************
declare WRK_DCL_STATUS	= i4  with protect, noconstant(0)
declare WRK_DCL_CMD		= vc  with protect, noconstant("")
 
;***************************************************************************
; WORKER VARIABLE DECLARATIONS
;***************************************************************************
declare WRK_FAIL_IND	= i2  with protect, noconstant(0)
declare WRK_BEG_DT_TM	= dq8 with protect, noconstant(0)
declare WRK_END_DT_TM	= dq8 with protect, noconstant(0)
declare WRK_MIN_DT_TM	= dq8 with protect, noconstant(0)
declare WRK_MAX_DT_TM	= dq8 with protect, noconstant(0)
declare WRK_CNT1		= i4  with protect, noconstant(0)
declare WRK_CNT2		= i4  with protect, noconstant(0)
declare WRK_CNT3		= i4  with protect, noconstant(0)
declare WRK_POS1		= i4  with protect, noconstant(0)
declare WRK_POS2		= i4  with protect, noconstant(0)
declare WRK_POS3		= i4  with protect, noconstant(0)
declare WRK_DISP1		= vc  with protect,	noconstant("")
declare WRK_DISP2		= vc  with protect,	noconstant("")
declare WRK_DISP3		= vc  with protect,	noconstant("")
declare WRK_ORG_ID		= f8  with protect,	noconstant(0.0)
declare WRK_ORG_TAX_ID	= f8  with protect,	noconstant(0.0)
declare WRK_ORG_NAME	= vc  with protect,	noconstant("")
declare WRK_ORG_CNT		= i4  with protect,	noconstant(0)
declare WRK_NORMAL_LOW	= vc  with protect,	noconstant("")
declare WRK_NORMAL_HIGH	= vc  with protect,	noconstant("")
 
;***************************************************************************
; THE ORGANIZATION RECORD STRUCTURE DEFINITION
;***************************************************************************
free record WRKORG
record WRKORG
(
1 org_cnt		= i4
1 org[*]
2 org_id		= f8
2 org_name		= vc
2 org_tax_id	= vc
)
 
;***************************************************************************
; THE PATIENT ONLY RECORD STRUCTURE DEFINITION
;***************************************************************************
free record WRKFHC1
record WRKFHC1
(
1 acct_cnt			= i4
1 acct[*]
2 person_id			= f8
2 mrn				= vc
2 cmrn		  		= vc
2 ssn				= vc
2 birth_dt_tm		= dq8
2 birth_dt			= vc
2 gender			= vc
2 encntr_id			= f8
2 acct_no			= vc
2 name_last			= vc
2 name_middle		= vc
2 name_first		= vc
2 name_full			= vc
2 street_addr1		= vc
2 street_addr2		= vc
2 street_addr3		= vc
2 state_cd			= f8
2 state				= vc
2 zipcode			= vc
2 phone_home		= vc
2 phone_work		= vc
2 fac_cd			= f8
2 fac_name			= vc
)
 
;***************************************************************************
; THE PATIENT/LAB RECORD STRUCTURE DEFINITION
;***************************************************************************
free record WRKFHC2
record WRKFHC2
(
1 lab_cnt			= i4
1 lab[*]
2 person_id			= f8
2 mrn				= vc
2 cmrn		  		= vc
2 ssn				= vc
2 birth_dt_tm		= dq8
2 birth_dt			= vc
2 gender			= vc
2 encntr_id			= f8
2 acct_no			= vc
2 name_last			= vc
2 name_middle		= vc
2 name_first		= vc
2 name_full			= vc
2 street_addr1		= vc
2 street_addr2		= vc
2 street_addr3		= vc
2 state_cd			= f8
2 state				= vc
2 zipcode			= vc
2 phone_home		= vc
2 phone_work		= vc
2 fac_cd			= f8
2 fac_name			= vc
2 order_id			= f8
2 order_name		= vc
2 order_dt_tm		= dq8
2 order_dt		 	= vc
2 order_status_cd	= f8
2 order_status		= vc
2 entered_by		= vc
2 ordered_by_id		= f8
2 ordered_by_npi	= vc
2 ordered_by		= vc
2 ordered_by_first	= vc
2 ordered_by_last	= vc
2 event_cnt			= i4
2 event[*]
3 loinc			 	= vc
3 event_type		= vc
3 event_cd		 	= f8
3 event_dt_tm		= dq8
3 event_dt		 	= vc
3 event_name		= vc
3 value				= vc
3 units_cd		 	= f8
3 units			 	= vc
3 ref_range			= vc
3 status_cd		 	= f8
3 status			= vc
3 accession			= vc
3 perform_dt_tm		= dq8
3 perform_dt		= vc
3 performed_by_id	= f8
3 performed_by		= vc
3 event_seq			= i4
)
 
free record WRKMSG
record WRKMSG
(
1 msg_cnt	= i4
1 msg[*]
2 msg		= vc
2 msg_flag	= i2 ;1=FAIL, 0=NORMAL
)
 
;***************************************************************************
; UTILITY SUBROUTINE PROTOTYPE DECLARATIONS
;***************************************************************************
declare LogMSG(p1=vc, p2=i2(value, 0))	= null with public
declare EchoMSG(p1=vc, p2=i2(value, 0))	= null with public
declare RemoveTrailingZeros(p1 = vc)	= vc   with public
 
;***************************************************************************
; SUBROUTINE PROTOTYPE DECLARATIONS
;***************************************************************************
declare SetOptions(null)		= i2 with protect
declare GetPatients(null)		= i2 with protect
declare GetLabResults(null)		= i2 with protect
declare WriteHeader(null)		= i2 with protect
declare WriteLabResults(null)	= i2 with protect
 
;***************************************************************************
; SUBROUTINE TO SET THE EXECUTION OPTIONS FOR THIS EXTRACT
;***************************************************************************
subroutine SetOptions(null)
 
declare auto_ind = i2 with protect, noconstant(0)
 
declare beg_disch_dt = vc with protect, noconstant(cnvtupper(trim($1, 3)))
declare end_disch_dt = vc with protect, noconstant(cnvtupper(trim($2, 3)))
 
if (beg_disch_dt = "AUTO")
	set WRK_BEG_DT_TM = cnvtdatetime(CURDATE-14, 000000)
else
	set WRK_BEG_DT_TM = cnvtdatetime(cnvtdate(cnvtdatetime(beg_disch_dt)), 000000)
endif
 
if (WRK_BEG_DT_TM > WRK_EXEC_DT_TM)
	call LogMSG("**** INVALID BEGIN DATE ****", 1)
	return (-1)
endif
 
if (end_disch_dt = "AUTO")
	set WRK_END_DT_TM = cnvtdatetime(CURDATE-1, 235959)
else
	set WRK_END_DT_TM = cnvtdatetime(cnvtdate(cnvtdatetime(end_disch_dt)), 235959)
endif
 
if (WRK_BEG_DT_TM > WRK_END_DT_TM)
	call LogMSG("**** INVALID BEGIN/END DATE RANGE ****", 1)
	return (-1)
endif
 
;***************************************************************************
; PARSE THE ORGANIZATION PARAMETER FOR THIS EXECUTION
;***************************************************************************
free record TMPORG
record TMPORG
(
1 org_cnt	= i4
1 org[*]
2 org_id	= f8
)
 
set WRK_CNT1 = 0
set WRK_DISP1 = substring(1, 1, trim(reflect(parameter(3, WRK_CNT1)), 3))
if (not(WRK_DISP1 in ("F", "L")))
	call LogMSG("**** INVALID DATATYPE (ORGANIZATION) ****", 1)
	return (-1)
endif
 
;***************************************************************************
; WAS A SINGLE ORGANIZATION REQUESTED???
;***************************************************************************
set WRK_CNT1 = 1
 
if (WRK_DISP1 = "F")
 
set WRK_ORG_ID = parameter(3, WRK_CNT1)
call EchoMSG(build("**** ORG_ID=", WRK_ORG_ID, " ****"))
 
if (WRK_ORG_ID = 0.0)
	set auto_ind = 1
else
	set TMPORG->org_cnt = 1
	set stat = alterlist(TMPORG->org, TMPORG->org_cnt)
	set TMPORG->org[TMPORG->org_cnt]->org_id = WRK_ORG_ID
endif
 
;***************************************************************************
; WERE MULTIPLE ORGANIZATIONS REQUESTED???
;***************************************************************************
else
 
while (WRK_CNT1 > 0) ;LOOP THROUGH ALL THE PARAMETER'S LIST OF VALUES
 
set WRK_DISP1 = substring(1, 1, trim(reflect(parameter(3, WRK_CNT1)), 3))
if (WRK_DISP1 != "F")
 	set WRK_CNT1 = 0
else
	set WRK_ORG_ID = parameter(1, WRK_CNT1)
	if ((WRK_ORG_ID = 0.0) and (WRK_CNT1 = 1))
		set auto_ind = 1
		set WRK_CNT1 = 0
	else
		set TMPORG->org_cnt = TMPORG->org_cnt + 1
		if (mod(TMPORG->org_cnt, 10) = 1)
			set stat = alterlist(TMPORG->org, (TMPORG->org_cnt + 9))
		endif
		set TMPORG->org[TMPORG->org_cnt]->org_id = WRK_ORG_ID
		set WRK_CNT1 = WRK_CNT1 + 1
	endif
endif
 
endwhile
 
set stat = alterlist(TMPORG->org, TMPORG->org_cnt)
 
endif
 
;***************************************************************************
; USE THE DEFAULT ORGANIZATIONS FOR THIS EXECUTION
;***************************************************************************
if (auto_ind = 1)
 
select into "nl:"
from organization o
plan o where o.organization_id in (
		628085.0,	;GEORGETOWN UNIVERSITY HOSPITAL
		589723.0,	;FRANKLIN SQUARE HOSPITAL
		628009.0,	;HARBOR HOSPITAL
		628088.0,	;WASHINGTON HOSPITAL CENTER
		628058.0,	;UNION MEMORIAL HOSPITAL
		628738.0,	;NATIONAL REHAB HOSPITAL
		628751.0,	;PENN MEDICAL
		627889.0,	;GOOD SAM HOSPITAL
		3763758.0,	;MONTGOMERY MEDICAL CENTER
		3837372.0)	;SOUTHERN MARYLAND HOSPITAL
	and o.end_effective_dt_tm > cnvtdatetime(WRK_EXEC_DT_TM)
	and o.active_ind = 1
order by o.org_name, o.organization_id
head report
	WRK_CNT1 = 0
head o.organization_id
	WRK_CNT1 = WRK_CNT1 + 1
	if (mod(WRK_CNT1, 10) = 1)
	stat = alterlist(WRKORG->org, (WRK_CNT1 + 9))
	endif
	WRKORG->org[WRK_CNT1]->org_id = o.organization_id
	WRKORG->org[WRK_CNT1]->org_name = trim(o.org_name, 3)
	WRKORG->org[WRK_CNT1]->org_tax_id = trim(o.federal_tax_id_nbr, 3)
foot report
	WRKORG->org_cnt = WRK_CNT1
	stat = alterlist(WRKORG->org, WRKORG->org_cnt)
with nocounter, time=300
 
if (error(WRK_ERR_MSG, 0) > 0)
	call LogMSG("**** THE DEFAULT ORG QUERY HAS FAILED ****", 1)
	return (-1)
endif
 
;***************************************************************************
; USE THE SPECIFIED ORGANIZATIONS FOR THIS EXECUTION
;***************************************************************************
else
 
select into "nl:"
from organization o
plan o where expand(WRK_CNT1, 1, TMPORG->org_cnt, o.organization_id, TMPORG->org[WRK_CNT1]->org_id)
	and o.end_effective_dt_tm > cnvtdatetime(WRK_EXEC_DT_TM)
	and o.active_ind = 1
order by o.org_name, o.organization_id
head report
	WRK_CNT1 = 0
head o.organization_id
	if (o.organization_id != 0.0)
	WRK_CNT1 = WRK_CNT1 + 1
	if (mod(WRK_CNT1, 10) = 1)
	stat = alterlist(WRKORG->org, (WRK_CNT1 + 9))
	endif
	WRKORG->org[WRK_CNT1]->org_id = o.organization_id
	WRKORG->org[WRK_CNT1]->org_name = trim(o.org_name, 3)
	WRKORG->org[WRK_CNT1]->org_tax_id = trim(o.federal_tax_id_nbr, 3)
	endif
foot report
	WRKORG->org_cnt = WRK_CNT1
	stat = alterlist(WRKORG->org, WRKORG->org_cnt)
with nocounter, time=300
 
if (error(WRK_ERR_MSG, 0) > 0)
	call LogMSG("**** THE ORG QUERY HAS FAILED ****", 1)
	return (-1)
endif
 
endif
 
if (DEBUG_IND = 1)
	call echorecord(WRKORG)
endif
 
free record TMPORG
 
return (1)
 
end ;SetOptions
 
;***************************************************************************
; SUBROUTINE TO GET INFO FOR FHC PATIENTS DISCHARGED DURING THE TIMEFRAME
;***************************************************************************
subroutine GetPatients(null)
 
call EchoMSG(build("DT1=", format(WRK_MIN_DT_TM, "DD-MMM-YYYY HH:MM;;Q")))
call EchoMSG(build("DT2=", format(WRK_MAX_DT_TM, "DD-MMM-YYYY HH:MM;;Q")))
 
;***************************************************************************
; GET ALL FHC PATIENTS DISCHARGED DURING THE SPECIFIC TIMEFRAME
;***************************************************************************
select into "nl:"
from encounter e
	,encntr_alias ea1
	,person p
	,person_alias pa1
	,person_alias pa2
	,person_alias pa3
plan e where e.disch_dt_tm >= cnvtdatetime(WRK_MIN_DT_TM)
	and e.disch_dt_tm <= cnvtdatetime(WRK_MAX_DT_TM)
	and e.organization_id = WRK_ORG_ID
	and e.encntr_status_cd = 856.0 ;DISCHARGED
	and e.active_ind = 1
	and 1 = (select 1 from encntr_plan_reltn epr, health_plan_alias hpa
		where epr.encntr_id = e.encntr_id
		and epr.end_effective_dt_tm > cnvtdatetime(WRK_EXEC_DT_TM)
		and epr.active_ind = 1
		and hpa.health_plan_id = epr.health_plan_id
		and hpa.end_effective_dt_tm > cnvtdatetime(WRK_EXEC_DT_TM)
		and cnvtupper(hpa.alias) = "J02"
		and hpa.active_ind = 1)
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.encntr_alias_type_cd = 1077.0 ;FIN
	and ea1.end_effective_dt_tm > cnvtdatetime(WRK_EXEC_DT_TM)
	and ea1.active_ind = 1
join p where p.person_id = e.person_id
join pa1 where pa1.person_id = p.person_id
	and pa1.person_alias_type_cd = 10.0 ;MRN
	and pa1.end_effective_dt_tm > cnvtdatetime(WRK_EXEC_DT_TM)
	and pa1.active_ind = 1
join pa2 where outerjoin(p.person_id) = pa2.person_id
	and pa2.person_alias_type_cd = outerjoin(2.0) ;CMRN
	and pa2.end_effective_dt_tm > outerjoin(cnvtdatetime(WRK_EXEC_DT_TM))
	and pa2.active_ind = outerjoin(1)
join pa3 where outerjoin(p.person_id) = pa3.person_id
	and pa3.person_alias_type_cd = outerjoin(18.0) ;SSN
	and pa3.end_effective_dt_tm > outerjoin(cnvtdatetime(WRK_EXEC_DT_TM))
	and pa3.active_ind = outerjoin(1)
order by e.encntr_id
head report
	WRK_CNT1 = 0
head e.encntr_id
	WRK_CNT1 = WRK_CNT1 + 1
	if (mod(WRK_CNT1, 1000) = 1)
	stat = alterlist(WRKFHC1->acct, (WRK_CNT1 + 999))
	endif
	WRKFHC1->acct[WRK_CNT1]->person_id		= p.person_id
	WRKFHC1->acct[WRK_CNT1]->mrn			= trim(cnvtalias(pa1.alias, pa1.alias_pool_cd), 3)
	WRKFHC1->acct[WRK_CNT1]->cmrn			= trim(cnvtalias(pa2.alias, pa2.alias_pool_cd), 3)
	WRKFHC1->acct[WRK_CNT1]->ssn			= trim(pa3.alias, 3)
	WRKFHC1->acct[WRK_CNT1]->name_last		= trim(p.name_last, 3)
	WRKFHC1->acct[WRK_CNT1]->name_middle	= trim(p.name_middle, 3)
	WRKFHC1->acct[WRK_CNT1]->name_first		= trim(p.name_first, 3)
	WRKFHC1->acct[WRK_CNT1]->name_full		= trim(p.name_full_formatted, 3)
	WRKFHC1->acct[WRK_CNT1]->birth_dt_tm	= cnvtdatetime(p.birth_dt_tm)
	WRKFHC1->acct[WRK_CNT1]->birth_dt		= trim(format(p.birth_dt_tm, "YYYYMMDD;;Q"), 3)
	WRKFHC1->acct[WRK_CNT1]->gender			= substring(1, 1, trim(uar_get_code_display(p.sex_cd), 3))
	WRKFHC1->acct[WRK_CNT1]->encntr_id		= e.encntr_id
	WRKFHC1->acct[WRK_CNT1]->acct_no		= trim(cnvtalias(ea1.alias, ea1.alias_pool_cd), 3)
	WRKFHC1->acct[WRK_CNT1]->fac_cd			= e.loc_facility_cd
	WRKFHC1->acct[WRK_CNT1]->fac_name		= trim(uar_get_code_display(e.loc_facility_cd), 3)
foot report
	WRKFHC1->acct_cnt = WRK_CNT1
	stat = alterlist(WRKFHC1->acct, WRKFHC1->acct_cnt)
with nocounter, orahintcbo("index (e xie4encounter)","index (epr xie1encntr_plan_reltn)"), time=300
 
if (error(WRK_ERR_MSG, 0) > 0)
	call LogMSG("**** THE FHC PATIENT QUERY HAS FAILED ****", 1)
	return (-1)
endif
 
if (WRKFHC1->acct_cnt = 0)
	return (0)
endif
 
;***************************************************************************
; GET HOME ADDRESS INFORMATION FOR QUALIFYING FHC PATIENTS
;***************************************************************************
select into "nl:"
from (dummyt d1 with seq = value(WRKFHC1->acct_cnt))
	,address a
plan d1 where WRKFHC1->acct[d1.seq]->person_id != 0.0
join a where a.parent_entity_id = WRKFHC1->acct[d1.seq]->person_id
	and a.parent_entity_name = "PERSON"
	and a.address_type_cd = 756.0
	and a.end_effective_dt_tm > cnvtdatetime(WRK_EXEC_DT_TM)
	and a.active_ind = 1
order by d1.seq
head d1.seq
	WRKFHC1->acct[d1.seq]->street_addr1 = trim(a.street_addr, 3)
	WRKFHC1->acct[d1.seq]->street_addr2 = trim(a.street_addr2, 3)
	WRKFHC1->acct[d1.seq]->street_addr3 = trim(a.street_addr3, 3)
	WRKFHC1->acct[d1.seq]->state_cd		= a.state_cd
	WRKFHC1->acct[d1.seq]->state		= trim(uar_get_code_display(a.state_cd), 3)
	WRKFHC1->acct[d1.seq]->zipcode		= trim(a.zipcode, 3)
with nocounter, time=300
 
if (error(WRK_ERR_MSG, 0) > 0)
	call LogMSG("**** THE HOME ADDRESS QUERY HAS FAILED ****", 1)
	return (-1)
endif
 
;***************************************************************************
; GET HOME PHONE INFORMATION FOR QUALIFYING FHC PATIENTS
;***************************************************************************
select into "nl:"
from (dummyt d1 with seq = value(WRKFHC1->acct_cnt))
	,phone p
plan d1 where WRKFHC1->acct[d1.seq]->person_id != 0.0
join p where p.parent_entity_id = WRKFHC1->acct[d1.seq]->person_id
	and p.parent_entity_name = "PERSON"
	and p.phone_type_cd in (170.0, 84428725.0)
	and p.end_effective_dt_tm > cnvtdatetime(WRK_EXEC_DT_TM)
	and p.active_ind = 1
order by d1.seq
head d1.seq
	WRKFHC1->acct[d1.seq]->phone_home = trim(p.phone_num, 3)
with nocounter, time=300
 
if (error(WRK_ERR_MSG, 0) > 0)
	call LogMSG("**** THE HOME PHONE QUERY HAS FAILED ****", 1)
	return (-1)
endif
 
call EchoMSG(build("*** TOTAL PATIENTS=", WRKFHC1->acct_cnt, " ***"))
 
return (1)
 
end ;GetPatients
 
;***************************************************************************
; SUBROUTINE TO GET LAB/RESULT INFORMATION FOR EACH PATIENT
;***************************************************************************
subroutine GetLabResults(null)
 
if (WRKFHC1->acct_cnt = 0)
	return (0)
endif
 
select into "nl:"
from orders o
	,order_action oa
	,prsnl p1
	,prsnl_alias pa1
	,prsnl p2
	,result r
	,perform_result pr
	,reference_range_factor rrf
	,clinical_event ce
	,prsnl p3
plan o where expand(WRK_CNT1, 1, WRKFHC1->acct_cnt, o.encntr_id, WRKFHC1->acct[WRK_CNT1]->encntr_id)
	and o.catalog_type_cd = 2513.0
	and o.order_status_cd not in (2542.0, 2545.0, 643467.0)
	and o.template_order_flag in (0, 1, 5)
	and o.active_ind = 1
join oa where oa.order_id = o.order_id
	and oa.action_type_cd = 2534.0
	and oa.action_sequence = 1
join p1 where outerjoin(oa.order_provider_id) = p1.person_id
join pa1 where outerjoin(p1.person_id) = pa1.person_id
	and pa1.prsnl_alias_type_cd = outerjoin(4038127.0)
	and pa1.end_effective_dt_tm > outerjoin(cnvtdatetime(CURDATE,CURTIME3))
	and pa1.active_ind = outerjoin(1)
join p2 where outerjoin(oa.action_personnel_id) = p2.person_id
join r where r.order_id = o.order_id
join pr where pr.result_id = r.result_id
	and pr.result_status_cd in (1738.0, 1721.0, 1722.0, 1723.0)
join rrf where outerjoin(pr.reference_range_factor_id) = rrf.reference_range_factor_id
join ce where ce.order_id = r.order_id
	and ce.task_assay_cd = r.task_assay_cd
	and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100")
	and ce.result_status_cd not in (28.0, 29.0, 30.0, 31.0)
	and cnvtupper(ce.event_tag) != "DATE\TIME CORRECTION"
	and ce.view_level = 1
join p3 where outerjoin(pr.perform_personnel_id) = p3.person_id
order by o.encntr_id, o.order_id, cnvtdatetime(pr.perform_dt_tm), r.result_id
head report
	WRK_CNT1 = 0
head o.encntr_id
	WRK_POS1 = locatevalsort(WRK_CNT3, 1, WRKFHC1->acct_cnt, o.encntr_id, WRKFHC1->acct[WRK_CNT3]->encntr_id)
head o.order_id
	WRK_CNT2 = 0
	WRK_CNT1 = WRK_CNT1 + 1
	if (mod(WRK_CNT1, 1000) = 1)
	stat = alterlist(WRKFHC2->lab, (WRK_CNT1 + 999))
	endif
	WRKFHC2->lab[WRK_CNT1]->order_id			= o.order_id
	WRKFHC2->lab[WRK_CNT1]->order_name			= trim(o.order_mnemonic, 3)
	WRKFHC2->lab[WRK_CNT1]->order_dt_tm			= cnvtdatetime(o.orig_order_dt_tm)
	WRKFHC2->lab[WRK_CNT1]->order_dt		 	= trim(format(o.orig_order_dt_tm, "YYYYMMDD;;Q"), 3)
	WRKFHC2->lab[WRK_CNT1]->order_status_cd		= o.order_status_cd
	WRKFHC2->lab[WRK_CNT1]->order_status		= trim(uar_get_code_display(o.order_status_cd), 3)
	WRKFHC2->lab[WRK_CNT1]->entered_by			= trim(p2.name_full_formatted, 3)
	WRKFHC2->lab[WRK_CNT1]->ordered_by_id		= p1.person_id
	WRKFHC2->lab[WRK_CNT1]->ordered_by_npi		= trim(cnvtalias(pa1.alias, pa1.alias_pool_cd), 3)
	WRKFHC2->lab[WRK_CNT1]->ordered_by			= trim(p1.name_full_formatted, 3)
	WRKFHC2->lab[WRK_CNT1]->ordered_by_first	= trim(p1.name_first, 3)
	WRKFHC2->lab[WRK_CNT1]->ordered_by_last		= trim(p1.name_last, 3)
head r.result_id
	WRK_CNT2 = WRK_CNT2 + 1
	if (mod(WRK_CNT2, 20) = 1)
	stat = alterlist(WRKFHC2->lab[WRK_CNT1]->event, (WRK_CNT2 + 19))
	endif
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->loinc			 	= ""
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->event_cd		 	= ce.event_cd
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->event_dt_tm		= cnvtdatetime(ce.event_end_dt_tm)
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->event_dt		 	= trim(format(ce.event_end_dt_tm, "YYYYMMDD;;Q"), 3)
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->event_name			= trim(uar_get_code_display(ce.event_cd), 3)
	WRK_DISP1 = trim(pr.result_value_alpha, 3)
	if (WRK_DISP1 > "")
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->event_type			= "ST"
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->value				= WRK_DISP1
	else
	WRK_DISP1 = trim(cnvtstring(pr.result_value_numeric, 35, 3), 3)
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->event_type			= "NM"
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->value				= WRK_DISP1
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->units_cd			= pr.units_cd
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->units			 	= trim(uar_get_code_display(pr.units_cd), 3)
	endif
;	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->value			 	= trim(ce.result_val, 3)
;	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->units_cd		 	= ce.result_units_cd
;	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->units			 	= trim(uar_get_code_display(ce.result_units_cd), 3)
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->status_cd		 	= r.result_status_cd
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->status			 	= trim(uar_get_code_display(r.result_status_cd), 3)
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->accession			= trim(ce.accession_nbr, 3)
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->perform_dt_tm		= cnvtdatetime(pr.perform_dt_tm)
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->perform_dt			= trim(format(pr.perform_dt_tm, "YYYYMMDD;;Q"), 3)
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->performed_by_id	= p3.person_id
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->performed_by		= trim(p3.name_full_formatted, 3)
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->event_seq			= WRK_CNT2
	if ((rrf.reference_range_factor_id != 0.0) and (rrf.normal_ind > 0))
	WRK_NORMAL_LOW = trim(cnvtstring(rrf.normal_low, 35, 6), 3)
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->ref_range = RemoveTrailingZeros(WRK_NORMAL_LOW)
	if (WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->ref_range = "")
	WRK_NORMAL_HIGH = trim(cnvtstring(rrf.normal_high, 35, 6), 3)
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->ref_range = RemoveTrailingZeros(WRK_NORMAL_HIGH)
	else
	WRK_NORMAL_HIGH = trim(cnvtstring(rrf.normal_high, 35, 6), 3)
	WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->ref_range =
	concat(WRKFHC2->lab[WRK_CNT1]->event[WRK_CNT2]->ref_range, "-", RemoveTrailingZeros(WRK_NORMAL_HIGH))
	endif
	endif
foot o.order_id
	WRKFHC2->lab[WRK_CNT1]->event_cnt = WRK_CNT2
	stat = alterlist(WRKFHC2->lab[WRK_CNT1]->event, WRKFHC2->lab[WRK_CNT1]->event_cnt)
	WRKFHC2->lab[WRK_CNT1]->person_id		= WRKFHC1->acct[WRK_POS1]->person_id
	WRKFHC2->lab[WRK_CNT1]->mrn				= WRKFHC1->acct[WRK_POS1]->mrn
	WRKFHC2->lab[WRK_CNT1]->cmrn			= WRKFHC1->acct[WRK_POS1]->cmrn
	WRKFHC2->lab[WRK_CNT1]->ssn				= WRKFHC1->acct[WRK_POS1]->ssn
	WRKFHC2->lab[WRK_CNT1]->name_last		= WRKFHC1->acct[WRK_POS1]->name_last
	WRKFHC2->lab[WRK_CNT1]->name_middle		= WRKFHC1->acct[WRK_POS1]->name_middle
	WRKFHC2->lab[WRK_CNT1]->name_first		= WRKFHC1->acct[WRK_POS1]->name_first
	WRKFHC2->lab[WRK_CNT1]->name_full		= WRKFHC1->acct[WRK_POS1]->name_full
	WRKFHC2->lab[WRK_CNT1]->birth_dt_tm		= WRKFHC1->acct[WRK_POS1]->birth_dt_tm
	WRKFHC2->lab[WRK_CNT1]->birth_dt		= WRKFHC1->acct[WRK_POS1]->birth_dt
	WRKFHC2->lab[WRK_CNT1]->gender			= WRKFHC1->acct[WRK_POS1]->gender
	WRKFHC2->lab[WRK_CNT1]->encntr_id		= WRKFHC1->acct[WRK_POS1]->encntr_id
	WRKFHC2->lab[WRK_CNT1]->acct_no			= WRKFHC1->acct[WRK_POS1]->acct_no
	WRKFHC2->lab[WRK_CNT1]->street_addr1	= WRKFHC1->acct[WRK_POS1]->street_addr1
	WRKFHC2->lab[WRK_CNT1]->street_addr2	= WRKFHC1->acct[WRK_POS1]->street_addr2
	WRKFHC2->lab[WRK_CNT1]->street_addr3	= WRKFHC1->acct[WRK_POS1]->street_addr3
	WRKFHC2->lab[WRK_CNT1]->state_cd		= WRKFHC1->acct[WRK_POS1]->state_cd
	WRKFHC2->lab[WRK_CNT1]->state			= WRKFHC1->acct[WRK_POS1]->state
	WRKFHC2->lab[WRK_CNT1]->zipcode			= WRKFHC1->acct[WRK_POS1]->zipcode
	WRKFHC2->lab[WRK_CNT1]->phone_home		= WRKFHC1->acct[WRK_POS1]->phone_home
	WRKFHC2->lab[WRK_CNT1]->phone_work		= WRKFHC1->acct[WRK_POS1]->phone_work
foot report
	WRKFHC2->lab_cnt = WRK_CNT1
	stat = alterlist(WRKFHC2->lab, WRKFHC2->lab_cnt)
with nocounter, orahintcbo("index (o xie2orders)"), time=300
 
if (error(WRK_ERR_MSG, 0) > 0)
	call LogMSG("**** THE LAB RESULT QUERY HAS FAILED ****", 1)
	return (-1)
endif
 
if (DEBUG_IND = 1)
	call echorecord(WRKFHC2)
endif
 
return (evaluate(WRKFHC2->lab_cnt, 0, 0, 1))
 
end ;GetLabResults
 
;***************************************************************************
; SUROUTINE TO WRITE THE HEADER ROW FOR THE EXTRACT FILE
;***************************************************************************
subroutine WriteHeader(null)
 
select into value(WRK_FILE_PATH1)
	 "SenderFileName"
	,"PID_01_SetIdPatientId"
	,"PID_02_PatientIdExternalId_CX_00_Id"
	,"PID_03_PatientIdInternalId_CX_00_Id"
	,"PID_04_AlternatePatientId_CX_00_Id"
	,"PID_05_PatientName_XPN_00_FamilyName"
	,"PID_05_PatientName_XPN_01_GivenName"
	,"PID_05_PatientName_XPN_02_MiddleInitialOrName"
	,"PID_07_DateOfBirth_TS_00_TimeOfAnEvent"
	,"PID_08_Sex"
	,"PID_10_Race"
	,"PID_11_PatientAddress_XAD_00_StreetAddress"
	,"PID_11_PatientAddress_XAD_02_City"
	,"PID_11_PatientAddress_XAD_03_StateOrProvince"
	,"PID_11_PatientAddress_XAD_04_ZipOrPostalCode"
	,"PID_13_PhoneNumberHome"
	,"PID_14_PhoneNumberBusiness"
	,"PID_15_PrimaryLanguage_CE_0296_0_Identifier"
	,"PID_15_PrimaryLanguage_CE_0296_1_Text"
	,"PID_16_MaritalStatus"
	,"PID_17_Religion"
	,"PID_18_PatientAccountNumber_CX_00_Id"
	,"PID_19_SsnNumberPatient"
	,"PID_20_DriverSLicenseNumber_DLN_0_DriverSLicenseNumber"
	,"PID_20_DriverSLicenseNumber_DLN_1_IssuingStateProvinceCountry"
	,"PID_20_DriverSLicenseNumber_DLN_2_ExpirationDate"
	,"PID_21_MotherSIdentifier_CX_00_Id"
	,"PID_22_EthnicGroup"
	,"PID_23_BirthPlace"
	,"ORC_1_OrderControl"
	,"ORC_2_PlacerOrderNumber_EI_0_EntityIdentifier"
	,"ORC_3_FillerOrderNumber_EI_0_EntityIdentifier"
	,"ORC_4_PlacerGroupNumber_EI_0_EntityIdentifier"
	,"ORC_5_OrderStatus"
	,"ORC_6_ResponseFlag"
	,"ORC_7_QuantityTiming"
	,"ORC_8_Parent"
	,"ORC_9_DateTimeOfTransaction_TS_00_TimeOfAnEvent"
	,"ORC_10_EnteredBy"
	,"ORC_11_VerifiedBy"
	,"ORC_12_OrderingProvider_XCN_00_IdNumberSt"
	,"ORC_12_OrderingProvider_XCN_01_FamilyName"
	,"ORC_12_OrderingProvider_XCN_02_GivenName"
	,"ORC_12_OrderingProvider_XCN_03_MiddleInitialOrName"
	,"ORC_12_OrderingProvider_XCN_12_IdentifierTypeCode"
	,"ORC_13_EntererSLocation"
	,"ORC_14_CallBackPhoneNumber"
	,"ORC_15_OrderEffectiveDateTime"
	,"ORC_16_OrderControlCodeReason_CE_0_Identifier"
	,"ORC_16_OrderControlCodeReason_CE_1_Text"
	,"ORC_17_EnteringOrganizationCE_0_Identifier"
	,"ORC_17_EnteringOrganizationCE_1_Text"
	,"ORC_18_EnteringDevice_CE_0_Identifier"
	,"ORC_18_EnteringDevice_CE_1_Text"
	,"ORC_18_EnteringDevice_CE_2_NameOfCodingSystem"
	,"ORC_19_ActionBy_XCN_00_IdNumberSt"
	,"ORC_19_ActionBy_XCN_01_FamilyName"
	,"ORC_19_ActionBy_XCN_02_GivenName"
	,"ORC_19_ActionBy_XCN_03_MiddleInitialOrName"
	,"OBX_1_SetIdObx"
	,"OBX_2_ValueType"
	,"OBX_3_ObservationIdentifier_CE_0_Identifier"
	,"OBX_3_ObservationIdentifier_CE_1_Text"
	,"OBX_3_ObservationIdentifier_CE_2_NameOfCodingSystem"
	,"OBX_3_ObservationIdentifier_CE_3_AlternateIdentifier"
	,"OBX_3_ObservationIdentifier_CE_4_AlternateText"
	,"OBX_3_ObservationIdentifier_CE_5_NameOfAlternateCodingSystem"
	,"OBX_4_ObservationSubId"
	,"OBX_5_ObservationValue"
	,"OBX_6_Units_CE_0_Identifier"
	,"OBX_7_ReferencesRange"
	,"OBX_8_AbnormalFlags"
	,"OBX_9_Probability"
	,"OBX_10_NatureOfAbnormalTest"
	,"OBX_11_ObservResultStatus"
	,"OBX_12_DateLastObsNormalValues_TS_00_TimeOfAnEvent"
	,"OBX_13_UserDefinedAccessChecks"
	,"OBX_14_DateTimeOfTheObservation_TS_00_TimeOfAnEvent"
	,"OBX_15_ProducerSId_CE_0_Identifier"
	,"OBX_15_ProducerSId_CE_1_Text"
	,"OBX_15_ProducerSId_CE_2_NameOfCodingSystem"
	,"OBX_16_ResponsibleObserver_XCN_00_IdNumberSt"
	,"OBX_16_ResponsibleObserver_XCN_01_FamilyName"
	,"OBX_16_ResponsibleObserver_XCN_02_GivenName"
	,"OBX_16_ResponsibleObserver_XCN_03_MiddleInitialOrName"
	,"OBX_17_ObservationMethod_CE_0_Identifier"
	,"OBX_17_ObservationMethod_CE_1_Text"
	,"OBR_1_SetIdObservationRequest"
	,"OBR_3_FillerOrderNumber_EI_0_EntityIdentifier"
	,"OBR_4_UniversalServiceIdentifier_CE_0_Identifier"
	,"OBR_4_UniversalServiceIdentifier_CE_1_Text"
	,"OBR_4_UniversalServiceIdentifier_CE_2_NameOfCodingSystem"
	,"OBR_5_Priority"
	,"OBR_6_RequestedDateTime_TS_00_TimeOfAnEvent"
	,"OBR_7_ObservationDateTime_TS_00_TimeOfAnEvent"
	,"OBR_8_ObservationEndDateTime_TS_00_TimeOfAnEvent"
	,"OBR_9_CollectionVolume_CQ_00_Quantity"
	,"OBR_10_CollectorIdentifier_XCN_00_IdNumberSt"
	,"OBR_11_SpecimenActionCode"
	,"OBR_12_DangerCode_CE_0_Identifier"
	,"OBR_13_RelevantClinicalInformation"
	,"OBR_14_SpecimenReceivedDateTime_TS_00_TimeOfAnEvent"
	,"OBR_15_SpecimenSource_CM_SPS_00_SpecimenSourceNameOrCode_00_Identifier"
	,"OBR_16_OrderingProvider_XCN_00_IdNumberSt"
	,"OBR_16_OrderingProvider_XCN_01_FamilyName"
	,"OBR_16_OrderingProvider_XCN_02_GivenName"
	,"OBR_16_OrderingProvider_XCN_03_MiddleInitialOrName"
	,"OBR_16_OrderingProvider_XCN_12_IdentifierTypeCode"
	,"OBR_17_OrderCallbackPhoneNumber_XTN_00_9999999999X99999CAnyText"
	,"OBR_18_PlacerField1"
	,"OBR_19_PlacerField2"
	,"OBR_20_FillerField1"
	,"OBR_21_FillerField2"
	,"OBR_22_ResultsRptStatusChngDateTime_TS_00_TimeOfAnEvent"
	,"OBR_23_ChargeToPractice_CM_MOC_00_DollarAmount_00_Quantity"
	,"OBR_24_DiagnosticServiceSectionId"
	,"OBR_25_ResultStatus"
	,"OBR_26_ParentResult_CM_PRL_00_Obx3ObservationIdentifierOfParentResult_00_Identifier"
	,"OBR_27_QuantityTiming_TQ_00_Quantity_00_Quantity"
	,"OBR_28_ResultCopiesTo_XCN_00_IdNumberSt"
	,"OBR_28_ResultCopiesTo_XCN_01_FamilyName"
	,"OBR_28_ResultCopiesTo_XCN_02_GivenName"
	,"OBR_28_ResultCopiesTo_XCN_03_MiddleInitialOrName"
	,"OBR_29_ParentNumber_CM_EIP_00_ParentSPlacerOrderNumber_00_EntityIdentifier"
	,"OBR_30_TransportationMode"
	,"OBR_31_ReasonForStudy_CE_0_Identifier"
	,"OBR_32_PrincipalResultInterpreter_CM_NDL_00_Name_00_IdNumberSt"
	,"OBR_32_PrincipalResultInterpreter_CM_NDL_00_Name_01_FamilyName"
	,"OBR_32_PrincipalResultInterpreter_CM_NDL_00_Name_02_GivenName"
	,"OBR_32_PrincipalResultInterpreter_CM_NDL_00_Name_03_MiddleInitialOrName"
	,"OBR_33_AssistantResultInterpreter_CM_NDL_00_Name_00_IdNumberSt"
	,"OBR_33_AssistantResultInterpreter_CM_NDL_00_Name_01_FamilyName"
	,"OBR_33_AssistantResultInterpreter_CM_NDL_00_Name_02_GivenName"
	,"OBR_33_AssistantResultInterpreter_CM_NDL_00_Name_03_MiddleInitialOrName"
	,"OBR_34_Technician_CM_NDL_00_Name_00_IdNumberSt"
	,"OBR_34_Technician_CM_NDL_00_Name_01_FamilyName"
	,"OBR_34_Technician_CM_NDL_00_Name_02_GivenName"
	,"OBR_34_Technician_CM_NDL_00_Name_03_MiddleInitialOrName"
	,"OBR_35_Transcriptionist_CM_NDL_00_Name_00_IdNumberSt"
	,"OBR_35_Transcriptionist_CM_NDL_00_Name_01_FamilyName"
	,"OBR_35_Transcriptionist_CM_NDL_00_Name_02_GivenName"
	,"OBR_35_Transcriptionist_CM_NDL_00_Name_03_MiddleInitialOrName"
	,"OBR_36_ScheduledDateTime_TS_00_TimeOfAnEvent"
	,"OBR_37_NumberOfSampleContainers"
	,"OBR_38_TransportLogisticsOfCollectedSample_CE_0_Identifier"
	,"OBR_39_CollectorSComment_CE_0_Identifier"
	,"OBR_40_TransportArrangementResponsibility_CE_0_Identifier"
	,"OBR_41_TransportArranged"
	,"OBR_42_EscortRequired"
	,"OBR_43_PlannedPatientTransportComment_CE_0_Identifier"
	,"NTE_01_SetIdNotesAndComments"
	,"NTE_02_SourceOfComment"
	,"NTE_03_Comment"
from (dummyt d1 with seq = 1)
with NOCOUNTER, FORMAT=STREAM, PCFORMAT("","|",1), NOHEADING, TIME=300, MAXCOL=32000
 
if (error(WRK_ERR_MSG, 0) > 0)
	call EchoMSG("**** UNABLE TO WRITE LAB RESULT HEADER ROW ****", 1)
	return (-1)
endif
 
return (1)
 
end ;WriteHeader
 
;***************************************************************************
; SUBROUTINE TO WRITE THE LAB RESULT ROWS FOR THIS EXECUTION
;***************************************************************************
subroutine WriteLabResults(null)
 
if (WRKFHC2->lab_cnt = 0)
	call EchoMsg("NO LAB RESULTS TO WRITE...")
	return (0)
endif
 
if (SKIP_FILE_IND = 0)
 
select into value(WRK_FILE_PATH1)
	 FIELD00 = substring(1, 40,	WRK_FILE_NAME2)
	,FIELD01 = "" ;PID_01_SetIdPatientId
	,FIELD02 = "" ;PID_02_PatientIdExternalId_CX_00_Id
	,FIELD03 = substring(1, 20,	 WRKFHC2->lab[d1.seq]->cmrn)
	,FIELD04 = substring(1, 20,	 WRKFHC2->lab[d1.seq]->mrn)
	,FIELD05 = substring(1, 48,	 WRKFHC2->lab[d1.seq]->name_last)
	,FIELD06 = substring(1, 48,	 WRKFHC2->lab[d1.seq]->name_first)
	,FIELD07 = substring(1, 1,	 WRKFHC2->lab[d1.seq]->name_middle)
	,FIELD08 = substring(1, 1,	 WRKFHC2->lab[d1.seq]->birth_dt)
	,FIELD09 = substring(1, 1,	 WRKFHC2->lab[d1.seq]->gender)
	,FIELD10 = "" ;PID_10_Race
	,FIELD11 = substring(1, 106, WRKFHC2->lab[d1.seq]->street_addr1)
	,FIELD12 = substring(1, 106, WRKFHC2->lab[d1.seq]->street_addr2)
	,FIELD13 = substring(1, 106, WRKFHC2->lab[d1.seq]->state)
	,FIELD14 = substring(1, 10,  WRKFHC2->lab[d1.seq]->zipcode)
	,FIELD15 = substring(1, 40,	 WRKFHC2->lab[d1.seq]->phone_home)
	,FIELD16 = "" ;PID_14_PhoneNumberBusiness"
	,FIELD17 = "" ;PID_15_PrimaryLanguage_CE_0296_0_Identifier
	,FIELD18 = "" ;PID_15_PrimaryLanguage_CE_0296_1_Text
	,FIELD19 = "" ;PID_16_MaritalStatus
	,FIELD20 = "" ;PID_17_Religion
	,FIELD21 = substring(1, 16,  WRKFHC2->lab[d1.seq]->acct_no)
	,FIELD22 = substring(1, 25,  WRKFHC2->lab[d1.seq]->ssn)
	,FIELD23 = "" ;PID_20_DriverSLicenseNumber_DLN_0_DriverSLicenseNumber
	,FIELD24 = "" ;PID_20_DriverSLicenseNumber_DLN_1_IssuingStateProvinceCountry
	,FIELD25 = "" ;PID_20_DriverSLicenseNumber_DLN_2_ExpirationDate
	,FIELD26 = "" ;PID_21_MotherSIdentifier_CX_00_Id
	,FIELD27 = "" ;PID_22_EthnicGroup
	,FIELD28 = "" ;PID_23_BirthPlace
	,FIELD29 = "" ;ORC_1_OrderControl
	,FIELD030 = substring(1, 35,  cnvtstring(WRKFHC2->lab[d1.seq]->order_id, 35, 0))
	,FIELD031 = substring(1, 35,  cnvtstring(WRKFHC2->lab[d1.seq]->order_id, 35, 0))
	,FIELD032 = "" ;ORC_4_PlacerGroupNumber_EI_0_EntityIdentifier
	,FIELD033 = substring(1, 35,  WRKFHC2->lab[d1.seq]->order_status)
	,FIELD034 = "" ;ORC_6_ResponseFlag
	,FIELD035 = "1"
	,FIELD036 = "" ;ORC_8_Parent
	,FIELD037 = substring(1, 8,   WRKFHC2->lab[d1.seq]->order_dt)
	,FIELD038 = substring(1, 48,  WRKFHC2->lab[d1.seq]->entered_by)
	,FIELD039 = "" ;ORC_11_VerifiedBy
	,FIELD040 = substring(1, 48,  WRKFHC2->lab[d1.seq]->ordered_by_npi)
	,FIELD041 = substring(1, 48,  WRKFHC2->lab[d1.seq]->ordered_by_last)
	,FIELD042 = substring(1, 48,  WRKFHC2->lab[d1.seq]->ordered_by_first)
	,FIELD043 = "" ;ORC_12_OrderingProvider_XCN_03_MiddleInitialOrName
	,FIELD044 = evaluate2(if (WRKFHC2->lab[d1.seq]->ordered_by_npi > "") "NPI" else "" endif)
	,FIELD045 = "" ;ORC_13_EntererSLocation"
	,FIELD046 = "" ;ORC_14_CallBackPhoneNumber"
	,FIELD047 = substring(1, 8,   WRKFHC2->lab[d1.seq]->order_dt)
	,FIELD048 = "" ;ORC_16_OrderControlCodeReason_CE_0_Identifier
	,FIELD049 = "" ;ORC_16_OrderControlCodeReason_CE_1_Text
	,FIELD050 = "L"
	,FIELD051 = substring(1, 20,  WRKFHC2->lab[d1.seq]->fac_name)
	,FIELD052 = "" ;ORC_18_EnteringDevice_CE_0_Identifier
	,FIELD053 = "" ;ORC_18_EnteringDevice_CE_1_Text
	,FIELD054 = "" ;ORC_18_EnteringDevice_CE_2_NameOfCodingSystem
	,FIELD055 = "" ;ORC_19_ActionBy_XCN_00_IdNumberSt
	,FIELD056 = "" ;ORC_19_ActionBy_XCN_01_FamilyName
	,FIELD057 = "" ;ORC_19_ActionBy_XCN_02_GivenName
	,FIELD058 = "" ;ORC_19_ActionBy_XCN_03_MiddleInitialOrName
	,FIELD059 = substring(1, 10,  cnvtstring(WRKFHC2->lab[d1.seq]->event[d2.seq]->event_seq, 10, 0))
	,FIELD060 = substring(1, 2,   WRKFHC2->lab[d1.seq]->event[d2.seq]->event_type)
	,FIELD061 = substring(1, 20,  WRKFHC2->lab[d1.seq]->event[d2.seq]->loinc)
	,FIELD062 = "LOINC"
	,FIELD063 = "LN"
	,FIELD064 = substring(1, 20,  cnvtstring(WRKFHC2->lab[d1.seq]->event[d2.seq]->event_cd, 20, 0))
	,FIELD065 = substring(1, 199, WRKFHC2->lab[d1.seq]->event[d2.seq]->event_name)
	,FIELD066 = "L"
	,FIELD067 = "" ;OBX_4_ObservationSubId"
	,FIELD068 = substring(1, 199, WRKFHC2->lab[d1.seq]->event[d2.seq]->value)
	,FIELD069 = substring(1, 20,  WRKFHC2->lab[d1.seq]->event[d2.seq]->units)
	,FIELD070 = substring(1, 20,  WRKFHC2->lab[d1.seq]->event[d2.seq]->ref_range)
	,FIELD071 = "" ;OBX_8_AbnormalFlags"
	,FIELD072 = "" ;OBX_9_Probability"
	,FIELD073 = "" ;OBX_10_NatureOfAbnormalTest"
	,FIELD074 = substring(1, 15,  WRKFHC2->lab[d1.seq]->event[d2.seq]->status)
	,FIELD075 = "" ;OBX_12_DateLastObsNormalValues_TS_00_TimeOfAnEvent"
	,FIELD076 = "" ;OBX_13_UserDefinedAccessChecks"
	,FIELD077 = substring(1, 8,   WRKFHC2->lab[d1.seq]->event[d2.seq]->perform_dt)
	,FIELD078 = "" ;OBX_15_ProducerSId_CE_0_Identifier"
	,FIELD079 = "" ;OBX_15_ProducerSId_CE_1_Text"
	,FIELD080 = "" ;OBX_15_ProducerSId_CE_2_NameOfCodingSystem"
	,FIELD081 = "" ;OBX_16_ResponsibleObserver_XCN_00_IdNumberSt"
	,FIELD082 = "" ;OBX_16_ResponsibleObserver_XCN_01_FamilyName"
	,FIELD083 = "" ;OBX_16_ResponsibleObserver_XCN_02_GivenName"
	,FIELD084 = "" ;OBX_16_ResponsibleObserver_XCN_03_MiddleInitialOrName"
	,FIELD085 = "" ;OBX_17_ObservationMethod_CE_0_Identifier"
	,FIELD086 = "" ;OBX_17_ObservationMethod_CE_1_Text"
	,FIELD087 = "" ;OBR_1_SetIdObservationRequest"
	,FIELD088 = "" ;OBR_3_FillerOrderNumber_EI_0_EntityIdentifier"
	,FIELD089 = "" ;OBR_4_UniversalServiceIdentifier_CE_0_Identifier"
	,FIELD090 = "" ;OBR_4_UniversalServiceIdentifier_CE_1_Text"
	,FIELD091 = "" ;OBR_4_UniversalServiceIdentifier_CE_2_NameOfCodingSystem"
	,FIELD092 = "" ;OBR_5_Priority"
	,FIELD093 = "" ;OBR_6_RequestedDateTime_TS_00_TimeOfAnEvent"
	,FIELD094 = "" ;OBR_7_ObservationDateTime_TS_00_TimeOfAnEvent"
	,FIELD095 = "" ;OBR_8_ObservationEndDateTime_TS_00_TimeOfAnEvent"
	,FIELD096 = "" ;OBR_9_CollectionVolume_CQ_00_Quantity"
	,FIELD097 = "" ;OBR_10_CollectorIdentifier_XCN_00_IdNumberSt"
	,FIELD098 = "" ;OBR_11_SpecimenActionCode"
	,FIELD099 = "" ;OBR_12_DangerCode_CE_0_Identifier"
	,FIELD100 = "" ;OBR_13_RelevantClinicalInformation"
	,FIELD101 = "" ;OBR_14_SpecimenReceivedDateTime_TS_00_TimeOfAnEvent"
	,FIELD102 = "" ;OBR_15_SpecimenSource_CM_SPS_00_SpecimenSourceNameOrCode_00_Identifier"
	,FIELD103 = "" ;OBR_16_OrderingProvider_XCN_00_IdNumberSt"
	,FIELD104 = "" ;OBR_16_OrderingProvider_XCN_01_FamilyName"
	,FIELD105 = "" ;OBR_16_OrderingProvider_XCN_02_GivenName"
	,FIELD106 = "" ;OBR_16_OrderingProvider_XCN_03_MiddleInitialOrName"
	,FIELD107 = "" ;OBR_16_OrderingProvider_XCN_12_IdentifierTypeCode"
	,FIELD108 = "" ;OBR_17_OrderCallbackPhoneNumber_XTN_00_9999999999X99999CAnyText"
	,FIELD109 = "" ;OBR_18_PlacerField1"
	,FIELD110 = "" ;OBR_19_PlacerField2"
	,FIELD111 = "" ;OBR_20_FillerField1"
	,FIELD112 = "" ;OBR_21_FillerField2"
	,FIELD113 = "" ;OBR_22_ResultsRptStatusChngDateTime_TS_00_TimeOfAnEvent"
	,FIELD114 = "" ;OBR_23_ChargeToPractice_CM_MOC_00_DollarAmount_00_Quantity"
	,FIELD115 = "" ;OBR_24_DiagnosticServiceSectionId"
	,FIELD116 = "" ;OBR_25_ResultStatus"
	,FIELD117 = "" ;OBR_26_ParentResult_CM_PRL_00_Obx3ObservationIdentifierOfParentResult_00_Identifier"
	,FIELD118 = "" ;OBR_27_QuantityTiming_TQ_00_Quantity_00_Quantity"
	,FIELD119 = "" ;OBR_28_ResultCopiesTo_XCN_00_IdNumberSt"
	,FIELD120 = "" ;OBR_28_ResultCopiesTo_XCN_01_FamilyName"
	,FIELD121 = "" ;OBR_28_ResultCopiesTo_XCN_02_GivenName"
	,FIELD122 = "" ;OBR_28_ResultCopiesTo_XCN_03_MiddleInitialOrName"
	,FIELD123 = "" ;OBR_29_ParentNumber_CM_EIP_00_ParentSPlacerOrderNumber_00_EntityIdentifier"
	,FIELD124 = "" ;OBR_30_TransportationMode"
	,FIELD125 = "" ;OBR_31_ReasonForStudy_CE_0_Identifier"
	,FIELD126 = "" ;OBR_32_PrincipalResultInterpreter_CM_NDL_00_Name_00_IdNumberSt"
	,FIELD127 = "" ;OBR_32_PrincipalResultInterpreter_CM_NDL_00_Name_01_FamilyName"
	,FIELD128 = "" ;OBR_32_PrincipalResultInterpreter_CM_NDL_00_Name_02_GivenName"
	,FIELD129 = "" ;OBR_32_PrincipalResultInterpreter_CM_NDL_00_Name_03_MiddleInitialOrName"
	,FIELD130 = "" ;OBR_33_AssistantResultInterpreter_CM_NDL_00_Name_00_IdNumberSt"
	,FIELD131 = "" ;OBR_33_AssistantResultInterpreter_CM_NDL_00_Name_01_FamilyName"
	,FIELD132 = "" ;OBR_33_AssistantResultInterpreter_CM_NDL_00_Name_02_GivenName"
	,FIELD133 = "" ;OBR_33_AssistantResultInterpreter_CM_NDL_00_Name_03_MiddleInitialOrName"
	,FIELD134 = "" ;OBR_34_Technician_CM_NDL_00_Name_00_IdNumberSt"
	,FIELD135 = "" ;OBR_34_Technician_CM_NDL_00_Name_01_FamilyName"
	,FIELD136 = "" ;OBR_34_Technician_CM_NDL_00_Name_02_GivenName"
	,FIELD137 = "" ;OBR_34_Technician_CM_NDL_00_Name_03_MiddleInitialOrName"
	,FIELD138 = "" ;OBR_35_Transcriptionist_CM_NDL_00_Name_00_IdNumberSt"
	,FIELD139 = "" ;OBR_35_Transcriptionist_CM_NDL_00_Name_01_FamilyName"
	,FIELD140 = "" ;OBR_35_Transcriptionist_CM_NDL_00_Name_02_GivenName"
	,FIELD141 = "" ;OBR_35_Transcriptionist_CM_NDL_00_Name_03_MiddleInitialOrName"
	,FIELD142 = "" ;OBR_36_ScheduledDateTime_TS_00_TimeOfAnEvent"
	,FIELD143 = "" ;OBR_37_NumberOfSampleContainers"
	,FIELD144 = "" ;OBR_38_TransportLogisticsOfCollectedSample_CE_0_Identifier"
	,FIELD145 = "" ;OBR_39_CollectorSComment_CE_0_Identifier"
	,FIELD146 = "" ;OBR_40_TransportArrangementResponsibility_CE_0_Identifier"
	,FIELD147 = "" ;OBR_41_TransportArranged"
	,FIELD148 = "" ;OBR_42_EscortRequired"
	,FIELD149 = "" ;OBR_43_PlannedPatientTransportComment_CE_0_Identifier"
	,FIELD150 = "" ;NTE_01_SetIdNotesAndComments
	,FIELD151 = "" ;NTE_02_SourceOfComment
	,FIELD152 = "" ;NTE_03_Comment
from (dummyt d1 with seq = value(WRKFHC2->lab_cnt))
	,(dummyt d2 with seq = 1)
plan d1 where maxrec(d2, WRKFHC2->lab[d1.seq]->event_cnt)
join d2
with NOCOUNTER, APPEND, FORMAT=STREAM, PCFORMAT("","|",1), NOHEADING, TIME=300
 
if (error(WRK_ERR_MSG, 0) > 0)
	call EchoMSG("**** UNABLE TO WRITE LAB RESULT ROWS", 1)
	return (-1)
endif
 
endif
 
return (1)
 
end ;WriteLabResults
 
;***************************************************************************
; SUBROUTINE TO DISPLAY A MESSAGE TO STANDARD OUTPUT. IF DEBUG MODE IS ON
; OR THE FORCE PARAMETER IS TRUE, THE MESSAGE WILL BE FORCED TO DISPLAY
;***************************************************************************
subroutine EchoMSG(p1, p2)
 
set p1 = trim(p1, 3)
if ((p1 > "") and ((DEBUG_IND = 1) or (p2 = 1)))
	call echo(p1)
endif
 
end ;EchoMSG
 
;***************************************************************************
; SUBROUTINE TO LOG MESSAGES TO THE TEMPORARY RECORD. IF DEBUG MODE IS ON
; OR THE FORCE PARAMETER IS TRUE, THE MESSAGE WILL BE FORCED TO DISPLAY
;***************************************************************************
subroutine LogMSG(p1, p2)
 
set p1 = trim(p1, 3)
if (p1 > "")
	set WRKMSG->msg_cnt = WRKMSG->msg_cnt + 1
	set stat = alterlist(WRKMSG->msg, WRKMSG->msg_cnt)
	set WRKMSG->msg[WRKMSG->msg_cnt]->msg = p1
	set WRKMSG->msg[WRKMSG->msg_cnt]->msg_flag = p2
endif
 
end ;LogMSG
 
;***************************************************************************
; SUBROUTINE TO THE REMOVE TRAILING ZEROS FROM A STRING RESULT
;***************************************************************************
subroutine RemoveTrailingZeros(p1)
 
set p1 = trim(p1, 3)
if (p1 = "")
	return ("")
endif
 
declare o_res		= vc with protect, noconstant(p1)
declare o_res_len	= i4 with protect, noconstant(textlen(o_res))
declare n_res		= vc with protect, noconstant("")
 
declare test_ind = i2 with protect, noconstant(1)
declare loop_ind = i2 with protect, noconstant(1)
declare loop_cnt = i2 with protect, noconstant(0)
 
set test_ind = isnumeric(o_res)
if (test_ind != 2)
	return (evaluate(test_ind, 1, o_res, "** ERROR **"))
endif
 
while ((loop_ind = 1) and (loop_cnt < 101))
 
set n_res = substring(o_res_len, 1, o_res)
if (n_res != "0")
	set loop_ind = 0
	set o_res_len = evaluate(n_res, ".", (o_res_len - 1), o_res_len)
else
	set o_res_len = (o_res_len - 1)
endif
 
set loop_cnt = loop_cnt + 1
 
endwhile
 
if (loop_cnt = 101)
	call EchoMSG("**** POSSIBLE INFINITE LOOP DETECTED ****", 1)
endif
 
if (o_res_len > 0)
	return (substring(1, o_res_len, o_res))
else
	return ("")
endif
 
end ;RemoveTrailingZeros
 
 

