; Here is the typical workflow when using tile iterators:



;TODO: make it actually tiled
function normalize_image_tiled, image_path, layer, in_orientation, normalize_image=normalize_image
  active = read_image_geotiff(image_path, in_orientation)

  ; if no normalization is needed
  if (keyword_set(normalize_image) eq 0) then $
    return, active

  ; normalization parameters
  normalization = layer.normalization
  min = float(layer.min)
  max = float(layer.max)

  ; PARAMETERS:
  ; for percentual normalization
  if (normalization EQ 'Perc') then begin
    perc = max
    if(perc GT 0.5 AND perc LT 100.0001) then perc = perc / 100.0
    
    start_t = SYSTIME(/SECONDS)
    
    ;TODO: uncomment and change to 

    ; min_values = []
    ; max_values = []

    ; find min, max for linear normalization
    
    ;FOR count=1, iterator_image.NTILES DO BEGIN
      image_tile = active ;active_tile
      distribution = cgPercentiles(active, Percentiles=[perc, 1.0-perc])
      ; min_values = [ min_values, distribution[0] ]
      ; max_values = [ max_values, distribution[1] ]
    ;endfor

    min = distribution[0] ; mean(min_values, /nan) -> for tiled version
    max = distribution[1] ; mean(max_values, /nan) -> for tiled version
    
    stop_t = SYSTIME(/SECONDS)
    seconds = start_t - stop_t
    
    print, 'Relative normalization - percentiles computation time: ', string(seconds), ' sec'
  endif

  ; NORMALIZATION:
  ; FOR count=1, iterator_image.NTILES DO BEGIN
    ; next tile
    normalized_image = normalize_lin(active, min, max); norm_min[visualization], norm_max[visualization])
  ; endfor

  return, normalized_image
end

function where2D
  index = WHERE(image EQ test)
  s = SIZE(image)
  ncol = s(1)
  col = index MOD ncol
  row = index / ncol
end

function where3D
  index = WHERE(image EQ test)
  s = SIZE(image)
  ncol = s[1]
  nrow = s[2]
  col = index MOD ncol
  row = (index / ncol) MOD nrow
  frame = index / (nrow*ncol)
end


pro test123
  seed = 111
  array = RANDOMU(seed, 10, 10)
  mx = MAX(array, location)
  dims = SIZE(array, /DIMENSIONS)
  ind = ARRAY_INDICES(dims, location, /DIMENSIONS)
  print, ind, array[ind[0],ind[1]], $
    format = '(%"Value at [%d, %d] is %f")'
end

; Adjust for RGB
; blend and render (opacity) two already normalized images
FUNCTION blend_render_tiled, background, active, blend_mode, opacity, image_title, min_c=min_c, max_c=max_c, geotiff=geotiff
  dim_active = size(active, /DIMENSIONS)
  dim_background = size(background, /DIMENSIONS)

  if ((dim_active[dim_active.length-1] ne dim_background[dim_background.length-1]) or $
    (dim_active[dim_active.length-2] ne dim_background[dim_background.length-2])) then begin
    print, 'Error! Image dimensions do not match!'
    return, null
  endif

  ; Channels
  n_channels_active = dim_active.length
  n_channels_background = dim_background.length

  ;if (Size(active_image) NE size(background_image)) then return
  dim_image = dim_background
  ; columns and lines/rows
  ncol = dim_image[dim_image.length-2]
  nrow = dim_image[dim_image.length-1]

  if (n_channels_active ne n_channels_background) then begin         
    if (n_channels_active eq 3 and n_channels_background eq 2) then begin
      indx_all = indgen(n_elements(background))
      
      ;indx_active = Where(finite(active))
