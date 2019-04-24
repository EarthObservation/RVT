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
    image = (float(image) - float(min)) / (float(max) - float(min))

    return, image
end

pro lin_cutoff_calc_from_perc, image, min, max, min_lin=min_lin, max_lin=max_lin
  if (min GT 1.0 AND min LE 100.0) then min = min / 100.0
  if (max GT 1.0 AND max LE 100.0) then max = max / 100.0
  
  distribution = cgPercentiles(image, Percentiles=[min, 1.0-max])
  min_lin = min(distribution)
  max_lin = max(distribution)
end

function normalize_perc, image, min, max, min_lin=min_lin, max_lin=max_lin
  lin_cutoff_calc_from_perc, image, min, max, min_lin=min_lin, max_lin=max_lin

  return, normalize_lin(image, min_lin, max_lin)
end

function topo_advanced_normalization, image, min, max, normalization
  if (normalization EQ 'Value') then begin
    ;equ_image = HIST_EQUAL(image, MINV=min, MAXV=max, TOP=1.0)
    equ_image = normalize_lin(image, min, max)
  endif
  if (normalization EQ 'Perc') then begin
    ;equ_image = HIST_EQUAL(image, PERCENT=max, TOP=1.0)
    equ_image = normalize_perc(image, min, max)
  endif
  if (normalization EQ '<none>') then begin
    equ_image = image
  endif
  return, equ_image
end

function mixer_normalize_image_tile, image, visualization, min_norm, max_norm, normalization
  ; for slope, putting this to one will invert scale
  ; meaning high slopes will be black
  switch_slope_scale = 1

  if (visualization EQ '<none>' OR visualization EQ '<custom>') then return, image

  ; Workaround:
  ; for RGB images, because they are
  ; on scale 0 to 255, not 0.0 - 1.0,
  ; we use multiplier to get proper values
  if normalization eq 'Value' and (visualization eq 'Hillshading from multiple directions' or visualization eq 'PCA of hillshading') then begin
    if max(image) gt 100.0  and (size(image, /N_DIMENSIONS) eq 3) then begin
      ; limit normalization 0.0 to 1.0;
      ; all numbers below are 0.0,
      ; numbers above are 1.0
      if min_norm lt 0.0 then min_norm = 0.0
      if max_norm gt 1.0 then max_norm = 1.0

      min_norm = round(min_norm * 255)
      max_norm = round(max_norm * 255)
    endif
  endif

  image = topo_advanced_normalization(image, min_norm, max_norm, normalization)
  
  ; make sure it scales 0 to 1
  if max(image) gt 1.0 then begin
    if (visualization eq 'Hillshading from multiple directions' or visualization eq 'PCA of hillshading') then begin
      ; from RGB to float
      image = RGB_to_float(image)
    endif else begin
      ; scale 0 to 1
      print, 'WARNING: unexpected values!'
    endelse
  endif

  ; inverted greyscale for negative openess
  if (visualization EQ 'Openness - Negative') OR (visualization EQ 'Slope gradient' and switch_slope_scale) then begin
    image = 1 - image
  endif
  
  return, image
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
      min_norm = float(layers[i].min)
      max_norm = float(layers[i].max)
      normalization = layers[i].normalization
      
      ; Workaround:
      ; for RGB images, because they are 
      ; on scale 0 to 255, not 0.0 - 1.0, 
      ; we use multiplier to get proper values
      if normalization eq 'Value' and (visualization eq 'Hillshading from multiple directions' or visualization eq 'PCA of hillshading') then begin 
        if max(image) gt 100.0 and (size(image, /N_DIMENSIONS) eq 3) then begin
          ; limit normalization 0.0 to 1.0;
          ; all numbers below are 0.0, 
          ; numbers above are 1.0
          if min_norm lt 0.0 then min_norm = 0.0 
          if max_norm gt 1.0 then max_norm = 1.0
          
          min_norm = round(min_norm * 255)
          max_norm = round(max_norm * 255)
        endif
      endif

      norm_image = topo_advanced_normalization(image, min_norm, max_norm, normalization)
      
      ; make sure it scales 0 to 1
      if max(norm_image) gt 1.0 then begin
        if (visualization eq 'Hillshading from multiple directions' or visualization eq 'PCA of hillshading') then begin
          ; from RGB to float
          norm_image = RGB_to_float(norm_image)
        endif else begin
          ; scale 0 to 1
          ;norm_image = scale_0_to_1(norm_image)
          print, 'WARNING: unexpected values! MAX > 1.0'
        endelse
      endif
      if min(norm_image) lt 0.0 then begin
        print, 'WARNING: unexpected values! MIN < 0.0'
      endif
      
      ; for slope and negative openess, invert scale
      ; meaning high slopes will be black
      if (visualization EQ 'Openness - Negative') OR (visualization EQ 'Slope gradient') then begin
        image = 1 - norm_image
      endif      

      (*p_wdgt_state).mixer_layer_images[i] = image
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

; Either float or integer
; TODO: should only be used right before writing to file (not during 'processing')
function scale_strict_0_to_1, numeric_value
  if min(numeric_value) eq 0.0 and max(numeric_value) eq 1.0 then $
    return, numeric_value

  NaN_indices = Where(~Finite(numeric_value), count)
  if (count gt 0) then numeric_value[NaN_indices] = 0

  min_value = min(numeric_value) ; min(numeric_value, /NAN)
  max_value = max(numeric_value) ; max(numeric_value, /NAN)
  
  ; new version
;  finite_indices = Where(Finite(numeric_value))
;  scaled[finite_indices] = float(numeric_value[finite_indices] - min_value) / float(max_value - min_value)

  scaled = float(numeric_value - min_value) / float(max_value - min_value)
  return, scaled
end

function scale_within_0_and_1, numeric_value
  if min(numeric_value) ge 0.0 and max(numeric_value) le 1.0 then $
    return, numeric_value

  NaN_indices = Where(~Finite(numeric_value), count)
  ;TODO: Replace min(numeric_value) with inpaint for NaN values
  if (count gt 0) then numeric_value[NaN_indices] = min(numeric_value)

  actual_min = min(numeric_value)
  norm_min_value = max(0.0, actual_min)
  
  actual_max = max(numeric_value)
  norm_max_value = min(1.0, actual_max)
  
  ; Do not scale values where max is between 1 and 255
  ; ... if the max-min values difference is at least 30 and min is >0
  ; ... and numeric values are integer type
  if (actual_max le 255 and actual_max gt 1.0) then begin
    if (actual_max - actual_min ge 30) and (actual_min ge 0) and typename(numeric_values) eq 'INT' then begin
       scaled = float(numeric_value) / float(255.0)
       return, scaled
    endif
  endif

  scaled = float(numeric_value - norm_min_value) / float(norm_max_value - norm_min_value)
  return, scaled
end

function scale_0_to_1, numeric_value
    if max(numeric_value) le 1.0 and max(numeric_value) gt 0.9 and min(numeric_value) eq 0.0 then return, numeric_value

    if max(numeric_value) - min(numeric_value) gt 0.3 then begin
      return, scale_within_0_and_1(numeric_value)
    endif else begin
      return, scale_strict_0_to_1(numeric_value)
    endelse
end

; Either float or integer
function numeric_to_luminosity, numeric_value
  min_value = min(numeric_value)
  max_value = max(numeric_value)

  luminosity = float(numeric_value - min_value) / float(max_value - min_value)
  return, luminosity
end

