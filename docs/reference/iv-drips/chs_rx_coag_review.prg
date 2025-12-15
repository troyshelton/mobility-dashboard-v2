/*
*****************************************************************************************************
*     Request ID              : 10                                                                  *
*     Last Updated On         : 10-MAR-2006                                                         *
*                                                                                                   *
*     Date Written            : 28-FEB-2006                                                         *
*     Source File Name        : CHS_RX_COAG_REVIEW.PRG                                              *
*     Created By              : Bhapindar Singh - FCG                                               *
*                                                                                                   *
*     HNA Version             :                                                                     *
*     CCL Version             :                                                                     *
*                                                                                                   *
*     Program purpose         :  Qualifying lab data matched with patients on anticoagulant
*                                therapy.                                                           *
*     Executing from          :                                                                     *
*                                                                                                   *
*****************************************************************************************************
*                               MODIFICATION LOG                                                    *
*****************************************************************************************************
* Date      Mod ind    Engineer               Comment                                               *
*===================================================================================================*
* 28-FEB-06            Bhapindar Singh - FCG  Coding started                                        *
* 10-MAR-06            Bhapindar Singh - FCG  Renamed program i.e. replaced initials CHS_ with FCG_ *
* 27-MAR-06			   Chris Bolger - CHS     Added lab mnemonics and connection to chs_rx_inp and  *
*                               fill_print_ord_hx tables and limited drugs on med_reconciliation    *
*                               table.                                                              *
* 12-dec-06  001       Chris Bolger - format changes, pulling product description for PYXIS and
*                                     manual charge.  Adding "Dose" column
* 03-mar-08  002       Jamie Jeffcoat - added new lab code for CRMC per request by Andrew Smith
* 04-apr-08  003       Jamie Jeffcoat - display key for lab code was corrected in CODE_VALUE table
										need to correct program w/ updated display_key
										requested by Matt Kern
* 06-jun-08  004       Jamie Jeffcoat - added 6 new ESH groups to pull lab results.  This was requested
                                        by Mat Kern in support of the BRHC go live.
* 15-SEP-08  005       Kathy Teter    - added Pharmacy Notes
* 02-DEV-08  005A                       After testing by Andrew Smith, determined that the Pharmacy department
*                                       wants order_comments not Pharmacy notes.
* 06/26/09   ---       Ron Barus      - Implement in prod, CC 27735, WO 2376771
* 08/06/09   ---       Ron Barus      - Add file (pdf) output to common folder.
* 08/11/09   006       Ron Barus      - Add DTA's from ETR to report output
* 10/6/09	007			Herbert hill	- changed clinical event sort to clinsig_dt_tm
* 11/30/09  008        Randy Mall	  - added inr for CMC-NE  -NOTICED that this code prompts for multiple
										facilities but only runs for one.  Sent into to Andrew for review.
* 06/08/10  009        Ron Barus	  - updated qualification values for PT, PTT, APTT, INR, and Heparin Anti XA
                                        Report now dynamically finds all associated values with grouper
                                        WO 3430797
* 06/21/2010 010       Lien Huynh	  - WO 3470730  Add Inr - Coudamin Montoring event to results
  12/08/2010 011       Ron Barus      - Added qualifier for projected_stop_dt_tm is NULL
  04/12/2011 012       Ron Barus      - WO 3934457 - WARFARIN DAILY not showing up on report.  Warfarin Daily
                                                     has no dispense event.  Resolved with outerjoin
                                                     to dispense hx.
******************************************************************************************************/
 
drop program chs_rx_coag_review go
create program chs_rx_coag_review
 
prompt
	"Output to File/Printer/MINE" = "MINE"                                ;* Enter or select the printer or file name to send this
	, "Faciliti(es):" = 0
	, "Nurse Unit (For all facility units, leave this field blank)" = 0
 
with OUTDEV, fac, nunit
 
;Request HNAM sign-on when executed from CCL on host
;if (validate(IsOdbc, 0) = 0)  execute cclseclogin  endif
 
;set maxsecs = 0
;if (validate(IsOdbc, 0) = 1)  set maxsecs = 60  endif
 
declare pharmacy_cd       = f8 with constant ( uar_get_code_by( "MEANING", 6000, "PHARMACY" ) )
declare laboratory_cd     = f8 with constant ( uar_get_code_by( "MEANING", 6000, "GENERAL LAB" ) )
declare inpat_cd          = f8 with constant ( uar_get_code_by( "MEANING", 69, "INPATIENT" ) )
declare freq_cd           = f8 with constant ( uar_get_code_by( "DISPLAY_KEY", 16449, "FREQUENCY" ) )
declare route_admin_cd    = f8 with constant ( uar_get_code_by( "DISPLAY_KEY", 16449, "ROUTE OF ADMINISTRATION" ) )
declare fin_nbr_cd        = f8 with constant ( uar_get_code_by( "MEANING", 319, "FIN NBR" ) )
declare strength_dose_cd  = f8 with constant ( uar_get_code_by( "DISPLAY_KEY", 16449, "STRENGTHDOSE" ) )
declare strength_unit_cd  = f8 with constant ( uar_get_code_by( "DISPLAY_KEY", 16449, "STRENGTH DOSE UNIT" ) )
declare rate_cd           = f8 with constant ( uar_get_code_by( "DISPLAY_KEY", 16449, "RATE" ) )
declare rate_unit_cd      = f8 with constant ( uar_get_code_by( "DISPLAY_KEY", 16449, "RATE UNIT" ) )
declare freetext_rate_cd  = f8 with constant ( uar_get_code_by( "DISPLAY", 16449, "Freetext Rate") )
declare ordered_cd        = f8 with constant ( uar_get_code_by( "MEANING", 6004, "ORDERED") )
declare suspend_cd        = f8 with constant ( uar_get_code_by( "MEANING", 6004, "SUSPENDED") )
declare completed_cd      = f8 with constant ( uar_get_code_by( "MEANING", 6004, "COMPLETED") )
declare cm_cd             = f8 with constant ( uar_get_code_by( "MEANING", 54, "CM" ) )
declare inch_cd           = f8 with constant ( uar_get_code_by( "MEANING", 54, "INCHES") )
declare ft_cd             = f8 with constant ( uar_get_code_by( "MEANING", 54, "FT") )
declare oz_cd             = f8 with constant ( uar_get_code_by( "MEANING", 54, "OZ") )
declare lb_cd             = f8 with constant ( uar_get_code_by( "MEANING", 54, "LB") )
declare kg_cd             = f8 with constant ( uar_get_code_by( "MEANING", 54, "KG") )
declare med_ident		  = f8 with Protect
declare pharm_mar		  = f8 with Protect
declare attend_phys_cd    = f8 with constant ( uar_get_code_by( "MEANING", 333, "ATTENDDOC") )
declare generic_name_cd   = f8 with constant ( uar_get_code_by( "MEANING", 11000, "GENERIC_NAME") )
 
;declaring code values for lab tests
declare ptt_cd 			= F8 with noconstant(0.0)
declare pt_cd 			= F8 with noconstant(0.0)
declare plt_cd 			= F8 with noconstant(0.0)
declare plts_cd 		= F8 with noconstant(0.0)
declare hct_cd 			= F8 with noconstant(0.0)
declare hgb_cd 			= F8 with noconstant(0.0)
declare ast_cd 			= F8 with noconstant(0.0)
declare alt_cd 			= F8 with noconstant(0.0)
declare height_cd 		= F8 with noconstant(0.0)
declare weight_cd 		= F8 with noconstant(0.0)
declare ibw_cd 			= F8 with noconstant(0.0)
declare inr_cd 			= F8 with noconstant(0.0)
declare heparin_anti_xa = F8 with noconstant(0.0)
 
declare r1_str       = vc with noConstant ("")
declare r2_str       = vc with noConstant ("")
declare r3_str       = vc with noConstant ("")
declare r4_str       = vc with noConstant ("")
declare r5_str       = vc with noConstant ("")
declare org_name     = vc with noConstant ("")
 
;set max_rows_per_page   = 70
;set page_footer_row     = max_rows_per_page - 5
set data_found_ind      = 0
set facility_code       = 0.0
set pharm_mar		= uar_get_code_by("MEANING", 4039, "MAR")
set med_ident		= uar_get_code_by("MEANING", 11000,"RX MISC4")
set med_desc_cd = uar_get_code_by("meaning",11000, "DESC")
 
declare rtxt = vc          ;001 cjb text field used generically in output
 
free record exclude_meds
record exclude_meds
(
     1 list[*]
       2 catalog_cd        = f8
       2 synonym_id        = f8
       2 item_id           = f8
       2 mnemonic_key_cap  = vc
)
 
free record reply
record reply
(
	 1 list_num           = i4   ;001 cjb
     1 list[*]
       2 location   	  = f8 ;008
       2 person_id        = f8
       2 encntr_id        = f8
       2 fin              = vc
       2 name             = vc
       2 sex              = vc
       2 dob              = dq8
       2 nurse_sta		  = vc
       2 nurse_sta_desc   = vc
       2 room_bed         = vc
       2 etr_dt           = vc
       2 etr_prsnl        = vc
       2 etr_was_pt_given = vc
       2 etr_was_prov     = vc
       2 etr_anti_coag_ed = vc
       2 etr_anti_prov    = vc
       2 etr_subsequent   = vc
       2 etr_subs_prov    = vc
       2 etr_meds         = vc
       2 eml[*];etr med lines
         3 line           = vc
       2 attend_phy		  = vc
       2 weight			  = f8
       2 weight_unit      = f8
       2 height_val       = f8
       2 height_unit      = f8
       2 ibw              = vc
       2 orders[*]
         3 order_id       = f8
         3 mnemonic       = vc
         3 nm_cnt         = i4
         3 nm[*]
           4 medname      = vc
         3 dose           = vc
         3 route          = vc
         3 freq           = vc
         3 rate           = vc
         3 start_dt_tm	  = dq8
         3 stop_dt_tm     = dq8
         3 dispense_dt_tm = dq8
         3 meddesc        = vc      ;001 cjb
         3 itemid 		  = f8      ;001 cjb
      	 3 ordflag        = i4      ;001 cjb
         3 ingflag        = i4      ;001 cjb
         3 dosetxt        = vc      ;001 cjb
         3 ltxt_id        = f8      ;005 klt
         3 lt_text        = vc      ;005 klt
         3 lt_cnt           = i4      ;005 klt
         3 pharnotes[*]             ;005 klt
          4 comments       = vc     ;005 klt
       2 results[*]
         3 order_id       = f8      ;001 cjb
         3 mnemonic       = vc      ;001 cjb
         3 code_value     = f8		;001 cjb
         3 display        = vc		;001 cjb
         3 value          = vc		;001 cjb
         3 units	      = vc		;001 cjb
         3 ref_range      = vc		;001 cjb
         3 res_dt_tm      = dq8		;001 cjb
)
 
;for word wrapping       ;005 klt
record pt
( 1 line_cnt = i2
  1 lns[*]
     2 line = vc
)
 
;storing qualifying encounters
record enc
( 1 encounters[*]
	2  encntr_id = f8)
 
 
set stat = alterlist(exclude_meds->list, 2)
 
set exclude_meds->list[1].mnemonic_key_cap = "HEPARIN 10 UNITS/ML INJECTABLE KIT"
set exclude_meds->list[2].mnemonic_key_cap = "HEPARIN 10 UNITS/ML INJECTABLE SOLUTION"
 
 
;------------------------------------------------------------------------------------
; Get code values for lab test
;------------------------------------------------------------------------------------
 
 
set     height_cd 	= uar_get_code_by("DISPLAY", 72, "Height")
set     weight_cd 	= uar_get_code_by("DISPLAY", 72, "Weight")
 
set maxlenln      =  102               ;005 klt
;------------------------------------------------------------------------------------
;-- Get the synonym ids for drugs by their mnemonic_key_cap -------------------------
;------------------------------------------------------------------------------------
 
select into "nl:"
 