;      indx_active = where(active)
;      indx_active = ARRAY_INDICES(active, indx_active)
;      indx_all = Where(finite(active[indx_active[0]]) and finite(background))
    endif
    if (n_channels_background eq 3 and n_channels_active eq 2) then begin
      indx_all = indgen(n_elements(active))
      
      ;indx_background = Where(finite(background)
;      indx_background = where(background)
;      indx_background = ARRAY_INDICES(background, indx_background)
;      indx_all = Where(finite(active) and finite(background[indx_background[0]]))
    endif
  endif else begin    
;    if (n_elements(active) ne n_elements(background)) then begin
;      print, "Image sizes do not match!"
;    endif  
    if (n_channels_active eq 3 and n_channels_background eq 3) then begin     
      single_channel = reform(active[0, *, *])
      indx_all = indgen(n_elements(single_channel))
      
;      indx_active = where(active)
;      indx_all = ARRAY_INDICES(active, indx_active)
;      indx_all = Where(finite(active[indx_all[0]]) and finite(background[indx_all[0]]))
    endif
    if (n_channels_active eq 2 and n_channels_background eq 2) then begin
      indx_all = indgen(n_elements(active))
;      indx_all = where(finite(active) and finite(background))
    endif
 
  endelse

  ; Number of pixels
  count_all = ncol * nrow
  ; count_all *= max(n_channels_active, n_channels_background)
  ; indx_all = image[*] ; 2D array -> 1D array


  ;Run it - if it is neccessary, divide everything into more tiles;
  sc_tile_size = 5L*10L^6
  nlt = sc_tile_size / ncol  ;the number of rows that can be processed at one moment
  nlt = ncol * nlt            ;the number of pixels to be processed at one moment
  ;n_tiles = ceil(float(nrow) / float(nlt))  ;the number of all tiles

  count_rendered_tiles = 0

  FOR i=0L,count_all-1,nlt DO BEGIN
    count_rendered_tiles += 1

    ; Processing the last tile (max size or smaller; only tile)
    ; IF (i+nlt) GT n_elements(indx_all) THEN BEGIN 
    IF (i+nlt) GT (nrow*ncol-1) THEN BEGIN
      nlt0 = nlt
;     nlt = n_elements(indx_all) 
      nlt = nrow * ncol - i ;?
      Print, 'Processing last tile...'

    ENDIF ELSE Print, 'Processing tile: ', i/nlt + 1

    indx_ok = indx_all[i:i+nlt-1]

    if (n_channels_active eq 3) then begin
      active_tile = active[*, indx_ok]
    endif else begin
      active_tile = active[indx_ok]
    endelse
    
    if (n_channels_background eq 3) then begin
      background_tile = background[*, indx_ok]
    endif else begin
      background_tile = background[indx_ok]
    endelse
    
    ; REFORM TILES BACK TO 2D IMAGES?
    
    ; BLEND IMAGES
    top_tile = blend_images(blend_mode, active_tile, background_tile, min_c=min_c, max_c=max_c)
    rendered_tile = render_images(top_tile, background_tile, opacity)

    ; SAVE RESULT
    Save, rendered_tile, File=Strtrim(i, 2)+'blend.sav'

  ENDFOR
  

  ;============================================================================

  count_height = N_elements(indx_all)   ; number of all elements  
  rendered_image = Fltarr(count_height)  
  
  indx_all = !null & indx_ok = !null
  
  ; JOIN TILES
  if count_rendered_tiles gt 0 then begin
    ; rendered_image ....
    is_RGB = max([n_channels_active, n_channels_background]) eq 3
    if is_RGB then rendered_image_out = Make_array(3, ncol, nrow) $
    else rendered_image_out = Make_array(ncol, nrow)
    
    nlt = nlt0
    FOR i=0L,count_all-1,nlt DO BEGIN
      IF (i+nlt) GT (nrow*ncol-1) THEN nlt = nrow*ncol - i                    ; IF (i+nlt) GT n_elements(indx_all) THEN nlt = n_elements(indx_all)
      Restore, Strtrim(i, 2)+'blend.sav'
      ; line_nr + 'blend.sav' file will be restored
      ; file restored will be stored in variable 'rendered_tile'
      File_delete, Strtrim(i, 2)+'blend.sav', /ALLOW_NONEXISTENT
      line1 = i/Long(ncol)
      line2 = (i+nlt-1L)/Long(ncol)
      if is_RGB then begin
        rendered_image_out[0, *, line1:line2] = rendered_tile[0, *]
        rendered_image_out[1, *, line1:line2] = rendered_tile[1, *]
        rendered_image_out[2, *, line1:line2] = rendered_tile[2, *]
      endif else begin 
        rendered_image_out[*, line1:line2] = rendered_tile
      endelse
    ENDFOR
    out_file = image_titile + '_blending_result.tif'    
  endif else rendered_image = rendered_tile
  
  write_tiff, rendered_image, out_file, geotiff=geotiff

  return, out_file
end

; Clear all files with certain extension or regex in current folder
;
pro clear_tmp_files, list_regex
    foreach regex_ext, list_regex do begin
      list_files = FILE_SEARCH(regex_ext, /FOLD_CASE)
      foreach tmp_file, list_file do begin
        file_delete, tmp_file, /ALLOW_NONEXISTENT
      endforeach
    endforeach
end

; Rendering across all layers - from last to first layer
;
; layers - from wdgt_state
; path_images - array of images
;          Each image is either:
;          (1) rendered image of visualization + blending or
;          (2) original image (if vis EQ '<none>' for that layer), according to path from array of images
;
function render_all_imgs_tiled, event, in_file
    widget_control, event.top, get_uvalue=p_wdgt_state
    layers = (*p_wdgt_state).current_combination.layers
    in_orientation = (*p_wdgt_state).in_orientation
 
    paths_images = mixer_get_paths_to_input_files(event, in_file)

    norm_min = hash()
    norm_max = hash()

    for i=layers.length-1,0,-1 do begin
      ; if current layer has no visualization applied, skip
      visualization = layers[i].vis
      if (visualization EQ '<none>') then continue

      ; if current layer has visualization applied, but there has been no rendering of images yet,
      ; then current layer will be the initial value of rendered_image
      if (path_rendered_image EQ [] OR i EQ layers.length-1) then begin
        path_rendered_image = paths_images[i]; paths_images[visualization] ; TO-DO: to path
        continue
      endif else begin
        ; if current layer has visualization applied, render it as active layer, where old rendered_image is background layer
        path_active = paths_images[i]; paths_images[visualization]
        path_background = path_rendered_image ; this will be image path when returned from
        
        ; Normalization
        ; not necessary when using input image
        normalize_active = visualization NE '<custom>'
        normalize_background = (path_background eq paths_images[i+1]) and visualization NE '<custom>' ; this could be in if part
        
        active = normalize_image_tiled(path_active, layers[i], in_orientation, normalize_image=normalize_active)
        background = normalize_image_tiled(path_background, layers[i+1], in_orientation, normalize_image=normalize_background)
        
        ; Blending parameters
        blend_mode = layers[i].blend_mode
        opacity = layers[i].opacity           
        
        image_title = in_file
        min_c = float(layers[i].min)
        max_c = float(layers[i].max)
        ;TODO: add geotiff info
        ;geotiff =          
                
        path_rendered_image = blend_render_tiled(background, active, blend_mode, opacity, image_title, min_c=min_c, max_c=max_c, geotiff=geotiff) ; returns path to image!
      endelse
    endfor
    
    ; Make sure all intermediate images are deleted
    clear_tmp_files, ['*blend.sav', 'tmp_*.tif']
      
    return, path_rendered_image
end

;; For every input file
;pro mixer_render_layered_images_tiled, event, in_file
;  widget_control, event.top, get_uvalue=p_wdgt_state
;
;  layers = (*p_wdgt_state).current_combination.layers
;  paths_images = mixer_get_paths_to_input_files(event, in_file)
;
;  ; Rendering in order
;  path_final_image = render_all_imgs_tiled(event, in_file)
;
;  ; ; Save image to file
;  ; write_rendered_image_to_file, p_wdgt_state, in_file, final_image
;  ;TODO: Above replace with Rename path_final_image to in_file
;end

; TILED VERSION OF topo_advanced_vis_mixer_blend_modes
pro topo_advanced_vis_mixer_tiled_blend_modes, event
  widget_control, event.top, get_uvalue=p_wdgt_state
  in_file_string = (*p_wdgt_state).selection_str

  in_file_list = strsplit(in_file_string, '#', /extract)
  for nF = 0,in_file_list.length-1 do begin
    ; Input file
    in_file = in_file_list[nF]
    print, 'File name:', in_file

    ; process with tiling (ENVI)
    ; mixer_render_layered_images_tiled, event, in_file
    
    ; process with tiling (manual)
    path_final_image = render_all_imgs_tiled(event, in_file)
  endfor
end

function blend_tile_iterator
  return, null
end

