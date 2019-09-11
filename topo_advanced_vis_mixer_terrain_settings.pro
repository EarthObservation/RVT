;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;   TERRAIN SETTINGS
;
;
; 1. VISUALIZATIONS TAB
; HS                               35        5 (15)    55 (?)
; MHS                              35        5 (15)    45
; SLRM radius (m)                  10        5         25
; LD search radius  (m)            10-20     10-20     10
; LD observer height  (m)          1.7       1.7       16
; SVF radius (always 10?)
;
;
; 2. MIXER TAB
; slope lin. histogram stretch     0-50°     0-15°     0-60°
; SLRM linear hist. stretch        -1,1      -0.5,0.5  -2,2
; SVF lin. hist. stretch           0.65,1.   0.9,1.    0.55,1.
; POZ. OPEN lin. hist. stretch     65-90°    85-91°    55-95°
; NEG. OPEN lin. hist. stretch     60-95°    75-95°    45-95°
; LD lin. stretch                  0.5-1.8   0.5-3     55°-95°   >>> ?
;
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

pro set_HS_sun_elevation, p_wdgt_state, angle
  angle = strtrim(string(angle), 2)
  widget_control, (*p_wdgt_state).hls_el_entry, set_value=angle
end

pro set_MHS_sun_elevation, p_wdgt_state, angle
  angle = strtrim(string(angle), 2)
  widget_control, (*p_wdgt_state).mhls_el_entry, set_value=angle
end

pro set_SVF_search_radius, p_wdgt_state, radius_pixels
  radius_pixels = strtrim(string(radius_pixels), 2)
  widget_control, (*p_wdgt_state).svf_sr_entry, set_value= string(radius_pixels)
end

pro set_SVF_remove_noise, p_wdgt_state, str_level
  ; Checkbox tick and Combobox display sensitivity
  if strmatch(str_level, 'none') then begin
    widget_control,(*p_wdgt_state).svf_rn_checkbox, set_button=0
    widget_control,(*p_wdgt_state).svf_rn_row, sensitive=0
    return
  endif else begin
    if strmatch(str_level, 'low') or strmatch(str_level, 'medium') or strmatch(str_level, 'high') then begin
      widget_control,(*p_wdgt_state).svf_rn_checkbox, set_button=1
      widget_control,(*p_wdgt_state).svf_rn_row, sensitive=1
    endif
  endelse

  ; Combobox value
  case str_level of
    'low': widget_control,(*p_wdgt_state).svf_rn_entry, set_combobox_select = 0
    'medium': widget_control,(*p_wdgt_state).svf_rn_entry, set_combobox_select = 1
    'high': widget_control,(*p_wdgt_state).svf_rn_entry, set_combobox_select = 2
  endcase
end

pro set_SLRM_radius, p_wdgt_state, radius_pixels
  radius_pixels = strtrim(string(radius_pixels), 2)
  widget_control, (*p_wdgt_state).slrm_entry, set_value=radius_pixels
end

pro set_LD_radius, p_wdgt_state, radius_min, radius_max
  radius_min = strtrim(string(radius_min), 2)
  radius_max = strtrim(string(radius_max), 2)
  widget_control, (*p_wdgt_state).locald_min_entry, set_value=radius_min
  widget_control, (*p_wdgt_state).locald_max_entry, set_value=radius_max
end

pro set_layer_normalization, p_wdgt_state, layer_nr, min=min , max=max , visualization=!null
  ; Set MIN and MAX on a layer & select default normalization
  if keyword_set(min) or keyword_set(max) then begin
    widgetIDs = (*p_wdgt_state).mixer_widgetIDs
    i = layer_nr
    if keyword_set(min) then widget_control, widgetIDs.layers[i].min, set_value = strtrim(string(min),2)
    if keyword_set(max) then widget_control, widgetIDs.layers[i].max, set_value = strtrim(string(max),2)

    vis_norm_hash = gen_vis_norm_default()
    if keyword_set(visualization) then vis = visualization $
    else vis =widget_info(widgetIDs.layers[i].vis, /combobox_gettext)
    widget_control, widgetIDs.layers[i].normalization, set_combobox_select = (*p_wdgt_state).hash_norm_get_index[vis_norm_hash[vis]]
  endif

  ; For visualizations that have same layer normalizations regardless of terrain type
  if keyword_set(visualization) and not(keyword_set(min) or keyword_set(max)) then begin
    case visualization of
      'Analytical hillshading': set_layer_normalization, p_wdgt_state, layer_nr=i, min=0, max=1
      'Hillshading from multiple directions': set_layer_normalization, p_wdgt_state, layer_nr=i, min=0 , max=1
      'PCA of hillshading': set_layer_normalization, p_wdgt_state, layer_nr=i, min=2.0 , max=2.0
      'Simple local relief model': set_layer_normalization, p_wdgt_state, layer_nr=i, min=-1.0 , max=1.0
      'Anisotropic Sky-View Factor': set_layer_normalization, p_wdgt_state, layer_nr=i, min=0.65 , max=1.0
      'Sky illumination': set_layer_normalization, p_wdgt_state, layer_nr=i, min=0.25 , max=0.3
    endcase
  endif