from
      (dummyt d with seq = size(exclude_meds->list, 5))
    , order_catalog_synonym  ocs
 
plan d where
 
    d.seq > 0
 
join ocs where
 
    ocs.mnemonic_key_cap    = exclude_meds->list[d.seq].mnemonic_key_cap
    ;and ocs.catalog_cd      = exclude_meds->list[d.seq].catalog_cd
    and ocs.catalog_type_cd = pharmacy_cd
    and ocs.active_ind      = 1
 
detail
 
    exclude_meds->list[d.seq].synonym_id = ocs.synonym_id
    exclude_meds->list[d.seq].item_id    = ocs.item_id
 
with nocounter
 
;call echorecord(exclude_meds)
;------------------------------------------------------------------------------------
;-- Get the facility_cd and organization-id -----------------------------------------
;------------------------------------------------------------------------------------
 
select into "nl:"
   org.org_name
from
   location  l,
   organization  org
 
plan l
   where l.location_cd =  $fac   ;3490569.00
     and l.active_ind = 1
 
join org
   where l.organization_id = org.organization_id
     and org.active_ind = 1
detail
   facility_code = l.location_cd
   org_name      = org.org_name
with nocounter
 
;call echo("After getting FACILITY")
;------------------------------------------------------------------------------------
;-- Get encounters
;------------------------------------------------------------------------------------
if ($nunit >0 )
select into "nl:"
e.encntr_id
from encntr_domain ed,
	encounter e
plan ed
  where ed.end_effective_dt_tm >= cnvtdatetime(curdate, curtime);cnvtdatetime("01-JAN-2006 00:00:00");
    and ed.loc_facility_cd +0 = facility_code
    and ed.loc_nurse_unit_cd = $nunit
    and ed.loc_bed_cd+0 > 0
    and ed.active_ind = 1
    ;and ed.encntr_id = 1417211
 
join e
   where e.encntr_id = ed.encntr_id
     and e.active_ind = 1
     and e.disch_dt_tm+0 = null
     ;and e.organization_id = org_id
 
head report
   cnt = 0
detail
   cnt = cnt + 1, stat = alterlist(enc->encounters, cnt)
   enc->encounters[cnt].encntr_id = e.encntr_id
with nocounter
 
if (curqual = 0)
set stat = alterlist(enc->encounters, 1)
set enc->encounters[1].encntr_id = 0.00
endif
 
else
 
select into "nl:"
e.encntr_id
from encntr_domain ed,
	encounter e
plan ed
  where ed.end_effective_dt_tm >= cnvtdatetime(curdate, curtime);cnvtdatetime("01-JAN-2006 00:00:00");
    and ed.loc_facility_cd  = facility_code
    and ed.loc_nurse_unit_cd > 0
    and ed.loc_bed_cd > 0
    and ed.active_ind = 1
    ;and ed.encntr_id = 1417211
 
join e
   where e.encntr_id = ed.encntr_id
     and e.active_ind = 1
     and e.disch_dt_tm+0 = null
     ;and e.organization_id = org_id
 
head report
   cnt = 0
detail
   cnt = cnt + 1, stat = alterlist(enc->encounters, cnt)
   enc->encounters[cnt].encntr_id = e.encntr_id
with nocounter
endif
;------------------------------------------------------------------------------------
;-- Get qualified orders
;------------------------------------------------------------------------------------
declare num = i4
select into "nl:"
 
  	p.name_first,
    o.person_id,
    o.ordered_as_mnemonic,
    o.encntr_id,
 
    o.order_id,
    o.order_mnemonic,
    room_bed    = build(uar_get_code_display( e.loc_room_cd ), "-", uar_get_code_display( e.loc_bed_cd )),
    nurse_sta	= uar_get_code_display( e.loc_nurse_unit_cd )
 
from
   ;encntr_domain  ed, ;;lth
   encounter e,
   orders o,
   order_ingredient oi,
   order_catalog_item_r ocir,
   med_identifier m,
   med_identifier m2,
   dispense_hx ds,
   order_detail od,
   dummyt d1,
   dummyt d2
 
/*;;lth
plan ed
  where ed.end_effective_dt_tm >= cnvtdatetime(curdate, curtime);cnvtdatetime("01-JAN-2006 00:00:00");
    and ed.loc_facility_cd  = facility_code
    and ed.loc_nurse_unit_cd > 0
    and ed.loc_bed_cd > 0
    and ed.active_ind = 1
    ;and ed.encntr_id = 1417211
 
join e
   where e.encntr_id = ed.encntr_id
     and e.active_ind = 1
     and e.disch_dt_tm+0 = null
     ;and e.organization_id = org_id
*/
plan e
	where expand(num,1,size(enc->encounters,5),e.encntr_id,enc->encounters[num].encntr_id)
join o
   where o.encntr_id = e.encntr_id
     and o.template_order_id+0 = 0
     and o.order_status_cd+0 in (ordered_cd, completed_cd)
     ;and o.projected_stop_dt_tm+0 >= cnvtdatetime("14-MAY-2008 00:00:00");cnvtdatetime(curdate-1, 0) ;005 klt
     and (o.projected_stop_dt_tm+0 >= cnvtdatetime(curdate-1, 0) OR                                       ;005 klt
          o.projected_stop_dt_tm is null);011
     and o.orig_ord_as_flag != 2
     and o.active_ind = 1
 
join oi
   where oi.order_id = o.order_id
     and oi.action_sequence = (select max(oix.action_sequence)
                               from order_ingredient oix
                               where oix.order_id = o.order_id)
   join ocir
     where ocir.catalog_cd = oi.catalog_cd
     and ocir.synonym_id+0 = oi.synonym_id
 
   join m
     where m.item_id = ocir.item_id
	 and m.med_identifier_type_cd = med_ident
	 and m.value_key = "COAG"
 
   join m2
     where m2.item_id = ocir.item_id
     and m2.med_identifier_type_cd = generic_name_cd ;3098
join d2
   join ds
     where ds.order_id = o.order_id
     and not exists (select dsx.dispense_hx_id
                      from dispense_hx dsx
                      where ds.order_id = dsx.order_id
                      and dsx.dispense_dt_tm > ds.dispense_dt_tm)
 
join d1
join od where
    o.order_id = od.order_id
    and od.oe_field_id in(route_admin_cd, freq_cd, strength_dose_cd, strength_unit_cd, rate_cd, rate_unit_cd, freetext_rate_cd)
    and od.action_sequence =
    (
        select max(odt.action_sequence) from order_detail odt
        where odt.order_id = od.order_id
        and odt.oe_field_id = od.oe_field_id
    )
 
order by
 	  nurse_sta
    , o.person_id
    , o.ordered_as_mnemonic
 
 
head report
 
   i = 0
   j = 0
 
   data_found_ind = 1
 
head o.person_id
 
   i = i + 1
 
   if( mod(i, 10) = 1)
       stat = alterlist(reply->list, i + 9)
   endif
 
   reply->list[i].person_id   = o.person_id
   reply->list[i].encntr_id   = o.encntr_id
   reply->list[i].room_bed    = room_bed
   reply->list[i].nurse_sta	  = nurse_sta
   reply->list[i].nurse_sta_desc = uar_get_code_description(e.loc_nurse_unit_cd)
   reply->list[i].location = e.loc_facility_cd ;008
 
   reply->list_num = i             ;001 cjb
 
   j = 0
 
;head o.ordered_as_mnemonic
 
 
head o.order_id
   j = j + 1
 
   if( mod(j, 10) = 1)
       stat = alterlist(reply->list[i].orders, j + 9)
   endif
   r6_str = fillstring(30, " ")
 
 
detail
 
    case(od.oe_field_id)
 
        of route_admin_cd   : reply->list[i].orders[j].route = substring(1, 10, trim(od.oe_field_display_value, 3))
 
        of freq_cd          : reply->list[i].orders[j].freq = substring(1, 20, trim(od.oe_field_display_value, 3))
 
        of rate_cd          : r1_str = od.oe_field_display_value
 
        of rate_unit_cd     : r2_str = od.oe_field_display_value
 
        of strength_dose_cd : r3_str = od.oe_field_display_value
 
        of strength_unit_cd : r4_str = od.oe_field_display_value
 
        of freetext_rate_cd : reply->list[i].orders[j].rate = od.oe_field_display_value
    endcase
 
foot od.order_id
 
     if( size(trim(r3_str, 3), 1) > 0)
         r5_str = concat( r3_str, " ", r4_str)
     endif
     if( size(trim(r1_str, 3), 1) > 0)
        reply->list[i].orders[j].rate = concat(r1_str, r2_str)
         if(size(trim(r5_str, 3), 1) > 0)
           r5_str = concat(r5_str ,", ", r1_str, r2_str)
 
         ;else
         ;  r5_str = concat(r1_str, r2_str)
         endif
     endif
 
	r1_str=" "
	r2_str=" "
	r3_str=" "
	r4_str=" "
 
;foot o.ordered_as_mnemonic
 
     reply->list[i].orders[j].order_id = o.order_id
   	 ;reply->list[i].orders[j].mnemonic = substring(1, 52, o.ordered_as_mnemonic);substring(1, 52, o.order_mnemonic)
     reply->list[i].orders[j].mnemonic = substring(1, 52, m2.value);substring(1, 52, o.order_mnemonic)
     reply->list[i].orders[j].start_dt_tm = o.current_start_dt_tm
     reply->list[i].orders[j].stop_dt_tm  = o.projected_stop_dt_tm
     reply->list[i].orders[j].dispense_dt_tm = ds.dispense_dt_tm
     reply->list[i].orders[j].dose = substring(1, 30, r5_str)
     ;if there is a rate, use it. Otherwise there should have been a free-text rate
     ;populated into this field above
 
;------ 001 cjb ---------------------------------
;	 reply->list[i].orders[j].meddesc
	 reply->list[i].orders[j].itemid  = m2.item_id
	 reply->list[i].orders[j].ordflag = o.orig_ord_as_flag
	 reply->list[i].orders[j].ingflag = oi.ingredient_type_flag
	 reply->list[i].orders[j].dosetxt = replace(oi.order_detail_display_line,", "," / ")
;------ 001 cjb ---------------------------------
     ;reply->list[i].orders[j].dose = substring(1, 30, r6_str)
     if(reply->list[i].orders[j].dose > " ")
        stat = 0
     else
        if(size(trim(cnvtstring(oi.strength), 3), 1) > 0)
           reply->list[i].orders[j].dose = concat(trim(cnvtstring(oi.strength), 3), " ",
                                                  trim(uar_get_code_display(oi.strength_unit), 1))
        endif
     ;endif
 
        if(size(trim(cnvtstring(oi.volume), 3), 1) > 0)
           if(size(trim(reply->list[i].orders[j].dose, 3), 1) > 0)
              reply->list[i].orders[j].dose = concat(reply->list[i].orders[j].dose, "/",
                                                     trim(cnvtstring(oi.volume), 3), " ",
                                                     trim(uar_get_code_display(oi.volume_unit), 1))
           else
             reply->list[i].orders[j].dose = concat(trim(cnvtstring(oi.volume), 3), " ",
                                                    trim(uar_get_code_display(oi.volume_unit), 1))
           endif
        endif
     endif
 
	 r5_str=" "
 
 
foot o.person_id
 
   stat = alterlist(reply->list[i].orders, j)
 
foot report
 
   stat = alterlist(reply->list, i)
 
with outerjoin = d1, outerjoin = d2;012
 
;call echo("After getting encounters")
 
if(size(reply->list, 5) = 0 )
 
    set data_found_ind = 0
    go to EXIT_SCRIPT
 
