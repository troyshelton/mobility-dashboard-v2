/*************************************************************************
 *
 * Program: 1_cust_mp_gen_get_er_encntrs
 * Purpose: Get active ER patient encounter IDs by unit codes (census-based)
 *
 * Issue #78: Shared ER Patient Lists
 * Returns encounter IDs for active ER patients in specified nurse units
 *
 * Usage:
 *   General ER: VALUE(273867287,271306097)  ; GEBB + GER
 *   Memorial ER: VALUE(TBD,TBD)
 *   Teays ER: VALUE(TBD,TBD)
 *   Women and Children's ER: VALUE(TBD,TBD)
 *
 * Based on: Census query for active patients by unit
 * Author: Troy Shelton (Integration Team)
 * Created: 2025-12-08
 * Version: v1 (General ER pilot)
 *
 *************************************************************************/
/*

ED Tracking groups that will be used for ED dropdown menu:

  271365867.00	; ED General Hospital
  271366149.00	; ED Teays Valley
  271366419.00	; ED Women and Children's
   28309431.00	; ED Memorial Hospital
 8800251397.00	; ED Greenbrier
 9799324931.00	; ED Plateau

*/
drop program 1_cust_mp_gen_get_er_encntrs:dba go
create program 1_cust_mp_gen_get_er_encntrs:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Tracking Group:" = 271365867.0 

with OUTDEV, P_TRACKING_GROUP

/*************************************************************************
 * RECORD STRUCTURE
 *************************************************************************/
free record erec
record erec (
    1 patientcnt = i4
    1 patients[*]
        2 encntrId = f8
)

/*************************************************************************
 * MAIN QUERY - Active ER patients using tracking tables (uCern pattern)
 * Based on: ER checkout tracking board query from uCern community
 * Modified: Filter by nurse unit instead of room location
 *************************************************************************/
select distinct into $OUTDEV
p.person_id
from tracking_checkin t,
     tracking_locator tl,
     tracking_item ti,
     encounter e,
     person p

plan t
    where t.tracking_group_cd = $P_TRACKING_GROUP  
    and t.checkout_id = 0.00
    and t.active_ind = 1

join tl
    where tl.tracking_id = t.tracking_id

join ti
    where ti.tracking_id = tl.tracking_id
    and ti.active_ind = 1

join e
    where e.encntr_id = ti.encntr_id
    and e.disch_dt_tm IS NULL  ; Not discharged
    and e.active_ind = 1

join p
    where p.person_id = e.person_id

/*************************************************************************
 * REPORT WRITER - Build encounter ID list
 *************************************************************************/
head report
    cnt = 0

detail
    cnt = cnt + 1
    stat = alterlist(erec->patients, cnt)
    erec->patients[cnt].encntrId = E.ENCNTR_ID

foot report
    erec->patientcnt = cnt

with time = 60, format, uar_code(c,d,e,m,0), format(date, "MM/DD/YYYY hh:mm;;Q")

/*************************************************************************
 * OUTPUT TO JSON (MPage integration pattern)
 * Use _memory_reply_string for XMLCclRequest (respiratory MPage pattern)
 *************************************************************************/
set _memory_reply_string = cnvtrectojson(erec, 4)

#exit_script
end
go