end

pro apply_terrain_settings, event, $
  hs_sun_elevation=hs_sun_elevation, $
  mhs_sun_elevation=mhs_sun_elevation, $
  slrm_radius=slrm_radius, $
  svf_noise=svf_noise, $
  svf_radius=svf_radius, $
  ld_radius_min=ld_radius_min, ld_radius_max=ld_radius_max, $
  slope_min=slope_min, slope_max=slope_max, $
  svf_min=svf_min, svf_max=svf_max, $
  pos_open_min=pos_open_min, pos_open_max=pos_open_max, $
  neg_open_min=neg_open_min, neg_open_max=neg_open_max, $
  ld_min=ld_min, ld_max=ld_max

  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state

  ; VISUALIZATIONS TAB
  if keyword_set(hs_sun_elevation) then set_HS_sun_elevation, p_wdgt_state, hs_sun_elevation
  if keyword_set(mhs_sun_elevation) then set_MHS_sun_elevation, p_wdgt_state, mhs_sun_elevation
  if keyword_set(slrm_radius) then set_SLRM_radius, p_wdgt_state, slrm_radius
  if keyword_set(svf_noise) then set_SVF_remove_noise, p_wdgt_state, svf_noise
  if keyword_set(svf_radius) then set_SVF_search_radius, p_wdgt_state, svf_radius
  if keyword_set(ld_radius_min) or keyword_set(ld_radius_max) then set_LD_radius, p_wdgt_state, ld_radius_min, ld_radius_max

  ; MIXER TAB
  layers = (*p_wdgt_state).current_combination.layers
  for i=0,layers.length-1 do begin
    visualization = layers[i].vis
    if (visualization eq '<none>') then continue
    case visualization of
      'Slope gradient': set_layer_normalization, p_wdgt_state, i, min=slope_min, max=slope_max
      'Sky-View Factor': set_layer_normalization, p_wdgt_state, i, min=svf_min, max=svf_max
      'Openness - Positive': set_layer_normalization, p_wdgt_state, i, min=pos_open_min, max=pos_open_max
      'Openness - Negative': set_layer_normalization, p_wdgt_state, i, min=neg_open_min, max=neg_open_max
      'Local dominance': set_layer_normalization, p_wdgt_state, i, min=ld_min, max=ld_max
      else: set_layer_normalization, p_wdgt_state, i, visualization=visualization
    endcase
  endfor

end

pro user_widget_mixer_set_terrain, event, terrain_type
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state


  terrain_hash = hash()
  terrain_hash += hash('flat', flat_terrain_settings())
  terrain_hash += hash('general', general_terrain_settings())
  terrain_hash += hash('steep', steep_terrain_settings())

  ts = terrain_hash[terrain_type]

  apply_terrain_settings, event, $
    hs_sun_elevation=ts['hs_sun_elevation'], $
    mhs_sun_elevation=ts['mhs_sun_elevation'], $
    slrm_radius=ts['slrm_radius'], $
    svf_noise=ts['svf_noise'], $
    svf_radius=ts['svf_radius'], $
    ld_radius_min=ts['ld_radius_min'], $
    ld_radius_max=ts['ld_radius_max'], $
    slope_min=ts['slope_min'], $
    slope_max=ts['slope_max'], $
    svf_min=ts['svf_min'], $
    svf_max=ts['svf_max'], $
    pos_open_min=ts['pos_open_min'], $
    pos_open_max=ts['pos_open_max'], $
    neg_open_min=ts['neg_open_min'], $
    neg_open_max=ts['neg_open_max'], $
    ld_min=ts['ld_min'], $
    ld_max=ts['ld_max']

