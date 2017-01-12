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
  if (size(active, /N_DIMENSIONS) EQ 2) then active = grayscale_to_RGB(active)
  return, RGB_to_float(active)
end

; Screen
function blend_screen, active, background
  blended_image = 1 - (1-active) * (1-background)
  return, blended_image
end

; Multiply
function blend_multiply, active, background
  blended_image = active * background
  return, blended_image
end

; Overlay
; - combination of multiply and screen
function blend_overlay, active, background
  ;blended_image = background[*] ; copying layer to get the dimensions of blended_image right

  idx1 = WHERE_XYZ(background GT 0.5, XIND=x1, YIND=y1, ZIND=z1) 
  idx2 = WHERE_XYZ(background LE 0.5, XIND=x2, YIND=y2, ZIND=z2) 
 
  background[x1,y1,z1] = (1 - (1-2*(background[x1,y1,z1]-0.5)) * (1-active[x1,y1,z1]))
  background[x2,y2,z2] = ((2*background[x2,y2,z2]) * active[x2,y2,z2])

  return, background
end

function equation_blend, blend_mode, active, background 
    case blend_mode of
      'Screen': return, blend_screen(active, background)
      'Multiply': return, blend_multiply(active, background)
      'Overlay': return, blend_overlay(active, background)
    endcase
end

