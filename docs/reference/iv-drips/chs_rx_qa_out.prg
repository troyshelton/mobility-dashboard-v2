drop   program chs_rx_qa_out:DBA go
create program chs_rx_qa_out:DBA
 
prompt 
	"Printer:" = "MINE" 

with OUTDEV
 
/*********************************************************************
Program:        chs_rx_qa_out
 
Programmer:     Michael Rhine
Date:           7/10/2006
Type:           On Demand PowerChart Task->Reports
Run from:
Who/Target:     Quality Outcomes Management
Request by:     June Newton, Pharmacy
 
Request ID:     66
 
Description:    To provide a census to Quality Outcomes management
                of all patients on medications that need follow up screening
 
Criteria:       All bedded patients with Active orders at URMC that are
                on Furosemide.  Should be pulled from the Orders database
                with activity type Pharmacy & status not equaled DC(discontinue)
                or Cancelled (Void)
                furosemide - cv 2758798 cs 200
/**********************************************************************
*                      GENERATED MODIFICATION CONTROL LOG             *
***********************************************************************
*                                                                     *
Mod Date       Worker        Comment                                  *
--- ---------- ------------- ---------------------------------------- *
000 7/17/2006  mrhine maxit  Initial Release in Build                 *
001 8/14/2006  mrhine maxit  URMC and include Urmc First Step Recovery*
002 11/11/06   ATrahan maxit Modified for performance, and qualification
**********************************************************************/
 
 
declare furosemide_cd = f8 with constant(uar_get_code_by("DISPLAY", 200, "furosemide"))

/****************************************************************************
            Array Record Structure
*****************************************************************************/
 
free record temp
record temp
(
  1 org_id        = f8
  1 lncnt         = i4
  1 data[*]
    2 person_id   = f8
    2 encntr_id   = f8
    2 order_id    = f8
    2 patient_name = vc
    2 nurse_unit   = vc
    2 room         = vc
    2 bed          = vc
    2 pat_age      = vc
    2 start_date   = f8
    2 order_num    = f8
    2 dept_misc    = vc
    2 drug         = vc
    2 freq         = vc
    2 dose         = vc
)
; ------------------- Declared Variables -------------------------------------
declare Hosp_name	= vc
declare facility    = f8
 
declare temp_count  = i4
; ------------------- Initialize Undeclared Variables ------------------------
;set facility        = $fac ;$org
 
set temp_count = 0
 
/****************************************************************************
*       Get hospital name from passed Org number                            *
****************************************************************************/
;select into "nl:"
;  o.org_name,
;  o.organization_id
;from  organization o
;where o.organization_id = org_id
;
;detail
;	temp->org_id = org_id
;with nocounter
 
 
/****************************************************************************
*       Get the location of the patient passed Org number                   *
****************************************************************************/
select into "nl:"
 p.name_full_formatted,
 o.order_mnemonic,
 o.hna_order_mnemonic,
 o.order_id,
 p.person_id
 
from
      orders o,
      person p,
      encounter e,
      encntr_domain ed,
      order_catalog_item_r ocir,
      order_product op
 
plan ed
   where ed.active_ind = 1
     and ed.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
     and ed.loc_facility_cd in (3490574, 3783264)
     and ed.loc_bed_cd > 0.00

  
join o where o.encntr_id = ed.encntr_id
;         and (o.catalog_cd     = 2758798 or o.order_mnemonic like "furosemide*") ; cs 200 furosemide
;              ; the above syntax retrieves the multi-ingredient orders in an IV without complex coding.
         and o.catalog_type_cd = 2516    ; pharmacy
         and o.active_ind      = 1
         and o.template_order_flag in(0,1) ; 0,1 means parent only: 0 means no child orders, 1 means template
         and o.order_status_cd in (2550,2548) ;,2551) ;(cs 6004 = ordered,InProcess,pending review)
         and o.orig_ord_as_flag = 0        ; 0=normal, 1=prescrip/dsch order,
                                           ;2=home meds, 3=pat owns meds, 4= pharm only, 5=superbill
join op
   where op.order_id = o.order_id
     and not exists (
        select opi.item_id
        from order_product opi
        where opi.order_id = o.order_id
          and opi.action_sequence > op.action_sequence)
   
join ocir
   where ocir.catalog_cd = furosemide_cd
     and ocir.item_id = op.item_id

join e where e.loc_facility_cd in(3490574, 3783264) ;URMC and Urmc First Step Recovery
         and e.encntr_id = ed.encntr_id	
         and e.active_status_cd= 188       ; cd 48  188    = active order
;         and e.encntr_type_class_cd = 391       ; cs 69 visit_status = inpatient
         and e.loc_nurse_unit_cd > 0       ; should always have a nurse unit
         and e.disch_dt_tm is null         ; no discharged patients! happen
join p
   where p.person_id = e.person_id 
