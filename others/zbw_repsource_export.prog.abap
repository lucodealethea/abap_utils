*   SELECTION - TEXTs
*______________________________________________________________________
*
** Tab 1 - selection by program name.
*   so_progs  =  program name
*   so_clas   =  program class
*   so_subc   =  program type
*   so_appl   =  application
*   so_cnam   =  author of the program
*   so_cdat   =  creation date
*
** Tab 2 - selection by development class
*   so_sour   = source system
*   so_devc   = development class
*   so_objt   = program name
*   so_auth   = author
*
** Tab 3 - selection by transport request
*   so_korr   = transport request (corection number)
*   so_targ   = target system
*   so_user   = user-owner of transport
*   so_objn   = program name
*
** Tab 4 - selection by function module
*   so_fdvc   = development class
*   so_faut   = author
*   so_fare   = function area
*   so_func   = function module - name
*   so_fmod   = type of modification
*   so_ftas   = type of Update (task)
*
** Other parameters on selection screen (main selection screen)
*   pa_path   = path in which store files
*   pa_ovrwr  = ovewrite existing files?
*   pa_esour  = extension for source code
*   pa_etext  = extension for text elements
*   pa_edynp  = extension for dynpro
*   pa_pincl  = process & save includes
*   pa_text   = save report's text elements
*   so_langu  = save text elements in these languages
*   pa_dynp   = save screens? (Yes/No)
*   pa_notss  = do not save selection screens (Yes/No)
*   pa_prefl  = preferred language for dynpro text
*   so_dynpr  = save only these screens
*______________________________________________________________________

*&---------------------------------------------------------------------*
*& Report  ZBW_REPSOURCE_EXPORT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZBW_REPSOURCE_EXPORT LINE-SIZE 250
        NO STANDARD PAGE HEADING .


TYPE-POOLS: icon.
*---------------------------------------------------------------------*
* CONSTANTS
*---------------------------------------------------------------------*


*---------------------------------------------------------------------*
* TYPES
*---------------------------------------------------------------------*
TYPES: BEGIN OF t_rep_source,
         line(300),
       END OF t_rep_source.

TYPES: BEGIN OF t_program,
        prog TYPE trdir-name,
        subc TYPE trdir-subc,
        text TYPE trdirt-text,
        sel(1),
       END OF t_program.

TYPES: BEGIN OF t_dynpro,
        prog TYPE trdir-name,
        dynp TYPE d020s-dnum,
        text TYPE d020t-dtxt,
       END OF t_dynpro.

TYPES: BEGIN OF t_dynpro_text,
        lang TYPE d020t-lang,
        dtxt TYPE d020t-dtxt,
       END OF t_dynpro_text.

TYPES: BEGIN OF t_pom_vypis,
        caseval(1),
        icon TYPE icon-name,
        text(80),
       END OF t_pom_vypis.


*---------------------------------------------------------------------*
* DATA DEFINITIONS
*---------------------------------------------------------------------*
DATA: ws_korr TYPE e070-trkorr,
      ws_user TYPE e070-as4user,
      ws_targ TYPE e070-tarsystem,
      ws_objn TYPE e071-obj_name,

      ws_sour TYPE tadir-srcsystem,
      ws_devc TYPE tadir-devclass,
      ws_auth TYPE tadir-author,

      wa_prog TYPE trdir-name,
      ws_clas TYPE trcl-code,
      ws_subc TYPE trdir-subc,
      ws_appl TYPE taplp-appl,
      ws_cnam TYPE usr02-bname,
      ws_cdat TYPE trdir-cdat,

      ws_fdvc TYPE tadir-devclass,
      ws_faut TYPE tadir-author,
      ws_fare TYPE tlibg-area,
      ws_func TYPE tfdir-funcname,
      ws_fmod TYPE tfdir-fmode,
      ws_ftas TYPE tfdir-utask,

      ws_spras TYPE t002-spras,
      ws_dynpr TYPE d020t-dynr.

DATA: g_i_progs TYPE STANDARD TABLE OF t_program WITH HEADER LINE,
      g_wa_prog TYPE t_program.

DATA: g_i_dynpros TYPE STANDARD TABLE OF t_dynpro,
      g_wa_dynpro TYPE t_dynpro,
      g_wa_type   TYPE d020s-type,
      g_pocet TYPE i,
      g_i_tmp_dynp TYPE STANDARD TABLE OF t_dynpro_text
                   WITH HEADER LINE.

DATA: g_i_langu TYPE STANDARD TABLE OF t002-spras WITH HEADER LINE.

DATA: g_i_vypis TYPE TABLE OF t_pom_vypis WITH HEADER LINE.

DATA TESTE TYPE STRING.


*---------------------------------------------------------------------*
* SELECTION SUBDYNPRO
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 1001 AS SUBSCREEN.
* text-su1 = 'Vyber podla nazvu a atributov programu:'
* text-su1(E)'Selection by program name and atributes:'
  SELECTION-SCREEN BEGIN OF BLOCK opt WITH FRAME TITLE text-su1.
    SELECT-OPTIONS:
                    so_progs FOR wa_prog,
                      " program name
                    so_clas  FOR ws_clas,
                      " program class
                    so_subc  FOR ws_subc,
                      " program type
                    so_appl  FOR ws_appl,
                      " application
                    so_cnam  FOR ws_cnam,
                      " author
                    so_cdat  FOR ws_cdat.
                      " creation date
  SELECTION-SCREEN END OF BLOCK opt.

SELECTION-SCREEN END OF SCREEN 1001.


*---------------------------------------------------------------------*
* SELECTION SUBDYNPRO
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 1002 AS SUBSCREEN.
* text-su2 = 'Vyber podla vyvojovej triedy:'
* text-su2(E)'Selection by development class:'
  SELECTION-SCREEN BEGIN OF BLOCK opt2 WITH FRAME TITLE text-su2.
    SELECT-OPTIONS:
                  so_sour  FOR ws_sour,
                    " source system
                  so_devc  FOR ws_devc,
                    " development class
                  so_objt  FOR wa_prog,
                    " program name
                  so_auth  FOR ws_auth.
                    " author
  SELECTION-SCREEN END OF BLOCK opt2.
SELECTION-SCREEN END OF SCREEN 1002.


*---------------------------------------------------------------------*
* SELECTION SUBDYNPRO
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 1003 AS SUBSCREEN.
* text-su3 = 'Vyber podla transportnej poziadavky:'
* text-su3 = 'Selection by transport request:'
  SELECTION-SCREEN BEGIN OF BLOCK opt3 WITH FRAME TITLE text-su3.
    SELECT-OPTIONS:
                  so_korr FOR ws_korr,
                    " transport request (corection number)
                  so_targ FOR ws_targ,
                    " target system
                  so_user FOR ws_user,
                    " user-owner of transport
                  so_objn FOR ws_objn.
                    " program name
  SELECTION-SCREEN END OF BLOCK opt3.