endif
;call echorecord(reply)
;005 klt -------------------------------------------------
/******************************************************************
*   Get Order comments                                            *
******************************************************************/
for (k=1 to reply->list_num)
   select into "nl:"
 
   from order_comment oc
        ,long_text lt
        ,(dummyt di with seq = value(size(reply->list[k].orders,5)))
   plan di ;where reply->list[k].orders[di.seq].ordflag = 4
   join oc where oc.order_id = reply->list[k].orders[di.seq].order_id
             and oc.comment_type_cd = 66.00
 
   join lt where lt.long_text_id = outerjoin(oc.long_text_id)
 
   detail
 
    reply->list[k].orders[di.seq].ltxt_id = oc.long_text_id
    reply->list[k].orders[di.seq].lt_text = lt.long_text
 
   with nocounter
endfor
;call echorecord(reply)
;------------------------------------------------------------------------------------
;-- Format long_text
;------------------------------------------------------------------------------------
 
for (m=1 to reply->list_num)
  for (k = 1 to size(reply->list[m].orders,5))
   if (reply->list[m].orders[k].ltxt_id > 0)
    set pt->line_cnt = 0
    set max_length = 70                                         ;005
    execute dcp_parse_text value(reply->list[m].orders[k].lt_text),value(max_length)
    set stat = alterlist(reply->list[m].orders[k].pharnotes, pt->line_cnt)
    set reply->list[m].orders[k].lt_cnt = pt->line_cnt
    for (y = 1 to pt->line_cnt)
      set reply->list[m].orders[k].pharnotes[y].comments = pt->lns[y].line
    endfor
   endif
  endfor
endfor
 
 
;------------------------------------------------------------------------------------
;-- 006 RLB - Get ETR results           ---------------------------------------------
;------------------------------------------------------------------------------------
 
select into "nl:"
from (dummyt d with seq = value(size(reply->list, 5)))
     ,clinical_event ce
     ,code_value cv
     ,prsnl pr
 
plan d
join ce where ce.encntr_id+0 = reply->list[d.seq].encntr_id
          and ce.person_id = reply->list[d.seq].person_id
 
join cv where cv.code_value = ce.event_cd
          and cv.display_key in ("MEDICATIONANTICOAGULATION"
                                ,"ANTICOAGULANTINITIALEDUCATION"
                                ,"ANTICOAGULANTSUBSEQUENTDCEDUCATION"
                                ,"WASPTEDUCATIONLEAFLETHANDOUTGIVEN")
join pr where pr.person_id = ce.performed_prsnl_id
 
order by ce.encntr_id, ce.event_end_dt_tm
head ce.encntr_id
row + 0
head ce.event_end_dt_tm
row + 0
detail
reply->list[d.seq].etr_dt = format(ce.event_end_dt_tm,"mm/dd/yy hhmm;;d")
reply->list[d.seq].etr_prsnl = trim(pr.name_full_formatted)
 
CASE(cv.display_key)
  OF "WASPTEDUCATIONLEAFLETHANDOUTGIVEN" : reply->list[d.seq].etr_was_pt_given = trim(ce.result_val),
                                           reply->list[d.seq].etr_was_prov     = concat('  (',
                                           format(ce.event_end_dt_tm,"mm/dd hhmm;;d"),") ",
                                           trim(pr.name_full_formatted))
  OF "ANTICOAGULANTINITIALEDUCATION"     : reply->list[d.seq].etr_anti_coag_ed = trim(ce.result_val),
                                           reply->list[d.seq].etr_anti_prov    = concat('  (',
                                           format(ce.event_end_dt_tm,"mm/dd hhmm;;d"),") ",
                                           trim(pr.name_full_formatted))
  OF "ANTICOAGULANTSUBSEQUENTDCEDUCATION": reply->list[d.seq].etr_subsequent   = "Yes" ,
                                           reply->list[d.seq].etr_subs_prov    = concat("  (",
                                           format(ce.event_end_dt_tm,"mm/dd hhmm;;d"),") ",
                                           trim(pr.name_full_formatted))
  OF "MEDICATIONANTICOAGULATION"         : reply->list[d.seq].etr_meds =
                                           concat(trim(ce.result_val),' (',
                                           format(ce.event_end_dt_tm,"mm/dd hhmm;;d"),") ",
                                           trim(pr.name_full_formatted))
ENDCASE
with nocounter
 
FOR(edm = 1 to size(reply->list,5));Set a "No" response, if the value is null)
 
  IF(size(reply->list[edm].etr_was_pt_given) = 0)
      set reply->list[edm].etr_was_pt_given  = "No" ENDIF
  IF(size(reply->list[edm].etr_anti_coag_ed) = 0)
      set reply->list[edm].etr_anti_coag_ed  = "No" ENDIF
  IF(size(reply->list[edm].etr_subsequent)   = 0)
      set reply->list[edm].etr_subsequent    = "No" ENDIF
 
 
  IF(size(reply->list[edm].etr_meds) > 130)
    execute dcp_parse_text value(reply->list[edm].etr_meds), value(130)
    set stat = alterlist(reply->list[edm].eml,pt->line_cnt)
     for (w = 1 to pt->line_cnt)
       set reply->list[edm].eml[w].line = pt->lns[w].line
     endfor
  ENDIF
 
ENDFOR
 
 
;-------------------------------------------------------------------------------------
;call echorecord(pt)
;call echorecord(reply)
;005 klt -------------------------------------------------
 
 
;------------------------------------------------------------------------------------
;-- Format order_mnemonic
;------------------------------------------------------------------------------------
 
for (n = 1 to reply->list_num)
  for (p = 1 to size(reply->list[n].orders,5))
    set pt->line_cnt = 0
    set max_length = 15
    execute dcp_parse_text value(reply->list[n].orders[p].mnemonic),value(max_length)
    set stat = alterlist(reply->list[n].orders[p].nm, pt->line_cnt)
    set reply->list[n].orders[p].nm_cnt = pt->line_cnt
    for (r = 1 to pt->line_cnt)
      set reply->list[n].orders[p].nm[r].medname = pt->lns[r].line
    endfor
 
  endfor
endfor
 
;call echorecord(pt)
;call echorecord(reply)
 
;003 cjb -------------------------------------------------
;------------------------------------------------------------------------------------
;-- Get product description for PYXIS and MANUAL entries
;------------------------------------------------------------------------------------
 
for (i=1 to reply->list_num)
   select into "nl:"
   from med_identifier mi
        ,(dummyt di with seq = value(size(reply->list[i].orders,5)))
   plan di where reply->list[i].orders[di.seq].ordflag = 4
   join mi where mi.item_id = reply->list[i].orders[di.seq].itemid
             and mi.med_identifier_type_cd = med_desc_cd    ;3097
             and mi.med_product_id = 0
             and mi.active_ind+0 = 1
   detail
      reply->list[i].orders[di.seq].meddesc = trim(mi.value)
   with nocounter
endfor
 
;003 ------------------------------------------------------
;------------------------------------------------------------------------------------
;-- Get patient demographic information ---------------------------------------------
;------------------------------------------------------------------------------------
select into "nl:"
from person p,
     encntr_alias ea,
     (dummyt d with seq = value(size(reply->list, 5)))
plan d
join p
   where p.person_id = reply->list[d.seq].person_id
     and p.active_ind = 1
join ea
   where ea.encntr_id = reply->list[d.seq].encntr_id
     and ea.active_ind = 1
     and ea.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
     and ea.encntr_alias_type_cd = fin_nbr_cd
detail
   reply->list[d.seq].dob = p.birth_dt_tm
   reply->list[d.seq].name = substring(1,20,p.name_full_formatted)        ;005 added substring formatting
   reply->list[d.seq].sex = uar_get_code_display(p.sex_cd)
   reply->list[d.seq].fin = build(ea.alias)
 
;------------------------------------------------------------------------------------
;-- Get attending physician             ---------------------------------------------
;------------------------------------------------------------------------------------
 
select into "nl:"
from encntr_prsnl_reltn epr,
     prsnl pr,
     (dummyt d with seq = value(size(reply->list, 5)))
plan d
join epr
   where epr.encntr_id = reply->list[d.seq].encntr_id
     and epr.active_ind = 1
     and epr.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
     and epr.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
     and epr.encntr_prsnl_r_cd = attend_phys_cd
join pr
   where pr.person_id = epr.prsnl_person_id
detail
   reply->list[d.seq].attend_phy = substring(1,15,pr.name_full_formatted)
with nocounter
;call echorecord(reply)
 
;------------------------------------------------------------------------------------
;-- Get lab orders details for the patient-------------------------------------------
;-- And their height and weight -----------------------------------------------------
;------------------------------------------------------------------------------------
 
;start change 004
free record ALT_SGPT
record ALT_SGPT (
  1 list[*]
    2 event_cd = f8
)
 
select into "nl:"
   v2.event_cd,
   event_disp = uar_get_code_display(v2.event_cd)
from v500_event_set_code v,
     v500_event_set_explode v2
plan v
   where v.event_set_cd_descr = "ALT (SGPT)"
join v2
   where v2.event_set_cd = v.event_set_cd
head report
   cnt = 0
detail
   cnt = cnt + 1
   if(mod(cnt,10) = 1)
      stat = alterlist(ALT_SGPT->list, cnt+9)
   endif
   ALT_SGPT->list[cnt].event_cd = v2.event_cd
foot report
   stat = alterlist(ALT_SGPT->list, cnt)
with nocounter
 
;call echorecord(ALT_SGPT)
;-------------------
free record AST_SGOT
record AST_SGOT (
  1 list[*]
    2 event_cd = f8
)
 
select into "nl:"
   v2.event_cd,
   event_disp = uar_get_code_display(v2.event_cd)
from v500_event_set_code v,
     v500_event_set_explode v2
plan v
   where v.event_set_cd_descr = "AST (SGOT)"
join v2
   where v2.event_set_cd = v.event_set_cd
head report
   cnt = 0
detail
   cnt = cnt + 1
   if(mod(cnt,10) = 1)
      stat = alterlist(AST_SGOT->list, cnt+9)
   endif
   AST_SGOT->list[cnt].event_cd = v2.event_cd
foot report
   stat = alterlist(AST_SGOT->list, cnt)
with nocounter
 
;call echorecord(AST_SGOT)
;-------------------
free record HCT
record HCT (
  1 list[*]
    2 event_cd = f8
)
 
select into "nl:"
   v2.event_cd,
   event_disp = uar_get_code_display(v2.event_cd)
from v500_event_set_code v,
     v500_event_set_explode v2
plan v
   where v.event_set_cd_descr = "HCT"
join v2
   where v2.event_set_cd = v.event_set_cd
head report
   cnt = 0
detail
   cnt = cnt + 1
   if(mod(cnt,10) = 1)
      stat = alterlist(HCT->list, cnt+9)
   endif
   HCT->list[cnt].event_cd = v2.event_cd
foot report
   stat = alterlist(HCT->list, cnt)
with nocounter
 
;call echorecord(HCT)
;-------------------
free record HGB
record HGB (
  1 list[*]
    2 event_cd = f8
)
 
select into "nl:"
   v2.event_cd,
   event_disp = uar_get_code_display(v2.event_cd)
from v500_event_set_code v,
     v500_event_set_explode v2
plan v
   where v.event_set_cd_descr = "HGB"
join v2
   where v2.event_set_cd = v.event_set_cd
head report
   cnt = 0
detail
   cnt = cnt + 1
   if(mod(cnt,10) = 1)
      stat = alterlist(HGB->list, cnt+9)
   endif
   HGB->list[cnt].event_cd = v2.event_cd
foot report
   stat = alterlist(HGB->list, cnt)
with nocounter
 
;call echorecord(HGB)
;-------------------
free record Platelet
record Platelet (
  1 list[*]
    2 event_cd = f8
)
 
select into "nl:"
   v2.event_cd,
   event_disp = uar_get_code_display(v2.event_cd)
from v500_event_set_code v,
     v500_event_set_explode v2
plan v
   where v.event_set_cd_descr = "Platelet"
join v2
   where v2.event_set_cd = v.event_set_cd
head report
   cnt = 0
detail
   cnt = cnt + 1
   if(mod(cnt,10) = 1)
      stat = alterlist(Platelet->list, cnt+9)
   endif
   Platelet->list[cnt].event_cd = v2.event_cd
