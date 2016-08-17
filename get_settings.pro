;; docformat = 'rst'   ; i.e. format of the documentation
;
; NAME:
;       get_settings
;
; PURPOSE:
;+
;       This function reads sensor parameter file (given within  folder \SensorSettings) 
;       and returns a structure containig sensor-specific settings. 
;       
;       In the parameter file attribute tags and attribute values should be delimited with 
;       uniform delimeter, which enables easy parsing of values. The delimeter '#' should not
;       be used, since it is used for comments.
;
; :Categories:
;       P0 Initial preprocessing
;
; :Params:
;       path: in, required, type=string
;           Full path (path+filename) of the sensor parameter TXT file containing sensor-specific 
;           settings (attributes), located within the folder \SensorSettings. 
;           The default location of this folder is:
;           <STORM_installation_dir>\SensorSettings\
;       delimiter: in, optional, type=string
;           Delimeter, which is used in the TXT file to delimit attribute tag from attribute value.
;           If this parameter is not set, then the delimeter '=' is used. 
;
; :Uses:
;       format_string
;
; :Examples:
;       An example of function call::
;
;           rapideye_settings = 'c:\storm_toolbox\SensorSettings\rapideye.txt'
;           img_settings = get_settings(rapideye_settings, '=') 
;
;       Result of the function is a structure, containing tags: .sensor_type, .blue, .green, ... 
;       .dynamic_range, ... aso.
;       
; :Author:
;       Klemen Cotar (Space-SI)
;
; :Copyright:
;       ZRC SAZU (Novi trg 2, 1000 Ljubljana, Slovenia) & Space-SI (Askerceva 12, 1000 Ljubljana, Slovenia)
;
; :History:
;       July 2014
;-
function get_settings, path, delimiter, append_settings=append_settings

comment = '#'   ;everything after this character is taken as a comment, thus discarded from further processing

print, '# Reading sensor specific settings (get_settings): ', path
if file_test(path) eq -1 then begin
  print, '# File does not exist: ', path
  return, {}
endif
if not(keyword_set(delimiter)) then delimiter = '='     ;default delimiter is set to equal sign

openr, csvFile, path, /get_lun
tags = []
line = ''
csvStruct = {}
while not eof(csvFile) do begin
  readf, csvFile, line
  if strpos(line, comment) gt -1 then line = strmid(line, 0, strpos(line, comment))
  lineSplit = strSplit(line, delimiter, /extract)
  
  if size(lineSplit, /n_elements) eq 2 then begin
    
    ;determine a type of variable read from text file
    lineSplit[1] = strjoin(strsplit(lineSplit[1], ' ', /extract), ' ')
    length = strlen(lineSplit[1])
    if strcmp(strmid(lineSplit[1], 0, 1),'[') eq 1 and strcmp(strmid(lineSplit[1], length-1, 1),']') eq 1 then begin ;value must be array
      arrayValues = strmid(lineSplit[1], 1, length-2)
      arrayValues = strSplit(arrayValues, ',', /extract)
      value =[]
      for ar = 0, size(arrayValues, /n_elements)-1 do value = [[[value]],format_string(arrayValues[ar])]  ;fill an array with comma separated values
    endif else value = format_string(lineSplit[1])
      
    ;add a tag and its value to the structure
    name = strcompress(lineSplit[0], /remove_all)
    if total(tags eq name) eq 0 then begin ;repeated tags are not included
      csvStruct = create_struct(csvStruct, name, value)
      tags = [[[tags]], name]
    endif 
  endif 
  
endwhile

if n_elements(append_settings) gt 0 then begin
  csvStruct = create_struct(csvStruct, append_settings)
endif

free_lun, csvFile
return, csvStruct
end