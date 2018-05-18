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

; Gama correction, decoding
function sRGB_to_RGB, sRGB, gama=gama

 if keyword_set(gama) eq 0 then gama = 2.0

 ; Color image
 if boolean(size(sRGB, /N_DIMENSIONS) EQ 3) then begin
   R = reform(sRGB[0, *, *])
   G = reform(sRGB[1, *, *])
   B = reform(sRGB[2, *, *])

   R = R^gama
   G = G^gama
   B = B^gama

   return, image_join_channels(R, G, B)  
   
 endif else begin
 ; Grayscale image
   Gs = sRGB^gama
   return, Gs
 endelse
end

; Gamma correction, encoding
function RGB_to_sRGB, linRGB, gama=gama

  if keyword_set(gama) eq 0 then gama = 2.0

  ; Color image
  if boolean(size(linRGB, /N_DIMENSIONS) EQ 3) then begin
    R = reform(linRGB[0, *, *])
    G = reform(linRGB[1, *, *])
    B = reform(linRGB[2, *, *])
  
    R = R^(1.0/gama)
    G = G^(1.0/gama)
    B = B^(1.0/gama)

  return, image_join_channels(R, G, B)

  endif else begin
  ; Grayscale image
    Gs = linRGB^(1.0/gama)
    return, Gs
  endelse
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

function to_lin_RGB_in_float, img
  if isa(img, /INT) then img = RGB_to_float(img)
  
  if (min(img) LT 0.0 OR max(img) GT 1.1) then img = scale_0_to_1(img)
  img = sRGB_to_RGB(img)
  return, img
end

function to_sRGB_in_float, img  
  if isa(img, /INT) then img = RGB_to_float(img)
  
  if (min(img) LT 0.0 OR max(img) GT 1.1) then img = scale_0_to_1(img)
  img = RGB_to_sRGB(img)
  return, img
end

; For images that could be either grayscale or RGB
function blend_multi_dim_images, blend_mode, active, background
  a_rgb = boolean(size(active, /N_DIMENSIONS) EQ 3)
  b_rgb = boolean(size(background, /N_DIMENSIONS) EQ 3)

;  active = to_lin_RGB_in_float(active)
;  background = to_lin_RGB_in_float(background)

;  active = scale_0_to_1(active)
;  background = scale_0_to_1(background)

;  if (min(active) LT 0.0 OR max(active) GT 1.1) then active = RGB_to_float(active)
;  if (min(background) LT 0.0 OR max(background) GT 1.1) then background = RGB_to_float(background)

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
;    dim = size(background, /DIMENSIONS)
;    blended_image = reform(background[*], dim[0], dim[1])
    blended_image = equation_blend(blend_mode, active, background)
  endif
  
;  active = to_sRGB_in_float(active)
;  background = to_sRGB_in_float(background)
;  blended_image = to_sRGB_in_float(blended_image)
  
  return, blended_image
end

function lum, img
  n_channels = size(img, /N_DIMENSIONS)
  
  if typename(img) ne 'FLOAT' then begin
    lum_img = RGB_to_float(lum_img)
  endif

  if (n_channels EQ 3) then begin
    lum_img = RGB_to_luminance(img)
  endif else begin
    lum_img = img
  endelse
  
  return, lum_img
end

function clip_color, c, min_c=min_c, max_c=max_c
  lum = lum(c)
  
  R = reform(c[0, *, *])
  G = reform(c[1, *, *])
  B = reform(c[2, *, *])

  if not keyword_set(min_c) then min_c = min([R, G, B]) 
  if not keyword_set(max_c) then max_c = max([R, G, B])
  
;  if (min_c lt 0.0) or (max_c gt 1.0) then begin
;        c[0, *, *] = float(c[0, *, *] - min_c) / float(max_c - min_c)
;        c[1, *, *] = float(c[1, *, *] - min_c) / float(max_c - min_c)
;        c[2, *, *] = float(c[2, *, *] - min_c) / float(max_c - min_c)
;  endif