foot report
   stat = alterlist(Platelet->list, cnt)
with nocounter
 
;call echorecord(Platelet)
;-------------------
free record Platelet_Coag_Survey
record Platelet_Coag_Survey (
  1 list[*]
    2 event_cd = f8
)
 
select into "nl:"
   v2.event_cd,
   event_disp = uar_get_code_display(v2.event_cd)
from v500_event_set_code v,
     v500_event_set_explode v2
plan v
   where v.event_set_cd_descr = "Platelet-Coag Survey"
join v2
   where v2.event_set_cd = v.event_set_cd
head report
   cnt = 0
detail
   cnt = cnt + 1
   if(mod(cnt,10) = 1)
      stat = alterlist(Platelet_Coag_Survey->list, cnt+9)
   endif
   Platelet_Coag_Survey->list[cnt].event_cd = v2.event_cd
foot report
   stat = alterlist(Platelet_Coag_Survey->list, cnt)
with nocounter
 
;call echorecord(Platelet_Coag_Survey)
;-------------------
 
 
free record labs
record labs(
  1 pt[*]
    2 event_cd = f8
  1 ptt[*]
    2 event_cd = f8
  1 aptt[*]
    2 event_cd = f8
  1 inr[*]
    2 event_cd = f8
  1 hax[*]
    2 event_cd = f8
)
; PT ---------------------------------------------
select into "nl:"
   v2.event_cd,
   event_disp = uar_get_code_display(v2.event_cd)
from v500_event_set_code v,
     v500_event_set_explode v2
plan v
   where v.event_set_cd_descr = "PT"
join v2
   where v2.event_set_cd = v.event_set_cd
head report
   cnt = 0
detail
   cnt = cnt + 1, stat = alterlist(labs->pt, cnt)
   labs->pt[cnt].event_cd = v2.event_cd
with nocounter
; PTT ---------------------------------------------
select into "nl:"
   v2.event_cd,
   event_disp = uar_get_code_display(v2.event_cd)
from v500_event_set_code v,
     v500_event_set_explode v2
plan v
   where v.event_set_cd_descr = "PTT"
join v2
   where v2.event_set_cd = v.event_set_cd
head report
   cnt = 0
detail
   cnt = cnt + 1, stat = alterlist(labs->ptt, cnt)
   labs->ptt[cnt].event_cd = v2.event_cd
with nocounter
; APTT ---------------------------------------------
select into "nl:"
   v2.event_cd,
   event_disp = uar_get_code_display(v2.event_cd)
from v500_event_set_code v,
     v500_event_set_explode v2
plan v
   where v.event_set_cd_descr = "APTT"
join v2
   where v2.event_set_cd = v.event_set_cd
head report
   cnt = 0
detail
   cnt = cnt + 1, stat = alterlist(labs->aptt, cnt)
   labs->aptt[cnt].event_cd = v2.event_cd
with nocounter
; INR ---------------------------------------------
select into "nl:"
   v2.event_cd,
   event_disp = uar_get_code_display(v2.event_cd)
from v500_event_set_code v,
     v500_event_set_explode v2
plan v
   where v.event_set_cd_descr in ("INR", "INR-Coumadin*") ;;010 lth
join v2
   where v2.event_set_cd = v.event_set_cd
head report
   cnt = 0
detail
   cnt = cnt + 1, stat = alterlist(labs->inr, cnt)
   labs->inr[cnt].event_cd = v2.event_cd
with nocounter
; Heparin Anti-Xa ---------------------------------------------
select into "nl:"
   v2.event_cd,
   p_event_disp = v.event_set_name_key,
   event_disp = uar_get_code_display(v2.event_cd)
from v500_event_set_code v,
     v500_event_set_explode v2
plan v
   where v.event_set_name_key = "HEPARINANTIXA"
join v2
   where v2.event_set_cd = v.event_set_cd
head report
   cnt = 0
detail
   cnt = cnt + 1, stat = alterlist(labs->hax, cnt)
   labs->hax[cnt].event_cd = v2.event_cd
with nocounter
 
 
;-------------------
declare idx1 = i4, declare ldx1 = i4
declare idx2 = i4, declare ldx2 = i4
declare idx3 = i4, declare ldx3 = i4
declare idx4 = i4, declare ldx4 = i4
declare idx5 = i4, declare ldx5 = i4
declare idx6 = i4, declare ldx6 = i4
declare idx7 = i4, declare ldx7 = i4
declare idx8 = i4, declare ldx8 = i4
declare idx9 = i4, declare ldx9 = i4
declare idx0 = i4, declare ldx0 = i4
declare idxa = i4, declare ldxa = i4
;end change 004
 
select into "nl:"
 
      ce.event_id
    , ce.event_cd
    , display = uar_get_code_display(ce.event_cd)
    , order_name = uar_get_code_display(ce.catalog_cd)
    , result_units = uar_get_code_display(ce.result_units_cd)
 
from
 
    (dummyt d with seq = size(reply->list, 5))
  , clinical_event ce
 
plan d where
 
    d.seq > 0
 
join ce where
 
	ce.encntr_id = reply->list[d.seq].encntr_id
	and ce.view_level = 1
	and ce.event_end_dt_tm between cnvtdatetime(curdate-7,0000)          ;001 cjb
	and cnvtdatetime(curdate,curtime)									 ;001 cjb
 
	and   (expand(idx1,1,size(HGB->list, 5),ce.event_cd,HGB->list[idx1].event_cd) ;004
		or expand(idx2,1,size(HCT->list, 5),ce.event_cd,HCT->list[idx2].event_cd)						;004
		or expand(idx3,1,size(Platelet->list, 5),ce.event_cd,Platelet->list[idx3].event_cd)
		or expand(idx4,1,size(Platelet_Coag_Survey->list, 5),ce.event_cd,Platelet_Coag_Survey->list[idx4].event_cd) ;004
		or expand(idx5,1,size(ALT_SGPT->list, 5),ce.event_cd,ALT_SGPT->list[idx5].event_cd)				;004
		or expand(idx6,1,size(AST_SGOT->list, 5),ce.event_cd,AST_SGOT->list[idx6].event_cd)				;004
		or expand(idx7,1,size(labs->pt  ,5),ce.event_cd,labs->pt[idx7].event_cd)
		or expand(idx8,1,size(labs->ptt ,5),ce.event_cd,labs->ptt[idx8].event_cd)
		or expand(idx9,1,size(labs->aptt,5),ce.event_cd,labs->aptt[idx9].event_cd)
		or expand(idx0,1,size(labs->inr ,5),ce.event_cd,labs->inr[idx0].event_cd)
		or expand(idxa,1,size(labs->hax ,5),ce.event_cd,labs->hax[idxa].event_cd)
		or ce.event_cd in (height_cd,weight_cd))						 														 ;001 cjb
 
 
order by
	ce.person_id,
	ce.event_cd,								 ;001 cjb
	ce.parent_event_id,
	ce.event_id,
;	ce.event_end_dt_tm ;desc                      ;001 cjb
 ce.clinsig_updt_dt_tm						;007
head ce.person_id
 
   i = 0
   person_result = fillstring( 9, " " )
 
;001 cjb head ce.event_id
head ce.event_cd								 ;001 cjb
   i = i + 1
;001 cjb   if( mod(i, 5) = 1)
         stat =  alterlist(reply->list[d.seq].results, 11)
;001 cjb   endif
;001 cjb  j = 0
 
detail
 
idx = 0
idx2 = 0
idx3 = 0
idx4 = 0
idx5 = 0
idx6 = 0
 
;001 cjb        j = j + 1
;001 cjb        if( mod (j, 10) = 1 )
;001 cjb            stat =  alterlist(reply->list[d.seq].results[i].values, j + 9)
;001 cjb        endif
 
 		if (ce.event_cd = height_cd)
 			reply->list[d.seq].height_val = cnvtreal(ce.result_val)
 			reply->list[d.seq].height_unit = ce.result_units_cd
;001 cjb 			j = j -1
 		elseif (ce.event_cd = weight_cd)
			reply->list[d.seq].weight = cnvtreal(ce.result_val)
			reply->list[d.seq].weight_unit = ce.result_units_cd
;001 cjb			j = j -1
 		elseif (ce.event_cd = ibw_cd)
 			person_result = substring(1,9,concat(trim(ce.result_val,3)," ",trim(result_units,3)))
			reply->list[d.seq].ibw = person_result
 
