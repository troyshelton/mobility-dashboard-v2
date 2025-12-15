/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-2003 Cerner Corporation                 *
      *                                                                      *
      *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
      *  This material contains the valuable properties and trade secrets of *
      *  Cerner Corporation of Kansas City, Missouri, United States of       *
      *  America (Cerner), embodying substantial creative efforts and        *
      *  confidential information, ideas and expressions, no part of which   *
      *  may be reproduced or transmitted in any form or by any means, or    *
      *  retained in any storage or retrieval system without the express     *
      *  written permission of Cerner.                                       *
      *                                                                      *
      *  Cerner is a registered mark of Cerner Corporation.                  *
      *                                                                      *
  ~BE~***********************************************************************/
 
/*****************************************************************************
 
        Source file name:       KI_RNDS_LAB_GV.PRG
        Object name:            KI_RNDS_LAB_GV
        Request #:               -
 
        Product:                 -
        Product Team:           KI
        HNA Version:            500
        CCL Version:            8.4
 
        Program purpose:        Return Last 36hrs of lab for rounds GV
 
 
        Tables read:            CLINICAL_EVENT,V500_EVENT_SET_EXPLODE,
								V500_EVENT_SET_CANON
 
 
	    Tables updated:          -
 
        Executing from:         PowerChart with encntr_id
 
******************************************************************************
 
 
;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date       Engineeer          Comment                             *
;    *--- ---------- ------------------ ----------------------------------- *
;     ### 12/15/2006 Christopher Canida 	Initial Release	   				*
;     001 12/04/2007 sb7135					display 'see flowsheet for micro*
;     002 05/12/2008 bu7702			    Changed to specialty lab results    *
;                                        indexed clinical_event query       *
;~DE~************************************************************************
 
 
;~END~ ******************  END OF ALL MODCONTROL BLOCKS  *******************/
 
 
;******************************************************************************
;*                      SHARP REVISION HISTORY                                *
;******************************************************************************
;Mod Date       Mod By  CM#       Comment
;--- ---------- ------- --------- ----------------------------------------------
;003 03/23/2010 petja5  CM006104  Custom sort order for labs added before
;                                 collating_seq; if not one of specified labs
;                                 then follows previous ordering.
;                                 Also reformated code and changed var names for
;                                 readability and put rtf format commands in an
;                                 include file for reusability.
;004 11/03/2010 Morteza Miraftab  Fixed the see flowsheet issue mm-beg/mm-end
;005 08/16/2011 petja5  CM009264  Clean up Custom Scripts id'd by Cerner Fitness team
;                                 Added +0 to query to facilitate Cerner recommended index
;******************************************************************************
drop program shrp_rnds_lab_gv:dba go
create program shrp_rnds_lab_gv:dba
 
;The following contains rtf format command constants
%I cust_script:1_rtf_cmds.inc     ; 003
 
;Load the RTF header commands into Reply structure
set reply->text = concat(pcsRtfBof,pcsRtfWR)
 
 
;******************************************************************************
; Declare Variables
;******************************************************************************
 
declare script_version  = vc with public, noconstant(" ")
 
;Get Code Values for Lab Section
declare lab_cd           = f8 with constant(uar_get_code_by("DISPLAYKEY",93,"ROUNDSREPORTQUICKLAB"))
declare high_cd          = f8 with constant(uar_get_code_by("MEANING",52,'HIGH'))
declare low_cd           = f8 with constant(uar_get_code_by("MEANING",52,'LOW'))
declare critical_high    = f8 with constant(uar_get_code_by("DISPLAYKEY",52,"CRITICALHIGH"))
declare critical_low     = f8 with constant(uar_get_code_by("DISPLAYKEY",52,"CRITICALLOW"))
declare critical         = f8 with constant(uar_get_code_by("MEANING",52,"CRITICAL"))
 
;Clincal Event Status
declare inerror          = f8 with constant(uar_get_code_by("MEANING",8,"INERROR")),Protect
declare notdone          = f8 with constant(uar_get_code_by("MEANING",8,"NOT DONE")),Protect
declare modified         = f8 with constant(uar_get_code_by("MEANING",8,"MODIFIED")),Protect
declare altered          = f8 with constant(uar_get_code_by("MEANING",8,"ALTERED")),Protect
 
;Clinical Events Result Type
declare txt_cd           = f8 with constant(uar_get_code_by("MEANING",53,"TXT"))
declare doc_cd           = f8 with constant(uar_get_code_by("MEANING",53,"DOC"))
declare mbo_cd           = f8 with constant(uar_get_code_by("MEANING",53,"MBO"))     ;001
 