;  if (min_c lt 0.0) then begin
;    c[*, *, *] = lum + (((reform(c[*, *, *]) - lum) * lum) / (lum - min_c))
;  end
;  if (max_c gt 1.0) then begin
;    c[*, *, *] = lum + (((reform(c[*, *, *]) - lum) * (1.0 - lum)) / (max_c - lum))
;  end
  
  if (min_c lt 0.0) then begin
    c[0, *, *] = lum + (((reform(c[0, *, *]) - lum) * lum) / (lum - min_c))
    c[1, *, *] = lum + (((reform(c[1, *, *]) - lum) * lum) / (lum - min_c))
    c[2, *, *] = lum + (((reform(c[2, *, *]) - lum) * lum) / (lum - min_c))
  end
  if (max_c gt 1.0) then begin
    c[0, *, *] = lum + (((reform(c[0, *, *]) - lum) * (1.0 - lum)) / (max_c - lum))
    c[1, *, *] = lum + (((reform(c[1, *, *]) - lum) * (1.0 - lum)) / (max_c - lum))
    c[2, *, *] = lum + (((reform(c[2, *, *]) - lum) * (1.0 - lum)) / (max_c - lum))
  end
  
  return, c
end

;TODO: background mora bit RGB, drugač vrne ... active!
function blend_luminosity_HSP, active, background, min_c=min_c, max_c=max_c

    background_channels = size(background, /N_DIMENSIONS)
    if (background_channels EQ 2) then return, active

    ; Luminosity:
    hsp_background = RGB_to_HSP_Rex(background)

    Hb = reform(hsp_background[0, *, *])
    Sb = reform(hsp_background[1, *, *])
    Pbd = reform(hsp_background[2, *, *])

    active_channels = size(active, /N_DIMENSIONS)
    if (active_channels EQ 2) then begin
      Pa = active
    endif else begin
      hsp_active = RGB_to_HSP_Rex(active)

      Ha = reform(hsp_active[0, *, *])
      Sa = reform(hsp_active[1, *, *])
      Pa = reform(hsp_active[2, *, *])
    endelse
    
    HSP_blended_image = image_join_channels(Hb, Sb, Pa)    
    blended_image = HSP_to_RGB_Rex(HSP_blended_image)
    
    return, blended_image
end

function blend_luminosity_equation, active, background, min_c=min_c, max_c=max_c
  ;background = RGB_to_float(background)

  lum_active = lum(active)
  lum_background = lum(background)
  
  ; luminosity
  lum = lum_active - lum_background
  
  n_channels = size(background, /N_DIMENSIONS)
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
  
;  ; TMP:
;  S_channel = 2
;  background = float_to_RGB(background)
;  clipped_image = float_to_RGB(clipped_image)
;  COLOR_CONVERT, background, HLS_background, /RGB_HLS
;  COLOR_CONVERT, clipped_image, HLS_clipped_image, /RGB_HLS
;  HLS_clipped_image[S_channel,*, *] = HLS_background[S_channel,*, *]
;  
;  COLOR_CONVERT, HLS_clipped_image, blended_image, /HLS_RGB
;  blended_image = RGB_to_float(blended_image)
;
;  return, blended_image 

   return, clipped_image
end