;**********************************************
 
       ;Hemoglobin Results
        elseif (locateval(ldx1,1,size(HGB->list, 5),ce.event_cd,HGB->list[ldx1].event_cd)) ;004
         	reply->list[d.seq].results[1].code_value = ce.event_cd
        	reply->list[d.seq].results[1].display    = substring(1, 30, trim(display, 3))
        	reply->list[d.seq].results[1].value      = concat(trim(ce.result_val,3)," ",
        									trim(uar_get_code_display(ce.result_units_cd),3))
        	reply->list[d.seq].results[1].ref_range  = build(ce.normal_low, "-", ce.normal_high)
        	reply->list[d.seq].results[1].res_dt_tm  = ce.event_end_dt_tm
       ;Hematocrit Results
	 	elseif (locateval(ldx2,1,size(HCT->list, 5),ce.event_cd,HCT->list[ldx2].event_cd)) ;004
        	reply->list[d.seq].results[2].display    = substring(1, 30, trim(display, 3))
        	reply->list[d.seq].results[2].value      = concat(trim(ce.result_val,3)," ",
        									trim(uar_get_code_display(ce.result_units_cd),3))
        	reply->list[d.seq].results[2].ref_range  = build(ce.normal_low, "-", ce.normal_high)
        	reply->list[d.seq].results[2].res_dt_tm  = ce.event_end_dt_tm
        	reply->list[d.seq].results[2].units      = result_units
       ;Platelet Results
		elseif (locateval(ldx3,1,size(Platelet->list, 5),ce.event_cd,Platelet->list[ldx3].event_cd)) ;004
         	reply->list[d.seq].results[3].code_value = ce.event_cd
        	reply->list[d.seq].results[3].display    = substring(1, 30, trim(display, 3))
        	reply->list[d.seq].results[3].value      = concat(trim(ce.result_val,3)," ",
        									trim(uar_get_code_display(ce.result_units_cd),3))
        	reply->list[d.seq].results[3].ref_range  = build(ce.normal_low, "-", ce.normal_high)
        	reply->list[d.seq].results[3].res_dt_tm  = ce.event_end_dt_tm
        	reply->list[d.seq].results[3].units      = result_units
       ;Platelet Coag Survey Results
		elseif (locateval(ldx4,1,size(Platelet_Coag_Survey->list, 5)
		    ,ce.event_cd,Platelet_Coag_Survey->list[ldx4].event_cd)) ;004
         	reply->list[d.seq].results[11].code_value = ce.event_cd
        	reply->list[d.seq].results[11].display    = substring(1, 30, trim(display, 3))
        	reply->list[d.seq].results[11].value      = concat(trim(ce.result_val,3)," ",
        									trim(uar_get_code_display(ce.result_units_cd),3))
        	reply->list[d.seq].results[11].ref_range  = build(ce.normal_low, "-", ce.normal_high)
        	reply->list[d.seq].results[11].res_dt_tm  = ce.event_end_dt_tm
        	reply->list[d.seq].results[11].units      = result_units
       ;ALT-SGPT Results
        elseif (locateval(ldx5,1,size(ALT_SGPT->list, 5),ce.event_cd,ALT_SGPT->list[ldx5].event_cd)) ;004
         	reply->list[d.seq].results[8].code_value = ce.event_cd
        	reply->list[d.seq].results[8].display    = substring(1, 30, trim(display, 3))
        	reply->list[d.seq].results[8].value      = concat(trim(ce.result_val,3)," ",
        									trim(uar_get_code_display(ce.result_units_cd),3))
        	reply->list[d.seq].results[8].ref_range  = build(ce.normal_low, "-", ce.normal_high)
        	reply->list[d.seq].results[8].res_dt_tm  = ce.event_end_dt_tm
        	reply->list[d.seq].results[8].units      = result_units
       ;AST-SGOT Results
        elseif (locateval(ldx6,1,size(AST_SGOT->list, 5),ce.event_cd,AST_SGOT->list[ldx6].event_cd)) ;004
         	reply->list[d.seq].results[9].code_value = ce.event_cd
        	reply->list[d.seq].results[9].display    = substring(1, 30, trim(display, 3))
        	reply->list[d.seq].results[9].value      = concat(trim(ce.result_val,3)," ",
        									trim(uar_get_code_display(ce.result_units_cd),3))
        	reply->list[d.seq].results[9].ref_range  = build(ce.normal_low, "-", ce.normal_high)
        	reply->list[d.seq].results[9].res_dt_tm  = ce.event_end_dt_tm
        	reply->list[d.seq].results[9].units      = result_units
 
 
        elseif (locateval(ldx7,1,size(labs->pt  ,5),ce.event_cd,labs->pt[ldx7].event_cd))
         	reply->list[d.seq].results[5].code_value = ce.event_cd
        	reply->list[d.seq].results[5].display    = substring(1, 30, trim(display, 3))
        	reply->list[d.seq].results[5].value      = concat(trim(ce.result_val,3)," ",
        									trim(uar_get_code_display(ce.result_units_cd),3))
        	reply->list[d.seq].results[5].ref_range  = build(ce.normal_low, "-", ce.normal_high)
        	reply->list[d.seq].results[5].res_dt_tm  = ce.event_end_dt_tm
        	reply->list[d.seq].results[5].units      = result_units
 
       	elseif (locateval(ldx8,1,size(labs->ptt ,5),ce.event_cd,labs->ptt[ldx8].event_cd))
         	reply->list[d.seq].results[4].code_value = ce.event_cd
        	reply->list[d.seq].results[4].display    = substring(1, 30, trim(display, 3))
        	reply->list[d.seq].results[4].value      = concat(trim(ce.result_val,3)," ",
        									trim(uar_get_code_display(ce.result_units_cd),3))
        	reply->list[d.seq].results[4].ref_range  = build(ce.normal_low, "-", ce.normal_high)
        	reply->list[d.seq].results[4].res_dt_tm  = ce.event_end_dt_tm
        	reply->list[d.seq].results[4].units      = result_units
 
        elseif (locateval(ldx9,1,size(labs->aptt,5),ce.event_cd,labs->aptt[ldx9].event_cd))
         	reply->list[d.seq].results[10].code_value = ce.event_cd
        	reply->list[d.seq].results[10].display    = substring(1, 30, trim(display, 3))
        	reply->list[d.seq].results[10].value      = concat(trim(ce.result_val,3)," ",
        									trim(uar_get_code_display(ce.result_units_cd),3))
        	reply->list[d.seq].results[10].ref_range  = build(ce.normal_low, "-", ce.normal_high)
        	reply->list[d.seq].results[10].res_dt_tm  = ce.event_end_dt_tm
        	reply->list[d.seq].results[10].units      = result_units
 
 
        elseif (locateval(ldx0,1,size(labs->inr ,5),ce.event_cd,labs->inr[ldx0].event_cd))
         	reply->list[d.seq].results[6].code_value = ce.event_cd
        	reply->list[d.seq].results[6].display    = substring(1, 30, trim(display, 3))
        	reply->list[d.seq].results[6].value      = concat(trim(ce.result_val,3)," ",
 
        						replace(trim(uar_get_code_display(ce.result_units_cd),3),"RANGE","",0) )
        	reply->list[d.seq].results[6].ref_range  = build(ce.normal_low, "-", ce.normal_high)
        	reply->list[d.seq].results[6].res_dt_tm  = ce.event_end_dt_tm
        	reply->list[d.seq].results[6].units      = result_units
 
        elseif (locateval(ldxa,1,size(labs->hax ,5),ce.event_cd,labs->hax[ldxa].event_cd))
         	reply->list[d.seq].results[7].code_value = ce.event_cd
        	reply->list[d.seq].results[7].display    = substring(1, 30, trim(display, 3))
        	reply->list[d.seq].results[7].value      = concat(trim(ce.result_val,3)," ",
        									trim(uar_get_code_display(ce.result_units_cd),3))
        	reply->list[d.seq].results[7].ref_range  = build(ce.normal_low, "-", ce.normal_high)
        	reply->list[d.seq].results[7].res_dt_tm  = ce.event_end_dt_tm
        	reply->list[d.seq].results[7].units      = result_units
 
 
 		endif
 
 
;this ends the section by 001 cjb
;*************************************************
 
 		person_result = fillstring( 9, " " )
 
;001 foot ce.event_id
foot ce.event_cd                           ;001 cjb
	dummy=0								   ;001 cjb
;001 cjb   stat = alterlist(reply->list[d.seq].results[i].values, j)
 
 
foot ce.person_id
 
;001 cjb   stat = alterlist(reply->list[d.seq].results, i)
   stat = alterlist(reply->list[d.seq].results, 11)
 
with nocounter
 
call echorecord(reply)
 
;------------------------------------------------------------------------------------
;-- This section prints data --------------------------------------------------------
;------------------------------------------------------------------------------------
declare output_device = vc
 
     free record units
     record units (
       1 list[*]
         2 disp = vc
         2 pgs = i4
     )
 
 
declare tot_pg = i4
set tot_pg = 0
;First Pass
     set output_device = "pagecount"
     execute from BEG_OUTPUT to END_OUTPUT
     call echorecord(units)
;Second Pass
 
     set output_device = $OUTDEV
 
#BEG_OUTPUT
SELECT INTO value(output_device)
 
 nurse_srt = reply->list[d.seq].nurse_sta
 ,pat_srt = reply->list[d.seq].name
 
 
FROM (DUMMYT D with seq = value(size(reply->list,5)))
 
order by nurse_srt, pat_srt
 
HEAD REPORT
cnt1 = 0
cnt2 = 0
cnt3 = 0
3cnt = 0
sumpg = 1
nu_pg = 0
lst_pg = 0
;tot_pg = 0
xcv  = 0
yy   = 30    ; initial indent for yy
xx   = 25    ; initial indent for xx
yc   = 13    ; y constant for line feed
ph   = 720   ; standard page height
hc   = 0     ; maxvalue for the next row after all the columns have been populated
yyback = 0 ; restore row for another column entry
cv = 280   ; centering value
CV1 = 310  ; 2ND centering value
x_var = 0  ; centering x
 
xh1  = 30  ; x headerline 1
xh2  = 85  ; x headerline 2
xh3  = 175 ; x headerline 3
xh4  = 200 ; x headerline 4
xh5  = 250 ; x headerline 5
xh6  = 300  ; x headerline 1 (row 2)
xh7  = 350 ; x headerline 2 (row 2)
xh8  = 400 ; x headerline 3 (row 2)
xh9  = 450 ; x headerline 4 (row 2)
xh0  = 335 ; x headerline 5 (row 2)
sumchk = 0
display = 0
 
xf1a = 190; x footerline 1 col a
xf1b = 340; x footerline 1 col b
 
xs1 = 30
xs2 = 110
xs3 = 185
xs35 = 210
xs4 = 300
xs5 = 370
xs6 = 450
xs7 = 200
xs8 = 295
xs9 = 360
xs10 = 445
 
xc1  = xh1+2; column 1
xc2  = xh2+5; column 2
xc3  = xh3+2; column 3
xc4  = xh4+2; column 4
xc5  = xh5+2; column 5
xc6  = xh6+2; column 1 (row 2)
xc7  = xh7+2; column 2 (row 2)
xc8  = xh8+2; column 3 (row 2)
xc9  = xh9+2; column 4 (row 2)
xc0  = xh0+2; column 5 (row 2)
 
ln_txt = fillstring(120,"__________________________________________________________________________________________________")
ln_txt2 = fillstring(80,"__________________________________________________________________________________________________")
dfnt = "{cpi/16}{f/8}" ; default font
bfnt = "{cpi/16}{f/9}" ; bold font (default size)
tfnt = "{cpi/12}{f/8}" ; title font
hfnt = "{cpi/14}{f/8}" ; slightly smaller "header font"
 
lncnt = 0
HEAD PAGE
 
nu_pg = nu_pg + 1
yy = 30
 
lst_pg = tot_pg
 
rtxt = "ANTICOAGULANT PATIENT REPORT"
faclen = (textlen(rtxt))/2*6
call print(calcpos(cnvtint(cv-faclen),yy)) tfnt, rtxt
row + 1
 
yy = yy + 16
 
rtxt = trim(uar_get_code_description(cnvtreal($fac)),3)
faclen = (textlen(rtxt))/2*6
call print(calcpos(cnvtint(cv1-faclen),yy)) hfnt, rtxt
row + 1
 
rtxt = concat("Report Date: ",trim(build(format(cnvtdatetime(curdate,curtime),"MM/DD/YY HH:MM;;d")),3))
call print(calcpos(30,yy)) dfnt, rtxt
row + 1
 
rtxt = concat("Report Name: ",trim(build(curprog),3))
call print(calcpos(430,yy)) dfnt, rtxt
row + 1
yy = yy + 20
 
rtxt = trim(reply->list[d.seq].nurse_sta_desc)
faclen = textlen(rtxt)/2*6
call print(calcpos(cnvtint(cv-faclen),yy)) hfnt, rtxt
row + 1
yy = yy + 15
 
HEAD nurse_srt
 
if (nu_pg > 1) nu_pg = 1   endif
 
  pha_ord_cnt =  size(reply->list[d.seq].orders, 5)
 
  tot_cnt = ((pha_ord_cnt * 8) + 12)
 
head pat_srt
 lncnt = lncnt + 2
   for (ordln = 1 to size(reply->list[d.seq].orders,5))
      lncnt = lncnt + 3
     for (comln = 1 to size(reply->list[d.seq].orders[ordln].pharnotes, 5))
        lncnt = lncnt + 1
      endfor
     for(xln = 1 to 11)
        if(reply->list[d.seq].results[xln].value > " ")
          lncnt = lncnt + 2
        endif
      endfor
 
   endfor
 
   IF (yy + yc *(lncnt) > ph) break     endif
 
 
   dd = replace(cnvtage(reply->list[d.seq].dob), "Years", "Yrs")
 
 
		find_age = cnvtint(trim(substring(1,3,cnvtage(reply->list[d.seq].dob)),3))
		find_years = substring(5,5,cnvtage(reply->list[d.seq].dob))
		inches = 0.0
		centimeters = 0.0
		ibw = 0.0
		ibw_text = fillstring(9," ")
		sex = substring(1,1,reply->list[d.seq].sex)
 
 
        if (uar_get_code_display(reply->list[d.seq].height_unit) != "cm")
			inches = cnvtreal(reply->list[d.seq].height_val)
			centimeters = cnvtreal(reply->list[d.seq].height_val)*2.54
		else
			inches = cnvtreal(reply->list[d.seq].height_val)/2.54
			centimeters = cnvtreal(reply->list[d.seq].height_val)
		endif
 
		if ((find_years = "Years") and ((find_age < 18) and (find_age >= 1)))
			ibw = (centimeters*centimeters)*(1.65/1000)
		elseif ((find_years = "Years") and (inches >= 60))
			if (sex = "M")
				ibw = 50 + 2.3*(inches - 60)
			elseif (sex = "F")
				ibw = 45.5 + 2.3*(inches - 60)
			else
				ibw = 0.0
			endif
		else
			ibw = 0.0
		endif
 
        ;convert ibw from kg to lbs
		if ((ibw = 0.0) or (inches = 0.0) or centimeters = 0.0)
			ibw_text = " "
		else
			ibw_text = build(format(ibw, "###.##")," kg")
		endif
 
        height_in = 0
	;convert charted height value to ft/in
		if(reply->list[d.seq].height_unit = cm_cd)
		   height_in = round(reply->list[d.seq].height_val / 2.54, 0) ;- (height_ft * 12)
		elseif(reply->list[d.seq].height_unit = ft_cd)
		   height_in = round(reply->list[d.seq].height_val * 12, 0) ;- (height_ft * 12)
		elseif(reply->list[d.seq].height_unit = inch_cd)
		   height_in = reply->list[d.seq].height_val
		endif
		if(height_in > 0)
		   height_disp = concat(build(cnvtint(height_in)), " in")
		else
		   height_disp = "           "
		endif
 
	;convert the charted weight into lbs
		weight_disp = "         "
		if(reply->list[d.seq].weight_unit = kg_cd)
		   weight_disp = build(format(reply->list[d.seq]->weight, "###.##"), " kg")
		elseif(reply->list[d.seq].weight_unit = lb_cd)
		   weight_disp = build(format(reply->list[d.seq].weight, "###.##"), " lbs")
		elseif(reply->list[d.seq].weight_unit = oz_cd)
		   weight_disp = build(format(reply->list[d.seq].weight, "###.##"), " oz")
		endif
 
 
 