SELECTION-SCREEN END OF SCREEN 1003.


*---------------------------------------------------------------------*
* SELECTION SUBDYNPRO
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 1004 AS SUBSCREEN.
* text-su4 = 'Vyber funkcnych modulov:'
* text-su4(E)'Selection by function modules:'
  SELECTION-SCREEN BEGIN OF BLOCK opt4 WITH FRAME TITLE text-su4.
    SELECT-OPTIONS:
                 so_fdvc FOR ws_fdvc,
                   " development class
                 so_faut FOR ws_faut,
                   " author
                 so_fare FOR ws_fare,
                   " function area
                 so_func FOR ws_func,
                   " function module - name
                 so_fmod FOR ws_fmod,
                   " type of modification
                 so_ftas FOR ws_ftas.
                   " type of Update (task)
  SELECTION-SCREEN END OF BLOCK opt4.

SELECTION-SCREEN END OF SCREEN 1004.



*---------------------------------------------------------------------*
* SELECTION DYNPRO  [MAIN]
*---------------------------------------------------------------------*
* text-se1 = 'Subory ulozit do'
* text-se1(E)'Files save to'
SELECTION-SCREEN BEGIN OF BLOCK file WITH FRAME TITLE text-se1.
*  PARAMETERS: pa_path(80) OBLIGATORY DEFAULT 'D:\Documents and Settings\Y4Y8\Desktop\ABAP\',
  PARAMETERS: pa_path(80) LOWER CASE OBLIGATORY DEFAULT '/home/vboard/Documents/SAPGUI/',
                " path in which store files
              pa_ovrwr AS CHECKBOX DEFAULT space.
                " ovewrite existing files?

* text-se2 = 'Pripony pre subory:'
* text-se2(E)'Extensions for files:'
  SELECTION-SCREEN BEGIN OF BLOCK exten WITH FRAME TITLE text-se2.
    PARAMETERS: pa_esour(5) DEFAULT 'ABAP',
                  " extension for source code
                pa_etext(5) DEFAULT 'TXTP',
                  " extension for text elements
                pa_edynp(5) DEFAULT 'DYNP'.
                  " extension for dynpro
  SELECTION-SCREEN END OF BLOCK exten.
SELECTION-SCREEN END OF BLOCK file.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF LINE.
* text-cm1 = 'Ddjde k vyberu podla aktualne zvolenej zalozky:'.
* text-cm1(E)'Reports are selected by actual choosen tab:'
  SELECTION-SCREEN COMMENT 1(50) text-cm1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF TABBED BLOCK tabed FOR 8 LINES.
  SELECTION-SCREEN TAB (8) tab1 USER-COMMAND TAB1 DEFAULT SCREEN 1001.
  SELECTION-SCREEN TAB (8) tab2 USER-COMMAND TAB2 DEFAULT SCREEN 1002.
  SELECTION-SCREEN TAB (8) tab3 USER-COMMAND TAB3 DEFAULT SCREEN 1003.
  SELECTION-SCREEN TAB (8) tab4 USER-COMMAND TAB4 DEFAULT SCREEN 1004.
SELECTION-SCREEN END OF BLOCK tabed.

SELECTION-SCREEN SKIP.

PARAMETERS: pa_pincl AS CHECKBOX DEFAULT 'X'.
               " process includes - search the source code for INCLUDE
               " and if found, save the include, too.

SELECTION-SCREEN SKIP.

* text-se3 = 'Textove prvky'
* text-se3(E)'Text elements'
SELECTION-SCREEN BEGIN OF BLOCK text WITH FRAME TITLE text-se3.
  PARAMETERS: pa_text AS CHECKBOX DEFAULT 'X'.
                " save report's text elements
  SELECT-OPTIONS: so_langu FOR ws_spras DEFAULT sy-langu.
                " save text elements in these languages
SELECTION-SCREEN END OF BLOCK text.

* text-se4 = 'Dynpra'
* text-se4(E)'Screens'
SELECTION-SCREEN BEGIN OF BLOCK dynp WITH FRAME TITLE text-se4.
  PARAMETERS: pa_dynp AS CHECKBOX DEFAULT 'X',
                " save screens? (Yes/No)
              pa_notss AS CHECKBOX DEFAULT 'X',
                " do not save selection screens (Yes/No)
              pa_prefl TYPE t002-spras DEFAULT sy-langu.
                " preferred language for dynpro text (if more in DB)
  SELECT-OPTIONS: so_dynpr FOR ws_dynpr.
                " save only these screens
SELECTION-SCREEN END OF BLOCK dynp.



*---------------------------------------------------------------------*
* INITIALIZATION
*---------------------------------------------------------------------*
INITIALIZATION.
* Texty na vyberovej obrazovke.
*  tab1 = 'Program'(t01).
*  tab2 = 'Vývoj.tr.'(t02).
*  tab3 = 'Trans.po.'(t03).
*  tab4 = 'Funkcie'(t04).

* E:
  tab1 = 'Program'(t01).
  tab2 = 'Devel.class'(t02).
  tab3 = 'Transp.req.'(t03).
  tab4 = 'Function'(t04).

* Infotexty v reporte.
  CLEAR g_i_vypis.
  REFRESH g_i_vypis.
  PERFORM fill_infotext USING:
'1' ICON_SELECT_ALL
   'Double click on THIS LINE to select ALL programs to export!'(v01),
'2' ICON_DESELECT_ALL
   'Double click on THIS LINE to Deselect ALL.'(v02),
'3' ICON_EXECUTE_OBJECT
   'Double click on THIS LINE to START EXPORT!'(v03).




*---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*---------------------------------------------------------------------*
AT SELECTION-SCREEN.
* Checks active only if user choose 'EXECUTE' on selection-screen.
  CHECK sy-ucomm = 'ONLI'.
* kontrola na vyplnenie aspon 1 vyberoveho kriteria!
  CASE tabed-activetab.
    WHEN 'TAB1'.
      CHECK
                    so_progs IS INITIAL AND
                      " program name
                    so_clas  IS INITIAL AND
                      " program class
                    so_subc  IS INITIAL AND
                      " program type
                    so_appl  IS INITIAL AND
                      " application
                    so_cnam  IS INITIAL AND
                      " author
                    so_cdat  IS INITIAL .
                      " creation date
    WHEN 'TAB2'.
      CHECK
                  so_sour  IS INITIAL AND
                    " source system
                  so_devc  IS INITIAL AND
                    " development class
                  so_objt  IS INITIAL AND
                    " program name
                  so_auth  IS INITIAL .
                    " author
    WHEN 'TAB3'.
      CHECK
                  so_korr IS INITIAL AND
                    " transport request (corection number)
                  so_targ IS INITIAL AND
                    " target system
                  so_user IS INITIAL AND
                    " user-owner of transport
                  so_objn IS INITIAL .
                    " program name
    WHEN 'TAB4'.
      CHECK
                 so_fdvc IS INITIAL AND
                   " development class
                 so_faut IS INITIAL AND
                   " author
                 so_fare IS INITIAL AND
                   " function area
                 so_func IS INITIAL AND
                   " function module - name
                 so_fmod IS INITIAL AND
                   " type of modification
                 so_ftas IS INITIAL .
                   " type of Update (task)
  ENDCASE.
