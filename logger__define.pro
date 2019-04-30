;; docformat = 'rst'   ; i.e. format of the documentation
;
; NAME:
;       logger__define
;
; PURPOSE:
;+
;       Ideja za razredom logger je poenostavitem pisanja log datoteke in hkratno obveščanje o dogajanju v
;       orodno vrstico. Vsekemu sporočilu je možno tudi nastaviti prioriteto, glede na katero se nato izvede odločitev
;       ali ga je potrebno tudi prikazati in izpisati.
;
; :Categories:
;
; :Params:
;
; :Keywords:
;
; :Uses:
;
; :Examples:
;
; :Author:
;       Klemen Cotar (Space-SI)
;
; :Copyright:
;       ZRC SAZU (Novi trg 2, 1000 Ljubljana, Slovenia) & Space-SI (Askerceva 12, 1000 Ljubljana, Slovenia)
;
; :History:
;       October 2015
;-

function logger::init, path, priority, empty=empty, width=width
  if keyword_set(empty) then append=0 else append=1
  if n_elements(priority) eq 0 then self.max_priority = 3 $
  else self.max_priority = priority
  ;priority levels (3-output everything, 2-medium output, 1-general info only, 0-none) to output to txt file
  openw, lun, path, /get_lun, append=append, width=width
  close, lun
  self.log_lun = lun
  self.log_path = path
  return, 1
end

pro logger::add, txt, priority, omit_timestamp=omit_timestamp
  if n_elements(priority) eq 0 then priority=3
  if n_elements(txt) gt 0 then begin
    print, txt
    if priority le self.max_priority then begin
      openw, self.log_lun, self.log_path, /append
      if txt ne '' then begin
        if keyword_set(omit_timestamp) then printf, self.log_lun, ' '+txt $
        else printf, self.log_lun, systime()+' :   '+txt 
      endif else printf, self.log_lun, txt
      close, self.log_lun
    endif
  endif
end

pro logger::destroy
  free_lun, self.log_lun
end

pro logger__define
  void = {logger, $
    log_path : '', $
    log_lun : 0ul, $
    max_priority : 0ul} ;default, save everything to txt file
  return
end