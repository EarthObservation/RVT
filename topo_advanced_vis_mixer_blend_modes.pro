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


function image_join_channels, R, G, B
  dim = size(R, /DIMENSIONS)
  x_size = dim[0]
  y_size = dim[1]
  rgb = make_array(3, x_size, y_size)

  rgb[0, *, *] = reform(R, 1, x_size, y_size)
  rgb[1, *, *] = reform(G, 1, x_size, y_size)
  rgb[2, *, *] = reform(B, 1, x_size, y_size)

  return, rgb
end

; Normal
function blend_normal, active, background
   return, active
end

; Screen
function blend_screen, active, background
  blended_image = 1 - (1-active) * (1-background)
  ;blended_image = active + background - active * background
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

  idx1 = WHERE_XYZ(background GT 0.5, XIND=x1, YIND=y1);, ZIND=z1) 
  idx2 = WHERE_XYZ(background LE 0.5, XIND=x2, YIND=y2);, ZIND=z2) 
 
  background[x1,y1] = (1 - (1-2*(background[x1,y1]-0.5)) * (1-active[x1,y1]))
  background[x2,y2] = ((2*background[x2,y2]) * active[x2,y2])
 
;  background[x1,y1,z1] = (1 - (1-2*(background[x1,y1,z1]-0.5)) * (1-active[x1,y1,z1]))
;  background[x2,y2,z2] = ((2*background[x2,y2,z2]) * active[x2,y2,z2])

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
  a_rgb = boolean(size(active, /N_DIMENSIONS) EQ 3)
  b_rgb = boolean(size(background, /N_DIMENSIONS) EQ 3)

  blended_image = []
  if (a_rgb) then begin
    if (b_rgb) then begin
      dim = size(background, /DIMENSIONS)
      blended_image = reform(background[*], dim[0], dim[1], dim[2])
      for i=0,2 do begin
        blended_image[i, *, *] = equation_blend(blend_mode, reform(active[i, *, *], dim[1], dim[2]), reform(background[i, *, *], dim[1], dim[2]))
      endfor
    endif
    if (~b_rgb) then begin
      dim = size(active, /DIMENSIONS)
      blended_image = reform(active[*], dim[0], dim[1], dim[2])
      for i=0,2 do begin
        blended_image[i, *, *] = equation_blend(blend_mode, reform(active[i, *, *], dim[1], dim[2]), background)
      endfor
    endif
  endif
  if (~a_rgb AND b_rgb) then begin
    dim = size(background, /DIMENSIONS)
    blended_image = reform(background[*], dim[0], dim[1], dim[2])
    for i=0,2 do begin
      blended_image[i, *, *] = equation_blend(blend_mode, active, reform(background[i, *, *], dim[1], dim[2]))
    endfor
  endif
  if (~a_rgb AND ~b_rgb) then begin
    blended_image = equation_blend(blend_mode, active, background)
  endif
  
  return, blended_image
end

function lum, img
  n_channels = size(img, /N_DIMENSIONS)
  
  if typename(img) ne 'FLOAT' then begin
    lum_img = RGB_to_float(img)
  endif

  if (n_channels EQ 3) then begin
    r = reform(img[0, *, *])
    g = reform(img[1, *, *])
    b = reform(img[2, *, *])

    lum_img = (0.3 * r) + (0.59 * g) + (0.11 * b)    
  endif else begin
    lum_img = img
  endelse
  
  return, lum_img
end

function matrix_eq_min_lt_zero, R, min_lt_zero, lum, min_c
    R[min_lt_zero] = lum[min_lt_zero] + (((R[min_lt_zero] - lum[min_lt_zero]) * lum[min_lt_zero]) / (lum[min_lt_zero] - min_c[min_lt_zero]))
    return, R
end

function matrix_eq_max_gt_one, R, max_c_gt_one, lum, max_c
    R[max_c_gt_one] = lum[max_c_gt_one] + (((R[max_c_gt_one] - lum[max_c_gt_one]) * (1.0 - lum[max_c_gt_one])) / (max_c[max_c_gt_one] - lum[max_c_gt_one]))
    return, R
end

function channel_min, R, G, B    
    min_c = R * 1.0
    idx_min = where(G lt min_c)
    min_c[idx_min] = G[idx_min]
    idx_min = where(B lt min_c)
    min_c[idx_min] = B[idx_min]
    
    return, min_c
end

function channel_max, R, G, B
    max_c = R * 1.0
    idx_max = where(G gt max_c)
    max_c[idx_max] = G[idx_max]
    idx_max = where(B gt max_c)
    max_c[idx_max] = B[idx_max]
    
    return, max_c
end

