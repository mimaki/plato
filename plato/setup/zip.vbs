'
' zip.vbs - Copmress files to ZIP file.
'
' Usage: wscript zip.vbs <zip_file> <src_path>
'   zip_file:  ZIP file name.
'   src_path:  Directory/File to compress.
'
set args = WScript.Arguments
if args.Count < 2 then
  WScript.Echo "Usage: wscirpt zip.vbs <zip_file> <src_path>" + chr(13) + "  zip_file: ZIP file name" + chr(13) + "  src_path: source directory to compress"
  WScript.Quit
end if

' ZIP Compress files
sub Zip(byval ZipPath, byval path)
  set fso = CreateObject("Scripting.FileSystemObject")
  set app = CreateObject("Shell.Application")
 
  ' Create ZIP file
  With fso.CreateTextFile(ZipPath, True)
    .Write "PK" & Chr(5) & Chr(6) & String(18,0)
    .Close
  End With
 
  set zipFolder = app.NameSpace(fso.GetAbsolutePathName(ZipPath))
  zipFolder.CopyHere(fso.GetAbsolutePathName(path))
 
  do while zipFolder.Items().Count < 1
    Wscript.sleep 100
  Loop
 
  set fso = Nothing
  set app = Nothing
end sub

call Zip(args(0), args(1))
