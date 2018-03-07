

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
  msg[2] = 'By Klemen Zaksek, Kristof Ostir, Peter Pehani, Klemen Cotar, Maja Somrak and Ziga Kokalj'
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
  id_locald_checkbox = widget_info(event.top, find_by_uname='u_locald_checkbox')
  widget_control, id_locald_checkbox, set_button=1
  id_locald_params = widget_info(event.top, find_by_uname='u_locald_params')
  widget_control, id_locald_params, sensitive=1
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
  id_locald_checkbox = widget_info(event.top, find_by_uname='u_locald_checkbox')
  widget_control, id_locald_checkbox, set_button=0
  id_locald_params = widget_info(event.top, find_by_uname='u_locald_params')
  widget_control, id_locald_params, sensitive=0
  
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
  ; ... define values to assist the display
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

function hash_visualizations_tab_widget_unames
  hashmap = hash('Analytical hillshading', 'u_hls')
  hashmap += hash('Hillshading from multiple directions', 'u_mhls')
  hashmap += hash('PCA of hillshading', 'u_mhls_pca')
  hashmap += hash('Slope gradient', 'u_slp')
  hashmap += hash('Simple local relief model', 'u_slrm')
  hashmap += hash('Sky-View Factor', 'u_svf')
  hashmap += hash('Anisotropic Sky-View Factor', 'u_asvf')
  hashmap += hash('Openness - Positive', 'u_open')
  hashmap += hash('Openness - Negative', 'u_open_neg')
  hashmap += hash('Sky illumination', 'u_skyilm')
  hashmap += hash('Local dominance', 'u_locald')
  return, hashmap
end

; For a visualization, used in mixer,
; select checkbox in first tab ('Visualizations')
pro select_used_visualization_mixer, visualization, hash_unames, event
  uname = hash_unames[visualization]

  ; check if visualization is already set, otherwise select it
  id_checkbox = widget_info(event.top, find_by_uname=uname+'_checkbox')
  widget_control, id_checkbox, set_button=1
  
  ; enable setting parameters for selected visualization
  id_params = widget_info(event.top, find_by_uname=uname+'_params')
  widget_control, id_params, sensitive=1
  ;endif
end

; For all visualizations that are NOT used in mixer,
; deselect their checkboxes in first tab ('Visualizations')
pro deselect_unused_visualizations_mixer, hash_unames, event
  widget_control, event.top, get_uvalue = p_wdgt_state

  foreach visualization, (*p_wdgt_state).vis_droplist do begin
    if (visualization EQ '<none>') then continue

    ; Check for visualization if it's used in mixer
    vis_used = boolean(0)
    foreach layer,(*p_wdgt_state).mixer_widgetIDs.layers do begin
      selected_visualization = widget_info(layer.vis, /combobox_gettext)
      ;visualization = (*p_wdgt_state).current_combination.layers[layer].vis

      if (selected_visualization EQ visualization) then vis_used = boolean(1)
    endforeach

    ; If visualization is not used, deselect it on first tab
    if (vis_used EQ 0) then begin
      uname = hash_unames[visualization]
      ; de-select checkbox and parameters
      id_checkbox = widget_info(event.top, find_by_uname=uname+'_checkbox')
      widget_control, id_checkbox, set_button=0
      id_params = widget_info(event.top, find_by_uname=uname+'_params')
      widget_control, id_params, sensitive=0
    endif
  endforeach
end

; Trigger when 'Mix selected' button is pressed
; For each visualization on layers
pro mixer_select_checkboxes_visualizations_tab, event
  widget_control, event.top, get_uvalue = p_wdgt_state  ; structure containing widget state

  ; Select/deselect checkboxes on Visualizations tab according to Mixer's layers' configurations
  hash_unames = hash_visualizations_tab_widget_unames()
  nr_layers = (*p_wdgt_state).mixer_widgetIDs.layers.length

  ; go through all visualizations, only use those, which will be used for layers
  for layer=0,nr_layers-1 do begin
    visualization = widget_info((*p_wdgt_state).mixer_widgetIDs.layers[layer].vis, /combobox_gettext)

    if (visualization NE '<none>') then begin
      select_used_visualization_mixer, visualization, hash_unames, event
    endif
  endfor

  ; deselect other visualizations?
  deselect_unused_visualizations_mixer, hash_unames, event
end

pro get_input_files, event
   widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
   
   id_selection_panel = widget_info(event.top, find_by_uname='u_selection_panel')
   widget_control, id_selection_panel, get_value=panel_text
   in_delimiter = ';'
   panel_text = strtrim(strsplit(strjoin(panel_text, in_delimiter), in_delimiter, /extract),2) ; split possible multiple entries within same string
   panel_text_string = strjoin(panel_text, '#')  ; concatenate all inputs into a single loooong string
   (*p_wdgt_state).selection_str = panel_text_string
end

;=====================================================================================
; When user presses OK button ========================================================
pro user_widget_save_state, event
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
  
  ; Input files, folders, lists ----------------
  get_input_files, event
;  id_selection_panel = widget_info(event.top, find_by_uname='u_selection_panel')
;  widget_control, id_selection_panel, get_value=panel_text
;  in_delimiter = ';'
;  panel_text = strtrim(strsplit(strjoin(panel_text, in_delimiter), in_delimiter, /extract),2) ; split possible multiple entries within same string
;  panel_text_string = strjoin(panel_text, '#')  ; concatenate all inputs into a single loooong string
;  (*p_wdgt_state).selection_str = panel_text_string
  
  ; Overwrite ---
  do_overwrite = widget_info((*p_wdgt_state).overwrite_checkbox, /button_set) 
  (*p_wdgt_state).overwrite = do_overwrite

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
  
  ; Local domimamce
  locald_use = widget_info((*p_wdgt_state).locald_checkbox, /button_set)
  (*p_wdgt_state).locald_use = locald_use
  widget_control, (*p_wdgt_state).locald_min_entry, get_value=locald_min_rad
  (*p_wdgt_state).locald_min_rad = locald_min_rad
  widget_control, (*p_wdgt_state).locald_max_entry, get_value=locald_max_rad
  (*p_wdgt_state).locald_max_rad = locald_max_rad

  ; user 
  (*p_wdgt_state).user_cancel = 0

end

pro user_widget_ok, event
  user_widget_save_state, event
  widget_control, event.top, /destroy
end

pro user_widget_mixer_add_layer, event
  widget_control, event.top, get_uvalue=p_wdgt_state
  
  nr_layers = (*p_wdgt_state).mixer_widgetIDs.layers.length()
  nr_layers++
  
  layers_tag = (*p_wdgt_state).layers_tag
  if (layers_tag.length LT nr_layers) then begin
    print, 'Maximum number of layers already reached!'
    return
  endif
  
