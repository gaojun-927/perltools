terminal is logical
pin is a physical shape and a terminal can have more than one pins.
A net is a logical object in the database. It has a name and graphical 
drawing shapes that are associated with it. 
dbCreateNet(cvId netName) ;Nothing here about shapes! 
A pin is a database association of a graphical shape and logical net. 
dbCreatePin(cvId figId netId name); 
A terminal is a logical database object (not graphical) that is used to 
define 
hierarchical connectivity. It associates a single net and one or more pins. 
It is created automatically when a dbCreatePin() 
call references a net for the first time. 
A graphical drawing shape may or may not have a net associated with it. 
A logical net may or may not have a pin associated with it. 
The following layout database queries can be insightul: 
cvId=geGetEditCellView() 
cvId->shapes~>nets~>pins~>name 
cvId->shapes~>nets~>pins~>fig 
cvId->terminals~>name 
cvId->terminals~>net~>name 
A schematic pin is a pin object that associates the graphic shape, the 
terminal object and a net object. 
A symbol pin serves the same purpose for a schematicSymbol cellview. 
A layout pin serves the same purpose for a layout cellview. 


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cvId=dbOpenCellViewByType("dac_sch_20080128" "newcell" "schematic" "schematic" "w")

;vdcId=schCreateInst(cvId dbOpenCellViewByType("analogLib" "vdc" "symbol") "" 0:0 "R0")
;net1Id=schCreateWire(cvId "draw" "direct" list(0:0 1:0) 0.0625 0.0625 0)
;labelId=schCreateWireLabel(cvId net1Id (0:0) "net1" "upperLeft" "R0" "stick" "" nil)
;schGlueLabel(
;sch function and db function realization
symId=dbOpenCellViewByType("analogLib" "vdc" "symbol")
vdc1Id=dbCreateParamInst(cvId symId "" (0:0) "R0" 1 list(list("vdc" "float" 1) list("vac" "float" 1)) )
vdc2Id=dbCreateParamInst(cvId symId "" (2:0) "R0" 1 list(list("vdc" "float" 2) list("vac" "float" 1)) )
;net1Id=dbCreateNet(cvId "net1")
;termId=dbCreateTerm(net1Id "term" "input")
;dbCreateConn(net1Id vdc2Id termId)
;dbCreateConnByName(net1Id vdc1Id "PLUS")


net1Id=schCreateWire(cvId "draw" "direct" list(0:0 1:0) 0.0625 0.0625 0)
labelId=schCreateWireLabel(cvId car(net1Id) (0:0) "net2" "upperLeft" "R0" "stick" 0.0625 nil)
inputCVId=dbOpenCellViewByType( "basic" "ipin" "symbol")
pinId=schCreatePin( cvId inputCVId "I1" "input" nil 2:0 "R0")


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cvId=dbOpenCellViewByType("test" "tttt" "schematic" "schematic" "w")


symId=dbOpenCellViewByType("analogLib" "vdc" "symbol")
vdc1Id=dbCreateParamInst(cvId symId "" (0:0) "R0" 1 list(list("vdc" "float" 1) list("vac" "float" 1)) )
vdc2Id=dbCreateParamInst(cvId symId "" (2:0) "R0" 1 list(list("vdc" "float" 2) list("vac" "float" 1)) )
net1Id=dbCreateNet(cvId "net1" nil)
net2Id=dbCreateNet(cvId "net2" nil)
net2Id=dbCreateNet(cvId "net3" nil)
conn1Id=dbCreateConnByname(net1Id vdc1Id "PLUS")
conn2Id=dbCreateConnByname(net2Id vdc1Id "MINUS")
conn3Id=dbCreateConnByname(net2Id vdc2Id "PLUS")
conn4Id=dbCreateConnByname(net3Id vdc2Id "MINUS")

line1Id=dbCreateLine(symId list(0 0) list(1:1 2:2))
line2Id=dbCreateLine(symId list(5 5) list(15:15 25:25))
dbAddFigToNet(line1Id net1Id)
dbAddFigToNet(line2Id net2Id)
line1Id~>parent=cvId
line2Id~>parent=cvId
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1. The SKILL Language Reference Manual 
UNIX> $CDSHOME/doc/sklangref/sklangref.pdf 


2. The SKILL Language User Guide 
UNIX> $CDSHOME/doc/sklanguser/sklanguser.pdf 


3. The Cadence? Design Framework II SKILL Functions Reference 
UNIX> $CDSHOME/doc/skdfref/skdfref.pdf 


4. Virtuoso? Schematic Editor SKILL Functions Reference 
UNIX> $CDSHOME/doc/skcompref/skcompref.pdf 


/* Skill Starts here rkSchConnectivityExample.il 
1. Load The file into the CIW 
2. launch something like: 
rkSchConnectivityExample("rkWorkLib" "rkSchConnectivityExample") 
*/ 


procedure( rkSchConnectivityExample(libName cellName "tt") 
  let( (masterId x y cvId instTermBbox instTermBboxInCv 
        instTermLLX instTermLLY instTermURX instTermURY 
        wireOriginX wireOriginY wireSpace wireWidth wireLength 
        deltaX deltaY wireLabel wireOrientation wireJustification 
        wireEndX wireEndY termWire 
  ) 
    x=1 
    y=1 
    wireSpace=0.0625 
    wireWidth=0 
    wireLength=0.6 
    ; Open the CV to create 
    cvId=dbOpenCellViewByType(libName cellName "schematic" 
         "schematic" "w") 
    ; Open the master cell to instatiate 
    masterId = dbOpenCellViewByType("analogLib" "nmos4" 
               "symbol" "schematicSymbol" "r") 
    ; Create an instance of analogLib/nmos4 at point 1:1 
    schCreateInst(cvId masterId nil x:y "R0") 
    ; Search all the instances in the CV 
    foreach( inst cvId~>instances 
      printf( "Instance : %s\n" inst~>name ) 
      ; Print all the Instance terminals for each instance found 
      ; in the CV. 
      foreach( instTerm inst~>instTerms 
          ; For each instance terminal, i.e D-S-B-G, get the bbox 
          ; of the  terminal's little square then use dbTransformBBox 
          ; to transform the pin bbox to the cellview 
          instTermBbox=car(instTerm~>term~>pins~>fig~>bBox) 
          instTermBboxInCv=dbTransformBBox(instTermBbox 
                           inst~>transform) 
          printf( " Instance Terminal= %s : absBbox=%L : 
                  relBbox=%L\n" instTerm~>name 
          instTermBbox instTermBboxInCv) 
          ; get the X/Y coordinates from the BBOX 
          instTermLLX=xCoord(lowerLeft(instTermBboxInCv)) 
          instTermLLY=yCoord(lowerLeft(instTermBboxInCv)) 
          instTermURX=xCoord(upperRight(instTermBboxInCv)) 
          instTermURY=yCoord(upperRight(instTermBboxInCv)) 
          wireOriginX=(instTermLLX+instTermURX)/2 
          wireOriginY=(instTermLLY+instTermURY)/2 
          ; A little bit of code to make a KOF nice schematic 
          case(lowerCase(instTerm~>name) 
            ("d" 
              deltaX=0 
              deltaY=wireLength 
              wireLabel="Drain" 
              wireOrientation="R90" 
              wireJustification="lowerRight" 
            ) 
            ("s" 
              deltaX=0 
              deltaY=-wireLength 
              wireLabel="Source" 
              wireOrientation="R90" 
              wireJustification="lowerLeft" 
            ) 
            ("b" 
              deltaX=wireLength 
              deltaY=0 
              wireLabel="Bulk" 
              wireOrientation="R0" 
              wireJustification="lowerRight" 
            ) 
            ("g" 
              deltaX=-wireLength 
              deltaY=0 
              wireLabel="Gate" 
              wireOrientation="R0" 
              wireJustification="lowerLeft" 
            ) 
            (t 
              printf("Unknow terminal !!! \n") 
            ) 
          ) 
          wireEndX=wireOriginX+deltaX 
          wireEndY=wireOriginY+deltaY 
          ; Create the wire 
          termWire=schCreateWire(cvId "draw" "full" 
          list(wireOriginX:wireOriginY wireEndX:wireEndY) 
          wireSpace wireSpace wireWidth) 
          ; createLabel 
          schCreateWireLabel(cvId car(termWire) 
                             wireEndX:wireEndY wireLabel 
                              wireJustification wireOrientation 
                              "fixed"  wireSpace nil) 


      ) ; foreach 
    ) ; foreach 


    ; Check and save, close the DB and then open the 
    ; schematic in Read. 
    schCheck(cvId) 
    getWarn() 
    dbSave(cvId) 
    dbClose(cvId) 
    geOpen(?lib libName ?cell cellName ?view "schematic" 
           ?viewType "schematic" ?mode "r") 
  ) 
) 
; Skill Ends here 


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cdfId  = cdfGetInstCDF(inst) 
    fingerLength = cdfFindParamByName(cdfId "fingerLength")~>value 
    fingerWidth  = cdfFindParamByName(cdfId "fingerWidth")~>value 
    
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/* abInvokeCdfCallbacks.il 


Author     A.D.Beckett 
Group      Structured Custom, Cadence Design Systems Ltd. 
Machine    SUN 
Date       Jul 11, 1995 
Modified   Nov 22, 2006 
By         A.D.Beckett 


Invoke all the CDF callbacks for instances 


The main entry point is (abInvokeCdfCallbacks cellView) 
which invokes all the CDF callbacks for every instance in 
a cellView. This has some keyword arguments which allow debug 
messages to be displayed, to invoke the formInitProc if needed, 
and to invoke using the instance CDF directly, rather than try 
to create something that looks more like the effective CDF that 
is found when the callbacks are normally invoked from the forms. 


You can use the variable abCallbackPatternsToIgnore so 
that some callbacks can be omitted. 


*************************************************** 


SCCS Info: @(#) abInvokeCdfCallbacks.il 06/07/07.14:29:59 1.11 


*/ 


/*************************************************************** 
*                                                              * 
*     The variable abCallbackPatternsToIgnore is set to be     * 
*      a list of patterns against which the callbacks are      * 
*      checked. If any of these patterns are matched then      * 
*                 the callback is not invoked.                 * 
*                                                              * 
***************************************************************/ 


(unless (boundp 'abCallbackPatternsToIgnore) 
   (setq abCallbackPatternsToIgnore 
        '("^SIG3Not_Allowed.*"))) 


/*************************************************************** 
*                                                              * 
*            (abShouldCallbackBeExecuted callback)             * 
*                                                              * 
*  This checks the callback against all the patterns defined   * 
*     in the list abCallbackPatternsToIgnore to determine      * 
*       whether the callback should be executed or not.        * 
*                                                              * 
***************************************************************/ 


(procedure (abShouldCallbackBeExecuted callback) 
   (forall pattern abCallbackPatternsToIgnore 
          (null (rexMatchp pattern callback))) 
   ) 


/********************************************************************* 
*                                                                    * 
*         (abCreateEffectiveCDFLookalike cdf [lookalikeParams])      * 
*                                                                    * 
*     Create a structure which looks (sort of) like an effective     * 
*  CDF. The reason for creating this is to allow the "id" parameter  * 
*  to be correctly set to the cell, rather than the instance, which  * 
* is what happens if we use the cdfGetInstCDF() function to simulate * 
* cdfgData. The lookalikeParams optional parameter allows creation   * 
* of the parameters to be "lookalike" as well, so that callbacks can * 
*          be called even if there is no actual instance.            * 
*                                                                    * 
*********************************************************************/ 


(procedure (abCreateEffectiveCDFLookalike cdf @optional lookalikeParams) 
   (let (new cdfFields newParam) 
        (unless (getd 'make_abEffCDF) 
               ;--------------------------------------------------------- 
               ; Because some slots appear twice in cdf->? have 
               ; to make the list unique 
               ;--------------------------------------------------------- 
               (setq cdfFields (makeTable 'cdfFields)) 
               (foreach field (getq cdf ?) 
                        (setarray cdfFields  field t) 
                        ) 
               (eval `(defstruct abEffCDF ,@(getq cdfFields ?)))) 
        (setq new (make_abEffCDF)) 
        (when (and lookalikeParams (null (getd 'make_abEffCDFparam))) 
         (setq cdfFields (makeTable 'cdfFields)) 
         (foreach field (getq (car (getq cdf parameters)) ?) 
                  (setarray cdfFields field t)) 
         (eval `(defstruct abEffCDFparam ,@(getq cdfFields ?)))) 
        ;----------------------------------------------------------------- 
        ; populate the effective cdf with the top level cdf attributes 
        ;----------------------------------------------------------------- 
        (foreach param (getq cdf ?) 
                (putprop new (get cdf param) param)) 
        ;----------------------------------------------------------------- 
        ; Set the id and type attributes appropriately 
        ;----------------------------------------------------------------- 
        (when (equal (getq new type) "instData") 
         (putpropq new (dbGetq (dbGetq (getq cdf id) master) cell) id) 
         (putpropq new "cellData" type) 
         ) 
        ;----------------------------------------------------------------- 
        ; If we want the parameters to be lookalike too, create those 
        ;----------------------------------------------------------------- 
        (when lookalikeParams 
         (putpropq new 
                   (foreach mapcar param (getq cdf parameters) 
                            (setq newParam (make_abEffCDFparam)) 
                            (foreach slot (getq param ?) 
                                     (putprop newParam (get param slot) slot)) 
                            ; reset the value to defValue for safety 
                            (putpropq newParam (getq newParam defValue) value) 
                            newParam 
                            ) 
                   parameters) 
         ) ; when 
        ;----------------------------------------------------------------- 
        ; Add the parameters as properties in the effective cdf 
        ;----------------------------------------------------------------- 
        (foreach param (getq new parameters) 
                (putprop new param (getq param name)) 
                ) 
        new 
        ) 
   ) 


/******************************************************************* 
*                                                                  * 
*       (abInvokeObjCdfCallbacks cdf @key (debug nil) order        * 
*               (callInitProc nil) (setCdfgForm t))                * 
*                                                                  * 
*      Underlying function which does all the real work. This      * 
* is separated from the original function abInvokeInstCdfCallbacks * 
*    so that this can be called with a completely virtual CDF.     * 
*      See abInvokeInstCdfCallbacks for a description of the       * 
*  arguments - note that there is the ability to control whether   * 
*                     cdfgForm is set or not.                      * 
* Return nil if any callback failed with a SKILL error, t otherwise* 
*                                                                  * 
*******************************************************************/ 


(procedure (abInvokeObjCdfCallbacks cdf @key (debug nil) order 
                                     (callInitProc nil) (setCdfgForm t)) 
   ;---------------------------------------------------------------------- 
   ; Make cdfgData and cdfgForm dynamically scoped, to avoid 
   ; interfering with any global usage of these variables 
   ;---------------------------------------------------------------------- 
   (let (callback parameters cdfgData cdfgForm (success t)) 
        ;----------------------------------------------------------------- 
        ; Set the cdfgData to be the instance CDF 
        ;----------------------------------------------------------------- 
        (setq cdfgData cdf) 
        (setq cdfgForm nil) 
        (when setCdfgForm 
         ;--------------------------------------------------------------- 
         ; some callbacks use cdfgForm instead 
         ;--------------------------------------------------------------- 
         (setq cdfgForm cdfgData) 
         ) 
        ;----------------------------------------------------------------- 
        ; Call the formInitProc if there is one. 
        ;----------------------------------------------------------------- 
        (when callInitProc 
             (setq callback (getq cdfgData formInitProc)) 
             (when (and callback 
                        (nequal callback "") 
                        (abShouldCallbackBeExecuted callback)) 
                   (when debug 
                         (printf "  Invoking formInitProc: '%s'\n" callback)) 
                   ;----------------------------------------------------- 
                   ; Evaluate the callback 
                   ;----------------------------------------------------- 
                   (unless 
                    (errset (evalstring 
                             (strcat callback "(cdfgData)")) t) 
                    (setq success nil) 
                    ) 
                   ) 
             ) 
        ;----------------------------------------------------------------- 
        ; Control order of parameter evaluation. If order specified, 
        ; just do those, otherwise do all in arbitrary order 
        ;----------------------------------------------------------------- 
        (if order 
           (setq parameters (foreach mapcar param order 
                                     (get cdfgData param))) 
           (setq parameters (getq cdfgData parameters)) 
           ) 
        ;----------------------------------------------------------------- 
        ; loop through all parameters 
        ;----------------------------------------------------------------- 
        (foreach param parameters 
                (setq callback (getq param callback)) 
                (when (and callback 
                           (nequal callback "") 
                           (abShouldCallbackBeExecuted callback)) 
                      (when debug 
                            (printf "  Invoking callback for '%s': '%s'\n" 
                                    (getq param name) callback)) 
                      ;-------------------------------------------------- 
                      ; evaluate the callback 
                      ;-------------------------------------------------- 
                      (unless (errset (evalstring callback) t) 
                       (setq success nil) 
                       ) 
                      )) 
   success)) 


/***************************************************************** 
*                                                                * 
*       (abInvokeInstCdfCallbacks instance [?debug debug]        * 
* [?order order] [?callInitProc callInitProc] [?useInstCDF nil]) * 
*                                                                * 
* Invoke all the parameter callbacks in the CDF for an instance. * 
*       This won't do anything if it doesn't have any CDF.       * 
* debug is a flag to turn on debug messages. order allows just   * 
* selected parameters to be called, in the specified order.      * 
* callInitProc allows the formInitProc to be called. useInstCDF  * 
* tells the formInitProc to be called with the instCDF rather    * 
*                than the effective lookalike CDF.               * 
*                                                                * 
*****************************************************************/ 


(procedure (abInvokeInstCdfCallbacks instance @key (debug nil) order 
                                     (callInitProc nil) (useInstCDF nil)) 
   ;---------------------------------------------------------------------- 
   ; Make cdfgData and cdfgForm dynamically scoped, to avoid 
   ; interfering with any global usage of these variables 
   ;---------------------------------------------------------------------- 
   (let (cdf) 
        (when debug 
             (printf " Invoking callbacks for instance '%s'\n" 
                     (dbGetq instance name))) 
        ;----------------------------------------------------------------- 
        ; Set the cdf to be the instance CDF 
        ;----------------------------------------------------------------- 
        (setq cdf (cdfGetInstCDF instance)) 
        (unless useInstCDF 
               (setq cdf (abCreateEffectiveCDFLookalike cdf)) 
               ) 
        ;----------------------------------------------------------------- 
        ; Return value will be nil if any callbacks had errors 
        ;----------------------------------------------------------------- 
        (abInvokeObjCdfCallbacks 
         cdf 
         ?debug debug ?order order ?callInitProc callInitProc 
         ?setCdfgForm (null useInstCDF) 
         ) 
   )) 


/*************************************************************** 
*                                                              * 
*               (abConvertCdfToPcellParams cdf)                * 
*                                                              * 
* Take modified parameters in the CDF, and return this as the  * 
*      list of parameter names, types, and values that is      * 
*       needed to create a pcell with dbCreateParamInst.       * 
*                                                              * 
***************************************************************/ 


(procedure (abConvertCdfToPcellParams cdf) 
   (foreach mapcar param 
           (setof par (getq cdf parameters) 
                  (nequal (getq par value) (getq par defValue))) 
           (list 
             (getq param name) 
             ; need to map this to pcell parameter types... 
             (case (getq param paramType) 
               (("int" "boolean" "float" "string") (getq param paramType)) 
               (t "string") 
               ) 
             (getq param value) 
             ) 
           ) 
   ) 


/*************************************************************** 
*                                                              * 
*        (abInvokeCdfCallbacks cellView @key (debug nil)       * 
*              (callInitProc nil) (useInstCDF nil))            * 
*                                                              * 
*  Invoke the CDF callbacks for all instances in the cellView. * 
*  Returns nil if any callback had a SKILL error, otherwise t  * 
*                                                              * 
***************************************************************/ 


(procedure (abInvokeCdfCallbacks cellView @key (debug nil) 
                                 (callInitProc nil) (useInstCDF nil)) 
   (let ((success t)) 
        (when debug 
             (printf "Invoking callbacks for all instances in cell '%s'\n" 
                     (dbGetq cellView cellName))) 
        (foreach instance (dbGetq cellView instances) 
                (unless 
                 (abInvokeInstCdfCallbacks instance 
                                           ?debug debug 
                                           ?order nil 
                                           ?callInitProc callInitProc 
                                           ?useInstCDF useInstCDF 
                                           ) 
                 (setq success nil) 
                 ) 
                ) ; foreach 
        success 
        ) 
   ) ; procedure 

