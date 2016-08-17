

;=====================================================================================
;=====================================================================================
;=== Widget actions ==================================================================
;=====================================================================================


; When user changes values of entry boxes, drop-down menus, etc.
pro user_widget_do_nothing, event
  ; dummy pro
end



; When user presses About button
pro user_widget_about, event 
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
  msg = strarr(16)
  msg[0] = 'Relief Visualization Toolbox (RVT), ver. ' + (*p_wdgt_state).rvt_vers
  msg[1] = '-------------------------------------------------------------------'
  msg[2] = 'By Klemen Zaksek, Kristof Ostir, Peter Pehani, Klemen Cotar and Ziga Kokalj'
  msg[4] = '* Online resource and manual'
  msg[5] = 'http://iaps.zrc-sazu.si/en/rvt'
  msg[6] = 'Check for updates from time to time. Please report any bugs and suggestions for improvements to peter.pehani@zrc-sazu.si'
  msg[8] = '* License agreement'
  msg[9] = 'This software is distributed without any warranty and without even the implied warranty of merchantability or fitness for a particular purpose.'
  msg[11] = '* Acknowledgment'
  msg[12] = "Development of RVT was partly financed by the European Commission's Culture Programme through the ArchaeoLandscapes Europe project."
  msg[14] = '* Copyright'
  msg[15] = '(c) Research Centre of the Slovenian Academy of Sciences and Arts (ZRC SAZU), ' + (*p_wdgt_state).rvt_year
  show_about = dialog_message(msg, title='About RVT', /information)
end



; When user un/checks arbitrary method (that is not dependent on other methods)
pro user_widget_toggle_method_checkbox, event
  id_parent = widget_info(event.id, /parent) 
  id_sibling_of_parent = widget_info(id_parent, /sibling) 
  sibling_sensitive_get = widget_info(id_sibling_of_parent, /sensitive) 
  sibling_sensitive_set = sibling_sensitive_get eq 1 ? 0 : 1    ; toggle sensitivity
  widget_control, id_sibling_of_parent, sensitive=sibling_sensitive_set
;  ; produce prints to see how this works
;  ; note: top is the very top widget; parent is hierarchically one above, sibling is on same level (brother)
;  print, event, ';      i.e. event.id, event.top, event.handler: ', event.id, event.top, event.handler
;  print, 'id_parent ', id_parent
;  print, '   sensitive y/n? ', widget_info(id_parent, /sensitive) 
;  print, '   all children   ', widget_info(id_parent, /all_children) 
;  print, 'id_sibling ', id_sibling
;  print, '   sensitive y/n? ', widget_info(id_sibling, /sensitive) 
;  print, '   all children   ', widget_info(id_sibling, /all_children)
;  print, '   new sibling sensitivity ', sibling_sensitive
end



; When user un/checks Hillshading from multiple directions (prerequisite also for PCA of hillshading)
pro user_widget_toggle_mhls_checkbox, event
  ; get status the Multiple checkbox itself, and id of its parameters
  id_mhls_checkbox = widget_info(event.top, find_by_uname='u_mhls_checkbox')   
  id_mhls_checkbox_get = widget_info(id_mhls_checkbox, /button_set) 
  id_mhls_params = widget_info(event.top, find_by_uname='u_mhls_params')   
  if id_mhls_checkbox_get then begin
    ; ... if status is checked, show Multiple params  
    widget_control, id_mhls_params, sensitive=1
  endif else begin
     ; ... if status is un-checked, and if also PCA is un-checked, hide Multiple params  
    id_mhls_pca_checkbox = widget_info(event.top, find_by_uname='u_mhls_pca_checkbox')   
    id_mhls_pca_checkbox_get = widget_info(id_mhls_pca_checkbox, /button_set) 
    if not id_mhls_pca_checkbox_get then begin
      widget_control, id_mhls_params, sensitive=0
    endif
  endelse  
end



; When user un/checks PCA of hillshading (dependent on Hillshading from multiple directions)
pro user_widget_toggle_mhls_pca_checkbox, event
  ; first toggle the PCA itself, 
  user_widget_toggle_method_checkbox, event
  ; ... get its status and id of Multiple parameters
  id_mhls_pca_checkbox = widget_info(event.top, find_by_uname='u_mhls_pca_checkbox')   
  id_mhls_pca_checkbox_get = widget_info(id_mhls_pca_checkbox, /button_set) 
  id_mhls_params = widget_info(event.top, find_by_uname='u_mhls_params')   
  if id_mhls_pca_checkbox_get then begin
    ; ... if status is checked, show Multiple params  
;    id_mhls_checkbox = widget_info(event.top, find_by_uname='u_mhls_checkbox')   
;    widget_control, id_mhls_checkbox, set_button=1
    widget_control, id_mhls_params, sensitive=1
  endif else begin
     ; ... if status is un-checked, and if also Multiple is un-checked, hide Multiple params  
    id_mhls_checkbox = widget_info(event.top, find_by_uname='u_mhls_checkbox')   
    id_mhls_checkbox_get = widget_info(id_mhls_checkbox, /button_set)
    if not id_mhls_checkbox_get then begin
      widget_control, id_mhls_params, sensitive=0
    endif
  endelse  
end



; When user un/checks SVF (prerequisite also for Anisotropic SVF, Openness and Negative openness)
pro user_widget_toggle_svf_checkbox, event
  ; get status the SVF checkbox itself, and id of its parameters
  id_svf_checkbox = widget_info(event.top, find_by_uname='u_svf_checkbox')   
  id_svf_checkbox_get = widget_info(id_svf_checkbox, /button_set) 
  id_svf_params = widget_info(event.top, find_by_uname='u_svf_params')   
  if id_svf_checkbox_get then begin
    ; ... if status is checked, show SVF params  
    widget_control, id_svf_params, sensitive=1
  endif else begin
     ; ... if status is un-checked, and if also Anisotropic SVF, Openness and Neg. open. is un-checked, hide SVF params  
    id_asvf_checkbox = widget_info(event.top, find_by_uname='u_asvf_checkbox')   
    id_asvf_checkbox_get = widget_info(id_asvf_checkbox, /button_set) 
    id_open_checkbox = widget_info(event.top, find_by_uname='u_open_checkbox')   
    id_open_checkbox_get = widget_info(id_open_checkbox, /button_set) 
    id_open_neg_checkbox = widget_info(event.top, find_by_uname='u_open_neg_checkbox')   
    id_open_neg_checkbox_get = widget_info(id_open_neg_checkbox, /button_set) 
    if (not id_asvf_checkbox_get) and (not id_open_checkbox_get) and (not id_open_neg_checkbox_get) then begin
      widget_control, id_svf_params, sensitive=0
    endif
  endelse  
end



; When user un/checks Anisotropic SVF (dependent on SVF)
pro user_widget_toggle_asvf_checkbox, event
  ; first toggle the Anisotropic SVF itself, 
  user_widget_toggle_method_checkbox, event
  ; ... get its status and id of SVF parameters
  id_asvf_checkbox = widget_info(event.top, find_by_uname='u_asvf_checkbox')   
  id_asvf_checkbox_get = widget_info(id_asvf_checkbox, /button_set) 
  id_svf_params = widget_info(event.top, find_by_uname='u_svf_params')   
  if id_asvf_checkbox_get then begin
    ; ... if status is checked, show SVF params  
    widget_control, id_svf_params, sensitive=1
  endif else begin
    ; ... if status is un-checked, and if also SVF and the other two dependent methods are un-checked, hide SVF params  
    id_svf_checkbox = widget_info(event.top, find_by_uname='u_svf_checkbox')   
    id_svf_checkbox_get = widget_info(id_svf_checkbox, /button_set)
    id_open_checkbox = widget_info(event.top, find_by_uname='u_open_checkbox')   
    id_open_checkbox_get = widget_info(id_open_checkbox, /button_set) 
    id_open_neg_checkbox = widget_info(event.top, find_by_uname='u_open_neg_checkbox')   
    id_open_neg_checkbox_get = widget_info(id_open_neg_checkbox, /button_set) 
    if (not id_svf_checkbox_get) and (not id_open_checkbox_get) and (not id_open_neg_checkbox_get) then begin
      widget_control, id_svf_params, sensitive=0
    endif
  endelse  
end



; When user un/checks Openness (dependent on SVF)
pro user_widget_toggle_open_checkbox, event
  ; first toggle the Openness itself, 
  user_widget_toggle_method_checkbox, event
  ; ... get its status and id of SVF parameters
  id_open_checkbox = widget_info(event.top, find_by_uname='u_open_checkbox')   
  id_open_checkbox_get = widget_info(id_open_checkbox, /button_set) 
  id_svf_params = widget_info(event.top, find_by_uname='u_svf_params')   
  if id_open_checkbox_get then begin
    ; ... if status is checked, show SVF params  
    widget_control, id_svf_params, sensitive=1
  endif else begin
    ; ... if status is un-checked, and if also SVF and the other two dependent methods are un-checked, hide SVF params  
    id_svf_checkbox = widget_info(event.top, find_by_uname='u_svf_checkbox')   
    id_svf_checkbox_get = widget_info(id_svf_checkbox, /button_set)
    id_asvf_checkbox = widget_info(event.top, find_by_uname='u_asvf_checkbox')   
    id_asvf_checkbox_get = widget_info(id_asvf_checkbox, /button_set) 
    id_open_neg_checkbox = widget_info(event.top, find_by_uname='u_open_neg_checkbox')   
    id_open_neg_checkbox_get = widget_info(id_open_neg_checkbox, /button_set) 
    if (not id_svf_checkbox_get) and (not id_asvf_checkbox_get) and (not id_open_neg_checkbox_get) then begin
      widget_control, id_svf_params, sensitive=0
    endif
  endelse  
end



; When user un/checks Negative openness (dependent on SVF)
pro user_widget_toggle_open_neg_checkbox, event
  ; first toggle the Negative openness itself, 
  user_widget_toggle_method_checkbox, event
  ; ... get its status and id of SVF parameters
  id_open_neg_checkbox = widget_info(event.top, find_by_uname='u_open_neg_checkbox')   
  id_open_neg_checkbox_get = widget_info(id_open_neg_checkbox, /button_set) 
  id_svf_params = widget_info(event.top, find_by_uname='u_svf_params')   
  if id_open_neg_checkbox_get then begin
    ; ... if status is checked, show SVF params  
    widget_control, id_svf_params, sensitive=1
  endif else begin
    ; ... if status is un-checked, and if also SVF and the other two dependent methods are un-checked, hide SVF params  
    id_svf_checkbox = widget_info(event.top, find_by_uname='u_svf_checkbox')   
    id_svf_checkbox_get = widget_info(id_svf_checkbox, /button_set)
    id_asvf_checkbox = widget_info(event.top, find_by_uname='u_asvf_checkbox')   
    id_asvf_checkbox_get = widget_info(id_asvf_checkbox, /button_set) 
    id_open_checkbox = widget_info(event.top, find_by_uname='u_open_checkbox')   
    id_open_checkbox_get = widget_info(id_open_checkbox, /button_set) 
    if (not id_svf_checkbox_get) and (not id_asvf_checkbox_get) and (not id_open_checkbox_get) then begin
      widget_control, id_svf_params, sensitive=0
    endif
  endelse  
end



; When user presses Select all button
pro user_widget_all, event
  id_hls_checkbox = widget_info(event.top, find_by_uname='u_hls_checkbox')   
  widget_control, id_hls_checkbox, set_button=1
  id_hls_params = widget_info(event.top, find_by_uname='u_hls_params')   
  widget_control, id_hls_params, sensitive=1
  id_mhls_checkbox = widget_info(event.top, find_by_uname='u_mhls_checkbox')   
  widget_control, id_mhls_checkbox, set_button=1
  id_mhls_params = widget_info(event.top, find_by_uname='u_mhls_params')   
  widget_control, id_mhls_params, sensitive=1
  id_mhls_pca_checkbox = widget_info(event.top, find_by_uname='u_mhls_pca_checkbox')   
  widget_control, id_mhls_pca_checkbox, set_button=1
  id_mhls_pca_params = widget_info(event.top, find_by_uname='u_mhls_pca_params')   
  widget_control, id_mhls_pca_params, sensitive=1
  id_slp_checkbox = widget_info(event.top, find_by_uname='u_slp_checkbox')   
  widget_control, id_slp_checkbox, set_button=1
  id_slp_params = widget_info(event.top, find_by_uname='u_slp_params')   
  widget_control, id_slp_params, sensitive=1
  id_slrm_checkbox = widget_info(event.top, find_by_uname='u_slrm_checkbox')   
  widget_control, id_slrm_checkbox, set_button=1
  id_slrm_params = widget_info(event.top, find_by_uname='u_slrm_params')   
  widget_control, id_slrm_params, sensitive=1
  id_svf_checkbox = widget_info(event.top, find_by_uname='u_svf_checkbox')   
  widget_control, id_svf_checkbox, set_button=1
  id_svf_params = widget_info(event.top, find_by_uname='u_svf_params')   
  widget_control, id_svf_params, sensitive=1
  id_asvf_checkbox = widget_info(event.top, find_by_uname='u_asvf_checkbox')   
  widget_control, id_asvf_checkbox, set_button=1
  id_asvf_params = widget_info(event.top, find_by_uname='u_asvf_params')   
  widget_control, id_asvf_params, sensitive=1
  id_open_checkbox = widget_info(event.top, find_by_uname='u_open_checkbox')   
  widget_control, id_open_checkbox, set_button=1
  id_open_params = widget_info(event.top, find_by_uname='u_open_params')   
  widget_control, id_open_params, sensitive=1
  id_open_neg_checkbox = widget_info(event.top, find_by_uname='u_open_neg_checkbox')   
  widget_control, id_open_neg_checkbox, set_button=1
  id_open_neg_params = widget_info(event.top, find_by_uname='u_open_neg_params')   
  widget_control, id_open_neg_params, sensitive=1
  id_open_skyilm_params = widget_info(event.top, find_by_uname='u_skyilm_params')
  widget_control, id_open_skyilm_params, sensitive=1
  id_open_skyilm_checkbox = widget_info(event.top, find_by_uname='u_skyilm_checkbox')
  widget_control, id_open_skyilm_checkbox, set_button=1
end



; When user presses Select none button
pro user_widget_none, event
  id_hls_checkbox = widget_info(event.top, find_by_uname='u_hls_checkbox')   
  widget_control, id_hls_checkbox, set_button=0
  id_hls_params = widget_info(event.top, find_by_uname='u_hls_params')   
  widget_control, id_hls_params, sensitive=0
  id_mhls_checkbox = widget_info(event.top, find_by_uname='u_mhls_checkbox')   
  widget_control, id_mhls_checkbox, set_button=0
  id_mhls_params = widget_info(event.top, find_by_uname='u_mhls_params')   
  widget_control, id_mhls_params, sensitive=0
  id_mhls_pca_checkbox = widget_info(event.top, find_by_uname='u_mhls_pca_checkbox')   
  widget_control, id_mhls_pca_checkbox, set_button=0
  id_mhls_pca_params = widget_info(event.top, find_by_uname='u_mhls_pca_params')   
  widget_control, id_mhls_pca_params, sensitive=0
  id_slp_checkbox = widget_info(event.top, find_by_uname='u_slp_checkbox')   
  widget_control, id_slp_checkbox, set_button=0
  id_slp_params = widget_info(event.top, find_by_uname='u_slp_params')   
  widget_control, id_slp_params, sensitive=0
  id_slrm_checkbox = widget_info(event.top, find_by_uname='u_slrm_checkbox')   
  widget_control, id_slrm_checkbox, set_button=0
  id_slrm_params = widget_info(event.top, find_by_uname='u_slrm_params')   
  widget_control, id_slrm_params, sensitive=0
  id_svf_checkbox = widget_info(event.top, find_by_uname='u_svf_checkbox')   
  widget_control, id_svf_checkbox, set_button=0
  id_svf_params = widget_info(event.top, find_by_uname='u_svf_params')   
  widget_control, id_svf_params, sensitive=0
  id_asvf_checkbox = widget_info(event.top, find_by_uname='u_asvf_checkbox')   
  widget_control, id_asvf_checkbox, set_button=0
  id_asvf_params = widget_info(event.top, find_by_uname='u_asvf_params')   
  widget_control, id_asvf_params, sensitive=0
  id_open_checkbox = widget_info(event.top, find_by_uname='u_open_checkbox')   
  widget_control, id_open_checkbox, set_button=0
  id_open_params = widget_info(event.top, find_by_uname='u_open_params')   
  widget_control, id_open_params, sensitive=0
  id_open_neg_checkbox = widget_info(event.top, find_by_uname='u_open_neg_checkbox')   
  widget_control, id_open_neg_checkbox, set_button=0
  id_open_neg_params = widget_info(event.top, find_by_uname='u_open_neg_params')   
  widget_control, id_open_neg_params, sensitive=0
  id_open_skyilm_params = widget_info(event.top, find_by_uname='u_skyilm_params')
  widget_control, id_open_skyilm_params, sensitive=0
  id_open_skyilm_checkbox = widget_info(event.top, find_by_uname='u_skyilm_checkbox')
  widget_control, id_open_skyilm_checkbox, set_button=0
  