;  widget_layer = create_struct('base', 0, 'params', 0, 'row', 0, 'text', 0, 'vis', 0, 'normalization', 0, 'min', 0, 'max', 0, 'blend_mode', 0, 'opacity', 100)
;  widget_layers = REPLICATE(widget_layer, nr_layers)
;  
;  for i=0, nr_layers-2 do begin
;    cp = (*p_wdgt_state).mixer_widgetIDs.layers[i]
;    
;    ; foreach tag, TAG_NAMES(widget_layers[i]) do     
;    widget_layers[i].base = cp.base
;    widget_layers[i].params = cp.params
;    widget_layers[i].row = cp.row
;    widget_layers[i].text = cp.text
;    widget_layers[i].vis = cp.vis    
;    widget_layers[i].normalization = cp.normalization
;    widget_layers[i].min = cp.min
;    widget_layers[i].max = cp.max
;    widget_layers[i].blend_mode = cp.blend_mode
;    widget_layers[i].opacity = cp.opacity
;  endfor
;  
;  nl = new_mixer_layer((*p_wdgt_state).base_mixer_layers, LONG(nr_layers), (*p_wdgt_state).layers_tag[nr_layers], (*p_wdgt_state).vis_droplist, (*p_wdgt_state).blend_droplist, (*p_wdgt_state).norm_droplist)
;  widget_layers[nr_layers-1].base = nl.base
;  widget_layers[nr_layers-1].params = nl.params
;  widget_layers[nr_layers-1].row = nl.row
;  widget_layers[nr_layers-1].text = nl.text
;  widget_layers[nr_layers-1].vis = nl.vis
;  widget_layers[nr_layers-1].normalization = nl.normalization
;  widget_layers[nr_layers-1].min = nl.min
;  widget_layers[nr_layers-1].max = nl.max
;  widget_layers[nr_layers-1].blend_mode = nl.blend_mode
;  widget_layers[nr_layers-1].opacity = nl.opacity

  (*p_wdgt_state).mixer_widgetIDs = create_struct('layers', widget_layers)
end

; combination_selected => index of selected combination (on radio buttons)
; when inputing parameters of the combination simply choose combination in an array
pro user_widget_mixer_toggle_combination_radio, event
  widget_control, event.top, get_uvalue=p_wdgt_state
  
  user_widget_mixer_save_combination_radio, event

  combination_selected = (*p_wdgt_state).combination_index
  print, 'Selected combination: ', combination_selected+1 ; because indices start with 0 in array, but with 1 in GUI
  
  WIDGET_CONTROL, event.ID, GET_VALUE=combination_name
  IF event.SELECT  EQ 1 THEN BEGIN
    ;set_preset_mixer, combination_name, event
    user_widget_mixer_set_combination, event, combination_selected, combination_name
  ENDIF

  user_widget_mixer_validate_visualization_all, p_wdgt_state
  
  ; Transfer visualizations parameters between 'Mixer' tab and Visualizations tab
  mixer_select_checkboxes_visualizations_tab, event
  
end

