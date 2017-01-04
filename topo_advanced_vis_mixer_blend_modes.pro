;
; NAME:
;       topo_advanced_vis_mixer_blend_modes
;
; PURPOSE:
;+
;       These functions perform image blending operations on images and apply transparency / opacity.
;
; :Categories:
;       Utilities
;
; :Params:
;       image: in, required, type=image 
;           loaded image (numeric representation)
;       opacity: in, required
;           value of alpha channel (measure of the object's opacity), where:
;           1.0 = complete opacity
;           0.0 = complete transparency
;
; :Examples:
;       TO-DO
;
; :Author:
;       Maja Somrak (ZRC SAZU)
;
; :Copyright:
;       ZRC SAZU (Novi trg 2, 1000 Ljubljana, Slovenia) & Space-SI (Askerceva 12, 1000 Ljubljana, Slovenia)
;
; :History:
;       December 2016
;-

; Normal
function blend_normal, active, background
  return, active
end

; Multiply
function blend_multiply, active, background
  blended_image = active * background 
  return, blended_image
end

; Blend
; A combination of multiply and screen.Also the same as Hard Light commuted
function blend_overlay, active, background
  blended_image = background[*]
  
  idx_GT = WHERE(background GT 0.5)
  idx_LE = WHERE(background LE 0.5)
  
  blended_image[idx_GT] = (1 - (1-2*(background[idx_GT]-0.5)) * (1-active[idx_GT]))
  blended_image[idx_LE] = ((2*background[idx_LE]) * active[idx_LE])
  return, blended_image
  
;  blended_image = target[*]
;
;  idx_GT = WHERE(target GT 0.5)
;  idx_LE = WHERE(target LE 0.5)
;
;  blended_image[idx_GT] = (1 - (1-2*(target[idx_GT]-0.5)) * (1-blend[idx_GT]))
;  blended_image[idx_LE] = ((2*target[idx_LE]) * blend[idx_LE])
;  return, blended_image
end

; 
; TO-DO:
; - check whih component is L (luminosity)
; - HLS structure
; 
; Luminosity mode blends the lightness values while ignoring the color information
function blend_luminosity, active, background
  COLOR_CONVERT, active, HLS_target, /RGB_HLS
  COLOR_CONVERT, background, HLS_blend, /RGB_HLS
  L = 1 ;index of lightness
  
  HLS_blended_image = HLS_background[*]
  HLS_blended_image[L] = HLS_active[L]
  
  COLOR_CONVERT, HLS_blended_image, blended_image, /HLS_RGB
  return, blended_image
end

; Screen
function blend_screen, active, background
  blended_image = 1 - (1-active) * (1-background)
  return, blended_image
end

function blend_images, blend_mode, active, background
  case blend_mode of
    'Multiply': return, blend_multiply(active, background)
    'Overlay': return, blend_overlay(active, background)
    'Luminosity': return, blend_luminosity(active, background)
    'Screen': return, blend_screen(active, background)
    ELSE: return, blend_normal(active, background)
  endcase
end

; Rendering images from two layers into one
function render_images, active, background, opacity
  rendered_image = active * opacity + background * (1 - opacity)
  return, rendered_image
end

; Rendering across all layers - from last to first layer
; 
; layers - from wdgt_state
; images - array of images
;          Each image is either: (1) image of visualization + blending or (2) original image (if vis EQ '<none>' for that layer)
;
function render_all_images, layers, images
  rendered_image = []

  for i=layers.length-1,0,-1 do begin
    ; if current layer has no visualization applied, skip
    if (layers[i].vis EQ '<none>') then continue

    ; if current layer has visualization applied, but there has been no rendering of images yet,
    ; then current layer will be the initial value of rendered_image
    if (rendered_image EQ []) then begin
      rendered_image = images[i]
      continue
    endif else begin
      ; if current layer has visualization applied, render it as active layer, where old rendered_image is background layer
      active = images[i]
      background = rendered_image
      blend_mode = layers[i].blend_mode
      opacity = layers[i].opacity
      
      top = blend_images(blend_mode, active, background)
      rendered_image = render_images(top, background, opacity)
    endelse
  endfor
  
  return, rendered_image
end

; For every input file
pro mixer_render_layered_images, event
  widget_control, event.top, get_uvalue=p_wdgt_state
  
  layers = (*p_wdgt_state).current_combination.layers

  ; Images to blend
  images = (*p_wdgt_state).mixer_layer_images

  ; Apply blending modes
  blended_images = images[*]
  for i=0,nr_layers-1 do begin
    if (visualization EQ '<none>') then continue
    blended_images[i] = blend_image(layers[i].blend_mode, images[visualization])
  endfor

  ; Rendering in order
  final_image = render_all_images(layers, blended_images)

  ; Save image to file
  overwrite = (*p_wdgt_state).overwrite
  widgetID = (*p_wdgt_state).combination_radios[combination_index]
  widget_control, widgetID, get_value = radio_label
  radio_label = StrJoin(StrSplit(radio_label, ' ', /Regex, /Extract, /Preserve_Null), '_')

  out_file = in_file + '_'+ radio_label
  write_image_to_geotiff, overwrite, out_file, final_image
end

; 
pro topo_advanced_vis_mixer_blend_modes, event
  widget_control, event.top, get_uvalue=p_wdgt_state
  in_file_string = (*p_wdgt_state).selection_str

  in_file_list = strsplit(in_file_string, '#', /extract)
  for nF = 0,in_file_list.length-1 do begin
    ;Input file
    in_file = in_file_list[nF]
    print, 'File name:', in_file
    
    ; Get file names of produced files and open them for layering
    mixer_input_images_to_layers, event, in_file

    ; Apply blend modes, opacity and render into a composed image
    mixer_render_layered_images, event
  endfor
  
end

