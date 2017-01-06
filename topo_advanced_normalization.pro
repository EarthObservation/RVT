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

function topo_advanced_normalization, image, min, max, normalization
   if (normalization EQ 'abs') then begin
      idx_min = WHERE(image LT min)
      idx_max = WHERE(image GT max)
      image[idx_min] = min
      image[idx_max] = max
   endif 
   if (normalization EQ 'rel') then begin
      offset = min(image) - min
      image_span = float(max(image) - min(image))
      final_span = float(max - min)
      image = (image - offset) * (final_span / image_span)
   endif

   return, image
end

; Iterate through images on layers in widget_state
; normalize them according to min, max, normalization
pro mixer_normalize_images_on_layers, event
    widget_control, event.top, get_uvalue = p_wdgt_state
    
    layers = (*p_wdgt_state).current_combination.layers
    images = (*p_wdgt_state).mixer_layer_images
 
    nr_layers = layers.length
    if (images.length NE nr_layers) then print, 'Error: Number of layers does not match number of images!'
    
    for i=0,nr_layers-1 do begin
      image = images[i]
      min = layers[i].min
      max = layers[i].min
      normalization = layers[i].normalization
      image = topo_advanced_normalization(image, min, max, normalization) ; is result the same as with line below? 
      ;(*p_wdgt_state).mixer_layer_images[i] = topo_advanced_normalization(image, min, max, normalization)
    endfor
end