; Compare two combination configurations (only layers' values, not the title!)
function is_equal_combination_config, combination1_config, combination2_config
  nr_layers1 = combination1_config.layers.LENGTH;
  nr_layers2 = combination2_config.layers.LENGTH;
  if (nr_layers1 NE nr_layers2) then return, BOOLEAN(0)
  
 ;nr_layers = (*p_wdgt_state).mixer_widgetIDs.layers.length

  for i=0,nr_layers1-1 do begin
    if (combination1_config.layers[i].vis NE combination2_config.layers[i].vis) then return, BOOLEAN(0) 
    ; if vis is '<none>' then it doesn't matter anyway!
    if ((combination1_config.layers[i].vis EQ '<none>') AND (combination2_config.layers[i].vis EQ '<none>')) then continue
      
    if (combination1_config.layers[i].normalization NE combination2_config.layers[i].normalization) then return, BOOLEAN(0)
    if (combination1_config.layers[i].min NE combination2_config.layers[i].min) then return, BOOLEAN(0)
    if (combination1_config.layers[i].max NE combination2_config.layers[i].max) then return, BOOLEAN(0)
    if (combination1_config.layers[i].blend_mode NE combination2_config.layers[i].blend_mode) then return, BOOLEAN(0)
    if (combination1_config.layers[i].opacity NE combination2_config.layers[i].opacity) then return, BOOLEAN(0)
    
  endfor
  return, BOOLEAN(1)
end

pro user_widget_mixer_save_combination_radio, event
  ; (*p_wdgt_state).combination_selected -> integer than corresponds to selected combination
  widget_control, event.top, get_uvalue=p_wdgt_state
  
  for i=0,(*p_wdgt_state).combination_radios.length-1 do begin
    if (1 EQ widget_info((*p_wdgt_state).combination_radios[i], /button_set)) then begin
      (*p_wdgt_state).combination_index = i
      return
    endif
  endfor
end

; It's the opposite of combination_to_mixer_widgets
pro user_widget_mixer_save_current_combination, event
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state

  combination = user_widget_mixer_state_to_combination((*p_wdgt_state).mixer_widgetIDs, 'Custom combination')
  (*p_wdgt_state).current_combination = combination
end

function gen_combination, title, nr_layers
  combination_layer = create_empty_mixer_layer()
  combination_layers = REPLICATE(combination_layer, nr_layers)
  combination = create_struct('title', title, 'layers', combination_layers)
  return, combination
end 

function user_widget_mixer_state_to_combination, widgetIDs, custom_combination_name
  ; inherit number of layers from widgets
  nr_layers = widgetIDs.layers.length

  combination = gen_combination(custom_combination_name, nr_layers)

  for i=0,nr_layers-1 do begin
    val_vis = widget_info(widgetIDs.layers[i].vis, /combobox_gettext)
    combination.layers[i].vis = val_vis
    
    widget_control, widgetIDs.layers[i].min, get_value = val_min
    combination.layers[i].min = float(val_min)
    
    widget_control, widgetIDs.layers[i].max, get_value = val_max
    combination.layers[i].max = float(val_max)
    
    val_blend_mode = widget_info(widgetIDs.layers[i].blend_mode, /combobox_gettext)
    combination.layers[i].blend_mode = val_blend_mode
    
    widget_control, widgetIDs.layers[i].opacity, get_value = val_opacity
    combination.layers[i].opacity = fix(val_opacity)
    
    val_norm = widget_info(widgetIDs.layers[i].normalization, /combobox_gettext)
    combination.layers[i].normalization = val_norm
  endfor
  
  return, combination
end

pro user_widget_mixer_set_combination_radio, event, index
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
  
  ; maybe it is triggered automatically in case block when using widget_control?
  (*p_wdgt_state).combination_index = index
  
  widget_control, (*p_wdgt_state).combination_radios[index], set_button=1
  
  ; Set custom combination title to reflect preset combination title / radio label
  widget_control, (*p_wdgt_state).combination_radios[index], get_value = combination_radio_title
  (*p_wdgt_state).current_combination.title = combination_radio_title
  
end

; Checking if current custom mixer configuration is actually a preset combination 
; WHEN LAYERS' PARAMETERS ARE CHANGED
pro user_widget_mixer_check_if_preset_combination, event
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
  
  user_widget_mixer_save_current_combination, event
  preset_found = BOOLEAN(0)

  nr_combinations = (*p_wdgt_state).all_combinations.length
  for index=0,nr_combinations-1 do begin
    ; if current configuration is equal to some preset configuration
    preset_combination = (*p_wdgt_state).all_combinations[index]
    if (is_equal_combination_config((*p_wdgt_state).current_combination, preset_combination)) then begin
        ; switch radio button to corresponding preset combination
        user_widget_mixer_set_combination_radio, event, index
        preset_found = BOOLEAN(1)
      return 
    endif
  endfor
  if (preset_found EQ BOOLEAN(0)) then begin
    ; change to custom combination
      widget_control, (*p_wdgt_state).combination_radios[nr_combinations], set_button=1  
      (*p_wdgt_state).combination_index = nr_combinations
  endif
end

; Generate widgets for mixer's layers
function user_widget_mixer_gen_widgets_2, widget_layers, i, base_mixer, nr_layers, layers_tag, vis_droplist, blend_droplist, norm_droplist
  if (layers_tag.length NE nr_layers) then print, 'Number of layers and number of labels dont match!'
  for i=0,nr_layers-1 do begin
    widget_layers[i] = new_mixer_layer(base_mixer, LONG(i), layers_tag[i], vis_droplist, blend_droplist, norm_droplist)
  endfor

  return, create_struct('layers', widget_layers)
end

function mixer_get_paths_to_input_files, event, source_image_file
    widget_control, event.top, get_uvalue = p_wdgt_state
    layers = (*p_wdgt_state).current_combination.layers
        
    ; Get paths to input files
    in_file = StrJoin(StrSplit(source_image_file, '.tiff', /Regex, /Extract, /Preserve_Null), '')
    in_file = StrJoin(StrSplit(in_file, '.tif', /Regex, /Extract, /Preserve_Null), '')
    input_files = (*p_wdgt_state).output_files_array[in_file]
    format_ending = '.tif'
    
    file_names = MAKE_ARRAY(layers.length, /STRING)
    for i=0,layers.length-1 do begin
      visualization = layers[i].vis
      if (visualization eq '<none>') then continue

        file_names[i] = input_files[visualization] + format_ending
    endfor
    
    (*p_wdgt_state).current_combination_file_names = file_names
    
    return, file_names
end

; 
pro mixer_input_images_to_layers, event, source_image_file
  widget_control, event.top, get_uvalue = p_wdgt_state
  
  ; Get paths to input files
  file_names = mixer_get_paths_to_input_files(event, source_image_file)

  ; Open the files into appropriate layers
  mixer_layer_images = orderedhash()
  layers = (*p_wdgt_state).current_combination.layers
  
  for i=0,layers.length-1 do begin
    visualization = layers[i].vis
    
    if (visualization EQ '<none>') then continue

    image = read_image_geotiff(file_names[i], (*p_wdgt_state).in_orientation)
    dim = size(image, /N_DIMENSIONS)
    
    ;TODO: images will be already normalized later (delete row below?)
    ; RGB to float
    if max(image) gt 2 and min(image) ge 0 and typename(image) eq 'INT' then $
      image = RGB_to_float(image)
    
    ; image negative for slope
    ; if (visualization EQ 'Slope gradient' and strpos(file_names[i], '_8bit.tif') LT 0) then begin
;    if (visualization EQ 'Slope gradient' and strpos(file_names[i], '.tif') GT 0) then begin
;       ;image = 1 - image ;image * (-1) + 1
;    endif
    
;    ; If image is 3-channel RGB, it has values 0-255 (but we need values 0.0-1.0) 
;    ; btw, grayscale has dim = 2, but has only 1 channel
;    if (dim EQ 3) then begin
;      idx = WHERE((*p_wdgt_state).mixer_layers_rgb EQ visualization, count)
;      if (~(count GT 0 AND max(image) GT 1 AND max(image) LT 256)) then continue
;      (*p_wdgt_state).is_blend_image_rbg = boolean(1)
;
;       image = RGB_to_float(image)
;    endif
    
    mixer_layer_images += hash(i, image)
    ;mixer_layer_images[i] = image

  endfor
  (*p_wdgt_state).mixer_layer_images = mixer_layer_images
  (*p_wdgt_state).mixer_layer_filepaths = file_names
end

pro user_widget_mixer_unit_test, event
  widget_control, event.top, get_uvalue=p_wdgt_state
  wdgt_state = *p_wdgt_state

  get_input_files, event
  in_file_string = (*p_wdgt_state).selection_str

  in_file_list = strsplit(in_file_string, '#', /extract)
  for nF = 0,in_file_list.length-1 do begin
    ;Input file
    in_file = in_file_list[nF]
    
    unit_test_mixer, event, in_file
  endfor

end

pro user_widget_mixer_ok, event
  widget_control, event.top, get_uvalue=p_wdgt_state
  wdgt_state = *p_wdgt_state

  ; Combination index - radio buttons
  user_widget_mixer_save_combination_radio, event

  ; Bottom layer validate
  user_widget_mixer_bottom_layer_validate, p_wdgt_state

  ; Current combination - wiget configuration by layers
  user_widget_mixer_save_current_combination, event
  
  ; Transfer visualizations parameters between 'Mixer' tab and Visualizations tab
  mixer_select_checkboxes_visualizations_tab, event
  
  ; Only save state after checkboxes on 'Visualizations' tab are changed, too
  user_widget_save_state, event

  ; Make visualizations
  topo_advanced_make_visualizations, p_wdgt_state, $
                                     (*p_wdgt_state).temp_sav, $
                                     (*p_wdgt_state).selection_str, $
                                     (*p_wdgt_state).rvt_version, $
                                     (*p_wdgt_state).rvt_issue_year, $
                                     /INVOKED_BY_MIXER                                                                
                                     
  ;TODO: Use TILED blending
  ; Blending visualizations with mixer
  ;topo_advanced_vis_mixer_blend_modes_tiled, event  
    
  ; Blending, non-tiled
  topo_advanced_vis_mixer_blend_modes, event  

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
  magic_y_size_number = 257   ;change this if you are changing GUI - minimum size of GUI window
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
  tab = widget_info(event.top, find_by_uname='base_tab_window')
  tab_all = widget_info(event.top, find_by_uname='base_tab_window_all')
  tab_mosaic = widget_info(event.top, find_by_uname='base_tab_mosaic')
  tab_converter = widget_info(event.top, find_by_uname='base_tab_converter')
  tab_mixer = widget_info(event.top, find_by_uname='base_tab_mixer')
  new_y_size = (event.y - magic_y_size_number) > 1
  widget_control, tab, ysize = new_y_size
  widget_control, tab_all, ysize = new_y_size
  widget_control, tab_mosaic, ysize = new_y_size
  widget_control, tab_converter, ysize = new_y_size
  widget_control, tab_mixer, ysize = new_y_size
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

  overwrite = wdgt_struct.overwrite

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
  
  local_dominance = wdgt_struct.locald_use
  min_radius = wdgt_struct.locald_min_rad
  max_radius = wdgt_struct.locald_max_rad
  
  save, overwrite,exaggeration_factor,hillshading,sun_azimuth,sun_elevation,shadow_modelling,pca_hillshading,number_components,multiple_hillshading, $
        hillshade_directions,slope_gradient,simple_local_relief,trend_radius,sky_view_factor,svf_directions,search_radius,remove_noise,noise_removal, $
        anisotropic_svf,anisotropy_level,anisotropy_direction,positive_openness,negative_openness,sky_illumination,sky_model,number_points,max_shadow_dist,$
        local_dominance,min_radius,max_radius,$
        description = '', filename = sav_path  
end


; lower two functions are actually the same
function user_widget_mixer_read_all_combinations, file_path
  all_combinations = read_combinations_from_file(file_path)
  return, all_combinations
end

function get_mixer_layer, event
  widget_control, event.ID, get_uvalue=active_layer
  return, active_layer
end

; It's the opposite of  user_widget_mixer_state_to_combination
pro combination_to_mixer_widgets, p_wdgt_state, combination, SET_TITLE = set_title
  widgetIDs = (*p_wdgt_state).mixer_widgetIDs
  nr_layers = widgetIDs.layers.length

  for i=0,nr_layers-1 do begin
    widget_control, widgetIDs.layers[i].vis, set_combobox_select = (*p_wdgt_state).hash_vis_get_index[combination.layers[i].vis]
    widget_control, widgetIDs.layers[i].min, set_value = strtrim(combination.layers[i].min, 1)
    widget_control, widgetIDs.layers[i].max, set_value = strtrim(combination.layers[i].max, 1)
    widget_control, widgetIDs.layers[i].blend_mode, set_combobox_select = (*p_wdgt_state).hash_blend_get_index[combination.layers[i].blend_mode]
    widget_control, widgetIDs.layers[i].opacity, set_value = strtrim(combination.layers[i].opacity, 1)
    widget_control, widgetIDs.layers[i].normalization, set_combobox_select = (*p_wdgt_state).hash_norm_get_index[combination.layers[i].normalization]
  endfor
  
  if (KEYWORD_SET(SET_TITLE)) then begin
    (*p_wdgt_state).current_combination.title = combination.title
  endif
end

; The lowest mixer layer with visualization set (other than '<none>')
; has max opacity and no blending mode
pro user_widget_mixer_bottom_layer_validate, p_wdgt_state
  widgetIDs = (*p_wdgt_state).mixer_widgetIDs
  combination = user_widget_mixer_state_to_combination(widgetIDs, (*p_wdgt_state).current_combination.title)

  combination = combination_bottom_layer_validate(combination)
  ; update in p_wdgt_state and widgets itself
  (*p_wdgt_state).current_combination = combination
  combination_to_mixer_widgets, p_wdgt_state, combination
end

pro user_widget_mixer_switch_layer_sensitivity, p_wdgt_state, layer, sensitivity
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].min, sensitive = sensitivity
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].max, sensitive = sensitivity
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].blend_mode, sensitive = sensitivity
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].opacity, sensitive = sensitivity
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].normalization, sensitive = sensitivity
end

