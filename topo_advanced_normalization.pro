; +
; NAME:
;       topo_advanced_normalization
;
; PURPOSE:
;       Normalization of an image, according to min and max values. 
;       Cut-off van be either linear (absolute) or percentual (relative).
;
; :Categories:
;       
;
; :Params:
;       image: in, required, type=image
;           loaded image (numeric representation)
;       min: in, required
;       max: in, required
;       normalization: in, required
;                      can have two values: 'abs' or 'rel'
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
;       January 2017
;-
function normalize_lin, image, min, max
    ; Linear cut off
    idx_min = WHERE(image LT min)
    idx_max = WHERE(image GT max)
    image[idx_min] = min
    image[idx_max] = max
    
    ; Stretch to 0.0-1.0 interval
    image = float(image - min) / (float(max-min))

    return, image
end

function normalize_perc, image, perc
    if (perc GT 0.5 AND perc LT 100.0001) then perc = perc / 100.0
    distribution = cgPercentiles(image, Percentiles=[perc, 1.0-perc])
    min = distribution[0]
    max = distribution[1]
    
    return, normalize_lin(image, min, max)
end

function topo_advanced_normalization, image, min, max, normalization

  if (normalization EQ 'Lin') then begin
    ;equ_image = HIST_EQUAL(image, MINV=min, MAXV=max, TOP=1.0)
    equ_image = normalize_lin(image, min, max)
  endif
  if (normalization EQ 'Perc') then begin
    ;equ_image = HIST_EQUAL(image, PERCENT=max, TOP=1.0)
    equ_image = normalize_perc(image, max)
  endif
  if (normalization EQ '<none>') then begin
    equ_image = image
  endif
  return, equ_image
end

; Iterate through images on layers in widget_state
; normalize them according to min, max, normalization
pro mixer_normalize_images_on_layers, event
    widget_control, event.top, get_uvalue = p_wdgt_state
    
    layers = (*p_wdgt_state).current_combination.layers
    images = (*p_wdgt_state).mixer_layer_images
 
    idx = WHERE(layers.vis NE '<none>', count)
    nr_layers = layers.length
    if (images.length NE count) then print, 'Error: Number of layers does not match number of images!'
    
    for i=0,nr_layers-1 do begin
      visualization = layers[i].vis
      if (visualization EQ '<none>') then continue
      image = images[i]
      min = float(layers[i].min)
      max = float(layers[i].max)
      normalization = layers[i].normalization

      (*p_wdgt_state).mixer_layer_images[i] = topo_advanced_normalization(image, min, max, normalization)
    endfor
end

function RGB_to_float, rgb
    float_value = float(rgb) / 255.0
    return, float_value
end

function float_to_RGB, float_value
    rgb = fix(float_value * 255)
    return, rgb
end

; grayscale, luminance
;function RGB_to_grayscale, rgb
;    r = reform(rgb[0, *, *])
;    g = reform(rgb[1, *, *])
;    b = reform(rgb[2, *, *])
;
;    gs = ((0.3 * R) + (0.59 * G) + (0.11 * B))
;    
;    return, gs
;end

function RGB_to_luminance, rgb
  r = reform(rgb[0, *, *])
  g = reform(rgb[1, *, *])
  b = reform(rgb[2, *, *])

  gs = (0.3 * R) + (0.59 * G) + (0.11 * B)
  ;gs = SQRT((0.299 * R * R) + (0.587 * G * G) + (0.114 * B * B))

  return, gs
end

;function RGB_to_lightness, rgb
;  r = reform(rgb[0, *, *])
;  g = reform(rgb[1, *, *])
;  b = reform(rgb[2, *, *])
;
;  ls = (min(R,G,B) + max([R,G,B])) / 2
;  return, ls
;end

; Either float or integer
; TODO: should only be used right before writing to file (not during 'processing')
function scale_strict_0_to_1, numeric_value
  if min(numeric_value) eq 0.0 and max(numeric_value) eq 1.0 then $
    return, numeric_value

  NaN_indices = Where(~Finite(numeric_value), count)
  if (count gt 0) then numeric_value[NaN_indices] = 0

  min_value = min(numeric_value)
  max_value = max(numeric_value)

  scaled = float(numeric_value - min_value) / float(max_value - min_value)
  return, scaled
end

function scale_within_0_and_1, numeric_value
  if min(numeric_value) ge 0.0 and max(numeric_value) le 1.0 then $
    return, numeric_value

  NaN_indices = Where(~Finite(numeric_value), count)
  if (count gt 0) then numeric_value[NaN_indices] = 0

  min_value = min(0.0, min(numeric_value))
  max_value = max(1.0, max(numeric_value))

  scaled = float(numeric_value - min_value) / float(max_value - min_value)
  return, scaled
end

function scale_0_to_1, numeric_value
    return, scale_strict_0_to_1(numeric_value)
end

