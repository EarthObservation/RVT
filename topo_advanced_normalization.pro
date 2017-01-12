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
      image = images[visualization]
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

function RGB_to_grayscale, rgb
    r = rgb[0, *, *] 
    g = rgb[1, *, *] 
    b = rgb[2, *, *] 

    gs = ((0.3 * R) + (0.59 * G) + (0.11 * B))
    return, gs
end

; Either float or integer
function scale_0_to_1, numeric_value
  min_value = min(numeric_value)
  max_value = max(numeric_value)

  scaled = float(numeric_value - min_value) / float(max_value - min_value)
  return, scaled
end

function grayscale_to_RGB, grayscale
  scaled = scale_0_to_1(grayscale)
  gs = float_to_RGB(scaled) 
  dimensions = size(gs, /DIMENSIONS)
  x_size = dimensions[0]
  y_size = dimensions[1]
  RGB = make_array(3, x_size, y_size)
  RGB[0, *, *] = reform(gs, 1, x_size, y_size)
  RGB[1, *, *] = reform(gs, 1, x_size, y_size)
  RGB[2, *, *] = reform(gs, 1, x_size, y_size)

  return, RGB
end


; Either float or integer
function numeric_to_luminosity, numeric_value
  min_value = min(numeric_value)
  max_value = max(numeric_value)

  luminosity = float(numeric_value - min_value) / float(max_value - min_value)
  return, luminosity
end