pro user_widget_mixer_disable_layer, p_wdgt_state, layer
  user_widget_mixer_switch_layer_sensitivity, p_wdgt_state, layer, 0
end

pro user_widget_mixer_enable_layer, p_wdgt_state, layer
  user_widget_mixer_switch_layer_sensitivity, p_wdgt_state, layer, 1
end

pro user_widget_mixer_show_input_custom_file, p_wdgt_state, layer
  ;TODO: hide other elements
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].min, xsize = 0
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].max, xsize = 0
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].blend_mode, xsize = 0
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].normalization, xsize = 0
  ;TODO: show path to input file where Lin/Perc, min, max, and Visualization elements are shown
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].input_custom_file, xsize = 160
end

pro user_widget_mixer_hide_input_custom_file, p_wdgt_state, layer

  ;TODO: hide other elements
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].min, xsize = 5
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].max, xsize = 5
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].blend_mode, xsize = 100
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].normalization, xsize = 50
  ;TODO: show path to input file where Lin/Perc, min, max, and Visualization elements are shown
  widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].input_custom_file, xsize = 0
end

pro user_widget_mixer_validate_visualization_all, p_wdgt_state
  nr_layers = (*p_wdgt_state).mixer_widgetIDs.layers.length

  for layer=0,nr_layers-1 do begin
    visualization = widget_info((*p_wdgt_state).mixer_widgetIDs.layers[layer].vis, /combobox_gettext)
    
    IF (visualization EQ '<none>') THEN BEGIN
      ; disable other fields: min, max, blend_mode, opacity
      ; TO-DO automatic input of empty layer to widgets
      empty_layer = create_empty_mixer_layer()
      widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].min, set_value = empty_layer.min
      widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].max, set_value = empty_layer.max
      widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].blend_mode, set_combobox_select = (*p_wdgt_state).hash_blend_get_index[empty_layer.blend_mode]
      widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].opacity, set_value = empty_layer.opacity
      widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].normalization, set_combobox_select = (*p_wdgt_state).hash_norm_get_index[empty_layer.normalization]
      user_widget_mixer_disable_layer, p_wdgt_state, layer
      
    ENDIF ELSE BEGIN
        ; make sure other elements are enabled(min, max, blend_mode, opacity)
        user_widget_mixer_enable_layer, p_wdgt_state, layer
        
        ;set default min and max values if the field was empty before
        widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].min, get_value = min_str
        widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].max, get_value = max_str
      
        if (min_str EQ '') then begin
          widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].min, set_value = strtrim(get_min_default(visualization, p_wdgt_state),1)
        endif else begin
          number = validate_number_limits(float(min_str), visualization, p_wdgt_state)
          widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].min, set_value = strtrim(string(number),1)
        endelse
        
        if (max_str EQ '') then begin
          widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].max, set_value = strtrim(get_max_default(visualization, p_wdgt_state),1)
        endif else begin
          number = validate_number_limits(float(max_str), visualization, p_wdgt_state)
          widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].max, set_value = strtrim(string(number),1)
        endelse
  
    ENDELSE
  endfor
  
  ; bottom layer: blend mode & opacity
  user_widget_mixer_bottom_layer_validate, p_wdgt_state
  
end