* Ked sme sa dostali az sem - WARNING - Zadat aspon 1 kriter.
* text-w01(E)='Please fill at least 1 selection criteria!'
  MESSAGE w208(00) WITH 'Zadajte aspoò 1 výberové kritérium!'(w01).



*---------------------------------------------------------------------*
* START-OF-SELECTION
*---------------------------------------------------------------------*
START-OF-SELECTION.

* Nahrat jazyky, v ktorych hladat textove prvky.
  SELECT spras FROM t002
      INTO TABLE g_i_langu
      WHERE spras IN so_langu.

* Nahrat reporty podla zvolenych vyberovych kriterii.
  CASE tabed-activetab.
    WHEN 'TAB1'.
      PERFORM load_podla_mena.

    WHEN 'TAB2'.
      PERFORM load_podla_devclass.

    WHEN 'TAB3'.
      PERFORM load_podla_transportu.

    WHEN 'TAB4'.
      PERFORM load_podla_funkcii.

  ENDCASE.

* Nahrat dynpra (IDcka dynpier) ak ich ukladame.
  IF pa_dynp = 'X' AND NOT g_i_progs[] IS INITIAL.
    LOOP AT g_i_progs INTO g_wa_prog.

      CLEAR g_wa_dynpro.
      g_wa_dynpro-prog = g_wa_prog-prog.

      SELECT dnum type FROM d020s
            INTO (g_wa_dynpro-dynp,g_wa_type)
            WHERE prog = g_wa_prog-prog
              AND dnum IN so_dynpr.

* Pokial je to report a dynpro je vyberova obrazovka - preskocime
        IF pa_notss = 'X' AND
          ( g_wa_type = 'S' OR g_wa_type = 'J' ).
              CONTINUE.
        ENDIF.


* Dynpro mame, este nahrat text dynpra, najlepsie v danom jazyku.
        CLEAR g_wa_dynpro-text.
        SELECT COUNT(*) FROM d020t INTO g_pocet
              WHERE prog = g_wa_dynpro-prog
                AND dynr = g_wa_dynpro-dynp.
        IF g_pocet = 0.
* Hups.. - nenasiel sa ziaden popis dynpra.
        ELSEIF g_pocet = 1.
* Iba jeden - nech je jazyk akykolvek, berieme ho
          SELECT SINGLE dtxt FROM d020t
              INTO g_wa_dynpro-text
              WHERE prog = g_wa_dynpro-prog
                AND dynr = g_wa_dynpro-dynp.
        ELSE.
* Skusime vybrat predvoleny, ak sa nenajde, tak 1 v poradi.
          REFRESH g_i_tmp_dynp. CLEAR g_i_tmp_dynp.
          SELECT lang dtxt FROM d020t
              INTO TABLE g_i_tmp_dynp
              WHERE prog = g_wa_dynpro-prog
                AND dynr = g_wa_dynpro-dynp.

          READ TABLE g_i_tmp_dynp WITH KEY lang = pa_prefl.
          IF sy-subrc <> 0.
            READ TABLE g_i_tmp_dynp INDEX 1.
          ENDIF.
          MOVE g_i_tmp_dynp-dtxt TO g_wa_dynpro-text.

        ENDIF.

        APPEND g_wa_dynpro TO g_i_dynpros.
      ENDSELECT.

    ENDLOOP.
  ENDIF.



*---------------------------------------------------------------------*
* END-OF-SELECTION
*---------------------------------------------------------------------*
END-OF-SELECTION.

  PERFORM write_list.

*---------------------------------------------------------------------*
* END-OF-PROGRAM
*---------------------------------------------------------------------*



*---------------------------------------------------------------------*
* AT LINE-SELECTION
*---------------------------------------------------------------------*
AT LINE-SELECTION.
  CHECK NOT g_i_vypis-caseval IS INITIAL.
  CASE g_i_vypis-caseval.
    WHEN '1'.
* Select all
      PERFORM change_all USING 'X'.
    WHEN '2'.
* Deselect all
      PERFORM change_all USING space.
    WHEN '3'.
* Start export - read list, update selection box & export selected
      PERFORM export.
  ENDCASE.
  CLEAR g_i_vypis.





*---------------------------------------------------------------------*
* SUBROUTINES
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  load_podla_mena
*&---------------------------------------------------------------------*
*  Nahrat reporty podla mena a atributov programu - najjednoduchsie :)
*----------------------------------------------------------------------*
FORM load_podla_mena.

  SELECT trdir~name trdir~subc trdirt~text
      INTO TABLE g_i_progs
      FROM trdir LEFT JOIN trdirt
        ON trdir~name = trdirt~name
       AND trdirt~sprsl = sy-langu
      WHERE trdir~name IN so_progs
        AND clas       IN so_clas
        AND subc       IN so_subc
        AND appl       IN so_appl
        AND cnam       IN so_cnam
        AND cdat       IN so_cdat .

ENDFORM.                    " load_podla_mena


*&---------------------------------------------------------------------*
*&      Form  load_podla_devclass
*&---------------------------------------------------------------------*
*  Nahrat reporty podla ich umiestnenia vo vyvojovej triede
*----------------------------------------------------------------------*
FORM load_podla_devclass.

 DATA: l_i_objn TYPE TABLE OF tadir-obj_name.

  SELECT obj_name FROM tadir
      INTO TABLE l_i_objn
      WHERE (
              ( pgmid = 'R3TR' AND object = 'PROG' ) OR
              ( pgmid = 'LIMU' AND object = 'REPS' ) )
        AND obj_name  IN so_objt
        AND srcsystem IN so_sour
        AND devclass  IN so_devc
        AND author    IN so_auth .

  CHECK NOT l_i_objn IS INITIAL.
  SELECT trdir~name trdir~subc trdirt~text
      INTO TABLE g_i_progs
      FROM trdir LEFT JOIN trdirt
        ON trdir~name   = trdirt~name
       AND trdirt~sprsl = sy-langu
      FOR ALL ENTRIES IN l_i_objn
      WHERE trdir~name = l_i_objn-table_line.

ENDFORM.                    " load_podla_devclass