function clip_color, c, min_c=min_c, max_c=max_c
  lum = lum(c)
  
  R = reform(c[0, *, *])
  G = reform(c[1, *, *])
  B = reform(c[2, *, *])
  
  min_c = channel_min(R, G, B)  
  max_c = channel_max(R, G, B) 
  
  min_lt_zero = where(min_c lt 0.0)
  R = matrix_eq_min_lt_zero(R, min_lt_zero, lum, min_c)
  G = matrix_eq_min_lt_zero(G, min_lt_zero, lum, min_c)
  B = matrix_eq_min_lt_zero(B, min_lt_zero, lum, min_c)
  
  max_c_gt_one = where(max_c gt 1.0)
  R = matrix_eq_max_gt_one(R, max_c_gt_one, lum, max_c)
  G = matrix_eq_max_gt_one(G, max_c_gt_one, lum, max_c)
  B = matrix_eq_max_gt_one(B, max_c_gt_one, lum, max_c)
  
  dimensions = size(c, /DIMENSIONS)
  x_size = dimensions[1]
  y_size = dimensions[2]

  c[0, *, *] = reform(R, 1, x_size, y_size)
  c[1, *, *] = reform(G, 1, x_size, y_size)
  c[2, *, *] = reform(B, 1, x_size, y_size)
  
  return, c
end

function blend_luminosity, active, background, min_c=min_c, max_c=max_c

  lum_active = lum(active)
  lum_background = lum(background)
  
  ; luminosity
  lum = lum_active - lum_background
  
  n_channels = size(background, /N_DIMENSIONS)
  if (n_channels EQ 2) then begin
    return, lum_active
  endif
  
  if (n_channels EQ 3) then begin
    R = reform(background[0, *, *]) + lum
    G = reform(background[1, *, *]) + lum
    B = reform(background[2, *, *]) + lum
    
    dimensions = size(background, /DIMENSIONS)
    x_size = dimensions[1]
    y_size = dimensions[2]
    
    c = make_array(3, x_size, y_size)
    c[0, *, *] = reform(r, 1, x_size, y_size)
    c[1, *, *] = reform(g, 1, x_size, y_size)
    c[2, *, *] = reform(b, 1, x_size, y_size)
  endif
  
  if keyword_set(min_c) and keyword_set(max_c) then clipped_image = clip_color(c, min_c=min_c, max_c=max_c) $
  else clipped_image = clip_color(c)

   return, clipped_image
end

; input images: active & background in
function blend_images, blend_mode, active, background, min_c=min_c, max_c=max_c
  case blend_mode of
    'Multiply': return, blend_multi_dim_images(blend_mode, active, background) 
    'Overlay': return, blend_multi_dim_images(blend_mode, active, background) 
    'Screen': return, blend_multi_dim_images(blend_mode, active, background)
    'Luminosity': return, blend_luminosity(active, background, min_c=min_c, max_c=max_c)
    ELSE: return, blend_normal(active, background)
  endcase
end

function apply_opacity, active, background, opacity
   if (opacity GT 1) then opacity = float(opacity) /100
   return, active * opacity + background * (1 - opacity)
end

; Rendering images from two layers into one
function render_images, active, background, opacity
  if (min(active) LT 0.0 OR max(active) GT 1.1) then active = scale_0_to_1(active)
  if (min(background) LT 0.0 OR max(background) GT 1.1) then background = scale_0_to_1(background)
  
  a_rgb = boolean(size(active, /N_DIMENSIONS) EQ 3)
  b_rgb = boolean(size(background, /N_DIMENSIONS) EQ 3)
  
  rendered_image = []
  if (a_rgb) then begin
    if (b_rgb) then begin
      dim = size(background, /DIMENSIONS)
      rendered_image = reform(background[*], dim[0], dim[1], dim[2])
      for i=0,2 do begin
        rendered_image[i, *, *] = apply_opacity(reform(active[i, *, *], dim[1], dim[2]), reform(background[i, *, *], dim[1], dim[2]), opacity)
      endfor
    endif
    if (~b_rgb) then begin
      dim = size(active, /DIMENSIONS)
      rendered_image = reform(active[*], dim[0], dim[1], dim[2])
      for i=0,2 do begin
        rendered_image[i, *, *] = apply_opacity(reform(active[i, *, *], dim[1], dim[2]), background, opacity)
      endfor
    endif
  endif
  if (~a_rgb AND b_rgb) then begin
    dim = size(background, /DIMENSIONS)
    rendered_image = reform(background[*], dim[0], dim[1], dim[2])
    for i=0,2 do begin
      rendered_image[i, *, *] = apply_opacity(active, reform(background[i, *, *], dim[1], dim[2]), opacity)
    endfor
  endif
  if (~a_rgb AND ~b_rgb) then begin
    rendered_image = apply_opacity(active, background, opacity)
  endif
  
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
      rendered_image = images[i]
      continue
    endif else begin
      ; if current layer has visualization applied, render it as active layer, where old rendered_image is background layer
      active = images[i]
      background = rendered_image
      blend_mode = layers[i].blend_mode
      opacity = layers[i].opacity    
      
      if (min(active) LT 0.0 OR max(active) GT 1) then active = scale_0_to_1(active)
      if (min(background) LT 0.0 OR max(background) GT 1) then background = scale_0_to_1(background)
      
      top = blend_images(blend_mode, active, background, min_c=min_c, max_c=max_c)
      rendered_image = render_images(top, background, opacity)
      
      if (min(background) LT 0.0 OR max(background) GT 1) then begin
        print, 'Rendered image scale distorted!'
      endif
      
    endelse
  endfor
  
  return, rendered_image
