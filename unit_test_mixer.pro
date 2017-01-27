; +
; 
; TESTING
; 
; 
; 
; 
; 
; -
;

function test_combination, event, in_file, visualization, blend_mode, opacity, ref_visualization
  widget_control, event.top, get_uvalue=p_wdgt_state

  ; Generate combination
  title = visualization +' '+blend_mode+' '+STRTRIM(opacity, 2)
  combination = gen_combination(title, 4)
  combination.layers[0] = create_new_mixer_layer(VISUALIZATION = visualization, BLEND_MODE = blend_mode, OPACITY = opacity, p_wdgt_state = p_wdgt_state)
  combination.layers[1] = create_new_mixer_layer(VISUALIZATION = ref_visualization, p_wdgt_state = p_wdgt_state)

  ; Put combination in widgets and current_combination
  combination_to_mixer_widgets, p_wdgt_state, combination, /SET_TITLE
  (*p_wdgt_state).current_combination = combination

  ; Make visualizations
  topo_advanced_make_visualizations, p_wdgt_state, $
    (*p_wdgt_state).temp_sav, $
    in_file, $                         ;(*p_wdgt_state).selection_str, $
    (*p_wdgt_state).rvt_version, $
    (*p_wdgt_state).rvt_issue_year, $
    /INVOKED_BY_MIXER

  ; Blending visualizations with mixer
  topo_advanced_vis_mixer_blend_modes, event

  ; Write image
  title_tif = '_'+StrJoin(StrSplit(title, ' ', /Regex, /Extract, /Preserve_Null), '_')+'.tif'
  out_file = StrJoin(StrSplit(in_file, '.tif', /Regex, /Extract, /Preserve_Null), title_tif)
  write_image_to_geotiff, overwrite, out_file, final_image
  
  return, out_file
end


function mixer_start, event, in_file
  widget_control, event.top, get_uvalue=p_wdgt_state

  op_list = [40,75,100]
  out_file = 'MIXER_TEST_STATS_'+ date_time() + '.txt'
  
  error_count = 0
  
  Get_lun, log
  Openw, log, out_file, /append
  printf, log, ''
  printf, log, ''
  printf, log, ''
  printf, log, ';-------------------------------------------------------------------------'
  printf, log, ';-------------------------------------------------------------------------'
  printf, log, ''
  printf, log, ' FILE: '+ in_file
  printf, log, ''
  printf, log, ';-------------------------------------------------------------------------'
  printf, log, ';-------------------------------------------------------------------------'

  foreach blend_mode, (*p_wdgt_state).blend_droplist do begin
    printf, log, ';------ Blend mode: '+blend_mode+' --------------------'
    printf, log, ';-------------------------------------------------------------------------'
    
    foreach visualization, (*p_wdgt_state).vis_droplist do begin
      if (visualization EQ '<none>') then continue
      ref_visualization = 'PCA of hillshading'
      if (visualization EQ ref_visualization) then ref_visualization = 'Sky-View Factor'
      printf, log, ''
      
      foreach opacity, op_list do begin
;          catch, errorStatus
;          if (errorStatus ne 0) then begin
;            catch, /cancel
;            print, 'ERROR: ', !ERROR_STATE.msg
;            printf, log, 'ERROR: ', !ERROR_STATE.msg
;            error_count++
;            continue
;          endif
      
          out_file = test_combination(event, in_file, visualization, blend_mode, opacity, ref_visualization)
          Printf, log, 'Visualization:  '+visualization+'      Opacity: '+ STRTRIM(opacity, 2)+'      Output file: '+out_file
         
       endforeach
    endforeach
  endforeach
  
  free_lun, log

  return, error_count
end

pro unit_test_mixer, event, in_file
   
   error_count = mixer_start(event, in_file)

   if error_count gt 0 then begin
     print, 'Unit test fails, number of errors: ' + STRTRIM(error_count, 2)
   endif else begin
     print, 'Unit test passed! Check log file and output images.'
   endelse 
   
end