end

; When user presses Cancel button
pro user_widget_cancel, event
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
  (*p_wdgt_state).user_cancel = 1
  ;widget_control, event.top, set_uvalue=wdgt_state  ; pass changes back to calling procedure
  widget_control, event.top, /destroy
  file_delete, programrootdir()+'settings\temp_settings.sav', /allow_nonexistent, /quiet
end


; When user presses Convert button under Convert tab
pro user_widget_convert, event
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
  format = widget_info((*p_wdgt_state).convert_dropdown, /combobox_gettext)
  lzw = widget_info((*p_wdgt_state).tzw_checkbox, /button_set)
  envi = widget_info((*p_wdgt_state).convert_dropdown_envi, /combobox_gettext)
  erdas = widget_info((*p_wdgt_state).erdas_checkbox, /button_set)
  erdas_stat = widget_info((*p_wdgt_state).erdas_stat_checkbox, /button_set)
  jp2000_cb_loss = widget_info((*p_wdgt_state).jp2000loss_checkbox, /button_set)
  widget_control, (*p_wdgt_state).jp2000q_text, get_value=jp2000_q  ; structure containing widget state
;  widget_control, (*p_wdgt_state).jpgq_text, get_value=jpg  ; structure containing widget state
  id_selection_panel = widget_info(event.top, find_by_uname='u_selection_panel')
  widget_control, id_selection_panel, get_value=panel_text
  in_delimiter = ';'
  panel_text = strtrim(strsplit(strjoin(panel_text, in_delimiter), in_delimiter, /extract),2) ; split possible multiple entries within same string
  n_files = n_elements(panel_text)
  
  (*p_wdgt_state).user_cancel = 3
  widget_control, event.top, /destroy  
  
  ; Initate progress-bar display (withot cancel button), ...
  statText = 'Converting selected images.
  progress_bar2 = obj_new('progressbar', title='Relief Visualization Toolbox - Progress ...', text=statText, xsize=300, ysize=20, $
    nocancel=0)
  progress_bar2 -> Start
  ; ... define values to assist bthe display
  progress_step = 100. / n_files
  progress_curr = progress_step/2
  progress_bar2 -> Update, progress_curr  
  
  for nF = 0, n_files -1 do begin
    date = Systime(/Julian)
    Caldat, date, Month, Day, Year, Hour, Minute, Second
    IF month LT 10 THEN month = '0' + Strtrim(month,1) ELSE month = Strtrim(month,1)
    IF day LT 10 THEN day = '0' + Strtrim(day,1) ELSE day = Strtrim(day,1)
    IF Hour LT 10 THEN Hour = '0' + Strtrim(Hour,1) ELSE Hour = Strtrim(Hour,1)
    IF Minute LT 10 THEN Minute = '0' + Strtrim(Minute,1) ELSE Minute = Strtrim(Minute,1)
    IF Second LT 10 THEN Second = '0' + Strtrim(Round(Second),1) ELSE Second = Strtrim(Round(Second),1)
    date_time = Strtrim(Year,1) + '-' + month + '-' + day + '_' + hour + '-' + minute + '-' + second
    
    last_dot = strpos(panel_text[nF], '.' , /reverse_search)
    if last_dot eq -1 or (last_dot gt 0 and strlen(panel_text[nF])-last_dot ge 6) then out_file = panel_text[nF] $  ;input file has no extension or extensions is very long (>=6) e.q. there is no valid extension or dost is inside filename
    else out_file = strmid(panel_text[nF], 0, last_dot) 
    out_file += '_process_log_' + date_time + '.txt'
        
    progress_bar2 -> Update, progress_curr
    progress_curr += progress_step
    topo_advanced_vis_converter, panel_text[nF], format, out_file, $
                                 lzw_tiff = lzw, $
                                 envi_interleave = envi, $ 
                                 jp2000_quality=jp2000_q, jp2000_lossless=jp2000_cb_loss, $
                                 jpg_quality=0, $ ;default predefined value as GUI has no option for this setting
                                 erdas_compression = erdas, erdas_statistics = erdas_stat  
  endfor
  progress_bar2 -> Update, progress_curr 
  progress_bar2 -> Destroy

end

; When user presses Create mosaic button under Mosaic tab
pro user_widget_mosaic, event
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
  id_selection_panel = widget_info(event.top, find_by_uname='u_selection_panel')
  widget_control, id_selection_panel, get_value=panel_text
  in_delimiter = ';'
  panel_text = strtrim(strsplit(strjoin(panel_text, in_delimiter), in_delimiter, /extract),2) ; split possible multiple entries within same string
  n_files = n_elements(panel_text)

  (*p_wdgt_state).user_cancel = 3
  widget_control, event.top, /destroy

  ; Initate progress-bar display (withot cancel button), ...
  statText = 'Converting selected images.
  progress_bar2 = obj_new('progressbar', title='Relief Visualization Toolbox - Progress ...', text=statText, xsize=300, ysize=20, $
    nocancel=0)
  progress_bar2 -> Start
  ; ... define values to assist bthe display
  progress_step = 100. / n_files
  progress_curr = progress_step/2
  progress_bar2 -> Update, progress_curr

  nf = 0
  date = Systime(/Julian)
  Caldat, date, Month, Day, Year, Hour, Minute, Second
  IF month LT 10 THEN month = '0' + Strtrim(month,1) ELSE month = Strtrim(month,1)
  IF day LT 10 THEN day = '0' + Strtrim(day,1) ELSE day = Strtrim(day,1)
  IF Hour LT 10 THEN Hour = '0' + Strtrim(Hour,1) ELSE Hour = Strtrim(Hour,1)
  IF Minute LT 10 THEN Minute = '0' + Strtrim(Minute,1) ELSE Minute = Strtrim(Minute,1)
  IF Second LT 10 THEN Second = '0' + Strtrim(Round(Second),1) ELSE Second = Strtrim(Round(Second),1)
  date_time = Strtrim(Year,1) + '-' + month + '-' + day + '_' + hour + '-' + minute + '-' + second

  last_dot = strpos(panel_text[nF], '.' , /reverse_search)
  if last_dot eq -1 or (last_dot gt 0 and strlen(panel_text[nF])-last_dot ge 6) then out_file = panel_text[nF] $  ;input file has no extension or extensions is very long (>=6) e.q. there is no valid extension or dost is inside filename
  else out_file = strmid(panel_text[nF], 0, last_dot)
  out_file += '_process_log_' + date_time + '.txt'

  progress_bar2 -> Update, progress_curr
  progress_curr += progress_step
  topo_advanced_vis_raster_mosaic, panel_text, out_file

  progress_bar2 -> Update, progress_curr
  progress_bar2 -> Destroy

end

; When shadow modelling under Sky illumination is toggled
pro user_widget_toggle_shadow_model, event
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
  shadow_model_button_set = widget_info((*p_wdgt_state).skyilm_checkbox2, /button_set)
  
  if shadow_model_button_set then sens = 1 $
  else sens = 0
  widget_control, widget_info(event.top, find_by_uname='skyilm_az_entry'), sensitive=sens
  widget_control, widget_info(event.top, find_by_uname='skyilm_el_entry'), sensitive=sens
  widget_control, widget_info(event.top, find_by_uname='skyilm_az_text'), sensitive=sens
  widget_control, widget_info(event.top, find_by_uname='skyilm_el_text'), sensitive=sens
end

;=====================================================================================
; When user presses OK button ========================================================
pro user_widget_ok, event
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
  
  ; Input files, folders, lists ----------------
  id_selection_panel = widget_info(event.top, find_by_uname='u_selection_panel')
  widget_control, id_selection_panel, get_value=panel_text
  in_delimiter = ';'
  panel_text = strtrim(strsplit(strjoin(panel_text, in_delimiter), in_delimiter, /extract),2) ; split possible multiple entries within same string
  panel_text_string = strjoin(panel_text, '#')  ; concatenate all inputs into a single loooong string
  (*p_wdgt_state).selection_str = panel_text_string

  ; Vertical exaggeration ---
  widget_control, (*p_wdgt_state).ve_entry, get_value=ve 
  (*p_wdgt_state).ve = ve


  ; Hillshading ----------------
  hls_use = widget_info((*p_wdgt_state).hls_checkbox, /button_set) 
  (*p_wdgt_state).hls_use = hls_use

;  if hls_use then begin
    widget_control, (*p_wdgt_state).hls_az_entry, get_value=hls_az
    (*p_wdgt_state).hls_az = hls_az
    widget_control, (*p_wdgt_state).hls_el_entry, get_value=hls_el
    (*p_wdgt_state).hls_el = hls_el
    shadow_use = widget_info((*p_wdgt_state).shadow_checkbox, /button_set)
    (*p_wdgt_state).shadow_use = shadow_use    
;  endif
   
   
  ; Multiple hillshading ----------------
  mhls_use = widget_info((*p_wdgt_state).mhls_checkbox, /button_set) 
  (*p_wdgt_state).mhls_use = mhls_use

;  if mhls_use then begin
    mhls_nd_selected = widget_info((*p_wdgt_state).mhls_nd_entry, /combobox_gettext) ; /droplist_select)
;    if (strmid(mhls_nd_selected,5,6,/reverse_offset) eq ' (def)') then $
;             mhls_nd_selected = strmid(mhls_nd_selected,0,strlen(mhls_nd_selected-6)) 
    mhls_nd = fix(mhls_nd_selected)
    (*p_wdgt_state).mhls_nd = mhls_nd
    widget_control, (*p_wdgt_state).mhls_el_entry, get_value=mhls_el
    (*p_wdgt_state).mhls_el = mhls_el
;  endif
   
   
  ; PCA ----------------
  mhls_pca_use = widget_info((*p_wdgt_state).mhls_pca_checkbox, /button_set) 
  (*p_wdgt_state).mhls_pca_use = mhls_pca_use

;  if mhls_pca_use then begin
    widget_control, (*p_wdgt_state).mhls_pca_entry, get_value=mhls_pca_nc
    (*p_wdgt_state).mhls_pca_nc = mhls_pca_nc
;  endif
   
   
  ; Slope gradient ----------------
  slp_use = widget_info((*p_wdgt_state).slp_checkbox, /button_set) 
  (*p_wdgt_state).slp_use = slp_use
  
  
  ; Simple local relief model ----------------
  slrm_use = widget_info((*p_wdgt_state).slrm_checkbox, /button_set) 
  (*p_wdgt_state).slrm_use = slrm_use

;  if slrm_use then begin
    widget_control, (*p_wdgt_state).slrm_entry, get_value=slrm_dist
    (*p_wdgt_state).slrm_dist = slrm_dist
;  endif
   
   
  ; SVF ----------------
  svf_use = widget_info((*p_wdgt_state).svf_checkbox, /button_set) 
  (*p_wdgt_state).svf_use = svf_use
  
;  if svf_use then begin
    svf_nd_selected = widget_info((*p_wdgt_state).svf_nd_entry, /combobox_gettext) ; /droplist_select)
;    if (strmid(svf_nd_selected,5,6,/reverse_offset) eq ' (def)') then $
;             svf_nd_selected = strmid(svf_nd_selected,0,strlen(svf_nd_selected-6)) 
    svf_nd = fix(svf_nd_selected)
    (*p_wdgt_state).svf_nd = svf_nd
  
    widget_control, (*p_wdgt_state).svf_sr_entry, get_value=svf_sr
    (*p_wdgt_state).svf_sr = svf_sr
    
    svf_rn = widget_info((*p_wdgt_state).svf_rn_checkbox, /button_set)
    if svf_rn then begin  ;  if button is checked then read values 
      svf_rn_selected = widget_info((*p_wdgt_state).svf_rn_entry, /combobox_gettext) ; /droplist_select)
      case svf_rn_selected of
        'low': svf_rn = 1
        'medium': svf_rn = 2
        'high': svf_rn = 3
        else: svf_rn = -1 
      endcase
    endif
    (*p_wdgt_state).svf_rn = svf_rn
;  endif


  ; Anisotropic SVF ----------------
  asvf_use = widget_info((*p_wdgt_state).asvf_checkbox, /button_set) 
  (*p_wdgt_state).asvf_use = asvf_use

;  if asvf_use then begin  ;  if button is checked then read values 
    asvf_lv_selected = widget_info((*p_wdgt_state).asvf_lv_entry, /combobox_gettext) ; /droplist_select)
    case asvf_lv_selected of
      'low': asvf_lv = 1
      'high': asvf_lv = 2
      else: asvf_lv = -1 
    endcase
    (*p_wdgt_state).asvf_lv = asvf_lv
    widget_control, (*p_wdgt_state).asvf_dr_entry, get_value=asvf_dr
    (*p_wdgt_state).asvf_dr = asvf_dr
;  endif    

  ; Openness ----------------
  open_use = widget_info((*p_wdgt_state).open_checkbox, /button_set) 
  (*p_wdgt_state).open_use = open_use
  
  ; Negative openness ----------------
  open_neg_use = widget_info((*p_wdgt_state).open_neg_checkbox, /button_set)
  (*p_wdgt_state).open_neg_use = open_neg_use
  
  ; Sky illumination openness ----------------
  skyilm_use = widget_info((*p_wdgt_state).skyilm_checkbox, /button_set)
  (*p_wdgt_state).skyilm_use = skyilm_use
  skyilm_model = widget_info((*p_wdgt_state).skyilm_droplist_entry, /combobox_gettext) 
  (*p_wdgt_state).skyilm_model = skyilm_model
  skyilm_points = widget_info((*p_wdgt_state).skyilm_droplist2_entry, /combobox_gettext)
  (*p_wdgt_state).skyilm_points = skyilm_points
  skyilm_shadow_use = widget_info((*p_wdgt_state).skyilm_checkbox2, /button_set)
  (*p_wdgt_state).skyilm_shadow_use = skyilm_shadow_use
  skyilm_shadow_dist = widget_info((*p_wdgt_state).skyilm_droplist3_entry, /combobox_gettext)
  (*p_wdgt_state).skyilm_shadow_dist = skyilm_shadow_dist
  widget_control, (*p_wdgt_state).skyilm_az_entry, get_value=skyilm_az
  (*p_wdgt_state).skyilm_az = skyilm_az
  widget_control, (*p_wdgt_state).skyilm_el_entry, get_value=skyilm_el
  (*p_wdgt_state).skyilm_el = skyilm_el

  ; user 
  (*p_wdgt_state).user_cancel = 0
  ;widget_control, event.top, set_uvalue=wdgt_state  ; pass changes back to calling procedure
  widget_control, event.top, /destroy
end

; Called when user presses Add file(s) button
pro user_select_files, event
  in_filter = ['*.tif;*.tiff;*.img;*.bin;*.xyz;*.dat;*.txt;*.asc;*.jp2;*.bsq']
  dialog_title = 'Select one or more input files'
  in_fname = dialog_pickfile(title=dialog_title, filter=in_filter, /multiple_files, path = 'C:/')
  if n_elements(in_fname) gt 0 then panel_new_entry, in_fname, event