*&---------------------------------------------------------------------*
*&      Form  load_podla_transportu
*&---------------------------------------------------------------------*
*  Nahrat reporty podla ich umiestnenia v transportnej poziadavke.
*----------------------------------------------------------------------*
FORM load_podla_transportu.
  DATA: l_i_trans TYPE TABLE OF e070-trkorr,
        l_i_objn  TYPE TABLE OF trdir-name.

* Transport requests
  SELECT trkorr FROM e070
      INTO TABLE l_i_trans
      WHERE trkorr    IN so_korr
        AND as4user   IN so_user
        AND tarsystem IN so_targ.

* Objects in requests - select only report sources
  SELECT obj_name FROM e071
      INTO TABLE l_i_objn
      FOR ALL ENTRIES IN l_i_trans
      WHERE trkorr = l_i_trans-table_line
        AND obj_name IN so_objn
        AND ( ( pgmid = 'R3TR' AND object = 'PROG' ) OR
              ( pgmid = 'LIMU' AND object = 'REPS' ) ) .

  CHECK NOT l_i_objn IS INITIAL.
* Report sources.
  SELECT trdir~name trdir~subc trdirt~text
      INTO TABLE g_i_progs
      FROM trdir LEFT JOIN trdirt
        ON trdir~name   = trdirt~name
       AND trdirt~sprsl = sy-langu
      FOR ALL ENTRIES IN l_i_objn
      WHERE trdir~name = l_i_objn-table_line.

ENDFORM.                    " load_podla_transportu


*&---------------------------------------------------------------------*
*&      Form  load_podla_funkcii
*&---------------------------------------------------------------------*
*  Nahrat zdrojove texty podla zadania funkcnych modulov
*----------------------------------------------------------------------*
FORM load_podla_funkcii.
 TYPES: BEGIN OF t_modul,
         area     TYPE enlfdir-area,
         funcname TYPE enlfdir-funcname,
        END OF t_modul.

 TYPES: BEGIN OF t_funkcia,
         funcname TYPE tfdir-funcname,
         include  TYPE tfdir-include,
        END OF t_funkcia.

 TYPES: BEGIN OF t_pname,
         pname TYPE trdir-name,
         funcname TYPE enlfdir-funcname,
        END OF t_pname.


 DATA: l_i_funcgroup TYPE TABLE OF enlfdir-area,
       l_i_funcname TYPE TABLE OF t_modul,
       l_i_include    TYPE TABLE OF t_funkcia,
       l_i_pname    TYPE TABLE OF t_pname.
*       l_i_pname    TYPE TABLE OF trdir-name.

 DATA: wa_func  TYPE t_modul,
       wa_include TYPE t_funkcia,
       wa_pname TYPE t_pname.
*       wa_pname TYPE trdir-name.


* Select function groups from devclass.
  SELECT obj_name FROM tadir
      INTO TABLE l_i_funcgroup
      WHERE pgmid = 'R3TR'
        AND object = 'FUGR'
        AND devclass IN so_fdvc
        AND obj_name IN so_fare
        AND author   IN so_faut.

  CHECK NOT l_i_funcgroup IS INITIAL.
* Select function modules by function group
  SELECT area funcname FROM enlfdir
      INTO TABLE l_i_funcname
      FOR ALL ENTRIES IN l_i_funcgroup
      WHERE funcname  IN so_func
        AND area      = l_i_funcgroup-table_line.


  CHECK NOT l_i_funcname IS INITIAL.
* Function modules with it's atributes
  SELECT funcname include FROM tfdir
      INTO TABLE l_i_include
      FOR ALL ENTRIES IN l_i_funcname
      WHERE funcname = l_i_funcname-funcname
        AND fmode  IN so_fmod
        AND utask  IN so_ftas.

* Set up name of function - include name
    LOOP AT l_i_funcname INTO wa_func.
      LOOP AT l_i_include INTO wa_include
        WHERE funcname = wa_func-funcname.

*        CONCATENATE 'L' wa_func-area 'U' wa_include-include
*          INTO wa_pname.

        CONCATENATE 'L' wa_func-area 'U' wa_include-include
          INTO wa_pname-pname.

        wa_pname-funcname = wa_func-funcname.

        APPEND wa_pname TO l_i_pname.

      ENDLOOP.
    ENDLOOP.


  CHECK NOT l_i_pname IS INITIAL.

* Report sources.
  SELECT trdir~name trdir~subc trdirt~text
      INTO TABLE g_i_progs
      FROM trdir LEFT JOIN trdirt
        ON trdir~name   = trdirt~name
       AND trdirt~sprsl = sy-langu
      FOR ALL ENTRIES IN l_i_pname
      WHERE trdir~name = l_i_pname-pname.
*      WHERE trdir~name = l_i_pname-table_line.

  loop at g_i_progs where text eq space.

     read table l_i_pname into wa_pname with key pname = g_i_progs-prog.
     if sy-subrc is initial.
        g_i_progs-text =  wa_pname-funcname.

        modify g_i_progs.

     endif.
  endloop.


ENDFORM.                    " load_podla_funkcii





*&---------------------------------------------------------------------*
*&      Form  read_and_save
*&---------------------------------------------------------------------*
* Nacitanie zdrojoveho textu reportu a ulozenie do suboru.
*---------------------------------------------------------------------*
*      --> P_NAME    Name of report to save
*---------------------------------------------------------------------*
FORM read_and_save USING p_name TYPE trdir-name.
  DATA: l_i_prog_source TYPE TABLE OF t_rep_source ,
        l_was TYPE t_rep_source.

  DATA: l_i_textpool TYPE TABLE OF textpool.

  DATA: l_filename LIKE rlgrap-filename .
  DATA: l_save_file TYPE string.

  DATA: l_odpoved(1),
        l_rc TYPE sy-subrc,
        l_pocet_riadkov TYPE i.

  CLEAR l_filename.
*  BREAK-POINT.
  CONCATENATE pa_path p_name '.' pa_esour INTO l_filename.

  IF pa_ovrwr IS INITIAL.
*  Skontrolovat existenciu, ak taky subor je - ukoncujeme
    CALL FUNCTION 'WS_QUERY'
      EXPORTING
*       ENVIRONMENT          =
        FILENAME             = l_filename
        QUERY                = 'FE'
*       WINID                =
     IMPORTING
       RETURN               = l_odpoved
     EXCEPTIONS
       INV_QUERY            = 1
       NO_BATCH             = 2
       FRONTEND_ERROR       = 3
*       OTHERS               = 4
              .
    IF SY-SUBRC <> 0.
      WRITE: / 'Error check! not saved'(e01) COLOR col_negative,
                l_filename.
      EXIT.
    ENDIF.

    IF l_odpoved = '1'.
      WRITE: / 'File exists! not saved'(e02) COLOR col_heading, g_wa_prog-text(35),
                l_filename.
      EXIT.
    ENDIF.

  ENDIF.


  WRITE: /1 'Working on'(s05),p_name.