end

function get_out_image_name_from_input, p_wdgt_state, in_file;, bit32=bit32
  widgetID = (*p_wdgt_state).combination_radios[(*p_wdgt_state).combination_index]
  widget_control, widgetID, get_value = radio_label

  radio_label = StrJoin(StrSplit(radio_label, ' ', /Regex, /Extract, /Preserve_Null), '_') 
  radio_label_tif = '_'+radio_label+'_8bit.tif'
  
  out_file = StrJoin(StrSplit(in_file, '.tif', /Regex, /Extract, /Preserve_Null), radio_label_tif)
  
  ;TODO: there is another var holding value of combination name!
  ;Combination name could be changed (?) if it's custom combination.
  
  return, out_file
end

; Save rendered image (blended) to file
pro write_rendered_image_to_file, p_wdgt_state, in_file, final_image, geotiff=geotiff, out_file=out_file
  overwrite = (*p_wdgt_state).overwrite
  out_file_RGB = get_out_image_name_from_input(p_wdgt_state, in_file)
  
  final_image_float = scale_0_to_1(final_image)
  final_image_RGB = float_to_RGB(final_image)

  print, out_file_RGB
  write_image_to_geotiff, overwrite, out_file_RGB, final_image_RGB, geotiff=geotiff
  
;  out_file_32 = get_out_image_name_from_input(p_wdgt_state, in_file, /bit32)
;  print, out_file_32
;  write_image_to_geotiff_float, overwrite, out_file_32, final_image_float, geotiff=geotiff
  
  (*p_wdgt_state).output_blend_images_paths.add, out_file_RGB
end

; For every input file
pro mixer_render_layered_images, event, in_file
  widget_control, event.top, get_uvalue=p_wdgt_state
  
  layers = (*p_wdgt_state).current_combination.layers
  images = (*p_wdgt_state).mixer_layer_images

  ; Rendering in order
  final_image = render_all_images(layers, images)
  
  ; Get geotiff data from original file
  tmp_img = read_tiff(in_file, orientation = in_orientation, geotiff=in_geotiff)
  tmp_img = !null
  

  ; Save image to file
  write_rendered_image_to_file, p_wdgt_state, in_file, final_image, geotiff=in_geotiff
end

; For every input file
pro mixer_write_layer_images, event, in_file
  widget_control, event.top, get_uvalue=p_wdgt_state

  layers = (*p_wdgt_state).current_combination.layers
  images = (*p_wdgt_state).mixer_layer_images

  for i=layers.length-1,0,-1 do begin
    ; if current layer has no visualization applied, skip
    visualization = layers[i].vis
    if (visualization EQ '<none>') then continue

    ; Save image to file
    layer_file = 'tmp_'+STRJOIN(STRSPLIT(visualization, /EXTRACT), '_')+'.tif'
    layer_image = images[i]

    write_image_to_geotiff_float, 1, layer_file, layer_image
  endfor
end

pro topo_advanced_vis_mixer_blend_modes, event, log_list
  widget_control, event.top, get_uvalue=p_wdgt_state
  tiling = 0
  in_file_string = (*p_wdgt_state).selection_str

 
  print, 'Blending images: '

  in_file_list = strsplit(in_file_string, '#', /extract)
  for nF = 0,in_file_list.length-1 do begin
    ; Time start
    start = systime(/seconds)
    
    ; Input file
    in_file = in_file_list[nF]
    ; print, 'File name:', in_file
    
    ; Get file names of produced files and open them for layering
    mixer_input_images_to_layers, event, in_file
    
    ; Normalize images on all layers
    mixer_normalize_images_on_layers, event
    
    ; Add saving normalized images?
    mixer_write_layer_images, event, in_file

    ; Apply blend modes, opacity and render into a composed image
    mixer_render_layered_images, event, in_file
    
    ; Time stop
    stop = systime(/seconds)
    elapsed = stop - start
    write_blend_log, p_wdgt_state, in_file, tiling, elapsed, log_list
  endfor
  
  print, 'Finished blending!'
  
  clear_tmp_files, ['tmp_*.tif']
  
  test_memory  
end