end

pro panel_new_entry, in_fname, event
  ;print, in_fname
  id_selection_panel = widget_info(event.top, find_by_uname='u_selection_panel')
  widget_control, id_selection_panel, get_value=panel_text
  in_delimiter = ';'
  panel_text = strtrim(strsplit(strjoin(panel_text, in_delimiter), in_delimiter, /extract),2) ; split possible multiple entries within same string
  panel_text = [panel_text, [in_fname]] ; add new entry
  if panel_text[0] eq '' then panel_text = panel_text[1:n_elements(panel_text)-1] ; remove first entry if it is blank
  widget_control, id_selection_panel, set_value=panel_text
  ;print, panel_text
end

; Called when user presses Remove all button
pro panel_remove_all, event
  id_selection_panel = widget_info(event.top, find_by_uname='u_selection_panel')
  widget_control, id_selection_panel, set_value=''
end

; In Converter display to user options, that are relevant only for the selected format  
pro enable_converter_settings, event
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
  format = widget_info((*p_wdgt_state).convert_dropdown, /combobox_gettext)
  
  d1 = widget_info(event.top, find_by_uname='tzw_label')
  d2 = widget_info(event.top, find_by_uname='tzw_checkbox')
  d3 = widget_info(event.top, find_by_uname='envi_label')
  d4 = widget_info(event.top, find_by_uname='convert_dropdown_envi')
  d5 = widget_info(event.top, find_by_uname='erdas_label')
  d6 = widget_info(event.top, find_by_uname='erdas_checkbox')
  d7 = widget_info(event.top, find_by_uname='erdas_stat_label')
  d8 = widget_info(event.top, find_by_uname='erdas_stat_checkbox')
  d9 = widget_info(event.top, find_by_uname='jp2000q_label')
  d10 = widget_info(event.top, find_by_uname='jp2000loss_checkbox')
  d11 = widget_info(event.top, find_by_uname='jp2000loss_label')
  d12 = widget_info(event.top, find_by_uname='jp2000q_text')
    
  case format of
    'GeoTIFF' : begin
                  widget_control, d1, sensitive=1
                  widget_control, d2, sensitive=1
                  widget_control, d3, sensitive=0
                  widget_control, d4, sensitive=0
                  widget_control, d5, sensitive=0
                  widget_control, d6, sensitive=0
                  widget_control, d7, sensitive=0
                  widget_control, d8, sensitive=0
                  widget_control, d9, sensitive=0
                  widget_control, d10, sensitive=0  
                  widget_control, d11, sensitive=0 
                  widget_control, d12, sensitive=0               
                end
    'ENVI':     begin
                  widget_control, d1, sensitive=0
                  widget_control, d2, sensitive=0
                  widget_control, d3, sensitive=1
                  widget_control, d4, sensitive=1
                  widget_control, d5, sensitive=0
                  widget_control, d7, sensitive=0
                  widget_control, d8, sensitive=0
                  widget_control, d9, sensitive=0
                  widget_control, d10, sensitive=0
                  widget_control, d11, sensitive=0
                  widget_control, d12, sensitive=0
                end
    'ERDAS':   begin
                  widget_control, d1, sensitive=0
                  widget_control, d2, sensitive=0
                  widget_control, d3, sensitive=0
                  widget_control, d4, sensitive=0
                  widget_control, d5, sensitive=1
                  widget_control, d6, sensitive=1
                  widget_control, d7, sensitive=1
                  widget_control, d8, sensitive=1
                  widget_control, d9, sensitive=0
                  widget_control, d10, sensitive=0
                  widget_control, d11, sensitive=0
                  widget_control, d12, sensitive=0
                end    
    'JP2000':   begin
                  widget_control, d1, sensitive=0
                  widget_control, d2, sensitive=0
                  widget_control, d3, sensitive=0
                  widget_control, d4, sensitive=0
                  widget_control, d5, sensitive=0
                  widget_control, d6, sensitive=0
                  widget_control, d7, sensitive=0
                  widget_control, d8, sensitive=0
                  widget_control, d9, sensitive=1
                  widget_control, d10, sensitive=1
                  widget_control, d11, sensitive=1
                  widget_control, d12, sensitive=1
                end            
    else:       begin
                  widget_control, d1, sensitive=0
                  widget_control, d2, sensitive=0
                  widget_control, d3, sensitive=0
                  widget_control, d4, sensitive=0
                  widget_control, d5, sensitive=0
                  widget_control, d6, sensitive=0
                  widget_control, d7, sensitive=0
                  widget_control, d8, sensitive=0
                  widget_control, d9, sensitive=0
                  widget_control, d10, sensitive=0
                  widget_control, d11, sensitive=0
                  widget_control, d12, sensitive=0
                end
  endcase

end

pro resize_event, event
  magic_y_size_number = 251   ;change this if you are changing GUI
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
  tab = widget_info(event.top, find_by_uname='base_tab_window')
  tab_all = widget_info(event.top, find_by_uname='base_tab_window_all')
  widget_control, tab, ysize = (event.y - magic_y_size_number) > 1
  widget_control, tab_all, ysize = (event.y  -magic_y_size_number) > 1
;  print, event.x, event.y
end

pro disable_last_row, event  
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
  tab = widget_info((*p_wdgt_state).base_tab, /tab_current)
  if tab gt 0 then begin
    buttons = widget_info(event.top, find_by_uname='buttons_last_raw')
    widget_control, buttons, scr_xsize = 0
  endif else begin
    buttons = widget_info(event.top, find_by_uname='buttons_last_raw')
    widget_control, buttons, scr_xsize = 600
  endelse
end

function test_tag, tag, tags
  return, total(tag eq tags)
end

pro save_to_sav, wdgt_struct, sav_path

  exaggeration_factor = wdgt_struct.ve
  
  hillshading = wdgt_struct.hls_use
  sun_azimuth = wdgt_struct.hls_az
  sun_elevation = wdgt_struct.hls_el
  shadow_modelling = wdgt_struct.shadow_use

  pca_hillshading = wdgt_struct.mhls_pca_use
  number_components = wdgt_struct.mhls_pca_nc

  multiple_hillshading = wdgt_struct.mhls_use
  hillshade_directions = wdgt_struct.mhls_nd

  slope_gradient = wdgt_struct.slp_use

  simple_local_relief = wdgt_struct.slrm_use
  trend_radius = wdgt_struct.slrm_dist

  sky_view_factor = wdgt_struct.svf_use
  svf_directions = wdgt_struct.svf_nd
  search_radius = wdgt_struct.svf_sr
  remove_noise = wdgt_struct.svf_rn_use
  noise_removal = (['low', 'medium', 'high'])[wdgt_struct.svf_rn-1]

  anisotropic_svf = wdgt_struct.asvf_use
  anisotropy_level = (['low', 'high'])[wdgt_struct.asvf_lv-1]
  anisotropy_direction = wdgt_struct.asvf_dr

  positive_openness = wdgt_struct.open_use

  negative_openness = wdgt_struct.open_neg_use

  sky_illumination = wdgt_struct.skyilm_use
  sky_model = wdgt_struct.skyilm_model
  number_points = wdgt_struct.skyilm_points
  max_shadow_dist = wdgt_struct.skyilm_shadow_dist
  
  save, exaggeration_factor,hillshading,sun_azimuth,sun_elevation,shadow_modelling,pca_hillshading,number_components,multiple_hillshading,hillshade_directions, $
        slope_gradient,simple_local_relief,trend_radius,sky_view_factor,svf_directions,search_radius,remove_noise,noise_removal, $
        anisotropic_svf,anisotropy_level,anisotropy_direction,positive_openness,negative_openness,sky_illumination,sky_model,number_points,max_shadow_dist, $
        description = '', filename = sav_path  
end


;=====================================================================================
;=====================================================================================
;=== Main program ====================================================================
;=====================================================================================

