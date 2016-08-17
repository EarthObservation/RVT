

;=====================================================================================
;=== Main program ====================================================================
;=====================================================================================

;+
; NAME:
;
;       delete_files_topo_advanced_vis.pro
;
; PURPOSE:
;
;       Deletes file from standalone EXE distribution of Relif Visualization Toolbox 
;       Win32 and Win64 
;
; INPUTS:
;
;       Folder of the standalone EXE distribution
;
; OUTPUTS:
;
;       Same folder as input folder, however with deleted files from the list.
;       IDL console gives the list of deleted and not-found files
;
; AUTHORS:
;
;       Peter Pehani
;
; DEPENDENCIES:
;
;       None
;
; MODIFICATION HISTORY:
;
;       1.0  November 2013
;       1.1  September 2014: Added final report of deleted/missed files
;-

pro delete_files_topo_advanced_vis, in_path

  compile_opt idl2
  
  ; Establish error handler
  catch, theError
  if theError ne 0 then begin
    catch, /cancel
    help, /last_message, output=errText
    errMsg = dialog_message(errText, /error, title='Error processing request')
    return
  endif
  
  ; Start the main program
  print
  print
  Print, '------------------------------------------------------------------------------------------------------'
  print, 'Delete files from standalone EXE distribution of Relief Visualization Toolbox for Win32/Win64'
  Print, '------------------------------------------------------------------------------------------------------'
  print


  
  ;=========================================================================================================
  ;=== Select input EXE distribution folder and list of files to be deleted ================================
  ;=========================================================================================================

;  in_path_start = 'f:\IDLWorkspace\RVT-IDL\RVT_1.2_Win64\'
;  in_path = dialog_pickfile(title='Select folder of standalone EXE distribution: ', path=in_path_start, /directory)
;  if in_path eq '' then return
  print, 'Folder of standalone EXE distribution: ', in_path

  in_list = '_RVT_standalone_Win32_files_to_delete.txt'
  print, 'List of files to be removed from distribution: ', in_list
  
  count = 0
  count_deleted = 0
  count_not_found = 0
  filename = ''
  openr, unit, in_list, /get_lun
  while ~ eof(unit) do begin
      readf, unit, filename
      file_searched = file_search(in_path, filename)
      file_found = file_test(file_searched)     
      if file_found then begin
        file_delete, file_searched
        print, '  deleted:  ' + string(count, format="(i3)") + '  ' + file_searched
        count_deleted++
      endif else begin
        print, '  NOT FOUND:  ' + string(count, format="(i3)") + '  ' + filename
        count_not_found++
      endelse    
      count++
   endwhile
   free_lun, unit

   
   ; Print final message to the console
   print
   if (count_deleted eq count) then begin
     print, 'All ' + strtrim(count,2) + ' listed files were found and deleted.'
   endif else begin
     print, 'Not all listed files were found and deleted. Number of listed files: ' + strtrim(count,2) + $
                        '. Number of missed files: ' + strtrim(count_not_found,2) + '.'
   endelse
end