end

;pro user_widget_mixer_save_terrain_radio, event
;  widget_control, event.top, get_uvalue=p_wdgt_state
;
;  for i=0,(*p_wdgt_state).terrain_radios.length-1 do begin
;    if (1 EQ widget_info((*p_wdgt_state).terrain_radios[i], /button_set)) then begin
;      (*p_wdgt_state).terrain_index = i
;      return
;    endif
;  endfor
;end

pro user_widget_mixer_save_terrain_combobox, event
  widget_control, event.top, get_uvalue=p_wdgt_state

  ; if terrain preset is checked in the first place
  preset_terrain = widget_info((*p_wdgt_state).terrain_checkbox, /button_set)
  if not preset_terrain then begin
    (*p_wdgt_state).terrain_index = -1
    (*p_wdgt_state).terrain_type = 'none'
    return
  endif

  ; if terrain preset is checked
  terrain_type = widget_info((*p_wdgt_state).terrain_entry, /combobox_gettext)
  widget_control, (*p_wdgt_state).terrain_entry, get_value=terrain_types

  for i=0,terrain_types.length-1 do begin
    if (terrain_types[i] eq terrain_type) then begin
      (*p_wdgt_state).terrain_index = i
      (*p_wdgt_state).terrain_type = terrain_type
      return
    endif
  endfor
end

pro user_widget_mixer_toggle_terrain, event
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state

  ; Checkbox selected or not -> make conboboc (in)visible
  widget_control, (*p_wdgt_state).terrain_entry, sensitive = widget_info((*p_wdgt_state).terrain_checkbox, /button_set)

  user_widget_mixer_save_terrain_combobox, event
  print, 'Selected terrain: ', (*p_wdgt_state).terrain_type ; because indices start with 0 in array, but with 1 in GUI

  if strmatch((*p_wdgt_state).terrain_type, 'none') then return $
  else user_widget_mixer_set_terrain, event, (*p_wdgt_state).terrain_type

  user_widget_mixer_validate_visualization_all, p_wdgt_state
end

;pro user_widget_mixer_toggle_terrain_radio, event
;  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state
;
;  user_widget_mixer_save_terrain_radio, event
;
;  ;TODO:
;  index = (*p_wdgt_state).terrain_index
;  widget_control, (*p_wdgt_state).terrain_radios[index], get_value = terrain_type
;  print, 'Selected terrain: ', terrain_type ; because indices start with 0 in array, but with 1 in GUI
;
;  WIDGET_CONTROL, event.ID, GET_VALUE=terrain_type
;
;  (*p_wdgt_state).terrain_type = terrain_type
;
;
;  IF event.SELECT  EQ 1 THEN BEGIN
;    user_widget_mixer_set_terrain, event, terrain_type
;  ENDIF
;
;
;  user_widget_mixer_validate_visualization_all, p_wdgt_state
;end


function normalization_match, vis, vis_check, ts, layer, min_test, max_test
  mismatch = BOOLEAN(0)
  if (vis eq vis_check) then begin
    if not (ts[min_test] eq layer.min) then mismatch = BOOLEAN(1)
    if not (ts[max_test] eq layer.max) then mismatch = BOOLEAN(1)
    ;    if not (ts[norm_test] eq layer.normalization) then mismatch = BOOLEAN(1)
  endif
  return, mismatch
end