* Read report from DB
  REFRESH l_i_prog_source .
  READ REPORT p_name INTO l_i_prog_source .

  CHECK sy-subrc = 0.


* Search for include.
  IF pa_pincl = 'X'.
    LOOP AT l_i_prog_source INTO l_was.
      PERFORM search_include USING l_was.
    ENDLOOP.
  ENDIF.

* Ulozenie reportu
  MOVE l_filename TO l_save_file.
  PERFORM save_file TABLES l_i_prog_source
                    USING  l_save_file
                    CHANGING l_rc.
  IF l_rc <> 0.
    WRITE: / 'Error when saving'(e03) COLOR col_negative, g_wa_prog-text(35), l_filename .
  ELSE.
    WRITE: / 'Saved '(s01) COLOR col_positive, g_wa_prog-text(35), l_filename  .

* Skusime ulozit textove prvky...
    IF pa_text = 'X'.
      LOOP AT g_i_langu.

        REFRESH l_i_textpool.
        READ TEXTPOOL p_name INTO l_i_textpool LANGUAGE g_i_langu.
        IF sy-subrc = 0.
          DESCRIBE TABLE l_i_textpool LINES l_pocet_riadkov.
          IF l_pocet_riadkov > 0.

            CONCATENATE pa_path p_name '.' g_i_langu '.' pa_etext
                        INTO l_save_file.
            PERFORM save_file TABLES l_i_textpool
                              USING  l_save_file
                              CHANGING l_rc.
            IF l_rc = 0.
    WRITE: / 'Saved texts'(s03) COLOR col_positive,g_i_langu,
             l_save_file.

            ENDIF.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDIF.

* Ulozit dynpra.
    IF pa_dynp = 'X'.

      LOOP AT g_i_dynpros INTO g_wa_dynpro
          WHERE prog = p_name.

        PERFORM save_dynpro USING g_wa_dynpro.

      ENDLOOP.

    ENDIF.
  ENDIF.
ENDFORM.                    "read_and_save





*&---------------------------------------------------------------------*
*&      Form  save_dynpro
*&---------------------------------------------------------------------*
* Ulozi dynpro s danym ID do suboru.
*----------------------------------------------------------------------*
*      <-- P_DYNS   Structure with dynpro key (prog, dynnr and text)
*----------------------------------------------------------------------*
FORM save_dynpro USING p_dyns TYPE t_dynpro.
 DATA: l_filename TYPE rlgrap-filename.

 DATA: BEGIN OF DYNP_ID,          "Identifika. eines Dynpros für IMPORT
        PROG TYPE PROGNAME,
        DNUM LIKE D020S-DNUM,
       END OF DYNP_ID.

 DATA: header TYPE D020S,
       fields TYPE TABLE OF D021S WITH HEADER LINE,
       flow   TYPE TABLE OF D022S WITH HEADER LINE,
       params  TYPE TABLE OF D023S WITH HEADER LINE.

* From dynpro painter :)
 CONSTANTS:
           STARS(64)          VALUE
'****************************************************************',
                                                        "#EC NOTEXT
           COMMENT1(64)       VALUE
'*   THIS FILE IS GENERATED BY THE SCREEN PAINTER.              *',
                                                        "#EC NOTEXT
           COMMENT2(64)       VALUE
'*   NEVER CHANGE IT MANUALLY, PLEASE !                         *',
                                                        "#EC NOTEXT
           DYNPRO_TEXT(8)     VALUE '%_DYNPRO',         "#EC NOTEXT
           HEADER_TEXT(8)     VALUE '%_HEADER',         "#EC NOTEXT
           PARAMS_TEXT(8)     VALUE '%_PARAMS',         "#EC NOTEXT
           DESCRIPT_TEXT(13)  VALUE '%_DESCRIPTION',    "#EC NOTEXT
           FIELDS_TEXT(8)     VALUE '%_FIELDS',         "#EC NOTEXT
           KREUZ(1)           VALUE 'x',                "#EC NOTEXT
           FLOWLOGIC_TEXT(11) VALUE '%_FLOWLOGIC'.      "#EC NOTEXT

 DATA  HEADER_CHAR LIKE SCR_CHHEAD.
 DATA  FIELDS_CHAR LIKE SCR_CHFLD OCCURS 0 WITH HEADER LINE.

 DATA  DYNP_CHAR LIKE SCR_CHFLD OCCURS 0 WITH HEADER LINE.
 DATA  PROG_LEN     TYPE P.

 DATA  l_d020t_prog TYPE d020t-prog.


* Load dynpro from DB.
  MOVE: p_dyns-prog TO dynp_id-prog,
        p_dyns-dynp TO dynp_id-dnum.

  IMPORT DYNPRO header fields flow params ID dynp_id.
  CHECK sy-subrc = 0.

* Spracovanie.
*--------------------------------------------------
* From dynpro painter R3 4.6c    :)
  CALL FUNCTION 'RS_SCRP_HEADER_RAW_TO_CHAR'
       EXPORTING
            HEADER_INT  = HEADER
       IMPORTING
            HEADER_CHAR = HEADER_CHAR
       EXCEPTIONS
            OTHERS      = 1.

  REFRESH DYNP_CHAR.

* Comment
  DYNP_CHAR = STARS.    APPEND DYNP_CHAR.
  DYNP_CHAR = COMMENT1. APPEND DYNP_CHAR.
  DYNP_CHAR = COMMENT2. APPEND DYNP_CHAR.
  DYNP_CHAR = STARS.    APPEND DYNP_CHAR.

* Identification
  DYNP_CHAR = DYNPRO_TEXT.      APPEND DYNP_CHAR.          "  '%_DYNPRO'
  DYNP_CHAR = HEADER_CHAR-PROG. APPEND DYNP_CHAR.
  DYNP_CHAR = HEADER_CHAR-DNUM. APPEND DYNP_CHAR.
  DYNP_CHAR = SY-SAPRL.         APPEND DYNP_CHAR.
  DESCRIBE FIELD l_d020t_prog LENGTH PROG_LEN in byte mode.
  DYNP_CHAR(16) = PROG_LEN.      APPEND DYNP_CHAR.

* Header
  DYNP_CHAR = HEADER_TEXT.      APPEND DYNP_CHAR.     "  '%_HEADER'
  APPEND HEADER_CHAR TO DYNP_CHAR.

* Description
  DYNP_CHAR = DESCRIPT_TEXT.    APPEND DYNP_CHAR.     "  '%_DESCRIPTION'
  APPEND p_dyns-text TO DYNP_CHAR.