pro mixer_widget_change_vis, event
  widget_control, event.top, get_uvalue=p_wdgt_state
  layer = get_mixer_layer(event)
  
  ; TO-DO: ? If previous vis selection was the same, don't alter min and max values?
  visualization = widget_info((*p_wdgt_state).mixer_widgetIDs.layers[layer].vis, /combobox_gettext)
  IF (visualization NE '<none>') THEN BEGIN
    default_norm = get_norm_default(visualization, p_wdgt_state)
    widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].normalization, set_combobox_select = (*p_wdgt_state).hash_norm_get_index[default_norm]
    widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].min, set_value = strtrim(get_min_default(visualization, p_wdgt_state),1)
    widget_control, (*p_wdgt_state).mixer_widgetIDs.layers[layer].max, set_value = strtrim(get_max_default(visualization, p_wdgt_state),1)
  ENDIF 
  
  user_widget_mixer_check_if_preset_combination, event
  user_widget_mixer_validate_visualization_all, p_wdgt_state
  
  ; Transfer visualizations parameters between 'Mixer' tab and Visualizations tab
  mixer_select_checkboxes_visualizations_tab, event  
end

pro mixer_widget_change_norm, event
  user_widget_mixer_check_if_preset_combination, event
end
 
pro mixer_widget_change_blend_mode, event
  user_widget_mixer_check_if_preset_combination, event
end

; uname = type of ''
function get_widget_sibling, event, uname
  child_widgets = widget_info(event.top, /all_children)
  foreach child, child_widgets do begin
    widget = widget_info(child, find_by_uname=uname)
    if (widget gt 0) then break
  endforeach
  return, widget
end

function validate_number_limits, number, visualization, p_wdgt_state
 
  min_limit = float(get_min_limit(visualization, p_wdgt_state))
  max_limit = float(get_max_limit(visualization, p_wdgt_state))

  if (number gt max_limit) then begin
    number = max_limit
  endif
  if (number lt min_limit) then begin
    number = min_limit
  endif
  return, number
end

pro mixer_widget_change_min, event
  widget_control, event.top, get_uvalue=p_wdgt_state 
  layer = get_mixer_layer(event)
  
  vis_value =  widget_info((*p_wdgt_state).mixer_widgetIDs.layers[layer].vis, /combobox_gettext)
  widget_control, event.ID, GET_VALUE=str_number

  number = validate_number_limits(float(str_number), vis_value, p_wdgt_state)
  widget_control, event.ID, set_value = strtrim(string(number),1)
  
  user_widget_mixer_check_if_preset_combination, event
end

pro mixer_widget_change_max, event
  widget_control, event.top, get_uvalue=p_wdgt_state 
  layer = get_mixer_layer(event)
 
  vis_value =  widget_info((*p_wdgt_state).mixer_widgetIDs.layers[layer].vis, /combobox_gettext)
  widget_control, event.ID, GET_VALUE=str_number

  number = validate_number_limits(float(str_number), vis_value, p_wdgt_state)
  widget_control, event.ID, set_value = strtrim(string(number),1)
  
  user_widget_mixer_check_if_preset_combination, event
end

pro mixer_widget_change_opacity, event
  layer = get_mixer_layer(event)
  widget_control, event.ID, GET_VALUE=slider_value
  
  user_widget_mixer_check_if_preset_combination, event
end

; Change values of widgets to contain selected combination values
; Also include combination index, too
pro user_widget_mixer_set_combination, event, index, combination_name
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state

  IF (combination_name EQ (*p_wdgt_state).custom_combination_name) THEN BEGIN
    print, 'Custom mixer combination/configuration selected'
      IF ((*p_wdgt_state).combination_index NE (*p_wdgt_state).all_combinations.length) then print, 'Index and type of combination do not match!'
    ;IF (combination_selected NE (*p_wdgt_state).all_combinations.length) then print, 'Index and type of combination do not match!'
  ENDIF ELSE BEGIN
    print, 'Selected preset configuration:' + combination_name 
    ;IF (strmatch(combination_name, (*p_wdgt_state).all_combinations[index].title) NE 1) print, 'Index and title of combination do not match!'
    IF (combination_name NE (*p_wdgt_state).all_combinations[index].title) then print, 'Index and title of combination do not match!'
    
    combination = (*p_wdgt_state).all_combinations[index]
    widgetIDs = (*p_wdgt_state).mixer_widgetIDs
    combination_to_mixer_widgets, p_wdgt_state, combination
  ENDELSE

end

function new_mixer_layer, base_mixer, layer_index, label_text, vis_droplist, blend_droplist, norm_droplist
  COMMON topo_advanced_tab_widgets, ysize_row, ysize_bigrow, xsize_frame_method_name, xsize_params, xsize_one_param, xsize_short_label, xsize_slider, xsize_wide_row

  txt_layer = 'layer'+strtrim(layer_index+1, 1)

  mixer_row_layer = widget_base(base_mixer, /row)
  layer_params = widget_base(mixer_row_layer, /row, xsize=xsize_wide_row, ysize=ysize_bigrow, /frame, $ ;sensitive=preset_mix,
    uname='u_'+txt_layer+'_params')
    
  layer = create_struct('base', mixer_row_layer, 'params', layer_params)

  layer_row = widget_base(layer_params, /row, ysize=ysize_bigrow)
  ;layer_label = widget_label(layer_row, value=label_text, xsize = xsize_short_label)
  layer_label = widget_label(layer_row, value=label_text, xsize = xsize_short_label-50)
  
  layer = create_struct(layer, 'row', layer_row, 'text', layer_label)

  layer_vis = widget_combobox(layer_row, event_pro='mixer_widget_change_vis', xsize = xsize_short_label*2, value=vis_droplist[*], $
    uname=txt_layer+'_vis', uvalue=layer_index)  
  widget_control, layer_vis, set_combobox_select = vis_droplist.LENGTH-1
  
  layer_norm = widget_combobox(layer_row, event_pro='mixer_widget_change_norm', xsize = 50, value=norm_droplist[*], $
    uname=txt_layer+'_norm', uvalue=layer_index)
  
  layer_min = widget_text(layer_row, event_pro='mixer_widget_change_min', scroll=0, value='', xsize = 5, ysize = 1, /editable, $
    uname=txt_layer+'_min', uvalue=layer_index)
  layer_max = widget_text(layer_row, event_pro='mixer_widget_change_max', scroll=0, value='', xsize = 5, ysize = 1, /editable, $
    uname=txt_layer+'_max', uvalue=layer_index)
  layer_blend_mode = widget_combobox(layer_row, event_pro='mixer_widget_change_blend_mode', xsize = xsize_short_label, value=blend_droplist[*], $
    uname=txt_layer+'_blend_mode', uvalue=layer_index)
  ;layer_opacity_text = widget_text(layer_row, event_pro='mixer_change_opacity_txt', value='0', scroll=0, xsize = 5, ysize = 1, /editable)
  layer_opacity_slider = widget_slider(layer_row, event_pro='mixer_widget_change_opacity', value=100, xoffset=50, xsize = xsize_slider, ysize = 20, min=0, max=100, $
    uname=txt_layer+'_opacity', uvalue=layer_index) ;/SUPPRESS_VALUE)
    
  layer = create_struct(layer, 'vis', layer_vis)
  layer = create_struct(layer, 'normalization', layer_norm)
  layer = create_struct(layer, 'min', layer_min)
  layer = create_struct(layer, 'max', layer_max)
  layer = create_struct(layer, 'blend_mode', layer_blend_mode)
  layer = create_struct(layer, 'opacity', layer_opacity_slider)
    
  return, layer  