call print(calcpos(30,yy)) hfnt, ln_txt
row + 1
yy = yy + 12
  call print(calcpos(xh1,yy)) dfnt, "Account #"
  call print(calcpos(xh2,yy)) dfnt, "Patient Name"
  call print(calcpos(xh3,yy)) dfnt, "Sex"
  call print(calcpos(xh4,yy)) dfnt, "Age"
  call print(calcpos(xh5,yy)) dfnt, "Height"
  call print(calcpos(xh6,yy)) dfnt, "Weight"
  call print(calcpos(xh7,yy)) dfnt, "IBW"
  call print(calcpos(xh8,yy)) dfnt, "Room-Bed"
  call print(calcpos(xh9,yy)) dfnt, "Attend Phys"
row + 1
yy = yy + 12
 
  rtxt = build(reply->list[d.seq].fin)
  call print(calcpos(xh1,yy)) dfnt, rtxt
  row + 1
  rtxt = build(trim(substring(1,19,reply->list[d.seq].name)))
  call print(calcpos(xh2,yy)) dfnt, rtxt
  row + 1
  rtxt = sex
  call print(calcpos(xc3,yy)) dfnt, rtxt
  row + 1
  rtxt = dd
  call print(calcpos(xh4,yy)) dfnt, rtxt
  row + 1
  rtxt = height_disp
  call print(calcpos(xh5,yy)) dfnt, rtxt
  row + 1
  rtxt =  weight_disp
  call print(calcpos(xh6,yy)) dfnt, rtxt
  row + 1
  rtxt = ibw_text
  call print(calcpos(xh7,yy)) dfnt, rtxt
  row + 1
  rtxt = build(trim(substring(1,8,reply->list[d.seq].room_bed)))
  call print(calcpos(xh8,yy)) dfnt, rtxt
  row + 1
  rtxt = build(trim(substring(1,15,reply->list[d.seq].attend_phy)))
  call print(calcpos(xh9,yy)) dfnt, rtxt
  row + 1
 
call print(calcpos(30,yy)) hfnt, ln_txt, row + 1
yy = yy + 12
; 006 -------------  ETR DOCUMENTATION SECTION ----------------------------
 
IF(size(reply->list[d.seq].eml,5) > 0)
 FOR (xmm = 1 to size(reply->list[d.seq].eml,5))
   IF(xmm = 1)
     rtxt = concat(bfnt, "MEDICATIONS(ETR) ", dfnt, reply->list[d.seq].eml[xmm].line)
     call print(calcpos(xs1+25,yy)) rtxt, row + 1
     yy = yy + 12
   ELSE
     rtxt = concat(dfnt, reply->list[d.seq].eml[xmm].line)
     call print(calcpos(xs2+25,yy)) rtxt, row + 1
     yy = yy + 12
   ENDIF
   call echo(BUILD(xmm))
 ENDFOR
ELSE
  rtxt = concat(bfnt, "MEDICATIONS(ETR) ", dfnt, reply->list[d.seq].etr_meds)
  call print(calcpos(xs1+25,yy)) rtxt, row + 1
  yy = yy + 12
ENDIF
  rtxt = concat(bfnt, "Was Patient Given Handouts?(ETR) ")
 
  call print(calcpos(xs1+25,yy)) rtxt, row + 1
  call print(calcpos(xs4   ,yy)) dfnt, reply->list[d.seq].etr_was_pt_given,
                                       reply->list[d.seq].etr_was_prov , row + 1
  yy = yy + 12
  rtxt = concat(bfnt, "Anticoagulation Education Given?(ETR) ")
 
  call print(calcpos(xs1+25,yy)) rtxt, row + 1
  call print(calcpos(xs4   ,yy)) dfnt, reply->list[d.seq].etr_anti_coag_ed,
                                       reply->list[d.seq].etr_anti_prov , row + 1
  yy = yy + 12
  rtxt = concat(bfnt, "Subsequent/Discharge Anticoagulation ED Given?(ETR) ")
 
  call print(calcpos(xs1+25,yy)) rtxt, row + 1
  call print(calcpos(xs4   ,yy)) dfnt, reply->list[d.seq].etr_subsequent,
                                       reply->list[d.seq].etr_subs_prov , row + 1
  yy = yy + 12
call print(calcpos(30,yy)) hfnt, ln_txt, row + 1
yy = yy + 12
/*****************  ORDERS SECTION   ********************/
  call print(calcpos(xs1,yy))  dfnt, "DRUG ORDERS", row + 1
  call print(calcpos(xs2,yy))  dfnt, "DOSAGE"     , row + 1
  call print(calcpos(xs35,yy)) dfnt, "Frequency"  , row + 1
  call print(calcpos(xs4,yy))  dfnt, "Route"      , row + 1
  call print(calcpos(xs5,yy))  dfnt, "Start Dt/Tm", row + 1
  call print(calcpos(xs6,yy))  dfnt, "Stop Dt/Tm" , row + 1
 
row + 1
yy = yy + 12
 
  pha_ord_cnt =  size(reply->list[d.seq].orders, 5)
 
 
  if(pha_ord_cnt = 0)
     row + 1
    call print(calcpos(xs1,yy)) dfnt, "------- None --------"
   else
    for( ocnt = 1 to pha_ord_cnt)
       row + 1
 
;   order_detail_1 start
 
        concatdesc = false
 
        if(reply->list[d.seq].orders[ocnt].ordflag = 4)
          tempstring = reply->list[d.seq].orders[ocnt].meddesc
          if(findstring(' + ',reply->list[d.seq].orders[ocnt].meddesc) > 0)
             concatdesc = true
          endif
        else
          tempstring = reply->list[d.seq].orders[ocnt].mnemonic
          if(findstring(' + ',reply->list[d.seq].orders[ocnt].mnemonic) > 0)
             concatdesc = true
          endif
        endif
 
        rtxt = trim(reply->list[d.seq].orders[ocnt].dosetxt)
 
	       call print(calcpos(xs2,yy)) dfnt, rtxt
 
        if (reply->list[d.seq].orders[ocnt].freq > " ")
        	call print(calcpos(xs35,yy)) dfnt, reply->list[d.seq].orders[ocnt].freq
        else
            call print(calcpos(xs35,yy)) dfnt, reply->list[d.seq].orders[ocnt].rate
        endif
 
        call print(calcpos(xs4,yy)) dfnt, reply->list[d.seq].orders[ocnt].route
        call print(calcpos(xs5,yy)) dfnt, reply->list[d.seq].orders[ocnt].start_dt_tm "mm/dd/yy hh:mm;;d"
        call print(calcpos(xs6,yy)) dfnt,  reply->list[d.seq].orders[ocnt].stop_dt_tm  "mm/dd/yy hh:mm;;d"
 
      ;yy = yy + 12
        maxlen = 14
        yyback = yy
 
      ;  line_wrap start
      limit = 0;, maxlen = 80
      cr=char(10)
      while (tempstring > " " and limit < 1000)
         ii = 0 limit = limit + 1, pos = 0
         while (pos = 0)   ii = ii + 1
             if (substring(maxlen-ii,1,tempstring) in (" ",",",cr)) pos = maxlen - ii
             elseif (ii = maxlen) pos = maxlen
             endif
         endwhile
         cr_loc = findstring(cr, substring(1,pos,tempstring))
         if(cr_loc > 0) pos = cr_loc endif
         printstring = substring(1,pos,tempstring)
         call print(calcpos(xs1,yy)) dfnt, printstring
         tempstring = trim(substring(pos+1,9999,tempstring), 2)
         if(tempstring > " ")
            row + 1
            yy = yy + 12
         endif
      endwhile
 
;line_wrap end
 
 
        if(yyback = yy)
           row + 1
           yy = yy + 12
        endif
 
 
       call print(calcpos(xs6,yy)) dfnt,  "LAST DISPENSE:  ",
              reply->list[d.seq].orders[ocnt].dispense_dt_tm "mm/dd/yy hh:mm;;d"
		row +1
		yy = yy + 12
		;call print(calcpos(xs2,yy)) dfnt, ln_txt
 
 		concatdesc = false
 
;Add order comments (klt)
    pha_com_cnt = size(reply->list[d.seq].orders[ocnt].pharnotes, 5)
 
If(pha_com_cnt = 0)
     call print(calcpos(xs2,yy)) dfnt, "ORDER COMMENTS:  None"
     yy = yy + 12
 Else
     call print(calcpos(xs2,yy)) dfnt, "ORDER COMMENTS:"
       ; yy = yy + 12
      For(pcnt = 1 to pha_com_cnt)
        If(reply->list[d.seq].orders[ocnt].lt_cnt > 0)
           Rtxt = reply->list[d.seq].orders[ocnt].pharnotes[pcnt].comments
        Endif
      ;yy = yy + 12
   call print(calcpos(xs35,yy)) dfnt,rtxt
   row + 1
        yy = yy + 12
   endfor
 
endif
        row + 1
        yy = yy + 12
 
        endfor
       endif
 
