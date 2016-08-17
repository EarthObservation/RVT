;; docformat = 'rst'   ; i.e. format of the documentation
;
; NAME:
;       format_string
;
; PURPOSE:
;+
;       This function detects the actual data type of the input string, and returns it in the 
;       proper data type format, i.e. either as long integer (64-bit) or double (64-bit) or 
;       string. 
;       
;       If the string comes within double-quotation marks (an example from Landsat metadata file:
;       "GLS2000"), this function removes both quotation marks and returns bare string (e.g. GLS2000).
;
; :Categories:
;       Utilities
;
; :Params:
;       in_string: in, required, type=string
;           Input string.
;
; :Examples:
;       Three examples of function call::
;
;           help, format_string('745')
;           help, format_string('2.232e-1')
;           help, format_string('"GLS2000"')
;
;       Results are::
;       
;           <Expression>    LONG      =   745
;           <Expression>    DOUBLE    =   0.22320000
;           <Expression>    STRING    =   GLS2000
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
function format_string, in_string
  numbers   = '0123456789'
  decimal   = '.'     ;decimal number representation
  exponents   = 'dDeE'    ;representing exponent with base 10
  ;exponentsCapital   = 'E'    ;representing exponent with base 10
  sig = '+-'    ;signs allowed in number

  ndots = 0
  nInt = 0
  nExp = 0

  in_string = strjoin(strsplit(in_string, ' ', /extract), ' ')

  length = strlen(in_string)
  totalLen = length

  for pos = 0, length-1 do begin
    char = strmid(in_string, pos, 1)
    if strpos(numbers,char) ne -1 then nInt++
    if strpos(decimal,char) ne -1 then ndots++
    if strpos(exponents,char) ne -1 then nExp++
    ;if strpos(exponentsCapital,char) ne -1 then nExp++
    if strpos(sig,char) ne -1 then begin
      if pos eq 0 then totalLen-- ;sign can be located as the first character
      if strpos(exponents,strmid(in_string, pos-1, 1)) ne -1 then totalLen-- ;sign can be located right after character 'e' representing exponent with base 10
      ;if strpos(exponentsCapital,strmid(in_string, pos-1, 1)) ne -1 then totalLen-- ;sign can be located right after character 'E' representing exponent with base 10
    endif
  endfor

  if nInt eq totalLen then return, long(in_string) ;is long
  if ndots eq 0 and nExp eq 1 and (nExp + ndots + nInt) eq totalLen then return, double(in_string) ;is float
  if ndots eq 1 and nExp le 1 and (nExp + ndots + nInt) eq totalLen then return, double(in_string) ;is float
  ;otherwise it is not a number, so it is string
  if strcmp(strmid(in_string, 0, 1),'"') eq 1 and strcmp(strmid(in_string, length-1, 1),'"') eq 1 then return, strmid(in_string, 1, length-2) $  ; remove quotations
  else return, in_string   ;input string cannot be formated to number, returning input string
end