;+
; NAME:
;       topo_advanced_vis.pro    
;
; PURPOSE:
;       Relif Visualization Toolbox (RVT) performs 10 different types or subtypes of 
;       relief visualizations.
;       User interactively select one or several input DEM files, and selects up to 10 
;       different visualisation types and corresponsing parameters, outputs are given 
;       as files with different suffix.
;       
;       RVT performs also conversion into various output raster file formats.
;
; INPUTS:
;       One or several DEM(s) in the form GeoTIFF or TIF + TFW 
;       (TIF without geoinformation is also supported, however not optimal),
;       or any other GDAL supported file format
;       
; OUTPUTS:
;       GeoTIFF visualizations; filenames differ only in suffix.
;
; AUTHORS:
;       Klemen Zaksek
;       Ziga Kokalj
;       Kristof Ostir
;       Peter Pehani
;       Klemen Cotar (ver 1.1+)
;
; DEPENDENCIES:
;       modified version of ProgressBar__define.pro (by David W. Fanning; http://www.dfanning.com)
;       programrootdir.pro (by David W. Fanning; http://www.dfanning.com)
;
; MODIFICATION HISTORY:
;       1.0  November 2013: Initial release (9 visualisations of single input file).
;       1.1  September 2014: Added support for processing of multiple files. Added support for reading of different 
;                     file formats (any of GDAL supported fomats). Added support for conversion of  the input file 
;                     into the following output formats: GeoTIFF, ASCII gridded XYZ, Erdas Imagine file or ENVI file
;       1.2  October 2014: Added sky illumination visualization
;            August 2016: Added txt settings reader that enables program running without any GUI manipulatio. New re_run
;                         keyword that enables settings to be stored between consecutive sessions. 
;-

pro topo_advanced_vis, re_run=re_run

  compile_opt idl2
  
  ; Create string for software version and year of issue
  rvt_version = '1.2'
  rvt_issue_year = '2015'
  
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
  print, '------------------------------------------------------------------------------------------------------'
  print, 'Relief Visualization Toolbox (version ' + rvt_version + '); (c) ZRC SAZU, ' + rvt_issue_year
  print, '------------------------------------------------------------------------------------------------------'
  print
  
  ;=========================================================================================================
  ;=== Read program settings from settings file or sav file between sessions ===============================
  ;=========================================================================================================
  temp_sav = programrootdir()+'settings\temp_settings.sav'
  if keyword_set(re_run) and file_test(temp_sav) then begin
    restore, temp_sav
  endif else begin
    set_file = programrootdir()+'settings\default_settings.txt'
    if file_test(set_file) then input_settings = get_settings(set_file) $
    else input_settings = create_struct('none','none')
    settings_tags = strlowcase(tag_names(input_settings))
    
    if test_tag('exaggeration_factor', settings_tags) then exaggeration_factor = input_settings.exaggeration_factor $
    else exaggeration_factor = 1.0
    if test_tag('hillshading', settings_tags) then hillshading = input_settings.hillshading $
    else hillshading = 1
    if test_tag('sun_azimuth', settings_tags) then sun_azimuth = input_settings.sun_azimuth $
    else sun_azimuth = 315
    if test_tag('sun_elevation', settings_tags) then sun_elevation = input_settings.sun_elevation $
    else sun_elevation = 35
    if test_tag('shadow_modelling', settings_tags) then shadow_modelling = input_settings.shadow_modelling $
    else shadow_modelling = 0
  
    if test_tag('pca_hillshading', settings_tags) then pca_hillshading = input_settings.pca_hillshading $
    else pca_hillshading = 0
    if test_tag('number_components', settings_tags) then number_components = input_settings.number_components $
    else number_components = 3
    
    if test_tag('multiple_hillshading', settings_tags) then multiple_hillshading = input_settings.multiple_hillshading $
    else multiple_hillshading = 0
    if test_tag('hillshade_directions', settings_tags) then hillshade_directions = input_settings.hillshade_directions $
    else hillshade_directions = 16
    
    if test_tag('slope_gradient', settings_tags) then slope_gradient = input_settings.slope_gradient $
    else slope_gradient = 0
    
    if test_tag('simple_local_relief', settings_tags) then simple_local_relief = input_settings.simple_local_relief $
    else simple_local_relief = 0
    if test_tag('trend_radius', settings_tags) then trend_radius = input_settings.trend_radius $
    else trend_radius = 20
    
    if test_tag('sky_view_factor', settings_tags) then sky_view_factor = input_settings.sky_view_factor $
    else sky_view_factor = 1
    if test_tag('svf_directions', settings_tags) then svf_directions = input_settings.svf_directions $
    else svf_directions = 16
    if test_tag('search_radius', settings_tags) then search_radius = input_settings.search_radius $
    else search_radius = 10
    if test_tag('remove_noise', settings_tags) then remove_noise = input_settings.remove_noise $
    else remove_noise = 0
    if test_tag('noise_removal', settings_tags) then noise_removal = input_settings.noise_removal $
    else noise_removal = 'low'
    
    if test_tag('anisotropic_svf', settings_tags) then anisotropic_svf = input_settings.anisotropic_svf $
    else anisotropic_svf = 0
    if test_tag('anisotropy_level', settings_tags) then anisotropy_level = input_settings.anisotropy_level $
    else anisotropy_level = 'low'
    if test_tag('anisotropy_direction', settings_tags) then anisotropy_direction = input_settings.anisotropy_direction $
    else anisotropy_direction = 315
    
    if test_tag('positive_openness', settings_tags) then positive_openness = input_settings.positive_openness $
    else positive_openness = 0
    
    if test_tag('negative_openness', settings_tags) then negative_openness = input_settings.negative_openness $
    else negative_openness = 0
    
    if test_tag('sky_illumination', settings_tags) then sky_illumination = input_settings.sky_illumination $
    else sky_illumination = 0
    if test_tag('sky_model', settings_tags) then sky_model = input_settings.sky_model $
    else sky_model = 'overcast'
    if test_tag('number_points', settings_tags) then number_points = input_settings.number_points $
    else number_points = 250
    if test_tag('max_shadow_dist', settings_tags) then max_shadow_dist = input_settings.max_shadow_dist $
    else max_shadow_dist = 100
    
    process_file = programrootdir()+'settings\process_files.txt'
    if file_test(process_file) then begin
      n_lines = file_lines(process_file)
      if n_lines gt 0 then begin
        files_to_process = make_array(n_lines, /string)
        openr, txt_proc, process_file, /get_lun
        readf, txt_proc, files_to_process
        free_lun, txt_proc
        skip_gui = 1
      endif
    endif    
  endelse  
  
  ;=========================================================================================================
  ;=== Setup constnants that cannot be changed by the user =================================================
  ;=========================================================================================================

  ;Vertical exagerattion
  sc_ve_ex = [-20., 20.]
  
  ;Hillshading
  sc_hls_sun_a = [0., 360.]            ;solar azimuth angle in degrees
  sc_hls_sun_h = [0, 90.]              ;solar vertical elevation angle in degres
  
  ;Multiple hillshading
  sc_mhls_n_dir = [4,16,8,32,64,360]   ;number of directions; drop-down menu values: 16,8,32,64; editable!
  sc_mhls_n_dir = [0., 75.]            ;solar vertical elevation angle in degres
  sc_mhls_a_rgb = [315., 15., 75.]     ;azimuth for RGB components
  sc_mhls_n_psc = [3, 5]               ;number of principal componnents to save
  
  ;Simple local relief model
  sc_slrm_r_max = [10., 50.]           ;radius in pixels
  
  ;SVF
  sc_svf_n_dir = [4, 16, 8, 32, 360]   ;number of directions; drop-down menu values: 16,8,32; editable!
  sc_svf_r_max = [5., 100.]            ;maximal search radius
  sc_svf_r_min = [0., 10., 20., 40.]   ;minimal search radius as percent of max search radius
  sc_asvf_min = [0.4, 0.1]             ;minimal brightness of the sky for both models
  in_asvf_dir = [0., 360.]             ;main direction of anisotropy in degrees
  sc_asvf_pol = [4, 8]                 ;polynomial level (how fast decreases brightness from the brightes to the darkest point )
  ;anisotropy 0-low 1-high
  
  ;Conversion to byte - linear, with below defined borders
  sc_hls_ev = [0.00, 1.00]
  sc_svf_ev = [0.6375, 1.00]
  sc_opns_ev = [60, 95.]
  sc_slp_ev = [0., 51.]
  sc_slrm_ev = [-2., 2.]
  sc_skyilu_ev = [2.,0.5]   ;percent

  ;If input DEM is larger as the size below, do tiling
  sc_tile_size = 5L*10L^6

  
  ;=========================================================================================================
  ;=== Select input DEM and verify geotiff information =====================================================
  ;=========================================================================================================

;  in_filter = ['*.tif;*.tiff']
;  ;in_fname = 'e:\2projekti\IDL_SkyView\DEM\barje.tif'
;;  in_fname = 'e:\2projekti\IDL_SkyView\DEM\dem_k_conv.tif'
;  ;in_fname = 'D:\_arhiv\ZRC\2007\Sky\Kobarid\dmr4.tif'
;  ;in_fname = 'e:\2projekti\IDL_AlesPolinom\input_ikonos_orto3.tif'
;  in_path = 'd:\'
;  dialog_title = 'Relief Visualization Toolbox, ver. ' + rvt_version + ' - Select input DEM (*.TIF): '
;  in_fname = dialog_pickfile(title=dialog_title, filter=in_filter, path=in_path)
;  print, '# Metadata of the input file'
;  print, '     Input filename:    ', in_fname
;  if in_fname eq '' then return
;  
;  ; Open the file and read data
;  in_orientation = 1
;  in_rotation = 7
;  heights = read_tiff(in_fname, orientation=in_orientation, geotiff=in_geotiff)
;
;  ; Define number of bands
;  in_file_dims = size(heights, /dimensions)
;  in_nb = n_elements(in_file_dims) > 2 ? in_file_dims[2] : 1   
;  if (in_nb ne 1) then begin
;    print
;    print, 'Processing stopped! Only one band is allowed for DEM files.'
;    errMsg = dialog_message('Processing stopped! Only one band is allowed for DEM files.', /error, title='Error')
;    return
;  endif
;
;  ; Extract raster parameters
;  heights_min = min(heights)
;  heights_max = max(heights)
;
;  in_file_dims = size(heights, /dimensions)  ; due to rotation calculate again
;  nrows = in_file_dims[1]
;  ncols = in_file_dims[0]
;
;  in_geotiff_elements = n_elements(in_geotiff) 
;  if (in_geotiff_elements gt 0) then begin  ; in_geotiff defined
;    in_geotiff_tags = strlowcase(tag_names(in_geotiff))
;    tag_exists = where(in_geotiff_tags eq strlowcase('ModelPixelScaleTag'))
;    if (tag_exists[0] eq -1) then begin  ; tif without tag ModelPixelScaleTag
;      in_pixel_size = dblarr(2) & in_pixel_size[0] = 1d & in_pixel_size[1] = 1d
;      in_crs = 1
;    endif else begin 
;      in_pixel_size = in_geotiff.ModelPixelScaleTag
;    endelse
;    
;    tag_exists = where(in_geotiff_tags eq strlowcase('GTModelTypeGeoKey'))
;    if (tag_exists[0] gt -1) then begin ; geotiff with defined tag GTModelTypeGeoKey
;      ; possible tag values: 1=projected, 2=geographic lat/lon, 3=geocentric (X,Y,Z)
;      in_crs = in_geotiff.GTModelTypeGeoKey
;      in_crs = (in_pixel_size[1] gt 0.1) ? 1 : 2
;    endif else begin  ; tif file (with tfw), or geotiff without tag GTModelTypeGeoKey
;      ; distinction based on pixel size
;      in_crs = (in_pixel_size[1] gt 0.1) ? 1 : 2
;    endelse
;  
;  endif else begin  ; in_geotiff undefined
;    in_pixel_size = dblarr(2) & in_pixel_size[0] = 1d & in_pixel_size[1] = 1d
;    in_crs = 1
;  endelse
;  ve_degrees = (in_crs eq 2) ? 1 : 0  ; units Degrees or Meters 
;  
;  ; Output to IDL console
;  print, '     Number of columns: ', strtrim(ncols,2)
;  print, '     Number of rows:    ', strtrim(nrows,2)
;  print, '     Number of bands:   ', strtrim(in_nb,2)
;  if (in_crs eq 2) then begin  ; geographic coordinate system
;    print, format='("     Resolution (x, y): ", f0.6, ", ", f0.6)', $ 
;    in_pixel_size[0], in_pixel_size[1]
;    wtext_resolution = string(format='("     Resolution (x, y):   ", f0.6, ", ", f0.6)', $
;    in_pixel_size[0], in_pixel_size[1])
;  endif else begin   ; projected or geocentric coordinate system
;    print, format='("     Resolution (x, y): ", f0.1, ", ", f0.1)', $
;    in_pixel_size[0], in_pixel_size[1]
;    wtext_resolution = string(format='("     Resolution (x, y):   ", f0.1, ", ", f0.1)', $
;    in_pixel_size[0], in_pixel_size[1])
;  endelse
;  resolution = in_pixel_size[1]


  ;=========================================================================================================
  ;=== Widget to get user parameters =======================================================================
  ;=========================================================================================================

  base_title = 'Relief Visualization Toolbox, ver. ' + rvt_version + '; (c) ZRC SAZU, ' + rvt_issue_year
  base_main = widget_base(title=base_title, xoffset=100, yoffset=50, xsize=710, uname='base_main_window',$
                xpad=15, ypad=15, space=0, /column, tab_mode=1, /TLB_Size_Events)             
  
  ysize_row = 32
  xsize_frame_method_name = 195
  xsize_params = 440
  xsize_one_param = 200
  
  ; input file metadata
;  wtext = ['Input file:   ' + in_fname, $
;    'Size (cols, rows):   ' + strtrim(ncols,2) + ' x ' + strtrim(nrows,2), $
;    strmid(wtext_resolution,5,strlen(wtext_resolution)-5), $
;    string(format='("Data range (min, max):   ", f0.2, ", ", f0.2)', $
;    heights_min, heights_max)]


  ;about_row = widget_base(base_main, /row, /align_right)
  ;bt_about = widget_button(about_row, event_pro='user_widget_about', value='About', xoffset=330, yoffset=20, scr_xsize=65)


  main_row_0 = widget_base(base_main, /row)
  add_files_text = widget_label(main_row_0, value='List of currently selected input files: ')
  add_files_text = widget_label(main_row_0, value='                                                                                                                                               ')
  bt_about = widget_button(main_row_0, event_pro='user_widget_about', value='About', yoffset=20, scr_xsize=65)
  st = widget_text(base_main, /scroll, value=files_to_process, xsize=107, ysize=4, uname='u_selection_panel', /editable)
  main_row_1 = widget_base(base_main, /row)
  add_files_text = widget_label(main_row_1, value='Add file(s) to input list:  ')
  add_files_btn = widget_button(main_row_1, event_pro='user_select_files', value='Add file(s)', xoffset=5, yoffset=20, scr_xsize=70)
  add_files_btn = widget_button(main_row_1, event_pro='panel_remove_all', value='Remove all files', xoffset=5, yoffset=20, scr_xsize=100)
  
  
  empty_text_row = widget_label(base_main, value='  ', scr_ysize=10)
  base_tab = WIDGET_TAB(base_main, event_pro='disable_last_row', uname = 'base_tab_window')
  base_all = WIDGET_BASE(base_tab, TITLE='   Visualizations   ', /COLUMN, xsize=655, /scroll, uname = 'base_tab_window_all')
  
  ; exaggetarion factor
  ve_floor = sc_ve_ex[0]
  ve_ceil = sc_ve_ex[1]

  base_row_1 = widget_base(base_all, /row)
  ve_text = widget_label(base_row_1, value='Vertical exaggetarion factor (used in all methods) (min=-20., max=20.):  ')
  ve_entry = widget_text(base_row_1, uvalue='u_ve', scroll=0, value=string(exaggeration_factor, format='(F0.2)'), xsize=5, /editable)
 

  base_row_2 = widget_base(base_all, /row, ysize=ysize_row+10)
  ve_user_text = widget_label(base_row_2, value='Select visualization method(s) and corresponding parameter(s):  ')


  ; Widget for Analytical hillshading --------------------
  base_row_3 = widget_base(base_all, /row) ; , /frame)
  hls_namebox = widget_base(base_row_3, /row, /nonexclusive, xsize=xsize_frame_method_name, ysize=2*ysize_row)
  hls_checkbox = widget_button(hls_namebox, event_pro='user_widget_toggle_method_checkbox', $
                  value='Analytical hillshading', uname='u_hls_checkbox')
  ; in user menu by default this method is selected and sensitive=1
  widget_control, hls_checkbox, set_button=hillshading
  hls_params = widget_base(base_row_3, /column, sensitive=hillshading, xsize=xsize_params, ysize=2*ysize_row, /frame, $
                  uname='u_hls_params')


  hls_az_row = widget_base(hls_params, /row, xsize=xsize_one_param)
  hls_az_text = widget_label(hls_az_row, value='Sun azimuth [deg.]:  ')
  hls_az_entry = widget_text(hls_az_row, event_pro='user_widget_do_nothing', scroll=0, value=strtrim(sun_azimuth,2), xsize=4, /editable)
  hls_no_text = widget_label(hls_az_row, value='', xsize = 65)
  hls_el_text = widget_label(hls_az_row, value='Sun elevation angle [deg.]:  ')
  hls_el_entry = widget_text(hls_az_row, event_pro='user_widget_do_nothing', scroll=0, value=strtrim(sun_elevation,2), xsize=4, /editable)
  
  hls_row_2 = widget_base(hls_params, /row)
  shadow_namebox = widget_base(hls_row_2, /nonexclusive, /row, xsize=2*xsize_frame_method_name, ysize=ysize_row)
  shadow_checkbox = widget_button(shadow_namebox, event_pro='user_widget_toggle_shadow_model', $
    value='Shadow modelling (binary output image)', uname='shadow_checkbox')
  widget_control, shadow_checkbox, set_button=shadow_modelling


  ; Widget for Hillshading from multiple directions --------------------
  base_row_4 = widget_base(base_all, /row) ; , /frame)
  mhls_namebox = widget_base(base_row_4, /row, /nonexclusive, xsize=xsize_frame_method_name, ysize=ysize_row)
  mhls_checkbox = widget_button(mhls_namebox, event_pro='user_widget_toggle_mhls_checkbox', $ 
                  value='Hillshading from multiple directions', uname='u_mhls_checkbox')
  widget_control, mhls_checkbox, set_button=multiple_hillshading
  mhls_params = widget_base(base_row_4, /row, sensitive=multiple_hillshading, xsize=xsize_params, ysize=ysize_row, /frame, $
                  uname='u_mhls_params')

  ;mhls_nd_floor = 4
  ;mhls_nd_ceil = 360
  mhls_nd_droplist = strarr(4)
  mhls_nd_droplist[0] = strtrim(hillshade_directions,2)
  mhls_nd_droplist[1] = '8'
  mhls_nd_droplist[2] = '32'
  mhls_nd_droplist[3] = '64'
  mhls_nd_row = widget_base(mhls_params, /row, xsize=xsize_one_param)
  mhls_nd_text = widget_label(mhls_nd_row, value='Number of directions:  ')
  mhls_nd_entry = widget_combobox(mhls_nd_row, event_pro='user_widget_do_nothing', value=mhls_nd_droplist)

  mhls_el_row = widget_base(mhls_params, /row, xsize=xsize_one_param+50)
  mhls_el_text = widget_label(mhls_el_row, value='Sun elevation angle [deg.]:  ')
  mhls_el_entry = widget_text(mhls_el_row, event_pro='user_widget_do_nothing', scroll=0, value=strtrim(sun_elevation,2), xsize=4, /editable)


  ; Widget for PCA of hillshading --------------------
  base_row_5 = widget_base(base_all, /row) ; , /frame)
  mhls_pca_namebox = widget_base(base_row_5, /row, /nonexclusive, xsize=xsize_frame_method_name, ysize=ysize_row)
  mhls_pca_checkbox = widget_button(mhls_pca_namebox, event_pro='user_widget_toggle_mhls_pca_checkbox', $
                 value='PCA of hillshading', uname='u_mhls_pca_checkbox')
  widget_control, mhls_pca_checkbox, set_button=pca_hillshading
  mhls_pca_params = widget_base(base_row_5, /row, sensitive=pca_hillshading, xsize=xsize_params, ysize=ysize_row, /frame, $
                 uname='u_mhls_pca_params')

  mhls_pca_row = widget_base(mhls_pca_params, /row, xsize=xsize_one_param+20)
  mhls_pca_text = widget_label(mhls_pca_row, value='Number of components to save:  ')
  mhls_pca_entry = widget_text(mhls_pca_row, event_pro='user_widget_do_nothing', scroll=0, value=strtrim(number_components,2), xsize=3, /editable)
  mhls_pca_text_2 = widget_label(mhls_pca_params, value='Set other parameters in the box above.')


  ; Widget for Slope gradient --------------------
  base_row_6 = widget_base(base_all, /row) ; , /frame)
  slp_namebox = widget_base(base_row_6, /row, /nonexclusive, xsize=xsize_frame_method_name, ysize=ysize_row)
  slp_checkbox = widget_button(slp_namebox, event_pro='user_widget_toggle_method_checkbox', $
                  value='Slope gradient', uname='u_slp_checkbox')
  widget_control, slp_checkbox, set_button=slope_gradient
  slp_params = widget_base(base_row_6, /row, sensitive=slope_gradient, xsize=xsize_params, ysize=ysize_row, /frame, $
                  uname='u_slp_params')
  slp_text = widget_label(slp_params, value=' No parameters required.')


  ; Widget for Simple local relief model --------------------
  base_row_7 = widget_base(base_all, /row) ; , /frame)
  slrm_namebox = widget_base(base_row_7, /row, /nonexclusive, xsize=xsize_frame_method_name, ysize=ysize_row)
  slrm_checkbox = widget_button(slrm_namebox, event_pro='user_widget_toggle_method_checkbox', $
                   value='Simple local relief model', uname='u_slrm_checkbox')
  widget_control, slrm_checkbox, set_button=simple_local_relief
  slrm_params = widget_base(base_row_7, /row, sensitive=simple_local_relief, xsize=xsize_params, ysize=ysize_row, /frame, $
                  uname='u_slrm_params')

