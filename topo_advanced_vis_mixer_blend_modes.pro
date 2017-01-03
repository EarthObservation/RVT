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

function blend_image_multiply, blended_image

  return, blended_image
end

function blend_image_overlay, blended_image

  return, blended_image
end

function blend_image_luminosity, blended_image

  return, blended_image
end

function blend_image_screen, blended_image

  return, blended_image
end

function blend_image, blend_mode, old_image
  case blend_mode of
    'Multiply': return, blend_image_multiply(old_image)
    'Overlay': return, blend_image_overlay(old_image)
    'Luminosity': return, blend_image_luminosity(old_image)
    'Screen': return, blend_image_screen(old_image)
    ELSE: return, old_image
  endcase
end

; Rendering images from two layers into one
; 
;  :Params:
;       A_image - Active layer image (top)
;       B_image - Background layer image (bottom)
;       opacity - opacity of Active layer image
; Output:
;       rendered_image
function render_images, A_image, B_image, opacity
  rendered_image = A_image * opacity + B_image * (1 - opacity)
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
      rendered_image = render_images(images[i], rendered_image, layers[i].opacity)
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
    
    ; Get file names of produced files and open them for layering
    mixer_input_images_to_layers, event, in_file

    ; Apply blend modes, opacity and render into a composed image
    mixer_render_layered_images, event
  endfor
  
end