* Fieldlist
  DYNP_CHAR = FIELDS_TEXT.          "  '%_FIELDS'
  APPEND DYNP_CHAR.
  CALL FUNCTION 'RS_SCRP_FIELDS_RAW_TO_CHAR'
       TABLES
            FIELDS_INT  = FIELDS
            FIELDS_CHAR = FIELDS_CHAR
       EXCEPTIONS
            OTHERS      = 1.

  LOOP AT FIELDS_CHAR.
    APPEND FIELDS_CHAR TO DYNP_CHAR.
  ENDLOOP.

* Flowlogic
  DYNP_CHAR = FLOWLOGIC_TEXT.         "  '%_FLOWLOGIC'
  APPEND DYNP_CHAR.

  LOOP AT FLOW.
    APPEND FLOW TO DYNP_CHAR.
  ENDLOOP.
**  refresh flowlogic.                   "vjb 25.06.98


* Dynpro Parameters                      "vjb ab 4.6A (01.07.98)
  DYNP_CHAR = PARAMS_TEXT.
  APPEND DYNP_CHAR.

  LOOP AT PARAMS.
    APPEND PARAMS TO DYNP_CHAR.
  ENDLOOP.
*-----------------------------------------------------------------


* Saving dynpro in 4.6c
  CONCATENATE pa_path p_dyns-prog '.' p_dyns-dynp '.' pa_edynp
              INTO l_filename.
  CALL FUNCTION 'WS_DOWNLOAD'
    EXPORTING
*     BIN_FILESIZE                  = ' '
*     CODEPAGE                      = ' '
     FILENAME                      = l_filename
     FILETYPE                      = 'ASC'
*     MODE                          = ' '
*     WK1_N_FORMAT                  = ' '
*     WK1_N_SIZE                    = ' '
*     WK1_T_FORMAT                  = ' '
*     WK1_T_SIZE                    = ' '
*     COL_SELECT                    = ' '
*     COL_SELECTMASK                = ' '
*     NO_AUTH_CHECK                 = ' '
*   IMPORTING
*     FILELENGTH                    =
    TABLES
      DATA_TAB                      = dynp_char
*     FIELDNAMES                    =
   EXCEPTIONS
     FILE_OPEN_ERROR               = 1
     FILE_WRITE_ERROR              = 2
     INVALID_FILESIZE              = 3
     INVALID_TYPE                  = 4
     NO_BATCH                      = 5
     UNKNOWN_ERROR                 = 6
     INVALID_TABLE_WIDTH           = 7
     GUI_REFUSE_FILETRANSFER       = 8
     CUSTOMER_ERROR                = 9
     OTHERS                        = 10 .
  IF sy-subrc = 0.
    WRITE: / 'Saved dynpro'(s02) COLOR col_positive,p_dyns-dynp,
             l_filename.
  ENDIF.

ENDFORM.                    " save_dynpro






**&-----------------------------------------------------------------*
**&      Form  save_dynpro_47
**&-----------------------------------------------------------------*
** Ulozi dynpro s danym ID do suboru.
**--------------------------------------------------------------------*
**      <-- P_DYNS   Structure with dynpro key (prog, dynnr and text)
**--------------------------------------------------------------------*
*FORM save_dynpro USING p_dyns TYPE t_dynpro.
* DATA: l_filename TYPE string.
*
* DATA: BEGIN OF DYNP_ID,         "Identifika. eines Dynpros für IMPORT
*        PROG TYPE PROGNAME,
*        DNUM LIKE D020S-DNUM,
*       END OF DYNP_ID.
*
* DATA: header TYPE D020S,
*       fields TYPE TABLE OF D021S WITH HEADER LINE,
*       flow   TYPE TABLE OF D022S WITH HEADER LINE,
*       params  TYPE TABLE OF D023S WITH HEADER LINE.
*
** From dynpro painter :)
* CONSTANTS:
*           STARS(64)          VALUE
*'****************************************************************',
*                                                        "#EC NOTEXT
*           COMMENT1(64)       VALUE
*'*   THIS FILE IS GENERATED BY THE SCREEN PAINTER.              *',
*                                                        "#EC NOTEXT
*           COMMENT2(64)       VALUE
*'*   NEVER CHANGE IT MANUALLY, PLEASE !                         *',
*                                                        "#EC NOTEXT
*           DYNPRO_TEXT(8)     VALUE '%_DYNPRO',         "#EC NOTEXT
*           HEADER_TEXT(8)     VALUE '%_HEADER',         "#EC NOTEXT
*           PARAMS_TEXT(8)     VALUE '%_PARAMS',         "#EC NOTEXT
*           DESCRIPT_TEXT(13)  VALUE '%_DESCRIPTION',    "#EC NOTEXT
*           FIELDS_TEXT(8)     VALUE '%_FIELDS',         "#EC NOTEXT
*           KREUZ(1)           VALUE 'x',                "#EC NOTEXT
*           FLOWLOGIC_TEXT(11) VALUE '%_FLOWLOGIC'.      "#EC NOTEXT
*
* DATA  HEADER_CHAR LIKE SCR_CHHEAD.
* DATA  FIELDS_CHAR LIKE SCR_CHFLD OCCURS 0 WITH HEADER LINE.
*
* DATA  DYNP_CHAR LIKE SCR_CHFLD OCCURS 0 WITH HEADER LINE.
* DATA  PROG_LEN     TYPE P.
*
* DATA  l_d020t_prog TYPE d020t-prog.
*
*
** Load dynpro from DB.
*  MOVE: p_dyns-prog TO dynp_id-prog,
*        p_dyns-dynp TO dynp_id-dnum.
*
*  IMPORT DYNPRO header fields flow params ID dynp_id.
*  CHECK sy-subrc = 0.
*
** Spracovanie.
**--------------------------------------------------
** From dynpro painter R3 4.6c    :)
*  CALL FUNCTION 'RS_SCRP_HEADER_RAW_TO_CHAR'
*       EXPORTING
*            HEADER_INT  = HEADER
*       IMPORTING
*            HEADER_CHAR = HEADER_CHAR
*       EXCEPTIONS
*            OTHERS      = 1.
*
*  REFRESH DYNP_CHAR.
*
** Comment
*  DYNP_CHAR = STARS.    APPEND DYNP_CHAR.
*  DYNP_CHAR = COMMENT1. APPEND DYNP_CHAR.
*  DYNP_CHAR = COMMENT2. APPEND DYNP_CHAR.
*  DYNP_CHAR = STARS.    APPEND DYNP_CHAR.
*
** Identification
*  DYNP_CHAR = DYNPRO_TEXT.      APPEND DYNP_CHAR.        "  '%_DYNPRO'
*  DYNP_CHAR = HEADER_CHAR-PROG. APPEND DYNP_CHAR.
*  DYNP_CHAR = HEADER_CHAR-DNUM. APPEND DYNP_CHAR.
*  DYNP_CHAR = SY-SAPRL.         APPEND DYNP_CHAR.
*  DESCRIBE FIELD l_d020t_prog LENGTH PROG_LEN IN CHARACTER MODE.
*  DYNP_CHAR(16) = PROG_LEN.      APPEND DYNP_CHAR.
*
** Header
*  DYNP_CHAR = HEADER_TEXT.      APPEND DYNP_CHAR.   "  '%_HEADER'
*  APPEND HEADER_CHAR TO DYNP_CHAR.
*
** Description
*  DYNP_CHAR = DESCRIPT_TEXT.    APPEND DYNP_CHAR.   "  '%_DESCRIPTION'
*  APPEND p_dyns-text TO DYNP_CHAR.
*
** Fieldlist
*  DYNP_CHAR = FIELDS_TEXT.          "  '%_FIELDS'
*  APPEND DYNP_CHAR.
*  CALL FUNCTION 'RS_SCRP_FIELDS_RAW_TO_CHAR'
*       TABLES
*            FIELDS_INT  = FIELDS
*            FIELDS_CHAR = FIELDS_CHAR
*       EXCEPTIONS
*            OTHERS      = 1.
*
*  LOOP AT FIELDS_CHAR.
*    APPEND FIELDS_CHAR TO DYNP_CHAR.
*  ENDLOOP.
*
** Flowlogic
*  DYNP_CHAR = FLOWLOGIC_TEXT.         "  '%_FLOWLOGIC'
*  APPEND DYNP_CHAR.
*
*  LOOP AT FLOW.
*    APPEND FLOW TO DYNP_CHAR.
*  ENDLOOP.
*
** Dynpro Parameters
*  DYNP_CHAR = PARAMS_TEXT.
*  APPEND DYNP_CHAR.
*
*  LOOP AT PARAMS.
*    APPEND PARAMS TO DYNP_CHAR.
*  ENDLOOP.
**-----------------------------------------------------------------
*
*
** Saving dynpro in 4.7
*  CONCATENATE pa_path p_dyns-prog '.' p_dyns-dynp '.' pa_edynp
*              INTO l_filename.
*  CALL FUNCTION 'GUI_DOWNLOAD'
*    EXPORTING
*      FILENAME                      = l_filename
*      FILETYPE                      = 'ASC'
**     APPEND                        = ' '
*      WRITE_FIELD_SEPARATOR         = 'X'
**     HEADER                        = '00'
*      TRUNC_TRAILING_BLANKS         = 'X'
**     WRITE_LF                      = 'X'
**     COL_SELECT                    = ' '
**     COL_SELECT_MASK               = ' '
**     DAT_MODE                      = ' '
**   IMPORTING
**     FILELENGTH                    =
*    TABLES
*      DATA_TAB                      = dynp_char
*   EXCEPTIONS
*     FILE_WRITE_ERROR              = 1
*     NO_BATCH                      = 2
*     GUI_REFUSE_FILETRANSFER       = 3
*     INVALID_TYPE                  = 4
*     NO_AUTHORITY                  = 5
*     UNKNOWN_ERROR                 = 6
*     HEADER_NOT_ALLOWED            = 7
*     SEPARATOR_NOT_ALLOWED         = 8
*     FILESIZE_NOT_ALLOWED          = 9
*     HEADER_TOO_LONG               = 10
*     DP_ERROR_CREATE               = 11
*     DP_ERROR_SEND                 = 12
*     DP_ERROR_WRITE                = 13
*     UNKNOWN_DP_ERROR              = 14
*     ACCESS_DENIED                 = 15
*     DP_OUT_OF_MEMORY              = 16
*     DISK_FULL                     = 17
*     DP_TIMEOUT                    = 18
*     FILE_NOT_FOUND                = 19
*     DATAPROVIDER_EXCEPTION        = 20
*     CONTROL_FLUSH_ERROR           = 21
*     OTHERS                        = 22 .
*  IF sy-subrc = 0.
*    WRITE: / 'Saved dynpro'(s02) COLOR col_positive,p_dyns-dynp,
*             l_filename.
*  ENDIF.
*
*ENDFORM.                    " save_dynpro_47