function grayscale_to_RGB, grayscale
  r = grayscale/0.3
  g = grayscale/0.59
  b = grayscale/0.11
  
  dimensions = size(grayscale, /DIMENSIONS)
  x_size = dimensions[0]
  y_size = dimensions[1]
  RGB = make_array(3, x_size, y_size)
  RGB[0, *, *] = reform(r, 1, x_size, y_size)
  RGB[1, *, *] = reform(g, 1, x_size, y_size)
  RGB[2, *, *] = reform(b, 1, x_size, y_size)

  scaled = scale_0_to_1(RGB)
  RGB = float_to_RGB(scaled) 
  
;  dimensions = size(gs, /DIMENSIONS)
;  x_size = dimensions[0]
;  y_size = dimensions[1]
;  RGB = make_array(3, x_size, y_size)
;  RGB[0, *, *] = reform(r, 1, x_size, y_size)
;  RGB[1, *, *] = reform(g, 1, x_size, y_size)
;  RGB[2, *, *] = reform(b, 1, x_size, y_size)

;  - - - - B:

;  dimensions = size(grayscale, /DIMENSIONS)
;  x_size = dimensions[0]
;  y_size = dimensions[1]
  
;  YUV_RGB = make_array(3, x_size, y_size, /FLOAT, VALUE = 1.0)
;  scaled = scale_0_to_1(grayscale)
;  YUV_RGB[1, *, *] = reform(scaled, 1, x_size, y_size)
;  COLOR_CONVERT, YUV_RGB, RGB, /YUV_RGB

  return, RGB
end

function grayscale_to_RGB_1, grayscale
  dimensions = size(grayscale, /DIMENSIONS)
  x_size = dimensions[0]
  y_size = dimensions[1]

  YUV_RGB = make_array(3, x_size, y_size, /FLOAT, VALUE = 0.0)
;  grayscale = scale_0_to_1(grayscale)
  YUV_RGB[0, *, *] = reform(grayscale, 1, x_size, y_size)
;  YUV_RGB[1, *, *] = make_array(x_size, y_size, /FLOAT, VALUE = 0.436)
;  YUV_RGB[2, *, *] = make_array(x_size, y_size, /FLOAT, VALUE = 0.615)
  COLOR_CONVERT, YUV_RGB, RGB, /YUV_RGB
    
;  YIQ_RGB = make_array(3, x_size, y_size, /FLOAT, VALUE = 0.0)
;  ;  grayscale = scale_0_to_1(grayscale)
;  YIQ_RGB[1, *, *] = reform(grayscale, 1, x_size, y_size)
;  COLOR_CONVERT, YIQ_RGB, RGB, /YIQ_RGB

    return, RGB
end


;function grayscale_to_RGB_2, grayscale
;  grayscale = scale_0_to_1(grayscale)
;
;  dimensions = size(grayscale, /DIMENSIONS)
;  x_size = dimensions[0]
;  y_size = dimensions[1]
;  RGB = make_array(3, x_size, y_size)
;  RGB[0, *, *] = reform(grayscale/3, 1, x_size, y_size)
;  RGB[1, *, *] = reform(grayscale/3, 1, x_size, y_size)
;  RGB[2, *, *] = reform(grayscale/3, 1, x_size, y_size)
; 
;  RGB = float_to_RGB(RGB) 
;
;  return, RGB
;end

;function grayscale_to_RGB_3, grayscale
;  r = grayscale*0.3
;  g = grayscale*0.59
;  b = grayscale*0.11
;
;  dimensions = size(grayscale, /DIMENSIONS)
;  x_size = dimensions[0]
;  y_size = dimensions[1]
;  RGB = make_array(3, x_size, y_size)
;  RGB[0, *, *] = reform(r, 1, x_size, y_size)
;  RGB[1, *, *] = reform(g, 1, x_size, y_size)
;  RGB[2, *, *] = reform(b, 1, x_size, y_size)
;
;  RGB = scale_0_to_1(RGB)
;
;  return, RGB
;end

function grayscale_to_RGB_4, grayscale
  r = grayscale
  g = grayscale
  b = grayscale

  dimensions = size(grayscale, /DIMENSIONS)
  x_size = dimensions[0]
  y_size = dimensions[1]
  RGB = make_array(3, x_size, y_size)
  RGB[0, *, *] = reform(r, 1, x_size, y_size)
  RGB[1, *, *] = reform(g, 1, x_size, y_size)
  RGB[2, *, *] = reform(b, 1, x_size, y_size)

  RGB = scale_0_to_1(RGB)
  
  ;scaled = scale_0_to_1(RGB)
  ;RGB = float_to_RGB(scaled)


  return, RGB
end

; Either float or integer
function numeric_to_luminosity, numeric_value
  min_value = min(numeric_value)
  max_value = max(numeric_value)

  luminosity = float(numeric_value - min_value) / float(max_value - min_value)
  return, luminosity
end

