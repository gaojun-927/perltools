;Author: Gao Jun
;Date: 20090714
;Description:  replace the instance to another instance, including master's lib and cell, including cdf
;              add bulk net from left to right
procedure( gjFR( lib cell )
	let( 	(cvId)
		cvId=dbOpenCellViewByType( lib cell "schematic" "schematic" "a")
		foreach( inst cvId~>instances
			if( inst->cellName=="pmos"||inst->cellName=="nmos"
				then
				printf("into %s %s\n" inst->baseName inst->cellName)
				gjReplace(cvId inst)
			)
		)
		dbSave(cvId)
		dbClose(cvId)
	)
)
procedure( gjReplace( cvId inst )
	let( 
		( 	(cellname1 "pmos")
			(cellname2 "nmos")
			totalw fingerw fingernum l m
			callback scale params cdfgData cdfgForm tt
			numl numw (shouldscale 1) node
			;shouldscale 1: make w l larger than min keep w/l
			;            ~1: make w l larger than min
		)
		cdfId=cdfGetInstCDF(inst)
		if( inst->cellName == cellname1 || inst->cellName == cellname2
			then
			totalw=cdfFindParamByName( cdfId "w")~>value
			l=cdfFindParamByName( cdfId "l")~>value
			m=cdfFindParamByName( cdfId "m")~>value
			node=cdfFindParamByName( cdfId "bn")~>value
			printf( "old w is %s l is %s m is %s\n " totalw l m)
			numl=aelNumber(l)
			numw=aelNumber(totalw)
			if( numl<200e-9
				then
				scale=200e-9/numl
				numw=round(numw*scale*1e8)/1e8
				l=aelSuffixNotation(200e-9)
				numl=200e-9
				if(numw<300e-9
					then
					scale=300e-9/numw
					totalw=aelSuffixNotation(300e-9)
					numl=round(numl*scale*1e8)/1e8
					numw=300e-9
				)
				if( shouldscale==1 
					then 
					totalw=aelSuffixNotation(numw) 
					l=aelSuffixNotation(numl)
				)
			)
			if( m=="" then m="1")
			printf( "to write w is %s l is %s m is %s\n " totalw l m)
			if( inst->cellName==cellname1
				then
				;dbSetInstHeaderMasterName( inst->instHeader "smic65ll_121825" "p18ll" "symbol") not right
				inst->master=dbOpenCellViewByType("smic65ll_121825" "p18ll" "symbol" "schematicSymbol" "r")
				else
				;dbSetInstHeaderMasterName( inst->instHeader "smic65ll_121825" "n18ll" "symbol")
				inst->master=dbOpenCellViewByType("smic65ll_121825" "n18ll" "symbol" "schematicSymbol" "r")
			)
			cdfgForm=nil
			cdfgData=cdfId
			cdfgData->m->value=m
			cdfgData->l->value=l
			cdfgData->w->value=totalw
			cdfgData->fw->value=totalw
			cdfgData->fingers->value="1"
			callback=getq( cdfgData formInitProc)
			when( callback&&callback!=""
				unless( 
					errset(
						evalstring( strcat( callback "(cdfgData)") )
						t
					)
					printf("? callback each\n")
				)
			)
			
			params=getq(cdfgData parameters)
			foreach( param params
				callback=getq( param callback)
				when( callback&&callback!=""
					unless( 
						errset(
							evalstring(  callback  )
						t
						)
						printf("??? callback each\n")
					)
				)	
				
			)
			schCheck(cvId) ;needed. If not, Bulk will not show in instance
			gjAddNodeline(cvId inst node)
		)
		
	)
)
procedure( gjAddNodeline( cvId inst node)
	let( 
		(
			instTermBbox instTermBboxInCV instTermLLX instTermLLY instTermURX instTermURY
			wireOriginX wireOriginY wireEndX wireEndY termWire
		)
		
		foreach( instTerm inst~>instTerms
			if( instTerm~>name =="B" 
				then
				printf("add net %s\n" node)
				instTermBbox=car(instTerm~>term~>pins~>fig~>bBox)
				instTermBboxInCV=dbTransformBBox(instTermBbox inst~>transform)
				instTermLLX=xCoord( lowerLeft( instTermBboxInCV))
				instTermLLY=yCoord( lowerLeft( instTermBboxInCV))	
				instTermURX=xCoord( upperRight( instTermBboxInCV))
				instTermURY=yCoord( upperRight( instTermBboxInCV))
				wireOriginX=(instTermLLX+instTermURX)/2
				wireOriginY=(instTermLLY+instTermURY)/2
				wireEndX=wireOriginX+0.1
				wireEndY=wireOriginY
				termWire=schCreateWire( cvId "draw" "full" list(wireOriginX:wireOriginY wireEndX:wireEndY) 0.1 0.1 0)
				schCreateWireLabel( cvId car(termWire) wireEndX:wireEndY node "upperLeft" "R0" "fixed" 0.0625 nil)
			)
		)
		schCheck(cvId)
	)
)
	