*&---------------------------------------------------------------------*
*&      Form  save_file
*&---------------------------------------------------------------------*
* Ulozenie internej tabulky (textovej) do suboru.
*---------------------------------------------------------------------*
*      <-> P_NAME      Internal table to save to file.
*      <-- P_FILENAME  Name of file
*      --> P_RC        Return-code
*---------------------------------------------------------------------*
FORM save_file TABLES p_table
               USING p_filename TYPE string
               CHANGING p_rc TYPE sy-subrc.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*     BIN_FILESIZE                  =
      FILENAME                      = p_filename
      FILETYPE                      = 'ASC'
*     APPEND                        = ' '
*     WRITE_FIELD_SEPARATOR         = ' '
*     HEADER                        = '00'
*     TRUNC_TRAILING_BLANKS         = ' '
*     WRITE_LF                      = 'X'
*     COL_SELECT                    = ' '
*     COL_SELECT_MASK               = ' '
*     DAT_MODE                      = ' '
*   IMPORTING
*     FILELENGTH                    =
    TABLES
      DATA_TAB                      = p_table
   EXCEPTIONS
     FILE_WRITE_ERROR              = 1
     NO_BATCH                      = 2
     GUI_REFUSE_FILETRANSFER       = 3
     INVALID_TYPE                  = 4
     NO_AUTHORITY                  = 5
     UNKNOWN_ERROR                 = 6
     HEADER_NOT_ALLOWED            = 7
     SEPARATOR_NOT_ALLOWED         = 8
     FILESIZE_NOT_ALLOWED          = 9
     HEADER_TOO_LONG               = 10
     DP_ERROR_CREATE               = 11
     DP_ERROR_SEND                 = 12
     DP_ERROR_WRITE                = 13
     UNKNOWN_DP_ERROR              = 14
     ACCESS_DENIED                 = 15
     DP_OUT_OF_MEMORY              = 16
     DISK_FULL                     = 17
     DP_TIMEOUT                    = 18
     FILE_NOT_FOUND                = 19
     DATAPROVIDER_EXCEPTION        = 20
     CONTROL_FLUSH_ERROR           = 21
*     OTHERS                        = 22
            .
  MOVE sy-subrc TO p_rc.
ENDFORM.



*&---------------------------------------------------------------------*
*&      Form  fill_infotext
*&---------------------------------------------------------------------*
*      <-- P_VAL   Action identifier, not 0 !!
*      <-- P_TEXT  Info-text to write.
*----------------------------------------------------------------------*
FORM fill_infotext USING    VALUE(p_val)
                            VALUE(p_icon)
                            VALUE(p_text).

  CLEAR g_i_vypis.
  MOVE: p_val TO g_i_vypis-caseval,
        p_icon TO g_i_vypis-icon,
        p_text TO g_i_vypis-text.
  APPEND g_i_vypis.