;003
;Get Code Values for Specific Labs to Order by
declare pcfGlucoseLvl    = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "GLUCOSELVL"))
declare pcfSodiumLvl     = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "SODIUMLVL"))
declare pcfPotassiumLvl  = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "POTASSIUMLVL"))
declare pcfChloride      = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "CHLORIDE"))
declare pcfC02           = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "CO2"))
declare pcfBUN           = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "BUN"))
declare pcfCreatinine    = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "CREATININE"))
declare pcfCalciumLvl    = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "CALCIUMLVL"))
declare pcfMagnesiumLvl  = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "MAGNESIUMLVL"))
declare pcfPhosphorusLvl = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "PHOSPHORUSLVL"))
declare pcfUricAcid      = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "URICACID"))
declare pcfTtlProtein    = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "TOTALPROTEIN"))
declare pcfAlbuminLvl    = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "ALBUMINLVL"))
declare pcfAST           = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "AST"))
declare pcfALT           = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "ALT"))
declare pcfGGT           = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "GGT"))
declare pcfAlkPhos       = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "ALKPHOS"))
declare pcfBiliTtl       = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "BILITOTAL"))
declare pcfLDHTtl        = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "LDHTOTAL"))
declare pcfWBC           = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "WBC"))
declare pcfPLT           = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "PLT"))
declare pcfHGB           = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "HGB"))
declare pcfHCT           = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "HCT"))
declare pcfRBC           = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "RBC"))
 
 
;structure to hold information to
;uniquely identify a person/encounter
record rUniqueId
( 1 encntr_id = f8
  1 person_id = f8
)
 
;Determine the person_id as it's not passed via
;request 600347 when code_value set to VISIT
select  into "nl:"
from    encounter e
plan    e
where   e.encntr_id ;=  48767193.00
=       request->visit[1].encntr_id
detail
        rUniqueId->encntr_id = e.encntr_id
        rUniqueId->person_id = e.person_id
with    nocounter
 
 
;****************Retrieve Lab Data ****************************************
 
;003
;According to uCern Collaboration responses, IF's within the SELECT
;execute faster than joining to a pre-populated temp table
;Not sure if I agree but the following simplifies the code
 
select  into "nl:"
        ce.event_end_dt_tm
,       event_disp  =       uar_get_code_display(ce.event_cd)
,       event_set   =       uar_get_code_display(vesc.event_set_cd)
;       003 - custom ordering
,       custom_lab_order
=   (   if(ce.event_cd = pcfGlucoseLvl)        1
        elseif(ce.event_cd = pcfSodiumLvl)     2
        elseif(ce.event_cd = pcfPotassiumLvl)  3
        elseif(ce.event_cd = pcfChloride)      4
        elseif(ce.event_cd = pcfC02)           5
        elseif(ce.event_cd = pcfBUN)           6
        elseif(ce.event_cd = pcfCreatinine)    7
        elseif(ce.event_cd = pcfCalciumLvl)    8
        elseif(ce.event_cd = pcfMagnesiumLvl)  9
        elseif(ce.event_cd = pcfPhosphorusLvl)10
        elseif(ce.event_cd = pcfUricAcid)     11  ;<- not in lab group
        elseif(ce.event_cd = pcfTtlProtein)   12
        elseif(ce.event_cd = pcfAlbuminLvl)   13
        elseif(ce.event_cd = pcfAST)          14
        elseif(ce.event_cd = pcfALT)          15
        elseif(ce.event_cd = pcfGGT)          16  ;<- not in lab group
        elseif(ce.event_cd = pcfAlkPhos)      17
        elseif(ce.event_cd = pcfBiliTtl)      18
        elseif(ce.event_cd = pcfLDHTtl)       19  ;<- not in lab group
        elseif(ce.event_cd = pcfWBC)          20
        elseif(ce.event_cd = pcfPLT)          21
        elseif(ce.event_cd = pcfHGB)          22
        elseif(ce.event_cd = pcfHCT)          23
        elseif(ce.event_cd = pcfRBC)          24
        else                                  25
        endif
    )
from    clinical_event          ce
,       v500_event_set_explode  vese
,       v500_event_set_canon    vesc
 