;  slrm_floor = 1 ; ??
;  slrm_ceil = round((nrows>ncols)/3) ; ??
  slrm_row = widget_base(slrm_params, /row)
  slrm_text = widget_label(slrm_row, value='Radius for trend assessment [pixels]:  ')
  slrm_entry = widget_text(slrm_row, event_pro='user_widget_do_nothing', scroll=0, value=strtrim(trend_radius,2), xsize=5, /editable)



  ; Widget for Sky-View Factor --------------------
  base_row_8 = widget_base(base_all, /row) ;, /frame)
  svf_namebox = widget_base(base_row_8, /row, /nonexclusive, xsize=xsize_frame_method_name)
  svf_checkbox = widget_button(svf_namebox, event_pro='user_widget_toggle_svf_checkbox', $
                  value='Sky-View Factor', uname='u_svf_checkbox')
  ; in user menu by default this method is selected and sensitive=1
  widget_control, svf_checkbox, set_button=sky_view_factor
  svf_params = widget_base(base_row_8, /row, sensitive=sky_view_factor, xsize=xsize_params, /frame, $
                  uname='u_svf_params')

  svf_params_column_1 = widget_base(svf_params, /column, xsize=xsize_one_param+50)

  ;svf_nd_floor = 4
  ;svf_nd_ceil = 360
  svf_nd_droplist = strarr(3)
  svf_nd_droplist[0] = strtrim(svf_directions,2)
  svf_nd_droplist[1] = '8'
  svf_nd_droplist[2] = '32'
  svf_nd_row = widget_base(svf_params_column_1, /row, xsize=xsize_one_param+50)
  svf_nd_text = widget_label(svf_nd_row, value='Number of search directions:  ')
  svf_nd_entry = widget_combobox(svf_nd_row, event_pro='user_widget_do_nothing', value=svf_nd_droplist)

  svf_sr_floor = 1
  ;svf_sr_ceil = round((nrows>ncols)/3)
  svf_sr_row = widget_base(svf_params_column_1, /row, xsize=xsize_one_param+50)
  svf_sr_text = widget_label(svf_sr_row, value='Search radius [pixels]:  ')
  svf_sr_entry = widget_text(svf_sr_row, event_pro='user_widget_do_nothing', scroll=0, value=strtrim(search_radius,2), xsize=5, /editable)

  svf_rn_droplist = strarr(3)
  svf_rn_droplist[0] = noise_removal
  svf_rn_droplist[1] = 'medium'
  svf_rn_droplist[2] = 'high'
  svf_rn_base = widget_base(svf_params, /column, xsize=xsize_one_param)
  svf_rn_nonexclusive = widget_base(svf_rn_base, /row, /nonexclusive)
  svf_rn_checkbox = widget_button(svf_rn_nonexclusive, event_pro='user_widget_toggle_method_checkbox', value='Remove noise')
  widget_control, svf_rn_checkbox, set_button=remove_noise
  svf_rn_row = widget_base(svf_rn_base, /row, sensitive=remove_noise)
  svf_rn_text = widget_label(svf_rn_row, value='level of noise removal:  ')
  svf_rn_entry = widget_combobox(svf_rn_row, event_pro='user_widget_do_nothing', value=svf_rn_droplist)

  ; ... and Anisotropic Sky-View Factor --------------------
  base_row_8_an = widget_base(base_all, /row) ;, /frame)
  asvf_namebox = widget_base(base_row_8_an, /row, /nonexclusive, xsize=xsize_frame_method_name, ysize=ysize_row)
  asvf_checkbox = widget_button(asvf_namebox, event_pro='user_widget_toggle_asvf_checkbox', $
                   value='Anisotropic Sky-View Factor', uname='u_asvf_checkbox')
  widget_control, asvf_checkbox, set_button=anisotropic_svf
  asvf_params = widget_base(base_row_8_an, /column, sensitive=anisotropic_svf, xsize=xsize_params, /frame, $
                   uname='u_asvf_params')

  asvf_row_1 = widget_base(asvf_params, /row, xsize=xsize_params)
  asvf_droplist = strarr(2)
  asvf_droplist[0] = anisotropy_level
  asvf_droplist[1] = 'high'
  asvf_lv_row = widget_base(asvf_row_1, /row, xsize=xsize_one_param)
  asvf_lv_text = widget_label(asvf_lv_row, value='Level of anisotropy:  ')
  asvf_lv_entry = widget_combobox(asvf_lv_row, event_pro='user_widget_do_nothing', value=asvf_droplist)

  asvf_dr_row = widget_base(asvf_row_1, /row)
  asvf_dr_text = widget_label(asvf_dr_row, value='Main direction of anisotropy [deg.]:  ')
  asvf_dr_entry = widget_text(asvf_dr_row, event_pro='user_widget_do_nothing', scroll=0, value=strtrim(anisotropy_direction,2), xsize=4, /editable)

  asvf_row_2 = widget_base(asvf_params, /row)
  asvf_text_row = widget_base(asvf_row_2)
  asvf_text = widget_label(asvf_text_row, value='Set other parameters in the box of the Sky-View Factor method (above).')


  ; Widget for Openness --------------------
  base_row_9 = widget_base(base_all, /row) ;, /frame)
  open_namebox = widget_base(base_row_9, /row, /nonexclusive, xsize=xsize_frame_method_name, ysize=ysize_row)
  open_checkbox = widget_button(open_namebox, event_pro='user_widget_toggle_open_checkbox', $
                   value='Openness - Positive', uname='u_open_checkbox')
  widget_control, open_checkbox, set_button=positive_openness
  open_params = widget_base(base_row_9, /row, sensitive=positive_openness, xsize=xsize_params, ysize=ysize_row, /frame, $
                   uname='u_open_params')
  open_text = widget_label(open_params, value=' Set parameters in the box of the Sky-View Factor method (above).')

;  open_neg_nonexclusive = widget_base(open_params, /row, /nonexclusive, xsize=xsize_one_param)
;  open_neg_checkbox = widget_button(open_neg_nonexclusive, event_pro='user_widget_do_nothing', value='Negative openness')

  ; ... and Negative Openness
  base_row_9_neg = widget_base(base_all, /row) ;, /frame)
  open_neg_namebox = widget_base(base_row_9_neg, /row, /nonexclusive, xsize=xsize_frame_method_name, ysize=ysize_row)
  open_neg_checkbox = widget_button(open_neg_namebox, event_pro='user_widget_toggle_open_neg_checkbox', $
                       value='Openness - Negative', uname='u_open_neg_checkbox')
  widget_control, open_neg_checkbox, set_button=negative_openness
  open_neg_params = widget_base(base_row_9_neg, /row, sensitive=negative_openness, xsize=xsize_params, ysize=ysize_row, /frame, $
                      uname='u_open_neg_params')
  open_neg_text = widget_label(open_neg_params, value=' Set parameters in the box of the Sky-View Factor method (above).')
  
  ; Sky illumination .......... 
  base_row_10 = widget_base(base_all, /row, ysize=2*ysize_row+10) ; , /frame)
  skyilm_namebox = widget_base(base_row_10, /row, /nonexclusive, xsize=xsize_frame_method_name, ysize=ysize_row)
  skyilm_checkbox = widget_button(skyilm_namebox, event_pro='user_widget_toggle_method_checkbox', $
    value='Sky illumination', uname='u_skyilm_checkbox')
  widget_control, skyilm_checkbox, set_button=sky_illumination                                           
  skyilm_params = widget_base(base_row_10, /column, sensitive=sky_illumination, xsize=xsize_params, /frame, $
    uname='u_skyilm_params')
    
  skyilm_row_1 = widget_base(skyilm_params, /row)  
  skyilm_droplist = strarr(2)
  skyilm_droplist[0] = sky_model
  skyilm_droplist[1] = 'uniform'
  skyilm_droplist_text = widget_label(skyilm_row_1, value='Sky model:     ')
  skyilm_droplist_entry = widget_combobox(skyilm_row_1, event_pro='user_widget_do_nothing', value=skyilm_droplist)
  
  skyilm_droplist2 = strarr(2)
  skyilm_droplist2[0] = strtrim(number_points,2)
  skyilm_droplist2[1] = '500'
  skyilm_droplist2_text = widget_label(skyilm_row_1, value='            Number of sampling points:  ')
  skyilm_droplist2_entry = widget_combobox(skyilm_row_1, event_pro='user_widget_do_nothing', value=skyilm_droplist2)
  
  skyilm_row_4 = widget_base(skyilm_params, /row)
  skyilm_droplist3 = strarr(4)
  skyilm_droplist3[0] = strtrim(max_shadow_dist,2)
  skyilm_droplist3[1] = '50'
  skyilm_droplist3[2] = '500'
  skyilm_droplist3[3] = 'unlimited'
  skyilm_droplist3_text = widget_label(skyilm_row_4, value='Max. shadow modelling distance [pixels]:      ')
  skyilm_droplist3_entry = widget_combobox(skyilm_row_4, event_pro='user_widget_do_nothing', value=skyilm_droplist3, /editable)
  
  skyilm_row_2 = widget_base(skyilm_params, /row)
  skyilm_namebox2 = widget_base(skyilm_row_2, /row, /nonexclusive, xsize=xsize_frame_method_name, ysize=ysize_row)
  skyilm_checkbox2 = widget_button(skyilm_namebox2, event_pro='user_widget_toggle_shadow_model', $
    value='Shadow modelling', uname='u_skyilm_checkbox2')
  widget_control, skyilm_checkbox2, set_button=0
   
  skyilm_row_3 = widget_base(skyilm_params, /row) 
  skyilm_az_text = widget_label(skyilm_row_3, value='Sun azimuth [deg.]:  ', uname='skyilm_az_text')
  skyilm_az_entry = widget_text(skyilm_row_3, event_pro='user_widget_do_nothing', scroll=0, value='135', xsize=4, /editable, uname='skyilm_az_entry')  
  
  skyilm_el_text = widget_label(skyilm_row_3, value='             Sun elevation angle [deg.]:  ', uname='skyilm_el_text')
  skyilm_el_entry = widget_text(skyilm_row_3, event_pro='user_widget_do_nothing', scroll=0, value='45', xsize=4, /editable, uname='skyilm_el_entry')


  ; Buttons --------------------
  bt_row = widget_base(base_main, /align_left, uname='buttons_last_raw', scr_ysize = 45, scr_xsize=600)
  bt_all = widget_button(bt_row, event_pro='user_widget_all', value='Select all', xoffset=5, yoffset=20, scr_xsize=65)
  bt_none = widget_button(bt_row, event_pro='user_widget_none', value='Select none', xoffset=85, yoffset=20, scr_xsize=65)
  bt_ok = widget_button(bt_row, event_pro='user_widget_ok', value='Start', xoffset=330, yoffset=20, scr_xsize=65)
  bt_cancel = widget_button(bt_row, event_pro='user_widget_cancel', value='Cancel', xoffset=430, yoffset=20, scr_xsize=65)
;  tole je varianta z le dvema gumboma Start in Cancel
;  bt_row = widget_base(base_all, /align_center)
;  bt_ok = widget_button(bt_row, event_pro='user_widget_ok', value='Start', xoffset=0, yoffset=20, scr_xsize=60)
;  bt_cancel = widget_button(bt_row, event_pro='user_widget_cancel', value='Cancel', xoffset=100, yoffset=20, scr_xsize=60)


  ; Converter tab --------------------
  base_convert = WIDGET_BASE(base_tab, TITLE='   Converter   ', /COLUMN)
  convert_row_0 = widget_label(base_convert, value='  ', scr_ysize=30)
  convert_row_1 = widget_base(base_convert, /row)
  convert_text = widget_label(convert_row_1, value='Convert input file(s) to:            ')
  convert_droplist = strarr(5)
  convert_droplist[0] = 'GeoTIFF'
  convert_droplist[1] = 'ENVI'
  convert_droplist[2] = 'ERDAS'
  convert_droplist[3] = 'ASCII gridded XYZ'
  convert_droplist[4] = 'JP2000'
;  convert_droplist[5] = 'JPG'
  convert_dropdown = widget_combobox(convert_row_1, event_pro = 'enable_converter_settings', value = convert_droplist)
  
  convert_row_1_2 = widget_label(base_convert, value='  ', scr_ysize=15)
  
  convert_row_2 = widget_base(base_convert, /row)  
  convert_text2 = widget_label(convert_row_2, value='Additional format specific settings:')
  base_convert_frame = WIDGET_BASE(base_convert, /column, /frame)
  
  convert_row_frame_1 = widget_base(base_convert_frame, /row)
  tzw_label = widget_label(convert_row_frame_1, value='TIFF compression:             ', uname = 'tzw_label')
  tzw_namebox = widget_base(convert_row_frame_1, /nonexclusive, ysize=ysize_row)
  tzw_checkbox = widget_button(tzw_namebox, event_pro='user_widget_do_nothing', $
      value='Enable LZW', uname = 'tzw_checkbox')
  widget_control, tzw_checkbox, set_button=1
  
  convert_row_frame_2 = widget_base(base_convert_frame, /row)
  envi_label = widget_label(convert_row_frame_2, value='ENVI interleave:                 ', sensitive=0, uname = 'envi_label')
  convert_droplist2 = strarr(3)
  convert_droplist2[0] = 'BSQ'
  convert_droplist2[1] = 'BIP'
  convert_droplist2[2] = 'BIL'
  convert_dropdown_envi = widget_combobox(convert_row_frame_2, event_pro = 'user_widget_do_nothing', value = convert_droplist2, sensitive=0, uname = 'convert_dropdown_envi')
  
  convert_row_frame_3 = widget_base(base_convert_frame, /row)
  jp2000q_label = widget_label(convert_row_frame_3, value='JP2000 quality [%]:             ', sensitive=0, uname = 'jp2000q_label')
  jp2000q_text = widget_text(convert_row_frame_3, event_pro='user_widget_do_nothing', scroll=0, value='25', xsize=4, sensitive=0, uname = 'jp2000q_text', /editable)
  
  convert_row_frame_4 = widget_base(base_convert_frame, /row)
  jp2000loss_label = widget_label(convert_row_frame_4, value='JP2000 compression:        ', sensitive=0, uname = 'jp2000loss_label')
  jp2000loss_namebox = widget_base(convert_row_frame_4, /nonexclusive, ysize=ysize_row)
  jp2000loss_checkbox = widget_button(jp2000loss_namebox, event_pro='user_widget_do_nothing', $
      value='Enable lossless compression', sensitive=0, uname = 'jp2000loss_checkbox')
  widget_control, tzw_checkbox, set_button=0
  
