#define vars here
$processname="csmc05ms";
$processdir="~/processmodel_modify/$processname/";
$processcornerfile="csmc05ms.list";
$designvar="vdd";
$processcornerlist1="tt"; #  tt
@processcornerlist2=("ff", "ss","fs","sf"); # sweep with min max,
@processcornerlist3=(); #, sweep with tt
%templist=( ""=> 27,  "cold"=> -40,  "hot"=> 95) ; #tt,min max
%designvarlist=( ""=>3,  "lv" =>2.4 ,  "hv" =>5.5 ) ; #tt,min,max
$id="pl"; #add special comment here
$outputpcffile="${processname}corner${id}.pcf";

#open file
open ( MYFILE, ">$outputpcffile")||die( "open file error! \n");

#body of pcf file
@cornertotal=($processcornerlist1,@processcornerlist2,@processcornerlist3);
$cornertotalstring=join("\",\"",@cornertotal);
$cornertotalstring="\"$cornertotalstring\"";
print MYFILE (<<HERE);
corAddProcess( "$processname" "$processdir" 'multipleModelLib )
corAddProcessVar( "$processname" "$designvar" )
corSetProcessVarVal( "$processname" "$designvar" "" )
corAddModelFileAndSectionChoices( "$processname" "$processcornerfile" '(  $cornertotalstring ) )
HERE

#tt corner
print MYFILE ( <<"HERE1" );

corAddCorner( "$processname" "$processcornerlist1" 
	?sections '( ("$processcornerfile" "$processcornerlist1") )
	?runTemp $templist{""}
	?vars '( ("$designvar" $designvarlist{""}) )
)

HERE1

# sweep ff,ss with temp and designvar

foreach $var1(@processcornerlist2){
	foreach $var2(sort keys(%templist)){
		foreach $var3(sort keys(%designvarlist)){
			
			print MYFILE (<<HERE) if( $var2 ne "" and $var3 ne "");
;;;;;				
            corAddCorner( 
            "$processname" "$var1$var2$var3"   
            ?sections '( ("$processcornerfile" "$var1") ) 
            ?runTemp $templist{$var2}
            ?vars '(  ("$designvar" $designvarlist{$var3} )  )
            )
HERE
			}
	}
}

print MYFILE (";process corners only\n");
foreach $var1(@processcornerlist3){
			print MYFILE (<<HERE);
;				
            corAddCorner( 
            "$processname" "$var1"   
            ?sections '( ("$processcornerfile" "$var1") ) 
            ?runTemp $templist{""}
            ?vars '(  ("$designvar" $designvarlist{""} )  )
            )
HERE
}

close(MYFILE);