plan    ce
where   ce.person_id             = rUniqueId->person_id
and     ce.event_end_dt_tm      >= cnvtlookbehind("36 H",cnvtdatetime(curdate,curtime3))
and     ce.valid_until_dt_tm    >= cnvtdatetime(curdate,curtime3)
and     ce.encntr_id             = rUniqueId->encntr_id
and     ce.result_status_cd not in (inerror,notdone)
and     ce.view_level   + 0      = 1
and     ce.publish_flag + 0      = 1
 
join    vese
where   vese.event_cd   = ce.event_cd                 ; code_set = 72, in essence matches 93
 
join    vesc
where   vesc.event_set_cd           = vese.event_set_cd  ; code_set = 93, in essence matches 72
and     vesc.parent_event_set_cd +0 = lab_cd ;005-cerner recommendation to facilitate alternate index
 
order   ce.event_end_dt_tm  DESC     ;004
,       custom_lab_order             ;003
,       vesc.event_set_collating_seq ;003
,       event_set
 
 
;******************************
;** REPORT WRITER - HEAD REPORT
;******************************
head report
flowsheet_ind = 0
 
;set Genview title
reply->text = concat(reply->text
                    ,pcsRtfWB
                    ,pcsRtfTab
                    ,"36hr Labs"
                    ,pcsRtfEop
                    ,pcsRtfBopTab
                    ,pcsRtfWR)
 
;***********************
;** REPORT WRITER - HEAD
;***********************
head ce.event_end_dt_tm
reply->text = concat(reply->text
;                    ,pcsRtfEol
                    ,pcsRtfWB
                    ,format(cnvtdatetime(ce.event_end_dt_tm),"MM/DD HHMM;;D")
                    ,pcsRtfEop
                    ,pcsRtfBopTab
                    ,pcsRtfWR)
 
;*************************
;** REPORT WRITER - DETAIL
;*************************
detail
if (ce.event_class_cd = mbo_cd)                                                                      ;001
    reply->text = concat(reply->text
                        ,trim(substring(1,15,event_disp))
                        ,pcsRtfTab
                        ,"See Flowsheet")                                                            ;001
    flowsheet_ind = 1                                                                                ;001
elseif (ce.event_class_cd in (txt_cd,doc_cd)
;mm-beg
;and     size(ce.event_tag,1)> 14)
 and     textlen(ce.event_tag)> 14)
;mm-end
    reply->text = concat(reply->text
                        ,trim(substring(1,15,event_disp))
                        ,pcsRtfTab
                        ,"See Flowsheet")
    flowsheet_ind = 1
else
    reply->text = concat(reply->text
                        ,trim(substring(1,15,event_disp))
                        ,pcsRtfTab
                        ,trim(ce.event_tag))
endif
 
if (flowsheet_ind = 0)
    if (ce.normalcy_cd = high_cd)
        reply->text = concat(reply->text, "   "
                            ,pcsRtfTab
                            ,"H"
                            ,pcsRtfEop
                            ,pcsRtfBopTab)
    elseif (ce.normalcy_cd = low_cd)
        reply->text = concat(reply->text, "   "
                            ,pcsRtfTab
                            ,"L"
                            ,pcsRtfEop
                            ,pcsRtfBopTab)
    elseif (ce.normalcy_cd = critical_low)
        reply->text = concat(reply->text, "   "
                            ,pcsRtfTab
                            ,"CL"
                            ,pcsRtfEop
                            ,pcsRtfBopTab)
    elseif(ce.normalcy_cd = critical_high)
        reply->text = concat(reply->text, "   "
                            ,pcsRtfTab
                            ,"CH"
                            ,pcsRtfEop
                            ,pcsRtfBopTab)
    elseif(ce.normalcy_cd = critical)
        reply->text = concat(reply->text, "   "
                            ,pcsRtfTab
                            ,"C"
                            ,pcsRtfEop
                            ,pcsRtfBopTab)
    else
        reply->text = concat(reply->text
                            ,pcsRtfEop
                            ,pcsRtfBopTab)
    endif
else
    flowsheet_ind = 0
    reply->text = concat(reply->text
                        ,pcsRtfEop
                        ,pcsRtfBopTab)
endif
 
;***********************
;** REPORT WRITER - FOOT
;***********************
foot ce.event_end_dt_tm
    row + 0
 
 
with nocounter
 
if(curqual > 0)
    set reply->text = concat(reply->text
                            ,pcsRtfEof)
else
    set reply->text = concat(reply->text
                            ,pcsRtfWB
                            ,"No 36hr Lab Data"   ;003
                            ,pcsRtfEof)
endif
 
 
set script_version = "005 08/16/2011" ;003;005
 
 
end
go