;  convert_row_frame_5 = widget_base(base_convert_frame, /row)
;  jpgq_label = widget_label(convert_row_frame_5, value='JPG quality [%]:                  ', sensitive=0, uname = 'jpgq_label')
;  jpgq_text = widget_text(convert_row_frame_5, event_pro='user_widget_do_nothing', scroll=0, value='80', xsize=4, sensitive=0, uname = 'jpgq_text', /editable)

  convert_row_frame_6 = widget_base(base_convert_frame, /row)
  erdas_stat_label = widget_label(convert_row_frame_6, value='ERDAS statistics:              ', uname = 'erdas_stat_label', sensitive=0)
  erdas_stat_namebox = widget_base(convert_row_frame_6, /nonexclusive, ysize=ysize_row)
  erdas_stat_checkbox = widget_button(erdas_stat_namebox, event_pro='user_widget_do_nothing', $
    value='Generate statistics and a histogram', uname = 'erdas_stat_checkbox' , sensitive=0)
  widget_control, erdas_stat_checkbox, set_button=1

  convert_row_frame_7 = widget_base(base_convert_frame, /row)
  erdas_label = widget_label(convert_row_frame_7, value='ERDAS compression:        ', uname = 'erdas_label', sensitive=0)
  erdas_namebox = widget_base(convert_row_frame_7, /nonexclusive, ysize=ysize_row)
  erdas_checkbox = widget_button(erdas_namebox, event_pro='user_widget_do_nothing', $
    value='Enable', uname = 'erdas_checkbox' , sensitive=0)
  widget_control, erdas_checkbox, set_button=0
  
  bt_row2 = widget_base(base_convert, /align_left)
  ;bt_all2 = widget_button(bt_row, event_pro='user_widget_all', value='Select all', xoffset=5, yoffset=20, scr_xsize=65)
  ;bt_none2 = widget_button(bt_row, event_pro='user_widget_none', value='Select none', xoffset=85, yoffset=20, scr_xsize=65)
  bt_ok2 = widget_button(bt_row2, event_pro='user_widget_convert', value='Convert', xoffset=330, yoffset=20, scr_xsize=65)
  bt_cancel2 = widget_button(bt_row2, event_pro='user_widget_cancel', value='Cancel', xoffset=430, yoffset=20, scr_xsize=65)
  
  ; Mosaic tab --------------------
  base_mosaic = WIDGET_BASE(base_tab, TITLE='   Mosaic   ', /COLUMN)
  mosaic_row_0 = widget_label(base_mosaic, value='  ', scr_ysize=30)
  mosaic_row_1 = widget_base(base_mosaic, /align_left)
  bt_mosaic_ok = widget_button(mosaic_row_1, event_pro='user_widget_mosaic', value='Create mosaic', xoffset= 20, yoffset=20, scr_xsize=120)
  bt_mosaic_cancel = widget_button(mosaic_row_1, event_pro='user_widget_cancel', value='Cancel', xoffset= 160, yoffset=20, scr_xsize=65)

  ; Realize user widget ===========================
  ve = 1.0

  hls_use = 0       ; Hillshading 
  hls_az = 0
  hls_el = 0
  shadow_use = 0

  mhls_use = 0       ; Multiple hillshading 
  mhls_nd = 4
  mhls_el = 0
  mhls_pca_use = 0   ; PCA
  mhls_pca_nc = 0  

  slp_use = 0       ; Slope gradient

  slrm_use = 0      ; Simple local relief model
  slrm_dist = 10

  svf_use = 0       ; SVF 
  svf_nd = 4
  svf_sr = 5
  svf_rn_use = 0
  svf_rn = 0  
  asvf_use = 0      ; Anisotropic SVF
  asvf_lv = 0
  asvf_dr = 0
  open_use = 0      ; Openness 
  open_neg_use = 0  ; Negative openness
  
  skyilm_use = 0    ;Sky illumination
  skyilm_shadow_use = 0
  skyilm_shadow_dist = ''
  skyilm_model = ''
  skyilm_points = ''
  skyilm_az = 0
  skyilm_el = 0

  user_cancel = 0   ; user
  
  selection_str = ''; Input files
  
  
  ; Create a pointer to annonymous structure, containing state of widgets
  ;wdgt_state = {svf_nd_entry:svf_nd_entry, svf_sr_entry:svf_sr_entry, ve_entry:ve_entry, nd:nd, sr:sr, ve:ve, user_cancel:user_cancel} 
  p_wdgt_state = ptr_new({rvt_vers:rvt_version, rvt_year:rvt_issue_year,  $    ; Version of RVT and year of issue 
                        ve_entry:ve_entry, ve:ve, $   
                        base_tab:base_tab, $                         ; Vertical exagg.
                        hls_checkbox:hls_checkbox, hls_use:hls_use, shadow_checkbox:shadow_checkbox, shadow_use:shadow_use, $          ; Hillshading
                             hls_az_entry:hls_az_entry, hls_az:hls_az, $
                             hls_el_entry:hls_el_entry, hls_el:hls_el, $
                        mhls_checkbox:mhls_checkbox, mhls_use:mhls_use, $      ; Multiple hillshading
                             mhls_nd_entry:mhls_nd_entry, mhls_nd:mhls_nd, $
                             mhls_el_entry:mhls_el_entry, mhls_el:mhls_el, $
                             mhls_pca_checkbox:mhls_pca_checkbox, mhls_pca_use:mhls_pca_use, $  ; PCA
                             mhls_pca_entry:mhls_pca_entry, mhls_pca_nc:mhls_pca_nc, $
                        slp_checkbox:slp_checkbox, slp_use:slp_use, $          ; Slope gradient
                        slrm_checkbox:slrm_checkbox, slrm_use:slrm_use, $      ; Simple local relief model
                             slrm_entry:slrm_entry, slrm_dist:slrm_dist, $
                        svf_checkbox:svf_checkbox, svf_use:svf_use, $          ; SVF
                             svf_nd_entry:svf_nd_entry, svf_nd:svf_nd, $
                             svf_sr_entry:svf_sr_entry, svf_sr:svf_sr, $
                             svf_rn_checkbox:svf_rn_checkbox, svf_rn_use:svf_rn_use, $
                             svf_rn_entry:svf_rn_entry, svf_rn:svf_rn, $
                        asvf_checkbox:asvf_checkbox, asvf_use:asvf_use, $      ; Anisotropic SVF
                             asvf_lv_entry:asvf_lv_entry, asvf_lv:asvf_lv, $ 
                             asvf_dr_entry:asvf_dr_entry, asvf_dr:asvf_dr, $ 
                        open_checkbox:open_checkbox, open_use:open_use, $      ; Openness
                        open_neg_checkbox:open_neg_checkbox, open_neg_use:open_neg_use, $  ; Negative openness
                        user_cancel:user_cancel, convert_dropdown:convert_dropdown, selection_str:selection_str,$
                        convert_dropdown_envi:convert_dropdown_envi,tzw_checkbox:tzw_checkbox,erdas_checkbox:erdas_checkbox,$
                        erdas_stat_checkbox:erdas_stat_checkbox,$
                        skyilm_checkbox:skyilm_checkbox, skyilm_checkbox2:skyilm_checkbox2, skyilm_use:skyilm_use, skyilm_shadow_use:skyilm_shadow_use, skyilm_shadow_dist:skyilm_shadow_dist, $  ;Sky illumination
                            skyilm_model:skyilm_model, skyilm_points:skyilm_points, skyilm_az:skyilm_az, skyilm_el:skyilm_el,$
                            skyilm_droplist_entry:skyilm_droplist_entry, skyilm_droplist2_entry:skyilm_droplist2_entry, skyilm_droplist3_entry:skyilm_droplist3_entry,$
                            skyilm_az_entry:skyilm_az_entry, skyilm_el_entry:skyilm_el_entry, jp2000loss_checkbox:jp2000loss_checkbox, jp2000q_text:jp2000q_text}, /no_copy)  ; data stored in heap only
;                        jpgq_text:jpgq_text

  ;skip GUI creation if user specied any files in process_files text file
  widget_control, base_main, set_uvalue=p_wdgt_state    
  if keyword_set(skip_gui) then user_widget_ok, create_struct('TOP', base_main) $
  else begin
    widget_control, base_main, /realize     ; create the widget
    xmanager, 'resize', base_main ; wait for the events
  endelse
;  xmanager, 'rvt_sa_v1', base_main    ; wait for the events
  
  ; Get the user values and free the pointer
  wdgt_state = *p_wdgt_state
  ptr_free, p_wdgt_state
  
  ; Continue after event handler: restore user inputs  ==========================
;  restore, 'skyview_tmp.sav'   ;  restores from C:\Documents and Settings\UserName\
;  file_delete, 'skyview_tmp.sav', /allow_nonexistent
  if wdgt_state.user_cancel eq 3 then topo_advanced_vis  ;user_cancel state from converter
  if wdgt_state.user_cancel then begin
    return
    file_delete, temp_sav, /allow_nonexistent, /quiet
  endif
  
  ;=========================================================================================================
  ;=== Save settings to temporary .sav file ================================================================
  ;=========================================================================================================
  save_to_sav, wdgt_state, temp_sav

  ;=========================================================================================================
  ;=== Initialize input parameters by user-selected values =================================================
  ;=========================================================================================================
  
  ;Initialize input parameters by user-selected values

  ;Vertical exaggeration
  in_ve_ex = float(wdgt_state.ve)                   ;-10. to 10.

  ;Hillshading
  in_hls = byte(wdgt_state.hls_use)                 ;1-run, 0-don't run
  in_hls_sun_a = float(wdgt_state.hls_az)           ;solar azimuth angle in degrees
  in_hls_sun_h = float(wdgt_state.hls_el)           ;solar vertical elevation angle in degres
  shadow_use = byte(wdgt_state.shadow_use)  

  ;Multiple hillshading + PCA
  in_mhls = byte(wdgt_state.mhls_use)               ;1-run, 0-don't run
  in_mhls_n_dir = fix(wdgt_state.mhls_nd)           ;number of directions
  in_mhls_sun_h = float(wdgt_state.mhls_el)         ;solar vertical elevation angle in degres
  ;in_mhls_rgb = 1                                   ;1-make multiple hillshaing RGB, 0-don't
  in_mhls_pca = byte(wdgt_state.mhls_pca_use)       ;1-run PCA hillshading, 0-don't run
  in_mhls_n_psc = fix(wdgt_state.mhls_pca_nc)       ;number of principal componnents to save

  ;Slope gradient
  in_slp = byte(wdgt_state.slp_use)                 ;1-run, 0-don't run

  ;Simple local relief model
  in_slrm = byte(wdgt_state.slrm_use)               ;1-run, 0-don't run
  in_slrm_r_max = float(wdgt_state.slrm_dist)       ;radius in pixels

  ;SVF + Openness + Negative openness
  in_svf = byte(wdgt_state.svf_use)                 ;1-run, 0-don't run
  in_svf_n_dir = fix(wdgt_state.svf_nd)             ;number of directions
  in_svf_r_max = float(wdgt_state.svf_sr)           ;maximal search radius
  in_svf_noise = fix(wdgt_state.svf_rn)             ;level of noise to remove (0- no removal, 1-low, 2-medium, 3-high)
  in_asvf = byte(wdgt_state.asvf_use)               ;1-run anisotropic SVF, 0-don't run
  in_asvf_level = fix(wdgt_state.asvf_lv)           ;0-low level (2, 0.5), 1-high level (5, 0.2)
  in_asvf_dir = float(wdgt_state.asvf_dr)           ;main direction of anisotropy in degrees
  in_open = byte(wdgt_state.open_use)               ;1-run openess, 0-don't run
  in_open_negative = fix(wdgt_state.open_neg_use)   ;1-compute negative openess, 0-positive
  
  ;Sky illumination
  in_skyilm = byte(wdgt_state.skyilm_use) 
  in_skyilm_shadow = byte(wdgt_state.skyilm_shadow_use) 
  in_skyilm_model = wdgt_state.skyilm_model
  in_skyilm_points = wdgt_state.skyilm_points
  in_skyilm_shadow_dist = wdgt_state.skyilm_shadow_dist
  in_skyilm_az = float(wdgt_state.skyilm_az)
  in_skyilm_el = float(wdgt_state.skyilm_el) 
  

  ;Get file names stored inside selection panel on top of the GUI
  ;id_selection_panel = widget_info(base_main, find_by_uname='u_selection_panel')
  in_file_string = wdgt_state.selection_str
  if (in_file_string eq '') then begin 
    print
    print, '# WARNING: No input files selected. Processing stopped!'
    return
  endif
  in_file_list = strsplit(in_file_string, '#', /extract)
  n_files = n_elements(in_file_list)
  
  ; Initate progress-bar display (withot cancel button), ...
  statText = 'Generating selected visualizations from selected input files.
  progress_bar = obj_new('progressbar', title='Relief Visualization Toolbox - Progress ...', text=statText, xsize=300, ysize=20, $
    nocancel=1)
  progress_bar -> Start
  ; ... define values to assist the display
  progress_total = in_hls + in_mhls + in_mhls_pca + in_slp + in_slrm + in_svf + in_open + in_asvf + in_open_negative + in_skyilm ; number of selected procedures
  progress_step = 100. / progress_total /n_files
  progress_step_image = 100. /n_files
  progress_curr = progress_step / 2
  ; ... and display progress
  ;  ; since prograss-bar has no cancel button, this lines are omitted
  ;  IF progress_bar->CheckCancel() THEN BEGIN
  ;     ok = Dialog_Message('Processing cancelled.')
  ;     progress_bar -> Destroy ; Destroy the progress bar.
  ;     return
  ;  ENDIF
  progress_bar -> Update, progress_curr
  
  
  for nF = 0, n_files-1 do begin     
    
    ;Input file
    in_fname = in_file_list[nF]
    in_file = in_fname
    
    ;========================================================================================================
    ;Start processing metadata TXT file
    ;========================================================================================================
    ;Define metadata filename
    date = Systime(/Julian)
    Caldat, date, Month, Day, Year, Hour, Minute, Second
    IF month LT 10 THEN month = '0' + Strtrim(month,1) ELSE month = Strtrim(month,1)
    IF day LT 10 THEN day = '0' + Strtrim(day,1) ELSE day = Strtrim(day,1)
    IF Hour LT 10 THEN Hour = '0' + Strtrim(Hour,1) ELSE Hour = Strtrim(Hour,1)
    IF Minute LT 10 THEN Minute = '0' + Strtrim(Minute,1) ELSE Minute = Strtrim(Minute,1)
    IF Second LT 10 THEN Second = '0' + Strtrim(Round(Second),1) ELSE Second = Strtrim(Round(Second),1)
    date_time = Strtrim(Year,1) + '-' + month + '-' + day + '_' + hour + '-' + minute + '-' + second
    
    last_dot = strpos(in_file, '.' , /reverse_search)
    if last_dot eq -1 or (last_dot gt 0 and strlen(in_file)-last_dot ge 6) then out_file = in_file $  ;input file has no extension or extensions is very long (>=6) e.q. there is no valid extension or dost is inside filename
    else out_file = strmid(in_file, 0, last_dot)
    out_file += '_process_log_' + date_time + '.txt'
    ;out_file = strmid(in_file,0,strlen(in_file)-4) + '_process_log_' + date_time + '.txt'
    ;Open metadata ASCII for writing    

    ; Write header of the metadata file
    Get_lun, unit
    Openw, unit, out_file, /append
    Printf, unit
    Printf, unit, '==============================================================================================='
    Printf, unit, 'Relief Visualization Toolbox (version ' + rvt_version + '); (c) ZRC SAZU, ' + rvt_issue_year
    Printf, unit, '==============================================================================================='
    Free_lun, unit

    
    ;=========================================================================================================
    ;Check if input file is TIFF, else convert it
    if strpos(strlowcase(in_file), '.tif') eq -1 and strpos(strlowcase(in_file), '.tiff') eq -1 then begin
      topo_advanced_vis_converter, in_file, 'GeoTIFF', out_file, out_img_file=out_img_file
      in_fname = out_img_file
      in_file = out_img_file
    endif
    
    
    ;=========================================================================================================
    ;=== Select input DEM and verify geotiff information =====================================================
    ;=========================================================================================================
  
    Get_lun, unit
    Openw, unit, out_file, /append
    Printf, unit
    Printf, unit
    Printf, unit
    Printf, unit, 'Processing info about visualizations'
    Printf, unit, '==============================================================================================='
    Free_lun, unit
  
    ; Open the file and read data
    in_orientation = 1
    in_rotation = 7
    
    if file_test(in_fname) eq 0 then begin
      errMsg = 'ERROR: Processing stopped! Selected TIF image was not found. '+ in_fname
      Get_lun, unit
      Openw, unit, out_file, /append
      Printf, unit
      Printf, unit, errMsg
      Printf, unit
      Free_lun, unit
      print, errMsg
      progress_bar -> Update, progress_curr
      progress_curr += progress_step_image
      continue
    endif $
    else begin
      heights = read_tiff(in_fname, orientation=in_orientation, geotiff=in_geotiff)
      if size(in_geotiff, /type) ne 8 then begin
        ;geotiff is not a structure type, try to read world file
        world_temp = read_worldfile(in_fname, pixels_size_temp, ul_x_temp, ul_y_temp, /to_geotiff)
        if world_temp gt 1 then begin
          in_geotiff = {MODELPIXELSCALETAG: [pixels_size_temp, pixels_size_temp, 0d], $
                        MODELTIEPOINTTAG: [0, 0, 0, ul_x_temp, ul_y_temp, 0]}
        endif        
      endif
    endelse
    
    ; Define number of bands
    in_file_dims = size(heights, /dimensions)
    in_nb = n_elements(in_file_dims) > 2 ? in_file_dims[2] : 1
    if (in_nb ne 1) then begin
      errMsg = 'ERROR: Processing stopped! Only one band is allowed for DEM files.'
      Get_lun, unit
      Openw, unit, out_file, /append
      Printf, unit
      Printf, unit, errMsg
      Printf, unit
      Free_lun, unit
      print, errMsg      
      progress_bar -> Update, progress_curr
      progress_curr += progress_step_image
      continue
    endif
  
    ; Extract raster parameters
    heights_min = min(heights)
    heights_max = max(heights)
  
    in_file_dims = size(heights, /dimensions)  ; due to rotation calculate again
    nrows = in_file_dims[1]
    ncols = in_file_dims[0]
  
    in_geotiff_elements = n_elements(in_geotiff)
    if (in_geotiff_elements gt 0) then begin  ; in_geotiff defined
      in_geotiff_tags = strlowcase(tag_names(in_geotiff))
      tag_exists = where(in_geotiff_tags eq strlowcase('ModelPixelScaleTag'))
      if (tag_exists[0] eq -1) then begin  ; tif without tag ModelPixelScaleTag
        in_pixel_size = dblarr(2) & in_pixel_size[0] = 1d & in_pixel_size[1] = 1d
        in_crs = 1
      endif else begin
        in_pixel_size = in_geotiff.ModelPixelScaleTag