; WHEN ANY (VISUALIZATIONS, MIXER LAYERS) PARAMETERS ARE CHANGED
pro user_widget_mixer_check_if_preset_terrain, event
  widget_control, event.top, get_uvalue=p_wdgt_state  ; structure containing widget state

  ; save how checks are currently displayed
  user_widget_mixer_save_terrain_combobox, event

  preset_found = BOOLEAN(0)
  mismatch = BOOLEAN(0)

  matching_terrain = ''
  ; terrain setting
  terrain_hash = hash()
  terrain_hash += hash('flat', flat_terrain_settings())
  terrain_hash += hash('general', general_terrain_settings())
  terrain_hash += hash('steep', steep_terrain_settings())

  combination = user_widget_mixer_state_to_combination((*p_wdgt_state).mixer_widgetIDs, (*p_wdgt_state).current_combination.title)
  layers = combination.layers

  foreach ts, terrain_hash, key do begin
    
    mismatch = BOOLEAN(0)
    for i=0, layers.length-1 do begin
      vis = layers[i].vis
      if (vis eq '<none>') then continue

      if (vis eq 'Analytical hillshading') then begin
        widget_control, (*p_wdgt_state).hls_el_entry, get_value = hs_sun_elevation
        if (ts['hs_sun_elevation'] ne hs_sun_elevation) then mismatch = BOOLEAN(1)
      endif

      if (vis eq 'Hillshading from multiple directions') then begin
        widget_control, (*p_wdgt_state).mhls_el_entry, get_value = mhs_sun_elevation
        if (ts['mhs_sun_elevation'] ne mhs_sun_elevation) then mismatch = BOOLEAN(1)
      endif

      if (vis eq 'Slope gradient') then begin
        mismatch = mismatch or normalization_match(vis, 'Slope gradient', ts, layers[i], 'slope_min', 'slope_max')
      endif

      if (vis eq 'Simple local relief model') then begin
        widget_control, (*p_wdgt_state).slrm_entry, get_value = slrm_radius
        if (ts['slrm_radius'] ne slrm_radius) then mismatch = BOOLEAN(1)
      endif

      if (vis eq 'Sky-View Factor') then begin
        mismatch = mismatch or normalization_match(vis, 'Sky-View Factor', ts, layers[i], 'svf_min', 'svf_max')
      endif

      if (vis eq 'Sky-View Factor') or (vis eq 'Openness - Positive') or (vis eq  'Openness - Negative') or (vis eq 'Anisotropic Sky-View Factor') then begin
        svf_noise = widget_info((*p_wdgt_state).svf_rn_entry, /combobox_gettext)
        svf_rn = widget_info((*p_wdgt_state).svf_rn_checkbox, /button_set)
        if not svf_rn then svf_noise = 'none'
        if (ts['svf_noise'] ne svf_noise) then mismatch = BOOLEAN(1)

        widget_control, (*p_wdgt_state).svf_sr_entry, get_value = svf_radius
        if (ts['svf_radius'] ne svf_radius) then mismatch = BOOLEAN(1)
      endif

      if (vis eq 'Openness - Positive') then begin
        mismatch = mismatch or normalization_match(vis, 'Openness - Positive', ts, layers[i], 'pos_open_min', 'pos_open_max')
      endif

      if (vis eq 'Openness - Negative') then begin
        mismatch = mismatch or normalization_match(vis, 'Openness - Negative', ts, layers[i], 'neg_open_min', 'neg_open_max')
      endif

      if (vis eq 'Local dominance') then begin
        mismatch = mismatch or normalization_match(vis, 'Local dominance', ts, layers[i], 'ld_min', 'ld_max')
        widget_control, (*p_wdgt_state).locald_min_entry, get_value = ld_min
        if (ts['ld_radius_min'] ne ld_min) then mismatch = BOOLEAN(1)
        widget_control, (*p_wdgt_state).locald_max_entry, get_value = ld_max
        if (ts['ld_radius_max'] ne ld_max) then mismatch = BOOLEAN(1)
      endif

      if mismatch then break

    endfor

    if mismatch then continue

    matching_terrain = key
    preset_found = BOOLEAN(1)
    break

  endforeach


  if (preset_found) then begin
    terrain_types = gen_terrain_types()
    widget_control, (*p_wdgt_state).terrain_checkbox, set_button=1
    widget_control, (*p_wdgt_state).terrain_entry, sensitive=1
    for i=0,terrain_types.length-1 do begin
      if strmatch(terrain_types[i], matching_terrain) then begin
        widget_control, (*p_wdgt_state).terrain_entry, set_combobox_select=i
        return
      endif
    endfor
  endif else begin
    ; uncheck the checkbox and remove sensitivity from combobox
    widget_control, (*p_wdgt_state).terrain_checkbox, set_button=0
    widget_control, (*p_wdgt_state).terrain_entry, sensitive=0
  endelse

end

pro topo_advanced_vis_mixer_terrain_settings

end