function get_lightness, active 
  n_channels = size(active, /N_DIMENSIONS)

  ; Monochrome (1) image
  if (n_channels EQ 2) then begin
    ; Luminosity of monochrome image IS the monochrome image itself
    ; Make sure it's correct value scale!
    lightness = active
    return, lightness
  endif
  ; Multichannel, RGB (3) image
  if (n_channels EQ 3) then begin
    ; Float to RGB (if it's not already)
    if typename(active) eq 'FLOAT' then active = float_to_RGB(active)

    L_channel = 1
    COLOR_CONVERT, active, HLS_active, /RGB_HLS
    lightness = reform(HLS_active[L_channel, *, *])
    
    ;L_channel = 0
    ;COLOR_CONVERT, active, YUV_active, /RGB_YUV
    ;luminance = reform(YUV_active[L_channel, *, *])

    return, lightness
  endif
end

function get_luminance, active
  n_channels = size(active, /N_DIMENSIONS)
  
  ; Float to RGB (if it's not already)
  if typename(active) eq 'FLOAT' then active = float_to_RGB(active)

  ; Monochrome (1) image
  if (n_channels EQ 2) then begin
    ; Luminosity of monochrome image IS the monochrome image itself
    ;active = grayscale_to_RGB_1(active)

    return, active
  endif
  ; Multichannel, RGB (3) image
  if (n_channels EQ 3) then begin

    R = reform(active[0, *, *])
    G = reform(active[1, *, *])
    B = reform(active[2, *, *])

    ; Calculate the Perceived brightness:
    P = R*0.3 + G*0.59 + B*0.11

    return, P
  endif
end

; TO-DO:
; - check whih component is L (luminosity)
; - HLS structure
; 
; Luminosity 
; - blends the lightness values while ignoring the color information
function blend_luminosity, active, background, min_c=min_c, max_c=max_c

   ;TO-DO - check
   n_active = size(active, /N_DIMENSIONS)
   n_background = size(background, /N_DIMENSIONS)

   ; Multichannel, RGB (3) background layer [n_background = 3]
   if (n_background EQ 3) then begin
     
;     active = to_lin_RGB_in_float(active)
;     background = to_lin_RGB_in_float(background)
 

;     A. HLS method with lightness:
      L_channel = 1
      if max(background) le 1.0 then background = fix(background*255)
      
      COLOR_CONVERT, background, HLS_background, /RGB_HLS
      HLS_background[L_channel,*, *] = get_lightness(active)
       
      COLOR_CONVERT, HLS_background, blended_image, /HLS_RGB
      blended_image = RGB_to_float(blended_image)
      
;      B. YUV method with luminance:
;      L_channel = 0
;      COLOR_CONVERT, background, YUV_background, /RGB_YUV
;      YUV_background[L_channel,*, *] = get_luminance(active)
;
;      COLOR_CONVERT, YUV_background, blended_image, /YUV_RGB
;      blended_image = RGB_to_float(blended_image)
      
;      C. Adobe equation
;      blended_image = blend_luminosity_equation(active, background, min_c=min_c, max_c=max_c)
      
;      D. USE RGB_to_HSP_Rex for LUMINOSITY
;      blended_image = blend_luminosity_HSP(active, background, min_c=min_c, max_c=max_c)
      
   endif
   ; Replacing luminosity of single channel, monochrome image
   ; means replacing the monochrome image completely
   if (n_background EQ 2) then begin
      ;blended_image =  get_luminance(active)
      blended_image = get_lightness(active)
   endif

;   blended_image = to_sRGB_in_float(blended_image)

   return, blended_image
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
    ;    dim = size(background, /DIMENSIONS)
    ;    blended_image = reform(background[*], dim[0], dim[1])
    rendered_image = apply_opacity(active, background, opacity)
  endif
  
;  rendered_image = active * opacity + background * (1 - opacity)
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
      
      top = blend_images(blend_mode, active, background, min_c=min_c, max_c=max_c)
      rendered_image = render_images(top, background, opacity)
    endelse
  endfor
  
  return, rendered_image
end

; Save rendered image (blended) to file
pro write_rendered_image_to_file, p_wdgt_state, in_file, final_image, geotiff=geotiff, out_file=out_file
  final_image = scale_0_to_1(final_image)
  final_image = float_to_RGB(final_image)

  overwrite = (*p_wdgt_state).overwrite
  widgetID = (*p_wdgt_state).combination_radios[(*p_wdgt_state).combination_index]
  widget_control, widgetID, get_value = radio_label
  
  radio_label = StrJoin(StrSplit(radio_label, ' ', /Regex, /Extract, /Preserve_Null), '_')
  radio_label_tif = '_'+radio_label+'.tif'
  out_file = StrJoin(StrSplit(in_file, '.tif', /Regex, /Extract, /Preserve_Null), radio_label_tif)
  print, out_file
  write_image_to_geotiff, overwrite, out_file, final_image, geotiff=geotiff
end

; For every input file
pro mixer_render_layered_images, event, in_file
  widget_control, event.top, get_uvalue=p_wdgt_state
  
  layers = (*p_wdgt_state).current_combination.layers
  images = (*p_wdgt_state).mixer_layer_images

  ; Rendering in order
  final_image = render_all_images(layers, images)
  
  ; Get geotiff data from original file
  tmp_img = read_image_geotiff(in_file, in_orientation, in_geotiff=in_geotiff)

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

pro topo_advanced_vis_mixer_blend_modes, event
  widget_control, event.top, get_uvalue=p_wdgt_state
  in_file_string = (*p_wdgt_state).selection_str

  print, 'Finished blending images: '

  in_file_list = strsplit(in_file_string, '#', /extract)
  for nF = 0,in_file_list.length-1 do begin
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
  endfor
  
  clear_tmp_files, ['tmp_*.tif']
  
  test_memory  
end