;        if in_pixel_size[0] eq 0 and in_pixel_size [1] eq 0 then begin  ;geotiff with pixelsize eq to 0
;          in_pixel_size[0] = 0.02002
;          in_pixel_size[1] = 0.02002
;        endif
      endelse
  
      tag_exists = where(in_geotiff_tags eq strlowcase('GTModelTypeGeoKey'))
      if (tag_exists[0] gt -1) then begin ; geotiff with defined tag GTModelTypeGeoKey
        ; possible tag values: 1=projected, 2=geographic lat/lon, 3=geocentric (X,Y,Z)
        in_crs = in_geotiff.GTModelTypeGeoKey
        in_crs = (in_pixel_size[1] gt 0.1) ? 1 : 2
      endif else begin  ; tif file (with tfw), or geotiff without tag GTModelTypeGeoKey
        ; distinction based on pixel size
        in_crs = (in_pixel_size[1] gt 0.1) ? 1 : 2
      endelse
  
    endif else begin  ; in_geotiff undefined
      in_pixel_size = dblarr(2) & in_pixel_size[0] = 1d & in_pixel_size[1] = 1d
      in_crs = 1
    endelse
    ve_degrees = (in_crs eq 2) ? 1 : 0  ; units Degrees or Meters
  
    ; Output to IDL console
    print, '     Number of columns: ', strtrim(ncols,2)
    print, '     Number of rows:    ', strtrim(nrows,2)
    print, '     Number of bands:   ', strtrim(in_nb,2)
    if (in_crs eq 2) then begin  ; geographic coordinate system
      print, format='("     Resolution (x, y): ", f0.6, ", ", f0.6)', $
      in_pixel_size[0], in_pixel_size[1]
      wtext_resolution = string(format='("     Resolution (x, y):   ", f0.6, ", ", f0.6)', $
      in_pixel_size[0], in_pixel_size[1])
    endif else begin   ; projected or geocentric coordinate system
      print, format='("     Resolution (x, y): ", f0.1, ", ", f0.1)', $
      in_pixel_size[0], in_pixel_size[1]
      wtext_resolution = string(format='("     Resolution (x, y):   ", f0.1, ", ", f0.1)', $
      in_pixel_size[0], in_pixel_size[1])
    endelse
    resolution = in_pixel_size[1]
  
    Get_lun, unit
    Openw, unit, out_file, /append
    ;Start writing metadata into the file
    ;DEM
    Printf, unit
    Printf, unit, '# Metadata of the input file'
    Printf, unit, '     Input filename:     ' + in_fname
    Printf, unit, '     Number of columns:  ', Strtrim(ncols,2)
    Printf, unit, '     Number of rows:     ', Strtrim(nrows,2)
    Printf, unit, '     Number of bands:    ', Strtrim(in_nb,2)
    IF (in_crs EQ 2) THEN BEGIN  ; geographic coordinate system
      Printf, unit, format='("     Resolution (x, y):  ", f0.6, ", ", f0.6)', $
        in_pixel_size[0], in_pixel_size[1]
    ENDIF ELSE BEGIN   ; projected or geocentric coordinate system
      Printf, unit, format='("     Resolution (x, y):  ", f0.1, ", ", f0.1)', $
        in_pixel_size[0], in_pixel_size[1]
    ENDELSE
    
  
    ;=== Change parameter values that are not within allowed intervals of values =============================
  
    print
    print, '# Warnings'
    Printf, unit
    Printf, unit, '# Warnings'
  
    ; Checks for Vertical exagerattion 
    if in_ve_ex eq 0. then begin
      in_ve_ex = 1.
      print, '     ! Vertical exaggeration was changed to 1.0 (value 0.0 is not allowed)!'
      Printf, unit, '     ! Vertical exaggeration was changed to 1.0 (value 0.0 is not allowed)!'
    endif
    if in_ve_ex lt ve_floor then begin
      in_ve_ex = ve_floor
      print, '     ! Vertical exaggeration was changed to minimal allowed value ' + string(ve_floor, format="(f0.1)") +  '!'
      Printf, unit, '     ! Vertical exaggeration was changed to minimal allowed value ' + string(ve_floor, format="(f0.1)") +  '!'
    endif
    if in_ve_ex gt ve_ceil then begin
      in_ve_ex = ve_ceil
      print, '     ! Vertical exaggeration was changed to maximal allowed value ' + string(ve_ceil, format="(f0.1)") +  '!'
      Printf, unit, '     ! Vertical exaggeration was changed to maximal allowed value ' + string(ve_ceil, format="(f0.1)") +  '!'
    endif
    if ve_degrees eq 1 then begin
      print, '     ! The input DEM is given in geographic cooridnates. To account for the difference between angular and metric unit '
      print, '       the approximate metric pixel resolution is considered in further computation!'
      Printf, unit, '     ! The input DEM is given in geographic cooridnates. To account for the difference between angular and metric unit '
      Printf, unit, '       the approximate metric pixel resolution is considered in further computation!'
    endif
   
    ; Checks for Analytical hillshading 
    if in_hls_sun_a lt 0. or in_hls_sun_a gt 360. then begin
      in_hls_sun_a = 360. < in_hls_sun_a > 0.
      print, '     ! Analytical hillshading: Sun azimuth was trimmed to fit into the allowed interval 0.0-360.0 degrees!'
      Printf, unit, '     ! Analytical hillshading: Sun azimuth was trimmed to fit into the allowed interval 0.0-360.0 degrees!'
    endif
    if in_hls_sun_h lt 0. or in_hls_sun_h gt 360. then begin
      in_hls_sun_h = 90. < in_hls_sun_h > 0.
      print, '     ! Analytical hillshading: Sun elevation angle was trimmed to fit into the allowed interval 0.0-90.0 degrees!'
      Printf, unit, '     ! Analytical hillshading: Sun elevation angle was trimmed to fit into the allowed interval 0.0-90.0 degrees!'
    endif
  
    ; Checks for Hillshading from multiple directions 
    if in_mhls_n_dir lt 4 or in_mhls_n_dir gt 360 then begin
      in_mhls_n_dir = 360 < in_mhls_n_dir > 4
      print, '     ! Hillshading from multiple directions: Number of directions was trimmed to the interval 4-360!'
      Printf, unit, '     ! Hillshading from multiple directions: Number of directions was trimmed to the interval 4-360!'
    endif
    if in_mhls_sun_h lt 0. or in_mhls_sun_h gt 75. then begin
      in_mhls_sun_h = 75. < in_mhls_sun_h > 0.
      print, '     ! Hillshading from multiple directions: Sun elevation angle was trimmed to fit into the allowed interval 0.0-75.0 degrees!'
      Printf, unit, '     ! Hillshading from multiple directions: Sun elevation angle was trimmed to fit into the allowed interval 0.0-75.0 degrees!'
    endif
    
    ; Checks for PCA: number of principal components to be saved 
    if in_mhls_pca then begin
      if in_mhls_n_psc ge in_mhls_n_dir then begin
        in_mhls_n_psc = in_mhls_n_dir - 1
        print, '     ! PCA: Number of principal components was changed into ' + strtrim(in_mhls_n_psc,2) + $
             ' (has to be smaller than number of direction of Hillshading from multiple directions method)!'
        Printf, unit, '     ! PCA: Number of principal components was changed into ' + strtrim(in_mhls_n_psc,2) + $
             ' (has to be smaller than number of direction of Hillshading from multiple directions method)!'
      endif 
      if in_mhls_n_psc lt 3 then begin
        in_mhls_n_psc = 3
        print, '     ! PCA: Number of principal components was changed into ' + strtrim(in_mhls_n_psc,2) + $
             ' (i.e. minimal number of direction of Hillshading from multiple directions method)!'
        Printf, unit, '     ! PCA: Number of principal components was changed into ' + strtrim(in_mhls_n_psc,2) + $
             ' (i.e. minimal number of direction of Hillshading from multiple directions method)!'
      endif    
    endif
  
    ; Checks for Simple local relief model 
    if in_slrm_r_max lt 10. or in_slrm_r_max gt 50. then begin
      in_slrm_r_max = 50. < in_slrm_r_max > 10.
      print, '     ! Simple local relief model: Radius for trend assessment was trimmed to the allowed interval 10-50 pixels!'
      Printf, unit, '     ! Simple local relief model: Radius for trend assessment was trimmed to the allowed interval 10-50 pixels!'
    endif
  
    ; Checks for SVF + Openness + Negative openness
    if in_svf_n_dir lt 4 or in_svf_n_dir gt 360 then begin
      in_svf_n_dir = 360 < in_svf_n_dir > 4
      print, '     ! Sky-View Factor: Number of search directions was trimmed to the allowed interval 4-360!'
      Printf, unit, '     ! Sky-View Factor: Number of search directions was trimmed to the allowed interval 4-360!'
    endif
    if in_svf_r_max lt 5 or in_svf_r_max gt 100 then begin
      in_svf_r_max = 100 < in_svf_r_max > 5
      print, '     ! Sky-View Factor: Search radius was trimmed to the allowed interval 5-100 pixels!'
      Printf, unit, '     ! Sky-View Factor: Search radius was trimmed to the allowed interval 5-100 pixels!'
    endif
    if in_asvf_dir lt 0 or in_asvf_dir gt 360 then begin
      in_asvf_dir = 360 < in_asvf_dir > 0
      print, '     ! Anisotropic Sky-View Factor: Main direction of anisotropy was trimmed to the allowed interval 0.0-360.0 degrees!'
      Printf, unit, '     ! Anisotropic Sky-View Factor: Main direction of anisotropy was trimmed to the allowed interval 0.0-360.0 degrees!'
    endif
    
    ; Close metadata file
    Close, unit
      
    ;=== Print selected parameter values =============================
  
    print
    print, '# Selected visualization parameter'
    print, '     Vertical exaggeration factor:  ', in_ve_ex
    ;print, format='("No data value:  ", f0.2)', nodata_value
    print
    print, '# The following visualizations will be performed:  '
  
    if in_hls then begin
      print, '     > Analytical hillshading'
      print, '          Sun azimuth [deg.]: ', in_hls_sun_a 
      print, '          Sun elevation angle [deg.]: ', in_hls_sun_h 
    endif
    
    ;Multiple hillshading + PCA
    if in_mhls then begin
      print, '     > Hillshading from multiple directions'
      print, '          Number of directions: ', in_mhls_n_dir
      print, '          Sun elevation angle [deg.]: ', in_mhls_sun_h
      ;in_mhls_rgb = 1                                   ;1-make multiple hillshaing RGB, 0-don't
    endif
    if in_mhls_pca then begin
      print, '     > PCA of hillshading'
      print, '          Number of components to save: ', in_mhls_n_psc
      print, '          Note: Components are taken from the Hillshading from multiple directions method'
      print, '          and are prepared with the following parameters:'
      print, '               Number of directions: ', in_mhls_n_dir
      print, '               Sun elevation angle [deg.]: ', in_mhls_sun_h
    endif
    
    ;Slope gradient
    if in_slp then begin
      print, '     > Slope gradient'
      print, '          Note: No parameters required.'
    endif
    
    ;Simple local relief model
    if in_slrm then begin
      print, '     > Simple local relief model'
      print, '          Radius for trend assessment [pixels]: ', in_slrm_r_max
    endif
    
    ;SVF + Openness + Negative openness
    if in_svf then begin
      print, '     > Sky-View Factor'
      print, '          Number of search directions: ', in_svf_n_dir
      print, '          Search radius [pixels]: ', in_svf_r_max
      case in_svf_noise of
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        else: str_in_svf_noise = 'no removal'
      endcase  
      print, '          Level of noise removal:       ', str_in_svf_noise
    endif
    if in_asvf then begin
      print, '     > Anisotropic Sky-View Factor'
      case in_asvf_level of
        1: str_in_asvf_level = 'low'
        2: str_in_asvf_level = 'high'
        else: str_in_asvf_level = 'no removal'
      endcase  
      print, '          Level of anisotropy:       ', str_in_asvf_level
      print, '          Main direction of anisotropy [degrees]:       ', in_asvf_dir
      print, '          Note: Other parameters are taken from the Sky-View Factor method:'
      print, '               Number of search directions: ', in_svf_n_dir
      print, '               Search radius [pixels]: ', in_svf_r_max
      case in_svf_noise of
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        else: str_in_svf_noise = 'no removal'
      endcase  
      print, '               Level of noise removal:       ', str_in_svf_noise
    endif
    if in_open then begin
      print, '     > Openness - Positive'
      print, '          Note: Parameters are taken from the Sky-View Factor method:'
      print, '               Number of search directions: ', in_svf_n_dir
      print, '               Search radius [pixels]: ', in_svf_r_max
      case in_svf_noise of
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        else: str_in_svf_noise = 'no removal'
      endcase  
      print, '               Level of noise removal:       ', str_in_svf_noise
    endif
    if in_open_negative then begin
      print, '     > Openness - Negative'
      print, '          Note: Parameters are taken from the Sky-View Factor method:'
      print, '               Number of search directions: ', in_svf_n_dir
      print, '               Search radius [pixels]: ', in_svf_r_max
      case in_svf_noise of
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        else: str_in_svf_noise = 'no removal'
      endcase  
      print, '               Level of noise removal:       ', str_in_svf_noise
    endif
    if in_skyilm then begin
      print, '     > Sky illumination'
      print, '          Sky model: ', in_skyilm_model
      print, '          Number of sampling points: ', in_skyilm_points
      if in_skyilm_shadow then begin
      print, '          Note: Shadow modelling enabled.'
      print, '               Sun azimuth [deg.]: ', in_skyilm_az
      print, '               Sun elevation angle [deg.]: ', in_skyilm_el
      endif $
      else print, '          Note: Shadow modelling disabled.'
    endif
  
    
    
    ;========================================================================================================
    ;=== Start processing  ==================================================================================
    ;========================================================================================================
    
    
    starttime = Systime(/seconds)
    Print
    Print
    Print, '# Computation started at  ', Systime()  
     
    ; Main part of the program
  
    ;Correct vertical scale if data are not projected (unprojected lon, lat data)
    heights = Float(heights) * in_ve_ex
    IF (ve_degrees) THEN  resolution = 111300. * resolution
    
    ;Correct filename
    len_in_file = Strlen(in_file)
    in_file = Strmid(in_file, 0, len_in_file-4)     ;preffix to add proccessing parameters
    str_ve = '_Ve' + String(in_ve_ex, Format='(F0.1)')  ;vertical exageration
    IF in_ve_ex EQ 1. then str_ve = ''
    
    ;Hillshading
    IF in_hls EQ 1 THEN BEGIN
      out_file_hls = in_file + '_HS_A' + Strtrim(Long(in_hls_sun_a), 2) + '_H' + Strtrim(Long(in_hls_sun_h), 2) + str_ve
      Topo_advanced_vis_hillshade, out_file_hls, in_geotiff, $
        heights, resolution, $                ;relief
        in_hls_sun_a, in_hls_sun_h, $                   ;solar position
        sc_hls_ev
      ; ... display progress
      out_file_shadow_only = in_file + '_shadow'
      if shadow_use then begin 
        Topo_advanced_vis_skyillumination, out_file_shadow_only, in_geotiff,$
          heights, resolution, $
          '', '', '', '', $
          in_hls_sun_a, in_hls_sun_h, /shadow_only
      endif
      progress_bar -> Update, progress_curr
      progress_curr += progress_step < 100
    ENDIF
    
    ;Multiple hillshading
    IF in_mhls EQ 1 THEN BEGIN
      out_file_mhls = in_file + '_MULTI-HS_D' + Strtrim(Long(in_mhls_n_dir), 2) + '_H' + Strtrim(Long(in_mhls_sun_h), 2) + str_ve
      Topo_advanced_vis_multihillshade, out_file_mhls, in_geotiff, $
        heights, resolution, $                ;relief
        in_mhls_n_dir, in_mhls_sun_h, $                 ;solar position
        sc_mhls_a_rgb, sc_hls_ev                        ;directions for RGB outputRGB
      ; ... display progress
      progress_bar = obj_new('progressbar', title='Relief Visualization Toolbox - Progress ...', text=statText, xsize=300, ysize=20, $
      nocancel=1, /start, percent = fix(progress_curr<100))
      progress_curr += progress_step
    ENDIF
    
    ;PCA hillshading
    IF in_mhls_pca EQ 1 THEN BEGIN
      out_file_mhls_pca = in_file + '_PCA_D' + Strtrim(Long(in_mhls_n_dir), 2) + '_H' + Strtrim(Long(in_mhls_sun_h), 2) + str_ve
      Topo_advanced_vis_PCAhillshade, out_file_mhls_pca, in_geotiff, $
          heights, resolution, $     ;relief
          in_mhls_n_dir, in_mhls_sun_h, $  ;solar position
          in_mhls_n_psc, sc_hls_ev         ;number of PCs to save
      ; ... display progress
      progress_bar -> Update, progress_curr
      progress_curr += progress_step
    ENDIF
    
    ;Slope
    IF in_slp EQ 1 THEN BEGIN
      out_file_slp = in_file + '_SLOPE' + str_ve
      topo_advanced_vis_gradient, out_file_slp, in_geotiff, $
        heights, resolution, $                    ;relief
        sc_slp_ev
      ; ... display progress
      progress_bar -> Update, progress_curr
      progress_curr += progress_step
    ENDIF
    
    ;Local releif
    IF in_slrm EQ 1 THEN BEGIN
      out_file_slrm = in_file + '_SLRM_R' + Strtrim(Long(in_slrm_r_max), 2) + str_ve
      topo_advanced_vis_localrelief, out_file_slrm, in_geotiff, $
        heights, resolution, $                    ;relief
        in_slrm_r_max, sc_slrm_ev
      ; ... display progress
      progress_bar -> Update, progress_curr
      progress_curr += progress_step
    ENDIF
    
    ;SVF / anisotropic SVF / openess
    IF in_svf+in_open+in_asvf NE 0 THEN BEGIN
      CASE in_svf_noise OF
        0: str_noise = ''
        1: str_noise = '_NRlow'
        2: str_noise = '_NRmedium'
        3: str_noise = '_NRstrong'
      ENDCASE
      CASE in_asvf_level OF
        1: str_aniso = '_AIlow'
        2: str_aniso = '_AIstrong'
      ENDCASE 
      out_file_svf = [in_file + '_SVF_R' + Strtrim(Round(in_svf_r_max), 2) + '_D' + Strtrim(in_svf_n_dir, 2) + str_noise + str_ve, $
                      in_file + '_SVF-A_R' + Strtrim(Round(in_svf_r_max), 2) + '_D' + Strtrim(in_svf_n_dir, 2) + '_A' + Strtrim(round(in_asvf_dir), 2) + str_aniso + str_noise + str_ve, $
                      in_file + '_OPEN-POS_R' + Strtrim(Round(in_svf_r_max), 2) + '_D' + Strtrim(in_svf_n_dir, 2) + str_noise + str_ve]
      Topo_advanced_vis_svf, out_file_svf, in_svf, in_open, in_asvf, in_geotiff, $
        heights, resolution, $                    ;elevation
        in_svf_n_dir, in_svf_r_max, $                       ;search dfinition
        in_svf_noise, sc_svf_r_min, $                       ;noise
        sc_tile_size, sc_svf_ev, sc_opns_ev, $              ;tile size
        in_asvf_dir, in_asvf_level, sc_asvf_min, sc_asvf_pol    ;anisotropy
      ; ... display progress
      progress_bar -> Update, progress_curr
      progress_curr += progress_step*(in_svf+in_open+in_asvf)
    ENDIF
    
    ;Negative openess
    IF in_open_negative EQ 1 THEN BEGIN
      CASE in_svf_noise OF
        0: str_noise = ''
        1: str_noise = '_NRlow'
        2: str_noise = '_NRmedium'
        3: str_noise = '_NRstrong'
      ENDCASE
      CASE in_asvf_level OF
        1: str_aniso = '_AIlow'
        2: str_aniso = '_AIstrong'
      ENDCASE 
      heights = heights * (-1.)
      out_file_no = ['', '', in_file + '_OPEN-NEG_R' + Strtrim(Round(in_svf_r_max), 2) + '_D' + Strtrim(in_svf_n_dir, 2) + str_noise + str_ve]
      Topo_advanced_vis_svf, out_file_no, 0, 1, 0, in_geotiff, $
          heights, resolution, $                    ;elevation
          in_svf_n_dir, in_svf_r_max, $                       ;search dfinition
          in_svf_noise, sc_svf_r_min, $                       ;noise
          sc_tile_size, sc_svf_ev, sc_opns_ev, $              ;tile size
          in_asvf_dir, in_asvf_level, sc_asvf_min, sc_asvf_pol    ;anisotropy
      ; ... display progress
      progress_bar -> Update, progress_curr
      progress_curr += progress_step*(in_svf+in_open+in_asvf)
    ENDIF
    
    ;Sky illumination
    IF in_skyilm EQ 1 THEN BEGIN
      out_file_skyilm = in_file + '_SIM_' +in_skyilm_model + '_' + in_skyilm_points+'sp'
      if in_skyilm_shadow_dist eq 'unlimited' then out_file_skyilm += '_'+in_skyilm_shadow_dist+'_px' $
      else out_file_skyilm += '_'+in_skyilm_shadow_dist+'px'
      if in_skyilm_shadow then begin
        Topo_advanced_vis_skyillumination, out_file_skyilm, in_geotiff,$
              heights, resolution, $
              in_skyilm_model, in_skyilm_points, in_skyilm_shadow_dist,$              
              sc_skyilu_ev, $
              in_skyilm_az, in_skyilm_el
      endif else begin
        Topo_advanced_vis_skyillumination, out_file_skyilm, in_geotiff,$
              heights, resolution, $
              in_skyilm_model, in_skyilm_points, in_skyilm_shadow_dist,$
              sc_skyilu_ev
      endelse
      progress_bar -> Update, progress_curr
      progress_curr += progress_step*(in_skyilm)
    ENDIF   
   
   
    ; End processing 
    endtime = Systime(/seconds)
    Print
    Print, '# Computation finished at ', Systime()
    Print, format='("# Computation time ", I3.2, ":", I2.2, ":", F0.1)', (endtime-starttime)/3600,$
      ((endtime-starttime)/60) MOD 60, (endtime-starttime) MOD 60
    Print
    Print, '# Processing logfile: ', out_file
    Print, '------------------------------------------------------------------------------------------------------'
  

    ;========================================================================================================
    ;Write processing metadata into TXT metafile
    ;========================================================================================================
    ;Start writing processing metadata into the file
    Openw, unit, out_file, /append
    ;Outputs
    Printf, unit
    Printf, unit, '# Selected visualization parameter'
    Printf, unit, '     Vertical exaggeration factor:  ', in_ve_ex
    Printf, unit
    Printf, unit, '# The following visualizations have been performed:  '
    ;Hillshade
    IF in_hls THEN BEGIN
      Printf, unit
      Printf, unit, '     Analytical hillshading --------------------------------------------------------'
      Printf, unit, '          Sun azimuth [deg.]: ', in_hls_sun_a
      Printf, unit, '          Sun elevation angle [deg.]: ', in_hls_sun_h
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_hls + '.tif'
      Printf, unit, '          >> Output file 2 (linear histogram stretch between 0 and 1 for 8-bit output): '
      Printf, unit, '              ' + out_file_hls + '_8bit.tif'
      if shadow_use then begin
        Printf, unit, '          >> Output file 3 (binary shadow image): '
        Printf, unit, '              ' + out_file_shadow_only + '.tif'
      endif
    ENDIF
    ;Multiple hillshading + PCA
    IF in_mhls THEN BEGIN
      Printf, unit
      Printf, unit, '     Hillshading from multiple directions ------------------------------------------'
      Printf, unit, '          Number of directions: ', in_mhls_n_dir
      Printf, unit, '          Sun elevation angle [deg.]: ', in_mhls_sun_h
      Printf, unit, '          >> Output file 1 (each band corresponds to shading from one direction; linear histogram strech between 0 and 1): '
      Printf, unit, '              ' + out_file_mhls + '.tif'
      Printf, unit, '          >> Output file 2 (RGB; Red-315°, Green-15°, Blue-75°; linear histogram strech between 0 and 1): '
      Printf, unit, '              ' + out_file_mhls + '_RGB.tif'
    ENDIF
    IF in_mhls_pca THEN BEGIN
      Printf, unit
      Printf, unit, '     PCA of hillshading ------------------------------------------------------------'
      Printf, unit, '          Number of components to save: ', in_mhls_n_psc
      Printf, unit, '          Note: Components are taken from the Hillshading from multiple directions method'
      Printf, unit, '          and are prepared with the following parameters:'
      Printf, unit, '               Number of directions: ', in_mhls_n_dir
      Printf, unit, '               Sun elevation angle [deg.]: ', in_mhls_sun_h
      Printf, unit, '          >> Output file 1 (each band corresponds to one PC): '
      Printf, unit, '              ' + out_file_mhls_pca + '.tif'
      Printf, unit, '          >> Output file 2 (RGB; Red-PC1, Green-PC2, Blue-PC3; histogram equal. with 2% cut-off for 8-bit output): '
      Printf, unit, '              ' + out_file_mhls_pca + '_RGB.tif'
    ENDIF
    ;Slope gradient
    IF in_slp THEN BEGIN
      Printf, unit
      Printf, unit, '     Slope gradient ----------------------------------------------------------------'
      Printf, unit, '          Note: No parameters required.'
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_slp + '.tif'
      Printf, unit, '          >> Output file 2 (linear histogram stretch between 0 and 51° for 8-bit output): '
      Printf, unit, '              ' + out_file_slp + '_8bit.tif'
    ENDIF
    ;Simple local relief model
    IF in_slrm THEN BEGIN
      Printf, unit
      Printf, unit, '     Simple local relief model -----------------------------------------------------'
      Printf, unit, '          Radius for trend assessment [pixels]: ', in_slrm_r_max
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_slrm + '.tif'
      Printf, unit, '          >> Output file 2 (histogram equal. with 2% cut-off for 8-bit output): '
      Printf, unit, '              ' + out_file_slrm + '_8bit.tif'
    ENDIF
    ;SVF + Openness + Negative openness
    IF in_svf THEN BEGIN
      Printf, unit
      Printf, unit, '     Sky-View Factor ---------------------------------------------------------------'
      Printf, unit, '          Number of search directions: ', in_svf_n_dir
      Printf, unit, '          Search radius [pixels]: ', in_svf_r_max
      CASE in_svf_noise OF
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        ELSE: str_in_svf_noise = 'no removal'
      ENDCASE
      Printf, unit, '          Level of noise removal:       ', str_in_svf_noise
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_svf[0] + '.tif'
      Printf, unit, '          >> Output file 2 (linear histogram stretch between 0.64 and 1.00 for 8-bit output): '
      Printf, unit, '              ' + out_file_svf[0] + '_8bit.tif'
    ENDIF
    IF in_asvf THEN BEGIN
      Printf, unit
      Printf, unit, '     Anisotropic Sky-View Factor ---------------------------------------------------'
      CASE in_asvf_level OF
        1: str_in_asvf_level = 'low'
        2: str_in_asvf_level = 'high'
        ELSE: str_in_asvf_level = 'no removal'
      ENDCASE
      Printf, unit, '          Level of anisotropy:       ', str_in_asvf_level
      Printf, unit, '          Main direction of anisotropy [degrees]:       ', in_asvf_dir
      Printf, unit, '          Note: Other parameters are taken from the Sky-View Factor method:'
      Printf, unit, '               Number of search directions: ', in_svf_n_dir
      Printf, unit, '               Search radius [pixels]: ', in_svf_r_max
      CASE in_svf_noise OF
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        ELSE: str_in_svf_noise = 'no removal'
      ENDCASE
      Printf, unit, '               Level of noise removal:       ', str_in_svf_noise
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_svf[1] + '.tif'
      Printf, unit, '          >> Output file 2 (histogram equal. with 2% cut-off for 8-bit output): '
      Printf, unit, '              ' + out_file_svf[1] + '_8bit.tif'
    ENDIF
    IF in_open THEN BEGIN
      Printf, unit
      Printf, unit, '     Openness - Positive -----------------------------------------------------------'
      Printf, unit, '          Note: Parameters are taken from the Sky-View Factor method:'
      Printf, unit, '               Number of search directions: ', in_svf_n_dir
      Printf, unit, '               Search radius [pixels]: ', in_svf_r_max
      CASE in_svf_noise OF
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        ELSE: str_in_svf_noise = 'no removal'
      ENDCASE
      Printf, unit, '               Level of noise removal:       ', str_in_svf_noise
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_svf[2] + '.tif'
      Printf, unit, '          >> Output file 2 (linear histogram stretch between 60° and 95° for 8-bit output): '
      Printf, unit, '              ' + out_file_svf[2] + '_8bit.tif'
    ENDIF
    IF in_open_negative THEN BEGIN
      Printf, unit
      Printf, unit, '     Openness - Negative -----------------------------------------------------------'
      Printf, unit, '          Note: Parameters are taken from the Sky-View Factor method:'
      Printf, unit, '               Number of search directions: ', in_svf_n_dir
      Printf, unit, '               Search radius [pixels]: ', in_svf_r_max
      CASE in_svf_noise OF
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        ELSE: str_in_svf_noise = 'no removal'
      ENDCASE
      Printf, unit, '               Level of noise removal:       ', str_in_svf_noise
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_no[2] + '.tif'
      Printf, unit, '          >> Output file 2 (linear histogram stretch between 60° and 95° for 8-bit output): '
      Printf, unit, '              ' + out_file_no[2] + '_8bit.tif'
    ENDIF
    if in_skyilm then begin
      Printf, unit, '     > Sky illumination'
      Printf, unit, '          Sky model: ', in_skyilm_model
      Printf, unit, '          Number of sampling points: ', in_skyilm_points
      Printf, unit, '          Maximum search radius for calculation of shadows: ', in_skyilm_shadow_dist