; order_header_2 start
   call print(calcpos(xs7,yy)) dfnt, "LAB ORDERS"
   call print(calcpos(xs8,yy)) dfnt, "VALUES"
   call print(calcpos(xs9,yy)) dfnt, "REFERENCE RANGE"
   call print(calcpos(xs10,yy)) dfnt, "RESULT DATE/TIME"
   row + 1
   yy = yy + 4
   call print(calcpos(xs7,yy)) dfnt, ln_txt2
 
		row +1
 
		YY = YY + 12
 
 		if (reply->list[d.seq].results[1].value > " ")
 			call print(calcpos(xs7,yy)) dfnt, "HGB",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[1].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[1].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[1].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
        endif
 
        if (reply->list[d.seq].results[2].value > " ")
 			call print(calcpos(xs7,yy)) dfnt, "HCT",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[2].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[2].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[2].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
        endif
 
        if (reply->list[d.seq].results[3].value > " ")
 			call print(calcpos(xs7,yy)) dfnt, "Platelet",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[3].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[3].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[3].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
        endif
 
         if (reply->list[d.seq].results[5].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "PT",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[5].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[5].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[5].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
         endif
 
 
         if (reply->list[d.seq].results[6].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "INR-Coumadin Monitoring",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[6].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[6].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[6].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
          endif
 
          if (reply->list[d.seq].results[4].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "PTT",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[4].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[4].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[4].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
          endif
 
          if (reply->list[d.seq].results[10].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "aPTT",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[10].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[10].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[10].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
           endif
 
           if (reply->list[d.seq].results[7].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "Heparin Anti-Xa",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[7].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[7].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[7].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
           endif
 
           if (reply->list[d.seq].results[11].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "Platelet-Coag Survey",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[11].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[11].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[11].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
           endif
 
           if (reply->list[d.seq].results[8].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "ALT (SGPT)"	,row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[8].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[8].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[8].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
           endif
 
           if (reply->list[d.seq].results[9].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "AST (SGOT)"	,row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[9].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[9].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[9].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 24
           endif
 
 
 
 
foot nurse_srt
 
   if(output_device = "pagecount")
      stat = alterlist(units->list, size(units->list, 5)+1)
      units->list[size(units->list, 5)].disp = nurse_srt
      units->list[size(units->list, 5)].pgs = nu_pg
     ;nu_pg = 0
   endif
 
   if(not curendreport)
      break
       endif
 
 
 
foot page
 
   lncnt = 0
   yy = yy + 16
   ;lst_pg = 0
   ;lst_pg = tot_pg
 
   idx = 0
   idx2 = 0
   idx2 = locateval(idx, 0, size(units->list, 5), nurse_srt, units->list[idx].disp);,row + 1
 
   ;rtxt = concat("Unit Page: ", nu_pg, " of ", units->list[idx2].pgs)
   call print(calcpos(30,750)) dfnt, "Unit Page: ", nu_pg "###", " of ", units->list[idx2].pgs "####"
 
   call print(calcpos(450,750)) dfnt,   "Report Page: ", curpage "#####", " of ", tot_pg "#####",row + 0
 
foot report
if(output_device = "pagecount")
   tot_pg = curpage
 endif
 
   row + 0
 
with nocounter, nocompress, maxcol = 2000, nolandscape, maxrow = 3000,
	dio= postscript
 
if(validate(request->batch_selection,"none") != "none");Check for OPS
declare outfile = vc, declare vplusfile = vc
 
set outfile = cnvtlower(replace(build(uar_get_code_display(cnvtreal($2))),"-",""))
set outfile = concat(outfile,"_coag_review_"
                     ,format(cnvtdatetime(curdate,0),"mmddyy;;d"),".pdf")
set vplusfile = cnvtlower(replace(build(uar_get_code_display(cnvtreal($2))),"-",""))
set vplusfile = concat(vplusfile,"_coag_review.pdf")
 
SELECT INTO value(outfile)
 
 nurse_srt = reply->list[d.seq].nurse_sta
 ,pat_srt = reply->list[d.seq].name
 
 
FROM (DUMMYT D with seq = value(size(reply->list,5)))
 
order by nurse_srt, pat_srt
 
HEAD REPORT
cnt1 = 0
cnt2 = 0
cnt3 = 0
3cnt = 0
sumpg = 1
nu_pg = 0
lst_pg = 0
;tot_pg = 0
xcv  = 0
yy   = 30    ; initial indent for yy
xx   = 25    ; initial indent for xx
yc   = 13    ; y constant for line feed
ph   = 720   ; standard page height
hc   = 0     ; maxvalue for the next row after all the columns have been populated
yyback = 0 ; restore row for another column entry
cv = 280   ; centering value
CV1 = 310  ; 2ND centering value
x_var = 0  ; centering x
 
xh1  = 30  ; x headerline 1
xh2  = 85  ; x headerline 2
xh3  = 175 ; x headerline 3
xh4  = 200 ; x headerline 4
xh5  = 250 ; x headerline 5
xh6  = 300  ; x headerline 1 (row 2)
xh7  = 350 ; x headerline 2 (row 2)
xh8  = 400 ; x headerline 3 (row 2)
xh9  = 450 ; x headerline 4 (row 2)
xh0  = 335 ; x headerline 5 (row 2)
sumchk = 0
display = 0
 
xf1a = 190; x footerline 1 col a
xf1b = 340; x footerline 1 col b
 
xs1 = 30
xs2 = 110
xs3 = 185
xs35 = 210
xs4 = 300
xs5 = 370
xs6 = 450
xs7 = 200
xs8 = 295
xs9 = 360
xs10 = 445
 
xc1  = xh1+2; column 1
xc2  = xh2+5; column 2
xc3  = xh3+2; column 3
xc4  = xh4+2; column 4
xc5  = xh5+2; column 5
xc6  = xh6+2; column 1 (row 2)
xc7  = xh7+2; column 2 (row 2)
xc8  = xh8+2; column 3 (row 2)
xc9  = xh9+2; column 4 (row 2)
xc0  = xh0+2; column 5 (row 2)
 
ln_txt = fillstring(120,"__________________________________________________________________________________________________")
ln_txt2 = fillstring(80,"__________________________________________________________________________________________________")
dfnt = "{cpi/16}{f/8}" ; default font
bfnt = "{cpi/16}{f/9}" ; bold font (default size)
tfnt = "{cpi/12}{f/8}" ; title font
hfnt = "{cpi/14}{f/8}" ; slightly smaller "header font"
 
lncnt = 0
HEAD PAGE
 
nu_pg = nu_pg + 1
yy = 30
 
lst_pg = tot_pg
 
rtxt = "ANTICOAGULANT PATIENT REPORT"
faclen = (textlen(rtxt))/2*6
call print(calcpos(cnvtint(cv-faclen),yy)) tfnt, rtxt
row + 1
 
yy = yy + 16
 
rtxt = trim(uar_get_code_description(cnvtreal($fac)),3)
faclen = (textlen(rtxt))/2*6
call print(calcpos(cnvtint(cv1-faclen),yy)) hfnt, rtxt
row + 1
 
rtxt = concat("Report Date: ",trim(build(format(cnvtdatetime(curdate,curtime),"MM/DD/YY HH:MM;;d")),3))
call print(calcpos(30,yy)) dfnt, rtxt
row + 1
 
rtxt = concat("Report Name: ",trim(build(curprog),3))
call print(calcpos(430,yy)) dfnt, rtxt
row + 1
yy = yy + 20
 
rtxt = trim(reply->list[d.seq].nurse_sta_desc)
faclen = textlen(rtxt)/2*6
call print(calcpos(cnvtint(cv-faclen),yy)) hfnt, rtxt
row + 1
yy = yy + 15
 
HEAD nurse_srt
 
if (nu_pg > 1) nu_pg = 1   endif
 
  pha_ord_cnt =  size(reply->list[d.seq].orders, 5)
 
  tot_cnt = ((pha_ord_cnt * 8) + 12)
 
head pat_srt
 lncnt = lncnt + 2
   for (ordln = 1 to size(reply->list[d.seq].orders,5))
      lncnt = lncnt + 3
     for (comln = 1 to size(reply->list[d.seq].orders[ordln].pharnotes, 5))
        lncnt = lncnt + 1
      endfor
     for(xln = 1 to 11)
        if(reply->list[d.seq].results[xln].value > " ")
          lncnt = lncnt + 1
        endif
      endfor
 
   endfor
 
   IF (yy + yc *(lncnt) > ph) break
    endif
 
 
   dd = replace(cnvtage(reply->list[d.seq].dob), "Years", "Yrs")
 
 
		find_age = cnvtint(trim(substring(1,3,cnvtage(reply->list[d.seq].dob)),3))
		find_years = substring(5,5,cnvtage(reply->list[d.seq].dob))
		inches = 0.0
		centimeters = 0.0
		ibw = 0.0
		ibw_text = fillstring(9," ")
		sex = substring(1,1,reply->list[d.seq].sex)
 
 
        if (uar_get_code_display(reply->list[d.seq].height_unit) != "cm")
			inches = cnvtreal(reply->list[d.seq].height_val)
			centimeters = cnvtreal(reply->list[d.seq].height_val)*2.54
		else
			inches = cnvtreal(reply->list[d.seq].height_val)/2.54
			centimeters = cnvtreal(reply->list[d.seq].height_val)
		endif
 
		if ((find_years = "Years") and ((find_age < 18) and (find_age >= 1)))
			ibw = (centimeters*centimeters)*(1.65/1000)
		elseif ((find_years = "Years") and (inches >= 60))
			if (sex = "M")
				ibw = 50 + 2.3*(inches - 60)
			elseif (sex = "F")
				ibw = 45.5 + 2.3*(inches - 60)
			else
				ibw = 0.0
			endif
		else
			ibw = 0.0
		endif
 
        ;convert ibw from kg to lbs
		if ((ibw = 0.0) or (inches = 0.0) or centimeters = 0.0)
			ibw_text = " "
		else
			ibw_text = build(format(ibw, "###.##")," kg")
		endif
 
        height_in = 0
	;convert charted height value to ft/in
		if(reply->list[d.seq].height_unit = cm_cd)
		   height_in = round(reply->list[d.seq].height_val / 2.54, 0) ;- (height_ft * 12)
		elseif(reply->list[d.seq].height_unit = ft_cd)
		   height_in = round(reply->list[d.seq].height_val * 12, 0) ;- (height_ft * 12)
		elseif(reply->list[d.seq].height_unit = inch_cd)
		   height_in = reply->list[d.seq].height_val
		endif
		if(height_in > 0)
		   height_disp = concat(build(cnvtint(height_in)), " in")
		else
		   height_disp = "           "
		endif
 
	;convert the charted weight into lbs
		weight_disp = "         "
		if(reply->list[d.seq].weight_unit = kg_cd)
		   weight_disp = build(format(reply->list[d.seq]->weight, "###.##"), " kg")
		elseif(reply->list[d.seq].weight_unit = lb_cd)
		   weight_disp = build(format(reply->list[d.seq].weight, "###.##"), " lbs")
		elseif(reply->list[d.seq].weight_unit = oz_cd)
		   weight_disp = build(format(reply->list[d.seq].weight, "###.##"), " oz")
		endif
 
 
 
call print(calcpos(30,yy)) hfnt, ln_txt
row + 1
yy = yy + 12
  call print(calcpos(xh1,yy)) dfnt, "Account #"
  call print(calcpos(xh2,yy)) dfnt, "Patient Name"
  call print(calcpos(xh3,yy)) dfnt, "Sex"
  call print(calcpos(xh4,yy)) dfnt, "Age"
  call print(calcpos(xh5,yy)) dfnt, "Height"
  call print(calcpos(xh6,yy)) dfnt, "Weight"
  call print(calcpos(xh7,yy)) dfnt, "IBW"
  call print(calcpos(xh8,yy)) dfnt, "Room-Bed"
  call print(calcpos(xh9,yy)) dfnt, "Attend Phys"
row + 1
yy = yy + 12
 
  rtxt = build(reply->list[d.seq].fin)
  call print(calcpos(xh1,yy)) dfnt, rtxt
  row + 1
  rtxt = build(trim(substring(1,19,reply->list[d.seq].name)))
  call print(calcpos(xh2,yy)) dfnt, rtxt
  row + 1
  rtxt = sex
  call print(calcpos(xc3,yy)) dfnt, rtxt
  row + 1
  rtxt = dd
  call print(calcpos(xh4,yy)) dfnt, rtxt
  row + 1
  rtxt = height_disp
  call print(calcpos(xh5,yy)) dfnt, rtxt
  row + 1
  rtxt =  weight_disp
  call print(calcpos(xh6,yy)) dfnt, rtxt
  row + 1
  rtxt = ibw_text
  call print(calcpos(xh7,yy)) dfnt, rtxt
  row + 1
  rtxt = build(trim(substring(1,8,reply->list[d.seq].room_bed)))
  call print(calcpos(xh8,yy)) dfnt, rtxt
  row + 1
  rtxt = build(trim(substring(1,15,reply->list[d.seq].attend_phy)))
  call print(calcpos(xh9,yy)) dfnt, rtxt
  row + 1
 
call print(calcpos(30,yy)) hfnt, ln_txt, row + 1
yy = yy + 12
; 006 -------------  ETR DOCUMENTATION SECTION ----------------------------
 
IF(size(reply->list[d.seq].eml,5) > 0)
 FOR (xmm = 1 to size(reply->list[d.seq].eml,5))
   IF(xmm = 1)
     rtxt = concat(bfnt, "MEDICATIONS(ETR) ", dfnt, reply->list[d.seq].eml[xmm].line)
     call print(calcpos(xs1+25,yy)) rtxt, row + 1
     yy = yy + 12
   ELSE
     rtxt = concat(dfnt, reply->list[d.seq].eml[xmm].line)
     call print(calcpos(xs2+25,yy)) rtxt, row + 1
     yy = yy + 12
   ENDIF
   call echo(BUILD(xmm))
 ENDFOR
ELSE
  rtxt = concat(bfnt, "MEDICATIONS(ETR) ", dfnt, reply->list[d.seq].etr_meds)
  call print(calcpos(xs1+25,yy)) rtxt, row + 1
  yy = yy + 12
ENDIF
  rtxt = concat(bfnt, "Was Patient Given Handouts?(ETR) ")
 
  call print(calcpos(xs1+25,yy)) rtxt, row + 1
  call print(calcpos(xs4   ,yy)) dfnt, reply->list[d.seq].etr_was_pt_given,
                                       reply->list[d.seq].etr_was_prov , row + 1
  yy = yy + 12
  rtxt = concat(bfnt, "Anticoagulation Education Given?(ETR) ")
 
  call print(calcpos(xs1+25,yy)) rtxt, row + 1
  call print(calcpos(xs4   ,yy)) dfnt, reply->list[d.seq].etr_anti_coag_ed,
                                       reply->list[d.seq].etr_anti_prov , row + 1
  yy = yy + 12
  rtxt = concat(bfnt, "Subsequent/Discharge Anticoagulation ED Given?(ETR) ")
 
  call print(calcpos(xs1+25,yy)) rtxt, row + 1
  call print(calcpos(xs4   ,yy)) dfnt, reply->list[d.seq].etr_subsequent,
                                       reply->list[d.seq].etr_subs_prov , row + 1
  yy = yy + 12
call print(calcpos(30,yy)) hfnt, ln_txt, row + 1
yy = yy + 12
/*****************  ORDERS SECTION   ********************/
  call print(calcpos(xs1,yy))  dfnt, "DRUG ORDERS", row + 1
  call print(calcpos(xs2,yy))  dfnt, "DOSAGE"     , row + 1
  call print(calcpos(xs35,yy)) dfnt, "Frequency"  , row + 1
  call print(calcpos(xs4,yy))  dfnt, "Route"      , row + 1
  call print(calcpos(xs5,yy))  dfnt, "Start Dt/Tm", row + 1
  call print(calcpos(xs6,yy))  dfnt, "Stop Dt/Tm" , row + 1
 
row + 1
yy = yy + 12
 
  pha_ord_cnt =  size(reply->list[d.seq].orders, 5)
 
 
  if(pha_ord_cnt = 0)
     row + 1
    call print(calcpos(xs1,yy)) dfnt, "------- None --------"
   else
    for( ocnt = 1 to pha_ord_cnt)
       row + 1
 
;   order_detail_1 start
 
        concatdesc = false
 
        if(reply->list[d.seq].orders[ocnt].ordflag = 4)
          tempstring = reply->list[d.seq].orders[ocnt].meddesc
          if(findstring(' + ',reply->list[d.seq].orders[ocnt].meddesc) > 0)
             concatdesc = true
          endif
        else
          tempstring = reply->list[d.seq].orders[ocnt].mnemonic
          if(findstring(' + ',reply->list[d.seq].orders[ocnt].mnemonic) > 0)
             concatdesc = true
          endif
        endif
 
        rtxt = trim(reply->list[d.seq].orders[ocnt].dosetxt)
 
	       call print(calcpos(xs2,yy)) dfnt, rtxt
 
        if (reply->list[d.seq].orders[ocnt].freq > " ")
        	call print(calcpos(xs35,yy)) dfnt, reply->list[d.seq].orders[ocnt].freq
        else
            call print(calcpos(xs35,yy)) dfnt, reply->list[d.seq].orders[ocnt].rate
        endif
 
        call print(calcpos(xs4,yy)) dfnt, reply->list[d.seq].orders[ocnt].route
        call print(calcpos(xs5,yy)) dfnt, reply->list[d.seq].orders[ocnt].start_dt_tm "mm/dd/yy hh:mm;;d"
        call print(calcpos(xs6,yy)) dfnt,  reply->list[d.seq].orders[ocnt].stop_dt_tm  "mm/dd/yy hh:mm;;d"
 
      ;yy = yy + 12
        maxlen = 14
        yyback = yy
 
      ;  line_wrap start
      limit = 0;, maxlen = 80
      cr=char(10)
      while (tempstring > " " and limit < 1000)
         ii = 0 limit = limit + 1, pos = 0
         while (pos = 0)   ii = ii + 1
             if (substring(maxlen-ii,1,tempstring) in (" ",",",cr)) pos = maxlen - ii
             elseif (ii = maxlen) pos = maxlen
             endif
         endwhile
         cr_loc = findstring(cr, substring(1,pos,tempstring))
         if(cr_loc > 0) pos = cr_loc endif
         printstring = substring(1,pos,tempstring)
         call print(calcpos(xs1,yy)) dfnt, printstring
         tempstring = trim(substring(pos+1,9999,tempstring), 2)
         if(tempstring > " ")
            row + 1
            yy = yy + 12
         endif
      endwhile
 
;line_wrap end
 
 
        if(yyback = yy)
           row + 1
           yy = yy + 12
        endif
 
 
       call print(calcpos(xs6,yy)) dfnt,  "LAST DISPENSE:  ",
              reply->list[d.seq].orders[ocnt].dispense_dt_tm "mm/dd/yy hh:mm;;d"
		row +1
		yy = yy + 12
		;call print(calcpos(xs2,yy)) dfnt, ln_txt
 
 		concatdesc = false
 
;Add order comments (klt)
    pha_com_cnt = size(reply->list[d.seq].orders[ocnt].pharnotes, 5)
 
If(pha_com_cnt = 0)
     call print(calcpos(xs2,yy)) dfnt, "ORDER COMMENTS:  None"
     yy = yy + 12
 Else
     call print(calcpos(xs2,yy)) dfnt, "ORDER COMMENTS:"
       ; yy = yy + 12
      For(pcnt = 1 to pha_com_cnt)
        If(reply->list[d.seq].orders[ocnt].lt_cnt > 0)
           Rtxt = reply->list[d.seq].orders[ocnt].pharnotes[pcnt].comments
        Endif
      ;yy = yy + 12
   call print(calcpos(xs35,yy)) dfnt,rtxt
   row + 1
        yy = yy + 12
   endfor
 
endif
        row + 1
        yy = yy + 12
 
        endfor
       endif
 
; order_header_2 start
   call print(calcpos(xs7,yy)) dfnt, "LAB ORDERS"
   call print(calcpos(xs8,yy)) dfnt, "VALUES"
   call print(calcpos(xs9,yy)) dfnt, "REFERENCE RANGE"
   call print(calcpos(xs10,yy)) dfnt, "RESULT DATE/TIME"
   row + 1
   yy = yy + 4
   call print(calcpos(xs7,yy)) dfnt, ln_txt2
 
		row +1
 
		YY = YY + 12
 
 		if (reply->list[d.seq].results[1].value > " ")
 			call print(calcpos(xs7,yy)) dfnt, "HGB",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[1].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[1].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[1].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
        endif
 
        if (reply->list[d.seq].results[2].value > " ")
 			call print(calcpos(xs7,yy)) dfnt, "HCT",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[2].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[2].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[2].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
        endif
 
        if (reply->list[d.seq].results[3].value > " ")
 			call print(calcpos(xs7,yy)) dfnt, "Platelet",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[3].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[3].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[3].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
        endif
 
         if (reply->list[d.seq].results[5].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "PT",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[5].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[5].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[5].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
         endif
 
 
         if (reply->list[d.seq].results[6].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "INR-Coumadin Monitoring",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[6].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[6].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[6].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
          endif
 
          if (reply->list[d.seq].results[4].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "PTT",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[4].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[4].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[4].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
          endif
 
          if (reply->list[d.seq].results[10].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "aPTT",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[10].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[10].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[10].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
           endif
 
           if (reply->list[d.seq].results[7].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "Heparin Anti-Xa",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[7].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[7].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[7].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
           endif
 
           if (reply->list[d.seq].results[11].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "Platelet-Coag Survey",row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[11].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[11].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[11].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
           endif
 
           if (reply->list[d.seq].results[8].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "ALT (SGPT)"	,row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[8].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[8].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[8].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 12
           endif
 
           if (reply->list[d.seq].results[9].value > " ")
            call print(calcpos(xs7,yy)) dfnt, "AST (SGOT)"	,row + 1
            call print(calcpos(xs8,yy)) dfnt, reply->list[d.seq].results[9].value,row + 1
            call print(calcpos(xs9,yy)) dfnt, reply->list[d.seq].results[9].ref_range, row + 1
            call print(calcpos(xs10,yy)) dfnt, reply->list[d.seq].results[9].res_dt_tm "mm/dd/yy hh:mm;;d", row + 1
            yy = yy + 24
           endif
 
 
 
 
foot nurse_srt
 
   if(output_device = "pagecount")
      stat = alterlist(units->list, size(units->list, 5)+1)
      units->list[size(units->list, 5)].disp = nurse_srt
      units->list[size(units->list, 5)].pgs = nu_pg
     ;nu_pg = 0
   endif
 
   if(not curendreport)
      break
       endif
 
 
 
foot page
 
   lncnt = 0
   yy = yy + 16
   ;lst_pg = 0
   ;lst_pg = tot_pg
 
   idx = 0
   idx2 = 0
   idx2 = locateval(idx, 0, size(units->list, 5), nurse_srt, units->list[idx].disp);,row + 1
 
   ;rtxt = concat("Unit Page: ", nu_pg, " of ", units->list[idx2].pgs)
   call print(calcpos(30,750)) dfnt, "Unit Page: ", nu_pg "###", " of ", units->list[idx2].pgs "####"
 
   call print(calcpos(450,750)) dfnt,   "Report Page: ", curpage "#####", " of ", tot_pg "#####",row + 0
 
foot report
if(output_device = "pagecount")
   tot_pg = curpage
 endif
 
   row + 0
 
with nocounter, nocompress, maxcol = 2000, nolandscape, maxrow = 3000,
	dio= 38
 
  declare command_d = vc
 
  set command_d = notrim(concat("cp ",outfile," /cerner/nfs/ismgmtkpi/vista_plus/",vplusfile))
  set st = size(trim(command_d))
  call dcl(command_d,st,0)
  call echo (command_d)
 
  set command_d = notrim(concat("cp ",outfile," /cerner/nfs/data/coag/",outfile))
  set st = size(trim(command_d))
  call dcl(command_d,st,0)
  call echo (command_d)
 
 
 
ENDIF;Check for OPS
 
;------------------------------------------------------------------------------------
;-- EXIT_SCRIPT : This section executed when no data is found for the criteria ------
;------------------------------------------------------------------------------------
 
#EXIT_SCRIPT
if(data_found_ind = 0 )
 
select into $1 from dummyt
 
head report
 
    line_double       = fillstring( 104, "=" )
    line_single       = fillstring( 104, "-" )
 
    title_line_1      = "ANTICOAGULANT PATIENT WORKSHEET"
    title_line_2      = ""
 
    title_col_1       = ( maxcol/2 - textlen( title_line_1 )/2 ) + 5
    title_col_2       = ( maxcol/2 - textlen( title_line_2 )/2 ) + 5
 
    col title_col_1 title_line_1
    row + 1
 
    col 0  org_name
    col 90 "Page: ", curpage "#####"
    row + 1
 
    col 0   "Report Date: ", curdate "MM/DD/YY;;Q" ," ", curtime "HH:MM;;S"
    row + 1
    col 0   "Time: ", curdate "HH:MM;;S"
    row + 1
    col 0   "CCL Name: CHS_RX_COAG_REVIEW.PRG"
    row + 2
    col 50 "No data available for given criteria.."
 
with nocounter, dio = 08,nocompress, maxcol = 2000,maxrow = 3000
 
endif
 
#END_OUTPUT
 
set last_mod = "008 rm010118 1/12/09 1500"
 
end
go
 
 
