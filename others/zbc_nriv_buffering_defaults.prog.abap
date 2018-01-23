*&---------------------------------------------------------------------*
*& Report  ZBC_NRIV_BUFFERING_DEFAULTS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZBC_NRIV_BUFFERING_DEFAULTS.
tables: nriv, tnro.

data: lt_nriv  type standard table of nriv
                     with key
                     CLIENT OBJECT SUBOBJECT NRRANGENR TOYEAR,

      ls_nriv  type nriv,

      lt_tnro  type hashed table of TNRO
                     with unique key OBJECT,

      ls_tnro  type tnro.

data: bwobject1 type RSNUMBRANR.
*/BIC/OIZCGTCNRBW.
data: bwobject2 type RSNUMBRANR.
*/BIC/OIZCGTCNRBW.
data: l_index type i.

parameters:

              p_value type i default 100,
              p_sid   type tablename,
              p_dim   type tablename,
              p_test  as checkbox default 'X'.


perform:
          select,
          find_linked_objects,
          update_tnro,
          display_list.


*************************************************************
*                           SELECT                          *
* Selecting number range objects from NRIV                  *
*************************************************************
form select.

     perform message using 5 'Retrieving objects...'.

     if p_sid is initial and p_dim is initial.

          select * from nriv into table lt_nriv
          where object like 'BID%' or object like 'BIM%'.

     else.

          select * from nriv into table lt_nriv
          where object = p_sid or object = p_dim.

     endif.

endform.


*************************************************************
*                 FIND_LINKED_OBJECTS                       *
* Retrieving BW object name for number range object and     *
* eliminating the ones that do not qualify (package dims, etc)
*************************************************************
form find_linked_objects.
data: dtext(44).

    sort lt_nriv by object.

    loop at lt_nriv into ls_nriv.

        concatenate 'Linking NR object' ls_nriv-object
        into dtext separated by space.

        perform message using 77 dtext.

        clear bwobject1.

        case ls_nriv-object(3).
        when 'BID'.

               select single dimension from rsddimeloc
               into bwobject1 where numbranr = ls_nriv-object+3(7).

               if bwobject1 is initial.
                    delete lt_nriv.
               else.
* Filter out package dimensions
                    move bwobject1 to bwobject2.
                    l_index = strlen( bwobject2 ).
                    subtract 1 from l_index.
                    if bwobject2+l_index(1) = 'P'.
                           delete lt_nriv.
                    endif.
               endif.

        when 'BIM'.

               select single chabasnm from rsdchabasloc
               into bwobject1 where numbranr = ls_nriv-object+3(7).

               if bwobject1 is initial or bwobject1 cs 'REQUEST'.
                    delete lt_nriv.
               endif.

        when others.

        endcase.

    endloop.

endform.


*************************************************************
*                        UPDATE_TNRO                        *
* Updating database table TNRO with changes                 *
*************************************************************
form update_tnro.

field-symbols: <tnro> type tnro.

    perform message using 95 'Updating TNRO table...'.

    check p_test is initial.

    select * from tnro into table lt_tnro
    for all entries in lt_nriv
    where object = lt_nriv-object.

    loop at lt_tnro assigning <tnro>.
     if <tnro>-noivbuffer < p_value.
        move:
               'X'     to <tnro>-buffer,
               p_value to <tnro>-noivbuffer.
     endif.
    endloop.

    update tnro from table lt_tnro.

    if sy-subrc = 0.
       commit work.
    endif.

endform.


*************************************************************
*                      DISPLAY_LIST                         *
* Displays list of updates                                  *
*************************************************************
form display_list.

write: text-001.
uline. skip. detail.

    loop at lt_nriv into ls_nriv.
        write:/ ls_nriv-object.
    endloop.

endform.

****************************************************
* MESSAGE
***************************************************
form message using pct text.

  call function 'SAPGUI_PROGRESS_INDICATOR'
       exporting
            percentage = pct
            text       = text
       exceptions
            others = 1.

  call function 'ABAP4_COMMIT_WORK'.


endform.