;      if in_skyilm_shadow then begin
;        Printf, unit, '          Note: Shadow modelling enabled.'
;        Printf, unit, '               Sun azimuth [deg.]: ', in_skyilm_az
;        Printf, unit, '               Sun elevation angle [deg.]: ', in_skyilm_el
;      endif $
;      else Printf, unit, '          Note: Shadow modelling disabled.'
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_skyilm + '.tif'
      Printf, unit, '          >> Output file 2 (linear histogram stretch with lower '+string(sc_skyilu_ev[0],format="(f3.1)")+'% and upper '+string(sc_skyilu_ev[1],format="(f3.1)")+'% values cut-off for 8-bit output):'
      Printf, unit, '              ' + out_file_skyilm + '_8bit.tif'
    endif    
    
    ; Computation time
    Printf, unit
    Printf, unit, format='("# Computation time ", I3.2, ":", I2.2, ":", F0.1)', (endtime-starttime)/3600,$
      ((endtime-starttime)/60) MOD 60, (endtime-starttime) MOD 60
    ;Close metadata file
    Free_lun, unit
    
  
  endfor
  
  ; End display progress
  progress_bar -> Destroy
  
  if keyword_set(skip_gui) eq 0 then topo_advanced_vis, /re_run
  
  
;  msg = strarr(8)
;  msg[0] = 'Relief Visualization Toolbox (version ' + rvt_version + ')'
;  msg[1] = '---------------------------------------------------------------------'
;  msg[3] = 'Processing finished!
;  msg[5] = 'Results, i.e. visualization files (TIFs) and processing logfile (TXT),
;  msg[6] = 'are located in the folder:' 
;  msg[7] = file_dirname(out_file, /mark_directory)
;  dummy = dialog_message(msg, /information, title='RVT Finished')
  
end