order by p.name_full_formatted
 
head report
  temp_count = 0
 
detail
   temp_count  = temp_count + 1
   stat        = alterlist(temp->data,temp_count)
   temp->data[temp_count].person_id    = p.person_id
   temp->data[temp_count].encntr_id    = e.encntr_id
   temp->data[temp_count].order_id     = o.order_id
   temp->data[temp_count].patient_name = p.name_full_formatted
   temp->data[temp_count].pat_age      = cnvtage(p.birth_dt_tm)
   temp->data[temp_count].order_num    = o.order_id
   temp->data[temp_count].drug         = cnvtupper(o.hna_order_mnemonic)
   temp->data[temp_count].start_date   = o.orig_order_dt_tm
   temp->data[temp_count].dept_misc    = o.dept_misc_line

 
   if(e.loc_bed_cd > 0)
     temp->data[temp_count].nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd))
     temp->data[temp_count].room       = trim(uar_get_code_display(e.loc_room_cd))
     temp->data[temp_count].bed        = trim(uar_get_code_display(e.loc_bed_cd))
   else
     temp->data[temp_count].nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd))
   endif
 
   temp->lncnt = temp_count
 
with nocounter
 
 
/******************************************************************************
*  output                     .                                               *
******************************************************************************/
declare xxoutdev = vc
declare totpages = i4
 
;to calculate the number of total pages
set xxoutdev = "nl:"
execute from output_begin to output_end
 
;to print actual output with total pages
set xxoutdev = $outdev
execute from output_begin to output_end
go to exit_program
/******************************************************************************/
 
#output_begin
; CALL ECHO ( "***  Build the output file ***" )
declare rtxt = vc
 
select into value(xxoutdev)
from (dummyt d1 with seq = 1)
plan d1
 
 
head report
    hosp_name = concat("{b}Carolinas Medical Center - Union{endb}")
    line_d = fillstring(124,"=")
    line_s = fillstring(124,"-")
    linex = fillstring(124,"_")
    rr0 = 8
    rrx = 0  ;lines to add to evaluate on pagination
 
 
;================================================================
    macro(print_pt_info)
      row-1
      for (i = 1 to temp->lncnt)
          col 1  temp->data[i].patient_name
            rtxt = concat(temp->data[i].nurse_unit,"/",temp->data[i].room,"/",temp->data[i].bed)
          col 32 rtxt
            rtxt = substring(1,3,temp->data[i].pat_age)
          col 44 rtxt
            rtxt = format(temp->data[i].start_date, "MM/DD/YY ;;Q")
          col 50 rtxt
          ;  rtxt = trim(cnvtstring(temp->data[i].order_num),3)
          ;col 50 rtxt
          col 60 temp->data[i].dept_misc
;          col 59 temp->data[i].drug
;          col 71 temp->data[i].freq
;          col 84 temp->data[i].dose
         row+1
      endfor
    endmacro
 
head page
;================================================================
 
  col 0, "{PS/792 0 translate 90 rotate/}"
 
row+1
call center ( Hosp_name, 0, 124)
row+1
call center ("{b}LASIX/CHF REPORT{endb}", 0, 124)
row+3
 
col 1   "Report Date: " , CURDATE "MM/DD/YY;;D"
col 102  "Report Time: " , CURTIME "HH:MM;;M"
row+1
 
  rtxt = concat("Page ",trim(cnvtstring(curpage))," of ",trim(cnvtstring(totpages)))
col 1   rtxt
col 102  CURPROG
row+2
col 1  "Name"
col 32 "Loc"
col 44 "Age"
col 50 "ST Date"
;ol 50 "ORD Id"
col 60 "Drug       Dose             Form        Freq"
;col 59 "DRUG"
;col 71 "Freq"
;col 84 "Dose"
row+1
line_d
 
detail
;================================================================
 
if(row+4 > maxrow) break endif
 
  if(row < rr0)
	row + rr0
	print_pt_info
  else
	row + 2
	print_pt_info
  endif
 
;================================================================
foot page
 row+1
 line_d
 row+1
 
   if(cnvtlower(xxoutdev) = "nl:")
     totpages = curpage
   endif
 
 
;================================================================
foot report
 row+1
 line_s
 row+1
 rtxt = concat("{b}Total Count: {endb}",trim(cnvtstring(temp->lncnt)))
call center (rtxt, 0,124)
 row+2
call center ( "{b}*** END of REPORT ***{endb}", 0, 124)
 
 
 
;================================================================
 with  maxrec = 400
;       ,landscape
       ,nullreport
       ,dio = POSTSCRIPT
       ,maxcol = 300
       ,maxrow = 72
       ,nocounter
 
;call echorecord(temp)
 
;call echo(build( "ord_id:     " ,   org_id ))
 
#output_end
#exit_program
 
 
end
go