; For images that could be either grayscale or RGB
function blend_multi_dim_images, blend_mode, active, background
  n_active = size(active, /N_DIMENSIONS)
  n_background = size(background, /N_DIMENSIONS)
  
  ; Transform grayscale to rgb
  if (n_active EQ 2) then active = grayscale_to_RGB(active)
  if (n_background EQ 2) then background = grayscale_to_RGB(background)
  
  ; Float to RGB (if it's not already)
  if (max(active) GT 1.1) then active = RGB_to_float(active)
  if (max(background) GT 1.1) then background = RGB_to_float(background)
  
  return, equation_blend(blend_mode, active, background)
  
;  for i=0,2 do begin
;    blended_image[i] = equation_blend(blend_mode, active[i], background[i])
;  endfor

;  blended_image = background[*]
;  if (a_rgb) then begin
;    if (b_rgb) then begin
;      for i=0,2 do begin
;        blended_image[i] = equation_blend(blend_mode, active[i], background[i])
;      endfor
;    endif
;    if (~b_rgb) then begin
;      blended_image = active[*]
;      for i=0,2 do begin
;        blended_image[i] = equation_blend(blend_mode, active[i], background)
;      endfor
;    endif
;  endif
;  if (b_rgb) then begin
;    for i=0,2 do begin
;      blended_image[i] = equation_blend(blend_mode, active, background[i])
;    endfor
;  endif
;  if (~a_rgb AND ~b_rgb) then begin
;    blended_image = equation_blend(blend_mode, active, background)
;  endif
  
  return, blended_image
end

function get_luminosity, active, L_channel_in_HLS
  n_channels = size(active, /N_DIMENSIONS)

  ; Monochrome (1) image
  if (n_channels EQ 2) then begin
    ; Luminosity of monochrome image IS the monochrome image itself
    ; Make sure it's correct value scale!
    luminosity = numeric_to_luminosity(active)
    return, luminosity
  endif
  ; Multichannel, RGB (3) image
  if (n_channels EQ 3) then begin
    ; Float to RGB (if it's not already)
    if (max(active) LT 1.1) then begin
      active = float_to_RGB(active)
    endif
    
    COLOR_CONVERT, active, HLS_active, /RGB_HLS
    luminosity =  reform(HLS_active[L_channel_in_HLS, *, *])
    return, luminosity
  endif
end

; TO-DO:
; - check whih component is L (luminosity)
; - HLS structure
; 
; Luminosity 
; - blends the lightness values while ignoring the color information
function blend_luminosity, active, background
   L_channel_in_HLS = 1
   ;TO-DO - check
   n_active = size(active, /N_DIMENSIONS)
   n_background = size(background, /N_DIMENSIONS)
   
   
   ; Transform grayscale to rgb
   if (n_active EQ 2) then active = grayscale_to_RGB(active)
   if (n_background EQ 2) then background = grayscale_to_RGB(background)
   
   ; Float to RGB (if it's not already)
   if (max(active) LT 1.1) then active = float_to_RGB(active)
   if (max(background) LT 1.1) then background = float_to_RGB(background)

   COLOR_CONVERT, background, HLS_background, /RGB_HLS  
   COLOR_CONVERT, active, HLS_active, /RGB_HLS

   ; Replace luminosity channel in background layer with luminosity from active layer
   HLS_background[L_channel_in_HLS, *, *] = HLS_active[L_channel_in_HLS, *, *]

   ; HLS to RGB
   COLOR_CONVERT, HLS_background, blended_image, /HLS_RGB
   ; RGB to Float
   blended_image = RGB_to_float(blended_image)
   return, blended_image

   

;   ; Multichannel, RGB (3) background layer [n_background = 3]
;   if (n_background EQ 3) then begin
;      ; Float to RGB (if it's not already)
;      if (max(background) LT 1.1) then background = float_to_RGB(background)
;      
;      COLOR_CONVERT, background, HLS_background, /RGB_HLS
;      
;      ; Replace luminosity channel in background layer with luminosity from active layer
;      luminosity = get_luminosity(active, L_channel_in_HLS)
;      dimensions = size(HLS_background[L_channel_in_HLS, *, *], /DIMENSIONS)
;      x_size = dimensions[1]
;      y_size = dimensions[2]
;      HLS_background[L_channel_in_HLS, *, *] = reform(luminosity, 1, x_size, y_size)
; 
;      ; HLS to RGB
;      COLOR_CONVERT, HLS_background, blended_image, /HLS_RGB
;      ; RGB to Float
;      blended_image = RGB_to_float(blended_image)
;      return, blended_image
;   endif
;   ; Replacing luminosity of single channel, monochrome image
;   ; means replacing the monochrome image completely
;   if (n_background EQ 2) then begin
;      return, get_luminosity(active, L_channel_in_HLS)
;   endif
end

function blend_images, blend_mode, active, background
  case blend_mode of
    'Multiply': return, blend_multi_dim_images(blend_mode, active, background) 
    'Overlay': return, blend_multi_dim_images(blend_mode, active, background) 
    'Screen': return, blend_multi_dim_images(blend_mode, active, background) 
;    'Multiply': return, blend_multiply(active, background)
;    'Overlay': return, blend_overlay(active, background)
;    'Screen': return, blend_screen(active, background)
    'Luminosity': return, blend_luminosity(active, background)
    ELSE: return, blend_normal(active, background)
  endcase
end

; Rendering images from two layers into one
function render_images, active, background, opacity
  
  if (max(active) GT 1.1) then active = RGB_to_float(active)
  if (max(background) GT 1.1) then background = RGB_to_float(background)
  
  if (opacity GT 1) then opacity = float(opacity) /100
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
    visualization = layers[i].vis
    if (visualization EQ '<none>') then continue

    ; if current layer has visualization applied, but there has been no rendering of images yet,
    ; then current layer will be the initial value of rendered_image
    if (rendered_image EQ []) then begin
      rendered_image = images[visualization]
      continue
    endif else begin
      ; if current layer has visualization applied, render it as active layer, where old rendered_image is background layer
      active = images[visualization]
      background = rendered_image
      blend_mode = layers[i].blend_mode
      opacity = layers[i].opacity
      
      top = blend_images(blend_mode, active, background)
      rendered_image = render_images(top, background, opacity)
    endelse
  endfor
  
  return, rendered_image
end

; Save rendered image (blended) to file
pro write_rendered_image_to_file, p_wdgt_state, in_file, final_image
  final_image = float_to_RGB(final_image)

  overwrite = (*p_wdgt_state).overwrite
  widgetID = (*p_wdgt_state).combination_radios[(*p_wdgt_state).combination_index]
  widget_control, widgetID, get_value = radio_label
  
  radio_label = StrJoin(StrSplit(radio_label, ' ', /Regex, /Extract, /Preserve_Null), '_')
  radio_label_tif = '_'+radio_label+'.tif'
  out_file = StrJoin(StrSplit(in_file, '.tif', /Regex, /Extract, /Preserve_Null), radio_label_tif)
  write_image_to_geotiff, overwrite, out_file, final_image
end


; For every input file
pro mixer_render_layered_images, event, in_file
  widget_control, event.top, get_uvalue=p_wdgt_state
  
  layers = (*p_wdgt_state).current_combination.layers
  images = (*p_wdgt_state).mixer_layer_images

  ; Rendering in order
  final_image = render_all_images(layers, images)
  
  ; If RBG, put all channels into one image
;  if (size(final_image, /N_DIMENSIONS) EQ 3) then begin
;    merged_image = merge_channels(final_image)
;  endif

  ; Save image to file
  write_rendered_image_to_file, p_wdgt_state, in_file, final_image
end


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
    
    ; Normalize images on all layers
    mixer_normalize_images_on_layers, event

    ; Apply blend modes, opacity and render into a composed image
    mixer_render_layered_images, event, in_file
  endfor
  
end