end

function new_struct_layer
  return, create_struct('base', 0, 'params', 0, 'row', 0, 'text', 0, 'vis', 0, 'normalization', 0, 'min', 0, 'max', 0, 'blend_mode', 0, 'opacity', 100)
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
;       Maja Somrak 
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
;       1.3  August 2016: Added txt settings reader that enables program running without any GUI manipulatio. New re_run
;                         keyword that enables settings to be stored between consecutive sessions. Overwrite keyword added 
;                         to all function/procesures that produce some kind of raster output.
;            September 2016: Added local dominance visualization procedure.
;       1.4 
;-

pro topo_advanced_vis, re_run=re_run
  compile_opt idl2
  
  ; Create string for software version and year of issue
  rvt_version = '2.1'
  rvt_issue_year = '2017'
  
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
    
    if test_tag('overwrite', settings_tags) then overwrite = input_settings.overwrite $
    else overwrite = 1.0
    
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
    
    if test_tag('local_dominance', settings_tags) then local_dominance = input_settings.local_dominance $
    else local_dominance = 0
    if test_tag('min_radius', settings_tags) then min_radius = input_settings.min_radius $
    else min_radius = 2
    if test_tag('max_radius', settings_tags) then max_radius = input_settings.max_radius $
    else max_radius = 0
    
    
    process_file = programrootdir()+'settings\process_files.txt'
    if file_test(process_file) then begin
      n_lines = file_lines(process_file)
      if n_lines gt 0 then begin
        files_to_process = make_array(n_lines, /string)
        openr, txt_proc, process_file, /get_lun
        readf, txt_proc, files_to_process
        free_lun, txt_proc
        skip_gui = 1
      endif else if keyword_set(re_run) then skip_gui = 1
    endif else if keyword_set(re_run) then skip_gui = 1   
  endelse  
  
  ;=========================================================================================================
  ;=== Setup constnants that cannot be changed by the user =================================================
  ;=========================================================================================================

  ;Vertical exaggeration
  sc_ve_ex = [-1000., 1000.]
  
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
  sc_skyilu_ev = [0.25, 0.]   ;percent
  sc_ld_ev = [0.5, 1.8]

  ;If input DEM is larger as the size below, do tiling
  sc_tile_size = 5L*10L^6
  
  ;  =========================================================================================================
  ;  === Select input DEM and verify geotiff information =====================================================
  ;  =========================================================================================================
  ;  WAS ERASED ...
  ;  restored in file ''
  



  ;=========================================================================================================
  ;=== Widget to get user parameters =======================================================================
  ;=========================================================================================================
  
  window_y_offset = 40  ;pixel space on top and bellow the GUI
  window_x_offset = 50  ;pixel space on the left side of GUI
  base_title = 'Relief Visualization Toolbox, ver. ' + rvt_version + '; (c) ZRC SAZU, ' + rvt_issue_year
  base_main = widget_base(title=base_title, xoffset=window_x_offset, yoffset=window_y_offset, xsize=710, uname='base_main_window',$
                xpad=15, ypad=15, space=0, /column, tab_mode=1, /TLB_Size_Events)             
  
  COMMON topo_advanced_tab_widgets, ysize_row, ysize_bigrow, xsize_frame_method_name, xsize_params, xsize_one_param, xsize_short_label, xsize_slider, xsize_wide_row
  ysize_row = 32
  ysize_bigrow = 40
  xsize_frame_method_name = 195
  xsize_params = 440
  xsize_one_param = 200
  xsize_short_label = 100
  xsize_slider = 140
  xsize_wide_row = 640

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
  
  ;overwrite checkbox
  add_files_text = widget_label(main_row_1, value='                                                                         ')
  overwrite_namebox = widget_base(main_row_1, /nonexclusive)
  overwrite_checkbox = widget_button(overwrite_namebox, event_pro='user_widget_do_nothing', $
    value='Overwrite existing output files', uname='u_overwrite_checkbox')
  widget_control, overwrite_checkbox, set_button=overwrite  
  
  empty_text_row = widget_label(base_main, value='  ', scr_ysize=10)
  base_tab = WIDGET_TAB(base_main, event_pro='disable_last_row', uname = 'base_tab_window')
  base_all = WIDGET_BASE(base_tab, TITLE='   Visualizations   ', /COLUMN, xsize=655, /scroll, uname = 'base_tab_window_all')
  
  ; exaggetarion factor
  ve_floor = sc_ve_ex[0]
  ve_ceil = sc_ve_ex[1]

  base_row_1 = widget_base(base_all, /row)
  ve_text = widget_label(base_row_1, value='Vertical exaggetarion factor (used in all methods) (min=-1000., max=1000.):  ')
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
  skyilm_az_entry = widget_text(skyilm_row_3, event_pro='user_widget_do_nothing', scroll=0, value=strtrim(sun_azimuth,2), xsize=4, /editable, uname='skyilm_az_entry')  
  
  skyilm_el_text = widget_label(skyilm_row_3, value='             Sun elevation angle [deg.]:  ', uname='skyilm_el_text')
  skyilm_el_entry = widget_text(skyilm_row_3, event_pro='user_widget_do_nothing', scroll=0, value=strtrim(sun_elevation,2), xsize=4, /editable, uname='skyilm_el_entry')
  
  ; Local dominance ..........
  base_row_11 = widget_base(base_all, /row, ysize=1*ysize_row+10) ; , /frame)
  locald_namebox = widget_base(base_row_11, /row, /nonexclusive, xsize=xsize_frame_method_name, ysize=ysize_row)
  locald_checkbox = widget_button(locald_namebox, event_pro='user_widget_toggle_method_checkbox', $
    value='Local dominance', uname='u_locald_checkbox')
  widget_control, locald_checkbox, set_button=local_dominance
  locald_params = widget_base(base_row_11, /column, sensitive=local_dominance, xsize=xsize_params, /frame, $
    uname='u_locald_params')
    
  locald_row_1 = widget_base(locald_params, /row)
  locald_text_1 = widget_label(locald_row_1, value='Minimum radius:  ')
  locald_min_entry = widget_text(locald_row_1, event_pro='user_widget_do_nothing', scroll=0, value=strtrim(min_radius,2), xsize=5, /editable, uname='skyilm_el_entry')
  locald_text_2 = widget_label(locald_row_1, value='                   ')
  locald_text_3 = widget_label(locald_row_1, value='Maximum radius:  ')
  locald_max_entry = widget_text(locald_row_1, event_pro='user_widget_do_nothing', scroll=0, value=strtrim(max_radius,2), xsize=5, /editable, uname='skyilm_el_entry')


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
  base_convert = WIDGET_BASE(base_tab, TITLE='   Converter   ', /COLUMN, /scroll, uname = 'base_tab_converter', xsize=655)
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
  base_mosaic = WIDGET_BASE(base_tab, TITLE='   Mosaic   ', /COLUMN, /scroll, uname = 'base_tab_mosaic', xsize=655)
  mosaic_row_0 = widget_label(base_mosaic, value='  ', scr_ysize=30)
  mosaic_row_1 = widget_base(base_mosaic, /align_left)
  bt_mosaic_ok = widget_button(mosaic_row_1, event_pro='user_widget_mosaic', value='Create mosaic', xoffset= 20, yoffset=20, scr_xsize=120)
  bt_mosaic_cancel = widget_button(mosaic_row_1, event_pro='user_widget_cancel', value='Cancel', xoffset= 160, yoffset=20, scr_xsize=65)
 
  ; Mixer tab --------------------
  base_mixer = WIDGET_BASE(base_tab, TITLE='   Mixer   ', /COLUMN, /scroll, uname = 'base_tab_mixer', xsize=655) 
  
  output_files_array = hash()
  mixer_layer_images = orderedhash()
  mixer_layers_rgb = ['Hillshading from multiple directions', 'PCA of hillshading']
  is_blend_image_rbg = boolean(0)
 
  ; --- Preset visualization combinations ---
  mixer_row_0 = widget_base(base_mixer, /row)
  mixer_row_1_text_preset = widget_label(base_mixer, value='Preset combinations:   ', /align_left)
  
  mixer_row_2 = widget_base(base_mixer, /row, xsize=xsize_frame_method_name*3)
  mixer_checkboxes = widget_base(mixer_row_2, /row, /exclusive, xsize=xsize_frame_method_name*3, ysize=ysize_row) 
    
  ; Select visualizations to blend
  mixer_row_2 = widget_base(base_mixer, /row, xsize=xsize_wide_row)
  mixer_row_2_col0 = widget_label(mixer_row_2, value=' ', xsize = 8)
  ;mixer_row_2_col1 = widget_label(mixer_row_2, value='Order of layering', xsize = xsize_short_label) ; -50
  mixer_row_2_col1 = widget_label(mixer_row_2, value='Layers: ', xsize = xsize_short_label-50)
  mixer_row_2_col2 = widget_label(mixer_row_2, value='Visualization method', xsize = xsize_short_label*2)
  mixer_row_2_col1 = widget_label(mixer_row_2, value='Norm', xsize = 50)
  mixer_row_2_col3 = widget_label(mixer_row_2, value='Min', xsize = 40)
  mixer_row_2_col4 = widget_label(mixer_row_2, value='Max', xsize = 40)
  mixer_row_2_col5 = widget_label(mixer_row_2, value='Blending mode', xsize = xsize_short_label)
  mixer_row_2_col6 = widget_label(mixer_row_2, value='Opacity', xsize = xsize_short_label * 1.5)

  vis_droplist = gen_vis_droplist()
  blend_droplist = gen_blend_droplist()
  norm_droplist = gen_norm_droplist()
 
  hash_vis_get_index = gen_hash_strings(vis_droplist)     ;gen_vis_hash_strings()
  hash_blend_get_index = gen_hash_strings(blend_droplist) ;gen_blend_hash_strings()
  hash_norm_get_index = gen_hash_strings(norm_droplist)   ;gen_norm_hash_strings() 
  
  hash_vis_norm_default = gen_vis_norm_default()
 
  file_settings_combinations = programrootdir()+'settings\default_settings_combinations_extended.txt'
  vis_min_limit = set_vis_min_limit(vis_droplist, -1000)
  vis_max_limit = set_vis_max_limit(vis_droplist, 1000)
  
  vis_defaults = read_default_min_max_from_file(file_settings_combinations)
  
  vis_min_default = vis_defaults.min_hash
  vis_max_default = vis_defaults.max_hash
 
  ; --- Mixer Tab: Layers
  ; Dinamically generated layer rows with widgets 
  nr_layers = 5 
  layers_tag = ['1st:', '2nd:', '3rd:', '4th:', '5th', '6th', '7th', '8th']
  base_mixer_layers = widget_base(base_mixer, row=8)
  mixer_layer_filepaths = make_array(nr_layers, /string)
  file_names = MAKE_ARRAY(nr_layers, /STRING, VALUE = '')
  
  widget_layer = create_struct('base', 0, 'params', 0, 'row', 0, 'text', 0, 'vis', 0, 'normalization', 0, 'min', 0, 'max', 0, 'blend_mode', 0, 'opacity', 100)
  widget_layers = REPLICATE(widget_layer, nr_layers)

  mixer_widgetIDs = user_widget_mixer_gen_widgets_2(widget_layers, i, base_mixer_layers, nr_layers, layers_tag, vis_droplist, blend_droplist, norm_droplist)
  
  ; Custom combination
  custom_combination_name = 'Custom combination'
  current_combination = user_widget_mixer_state_to_combination(mixer_widgetIDs, custom_combination_name) 
 
  ; TO-DO hash tables of defaults: norm, min, max
  all_combinations = user_widget_mixer_read_all_combinations(file_settings_combinations)
  
  ; TO-DO: If more preset visualizations are needed, rethink the placement of radio buttons
  nr_combinations = 4
  
  all_combinations = limit_combinations(all_combinations, nr_combinations)
  nr_combinations = all_combinations.length
  
  combination_radios = []
  ; nr_combinations + 1 = nr_radio_buttons
  for i = 0,nr_combinations-1 do begin
    combination_radios = [combination_radios, widget_button(mixer_checkboxes, event_pro='user_widget_mixer_toggle_combination_radio', value=all_combinations[i].title)]
  endfor
  combination_radios = [combination_radios, widget_button(mixer_checkboxes, event_pro='user_widget_mixer_toggle_combination_radio', value=custom_combination_name)]

  ; default combination radio button set to 'custom' (index = nr_combinations)
  widget_control, combination_radios[nr_combinations], set_button=1
  combination_index = nr_combinations
  

  ; --- Mixer Tab: Buttons to Mix selected
  mixer_row_finish = widget_base(base_mixer, /align_left)
  bt_mixer_ok = widget_button(mixer_row_finish, event_pro='user_widget_mixer_ok', value='Mix selected', xoffset= 20, yoffset=20, scr_xsize=120)
  
  mixer_row_finish_test = widget_base(mixer_row_finish, /align_left)
  bt_mixer_test = widget_button(mixer_row_finish_test, event_pro='user_widget_mixer_unit_test', value='Unit test', xoffset= 160, yoffset=20, scr_xsize=120)
  WIDGET_CONTROL, mixer_row_finish_test, MAP=0 ; hide test button
  
  bt_mixer_add_layer = widget_button(mixer_row_finish, event_pro='user_widget_mixer_add_layer', value='Add layer', xoffset= 160, yoffset=20, scr_xsize=120)

  ; --- Preset visualizations ---


  ;---------------------------------------------------------

  ;modify ysize of the GUI depending on user screen resolution
  gui_geometry = widget_info(base_main, /geometry)
  ;get information about user screen resolution
  screen_pixel_size = get_screen_size(resolution=screen_cm_per_pixel_resolution)
  ;check if GUI needs to be resized
  if screen_pixel_size[1] lt gui_geometry.ysize + 2*window_y_offset then begin
    ;GUI won't fit on the screen, resize it before showing it to the user
    new_y_size = screen_pixel_size[1] - 2*window_y_offset
    ;simulate resize event
    gui_size_event = create_struct('TOP', base_main, 'X', gui_geometry.xsize, 'Y', new_y_size)
    resize_event, gui_size_event
  endif

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

  locald_use = 0
  locald_min_rad = 0
  locald_max_rad = 0

  user_cancel = 0   ; user
  
  selection_str = ''; Input files

  
  
  ; Create a pointer to annonymous structure, containing state of widgets
  ;wdgt_state = {svf_nd_entry:svf_nd_entry, svf_sr_entry:svf_sr_entry, ve_entry:ve_entry, nd:nd, sr:sr, ve:ve, user_cancel:user_cancel} 
  p_wdgt_state = ptr_new({rvt_vers:rvt_version, rvt_year:rvt_issue_year,  $    ; Version of RVT and year of issue 
                        ve_entry:ve_entry, ve:ve, $   
                        overwrite:overwrite, overwrite_checkbox:overwrite_checkbox, base_tab:base_tab, $                         ; Vertical exagg.
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
                        user_cancel:user_cancel, convert_dropdown:convert_dropdown, $
                        convert_dropdown_envi:convert_dropdown_envi,tzw_checkbox:tzw_checkbox,erdas_checkbox:erdas_checkbox,$
                        erdas_stat_checkbox:erdas_stat_checkbox,$
                        skyilm_checkbox:skyilm_checkbox, skyilm_checkbox2:skyilm_checkbox2, skyilm_use:skyilm_use, skyilm_shadow_use:skyilm_shadow_use, skyilm_shadow_dist:skyilm_shadow_dist, $  ;Sky illumination
                            skyilm_model:skyilm_model, skyilm_points:skyilm_points, skyilm_az:skyilm_az, skyilm_el:skyilm_el,$
                            skyilm_droplist_entry:skyilm_droplist_entry, skyilm_droplist2_entry:skyilm_droplist2_entry, skyilm_droplist3_entry:skyilm_droplist3_entry,$
                            skyilm_az_entry:skyilm_az_entry, skyilm_el_entry:skyilm_el_entry, $
                        locald_checkbox:locald_checkbox,locald_use:locald_use,locald_min_entry:locald_min_entry, locald_max_entry:locald_max_entry,locald_min_rad:locald_min_rad, locald_max_rad:locald_max_rad,  $
                        jp2000loss_checkbox:jp2000loss_checkbox, jp2000q_text:jp2000q_text, $
                        output_files_array:output_files_array, $
                        base_mixer_layers:base_mixer_layers, $
                        mixer_layer_filepaths:mixer_layer_filepaths, $
                        mixer_layer_images:mixer_layer_images, $
                        mixer_layers_rgb:mixer_layers_rgb, $
                        selection_str:selection_str, $  ; selection string
                        in_orientation:1, $             ; tiff reading parameters
                        mixer_row_0:mixer_row_0, mixer_row_2:mixer_row_2, $     ; Mixer states
                        vis_droplist:vis_droplist, $
                        blend_droplist:blend_droplist, $
                        norm_droplist:norm_droplist, $
                        hash_vis_norm_default:hash_vis_norm_default, $
                        hash_vis_get_index:hash_vis_get_index, $
                        hash_norm_get_index:hash_norm_get_index, $
                        hash_blend_get_index:hash_blend_get_index, $
;                        nr_layers:nr_layers, $
                        layers_tag:layers_tag, $
                        vis_max_limit:vis_max_limit, $
                        vis_min_limit:vis_min_limit, $
                        vis_max_default:vis_max_default, $
                        vis_min_default:vis_min_default, $
                        custom_combination_name:custom_combination_name, $
                        nr_combinations:nr_combinations, $
                        combination_radios:combination_radios, $
                        mixer_row_finish:mixer_row_finish, bt_mixer_ok:bt_mixer_ok, bt_mixer_test:bt_mixer_test, $
                        mixer_widgetIDs:mixer_widgetIDs, $
                        current_combination:current_combination, $
                        current_combination_file_names:file_names, $
                        all_combinations:all_combinations, combination_index:combination_index, $
                        is_blend_image_rbg:is_blend_image_rbg, $
                        temp_sav:temp_sav, rvt_version:rvt_version, rvt_issue_year:rvt_issue_year}, $
                        /no_copy)  ; data stored in heap only

  ;skip GUI creation if user specied any files in process_files text file
  widget_control, base_main, set_uvalue=p_wdgt_state
  if keyword_set(skip_gui) then user_widget_ok, create_struct('TOP', base_main) $
  else begin
    widget_control, base_main, /realize     ; create the widget
    user_widget_mixer_validate_visualization_all, p_wdgt_state
    xmanager, 'resize', base_main ; wait for the events
  endelse
