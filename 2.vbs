
 Public ount,fcount,sourcedir,targetdir,ser
 Dim fso
  ount=0
  fcount=0
  ser=0
  sourcedir="e:\gaojun\downloads\"
  targetdir="e:\gaojun\ime2\"
  Set fso = CreateObject("Scripting.FileSystemObject")
  If( fso.FolderExists(targetdir&"pi\"&CStr(Date))<>True)Then 
  	fso.createfolder(targetdir&"pi\"&CStr(Date))
  End If 
  If( fso.FolderExists(targetdir&"vi\"&CStr(Date))<>True)Then 
  	fso.createfolder(targetdir&"vi\"&CStr(Date))
  End If 
  If( fso.FolderExists(targetdir&"zi\"&CStr(Date))<>True)Then 
  	fso.createfolder(targetdir&"zi\"&CStr(Date))
  End If
  
  getfileobj(sourcedir)
  
  
Function getfileobj(folds)
  Dim fosf, ff,sff,f1f,paths,fff,arr,fname,three

  fcount=fcount+1
  
  
  Set fsof = CreateObject("Scripting.FileSystemObject")
  Set ff = fsof.GetFolder(folds)
  Set sff=ff.subfolders
  For each f1f in sff 
  	If f1f.attributes =16 Then
  		paths=CStr(f1f.path)
  		getfileobj(paths)		
  	End If
  Next
  Set fff=ff.files
  For each f1f in fff
  	arr=split(f1f.name,".")
  	three=LCase(arr(UBound(arr)))
  	fname=CStr(date)&"-"&CStr(ount)&"."&three
  	If three="jpg" Then
  		
  		f1f.copy (targetdir&"pi\"&CStr(date)&"\"&fname)
  		ount=ount+1
  	ElseIf (three="rm" or three="mpeg" or three="mpg" or three="asx" or three="asf" or three="ram" or three="mp3" )Then 
  		
  		f1f.copy (targetdir&"vi\"&CStr(date)&"\"&fname)
  		ount=ount+1
  	ElseIf  (three="zip" or three="cab" )Then
  		
  		f1f.copy (targetdir&"zi\"&CStr(date)&"\"&fname)
  		ount=ount+1
  	End If
  	
  Next
 End Function