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

; 
pro topo_advanced_vis_mixer_blend_modes, layers, images
  
  ; Apply blending modes
  blended_images = images[*]
  for i=0,nr_layers-1 do begin
    if (visualization EQ '<none>') then continue
    blended_images[i] = blend_image(layers[i].blend_mode, layers[i].images)
  endfor
  
  ; Rendering in order
  final_image = render_all_images(layers, blended_images)

end