;  xmanager, 'rvt_sa_v1', base_main    ; wait for the events
  
  ; Get the user values and free the pointer
  wdgt_state = *p_wdgt_state
  
  ; Continue after event handler: restore user inputs  ==========================
;  restore, 'skyview_tmp.sav'   ;  restores from C:\Documents and Settings\UserName\
;  file_delete, 'skyview_tmp.sav', /allow_nonexistent
  if wdgt_state.user_cancel eq 3 then topo_advanced_vis  ;user_cancel state from converter
  if wdgt_state.user_cancel then begin
    file_delete, temp_sav, /allow_nonexistent, /quiet
    return
  endif
  
  ;=========================================================================================================
  ;=== Save settings to temporary .sav file ================================================================
  ;=========================================================================================================
  save_to_sav, wdgt_state, temp_sav

  ;=========================================================================================================
  ;=== Setup constnants that cannot be changed by the user =================================================
  ;=== Initialize input parameters by user-selected values =================================================
  ;=== Start processing metadata TXT file ==================================================================
  ;=== Select input DEM and verify geotiff information =====================================================
  ;=== Start processing  ===================================================================================
  ;=== Write processing metadata into TXT metafile =========================================================
  ;=========================================================================================================

  topo_advanced_make_visualizations, p_wdgt_state, temp_sav, wdgt_state.selection_str, rvt_version, rvt_issue_year
  
  ; Free pointer
  ptr_free, p_wdgt_state
  
  
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