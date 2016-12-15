;; docformat = 'rst'   ; i.e. format of the documentation
;
; NAME:
;       get_settings_combinations
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
;           img_settings = get_settings_combinations(rapideye_settings, '=') 
;
;       Result of the function is a structure, containing array of combinations (= preset visualization mixes);
;       each combination
;         
;       
; :Author:
;       Maja Somrak
;
; :Copyright:
;       ZRC SAZU (Novi trg 2, 1000 Ljubljana, Slovenia) & Space-SI (Askerceva 12, 1000 Ljubljana, Slovenia)
;
; :History:
;       December 2016
;-
pro get_settings_combinations, 

end