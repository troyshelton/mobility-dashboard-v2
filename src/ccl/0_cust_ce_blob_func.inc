declare cust_ceblob_get(event_id = f8) = vc
declare cust_ceblob_rtf(blob = vc) = vc

/**********************************************************************
cust_ceblob_get

DESCRIPTION:  Collect and Uncompress the a CE_blob

      NOTES:  I had such a hard time doing this... I tried a dozen 
              different ways.  None worked.  I eventually found code on 
              uCern that performed the work as intended, and was a
              collection of various stuff I tried.  Apparently better
              than I could cobble together.
              
              In any case.  I'm packing this up in hopes someone else
              can be saved the fight.
              
              Another note.  It might be important that BLR.FORMAT_CD
              be checked.  Where I was using this I always expected 
              xhtml... but if needed you might have to gather that 
              yourself.  That should be a straightforward hit to 
              CE_BLOB_RESULT however... so shouldn't be too difficult.
             
***********************************************************************/
subroutine cust_ceblob_get(event_id)
    declare good_blob  = vc
    declare print_blob = vc
    declare outbuf     = c32768
    declare blobout    = vc

    declare retlen     = i4
    declare offset     = i4
    declare newsize    = i4
    declare finlen     = i4
    declare xlen       = i4
    
    
    select into 'nl:'
           cb.event_id
         , cb.blob_seq_num
         , cb.blob_length
         , cb.valid_from_dt_tm
         , cb.valid_until_dt_tm

      from ce_blob cb

     where cb.event_id          =  event_id
       and cb.VALID_FROM_DT_TM  <  cnvtdatetime(curdate,curtime3)
       and cb.VALID_UNTIL_DT_TM >  cnvtdatetime(curdate,curtime3)

    order by cb.event_id  ;since blobget() is used sorting must be done at the RDBMS level
           , cb.blob_seq_num
       
    head cb.event_id
        if(cb.compression_cd = 728)
            blobout   = " "
            outbuf    = " "
            good_blob = " "
            
            for (x = 1 to (cb.blob_length / 32768))
                blobout = notrim(concat(notrim(blobout),notrim(fillstring(32768, " "))))
            endfor
            
            finlen  = mod(cb.blob_length, 32768)
            blobout = notrim(concat(notrim(blobout), notrim(substring(1, finlen, fillstring(32768, " ")))))
        
        else
            outbuf    = " "
            good_blob = " "
        endif
        
    DETAIL
        if(cb.compression_cd = 728)
            retlen = 1
            offset = 0

            while (retlen > 0)
                retlen = blobget(outbuf, offset, cb.blob_contents)
                offset = offset + retlen
                if(retlen!=0)
                    xlen = findstring("ocf_blob", outbuf, 1) - 1

                    if(xlen<1)
                       xlen = retlen
                    endif

                    good_blob = notrim(concat(notrim(good_blob), notrim(substring(1, xlen, outbuf))))

                endif
             endwhile
        
        else
            outbuf = cb.blob_contents
            xlen = findstring("ocf_blob", outbuf, 1) - 1
            
            good_blob = notrim(concat(notrim(good_blob), notrim(substring(1, xlen, outbuf))))
        endif

    foot cb.event_id
        if(cb.compression_cd = 728)
            newsize = 0
            
            good_blob = concat(notrim(good_blob),"ocf_blob")
            
            blob_un = uar_ocf_uncompress(good_blob, size(good_blob),
                                    blobout, size(blobout), newsize)
        
        else
            blobout = good_blob
        endif

    with maxcol = 32100 , rdbarrayfetch = 1, format=undefined


    return(blobout)

end


/**********************************************************************
cust_ceblob_rtf

DESCRIPTION:  Do cleaning and RTF -> Text conversion for a gathered blob             
***********************************************************************/
subroutine cust_ceblob_rtf(blob)

    declare result_val = vc with protect, noconstant('')

    set blobout2 = fillstring(32768, ' ')

    call uar_rtf(blob, textlen(blob), blobout2, 32768, 32768, 0)

    set result_val = trim(replace(blobout2, build(char(13),char(10)), "  "))

    return(result_val)

end