ENDFORM.                    " fill_infotext



*&---------------------------------------------------------------------*
*&      Form  write_list
*&---------------------------------------------------------------------*
*  Vypise cely vystup (aj opakovane) - kvoli volaniu z roznych miest.
*----------------------------------------------------------------------*
FORM write_list.

* Infotext + Hide oblast (na odchytavanie dvojkliku)
  LOOP AT g_i_vypis.
    WRITE: /2 g_i_vypis-icon AS ICON HOTSPOT,
            5 g_i_vypis-text.
    HIDE g_i_vypis-caseval.
  ENDLOOP.

  ULINE.

* Vypis programov.
  LOOP AT g_i_progs.
    WRITE: /2 g_i_progs-sel AS CHECKBOX INPUT,
            5 g_i_progs-subc,
            7 g_i_progs-prog,
            50 g_i_progs-text.
  ENDLOOP.

  CLEAR g_i_vypis.
  sy-lsind = 0.

ENDFORM.                    " write_list



*&---------------------------------------------------------------------*
*&      Form  change_all
*&---------------------------------------------------------------------*
*  Zmeni priznak vyberu na vsetky polozky.
*----------------------------------------------------------------------*
*      <-- P_SEL   Select all ('X') or Deselect all (space)
*----------------------------------------------------------------------*
FORM change_all USING    VALUE(p_sel).

  LOOP AT g_i_progs.
    g_i_progs-sel = p_sel.
    MODIFY g_i_progs.
  ENDLOOP.

  PERFORM write_list.
ENDFORM.                    " change_all



*&---------------------------------------------------------------------*
*&      Form  export
*&---------------------------------------------------------------------*
*  Nacita uzivatelom modifikovany zoznam programov na export a uklada.
*----------------------------------------------------------------------*
FORM export.
 DATA: l_index TYPE i,
       l_sel(1).

* Vycitat nastavenia z listu
  LOOP AT g_i_progs .
    l_index = sy-tabix + 4.
    READ LINE l_index FIELD VALUE g_i_progs-sel INTO l_sel.
    g_i_progs-sel = l_sel.
    MODIFY g_i_progs.
  ENDLOOP.

* A export.
  LOOP AT g_i_progs INTO g_wa_prog
      WHERE sel = 'X' .
    PERFORM read_and_save USING g_wa_prog-prog.
  ENDLOOP.

ENDFORM.                    " export



*&---------------------------------------------------------------------*
*&      Form  search_include
*&---------------------------------------------------------------------*
*  Hlada v riadku slovo INCLUDE a spracuva ho - ak je to skutocne
*  include programu, vyberie nazov includu a vlozi ho do spracovania
*----------------------------------------------------------------------*
*      -->P_LINE   Report line, where presence of 'INCLUDE' is tested
*----------------------------------------------------------------------*
FORM search_include USING p_line TYPE t_rep_source.
 DATA:
        l_pozicia TYPE i,
        l_dlzka   TYPE i,
        l_wa_incl_search(72),
        l_include(72),
        l_next_search TYPE t_rep_source.


  IF p_line-line CP '*INCLUDE*'.
    CLEAR: l_include, l_next_search.
    MOVE sy-fdpos TO l_pozicia.
* Include found. Check if it is not a comment or something like that.
    CHECK NOT p_line-line+0(1) = '*' AND
          NOT p_line-line+0(1) = '"' .
* este to moze byt komentar so znakom '"'.
    SEARCH p_line-line FOR '"' STARTING AT 1 ENDING AT l_pozicia.
    CHECK sy-subrc <> 0.

* OK, komentar tam nie je, berieme teda dalsie slovo
    ADD 7 to l_pozicia.
    MOVE p_line-line+l_pozicia TO l_wa_incl_search.
* ostranime medzery zo zaciatku
    SHIFT l_wa_incl_search LEFT DELETING LEADING space.

* Ak je ale komentar TERAZ, je to zasa nanic
    CHECK NOT l_wa_incl_search+0(1) = '"'.

* Teraz NESMIE nasledovat slovo STRUCTURE alebo TYPE !!!
* islo by o prikazy INCLUDE STRUCTRUE alebo INCLUDE TYPE.
    CHECK l_wa_incl_search NP 'STRUCTURE*' AND
          l_wa_incl_search NP 'TYPE*'.

* Analyza substringu - musime najst bodku a brat potial, inak berieme
* vsetko po koniec retazca. Osetria sa pripady:
* a.) INCLUDE  xxxxxxx .
* b.) INCLUDE  yyyyyyy
*     .
*
*  nevieme ale korektne osetrit pripad
* INCLUDE
*   zzzzzzzz
*  .
    IF l_wa_incl_search CA '.'.
* Bodka je na tomto riadku, vysekneme si usek po nu a mame nazov inc.
      l_pozicia = sy-fdpos.
      CHECK l_pozicia > 0.
      MOVE l_wa_incl_search+0(l_pozicia) TO l_include.
      CONDENSE l_include NO-GAPS.

* Kedze je tu bodka, na riadku moze byt este dalsi prikaz, a opat na
* include - radsej overime.
      MOVE l_wa_incl_search+l_pozicia TO l_next_search-line.
    ELSE.
* Skusime zobrat to co je na danom riadku, mohol by tam byt program
      CONDENSE l_wa_incl_search NO-GAPS.
      MOVE l_wa_incl_search TO l_include.
    ENDIF.

* Spracovat include - overit ci existuje a ak ano, zaradit.
    CHECK NOT l_include IS INITIAL.
    TRANSLATE l_include TO UPPER CASE.

* Overenie, ci dany Include uz nie je zaradeny do spracovania.
    READ TABLE g_i_progs WITH KEY prog = l_include sel = 'X' .
    IF sy-subrc <> 0.
* este nie je zaradeny - overime jeho existenciu v DB.
      CLEAR g_i_progs.

      SELECT SINGLE trdir~name trdir~subc trdirt~text
            INTO g_i_progs
            FROM trdir LEFT JOIN trdirt
              ON trdir~name = trdirt~name
             AND trdirt~sprsl = sy-langu
            WHERE trdir~name = l_include .
      IF sy-subrc = 0.
        g_i_progs-sel = 'X'.    " required to save this include too.
        APPEND g_i_progs.
        WRITE: /1 'Include found'(s04) COLOR col_total, l_include.
      ENDIF.
    ENDIF.

* Ak este moze byt dalsi vnoreny - rekurzivne volanie
* Ostetrenie prikazov ako>
*  INCLDUE xxxxxx .  INCLUDE zzzzzz .   ...
    IF NOT l_next_search IS INITIAL.
      PERFORM search_include USING l_next_search.
    ENDIF.
  ENDIF.

ENDFORM. "search_include
