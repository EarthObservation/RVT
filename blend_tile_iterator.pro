; Here is the typical workflow when using tile iterators:

function do_i_need_tiling, event
   widget_control, event.top, get_uvalue=p_wdgt_state

   ; 32-bit systems should use tiling
   IF Float(!Version.memory_bits) le 32 THEN return, 1
   
   ; LARGE IMAGES should also use tiling (current threshold = 800 MB)
   in_file_string = (*p_wdgt_state).selection_str
   in_file_list = strsplit(in_file_string, '#', /extract)
   file_infos = (file_info(in_file_list))
   file_sizes = file_infos.size
   largest_file = max(file_sizes)
      
   if largest_file ge 8L*10L^8 then return, 1 
   
   ; LARGEST IMAGE x NR LAYERS over 1 GB
   layers = (*p_wdgt_state).current_combination.layers
   used_layers = 0
   foreach layer, layers do begin
    if layer.vis ne '<none>' then used_layers += 1
   endforeach
   
   if (used_layers * largest_file) gt 10L^9 then return, 1
   
   return, 0
end


function normalize_image_tiled, image_path, layer, in_orientation, normalize_image=normalize_image
  image = read_image_geotiff(image_path, in_orientation)

  ; if no normalization is needed
  if (keyword_set(normalize_image) eq 0) then $
    return, image
    
  ; normalization parameters
  vizualization = layer.vis
  normalization = layer.normalization
  min = float(layer.min)
  max = float(layer.max)
    
  norm_image = mixer_normalize_image(image, vizualization, min, max, normalization)
  
  return, norm_image
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


; Make a tile from full image
function make_tile, full_image, indx_ok, ncol
  dim_image = size(full_image, /DIMENSIONS)
  n_channels_image = dim_image.length
  
  row_start = indx_ok[0]/ncol
  row_end = (indx_ok[-1]+1)/ncol - 1

  if (n_channels_image eq 3) then begin
    image_tile = make_array(3, ncol, indx_ok.length / ncol)
    image_tile[0, *, *] = full_image[0, *, row_start:row_end]
    image_tile[1, *, *] = full_image[1, *, row_start:row_end]
    image_tile[2, *, *] = full_image[2, *, row_start:row_end]
  endif else begin
    image_tile = make_array(ncol, indx_ok.length / ncol)
    image_tile[*, *] = full_image[indx_ok]
  endelse
  
  return, image_tile
end

; Adjust for RGB
; blend and render (opacity) two already normalized images
FUNCTION blend_render_tiled, background, active, blend_mode, opacity, image_title, p_wdgt_state, min_c=min_c, max_c=max_c
  dim_active = size(active, /DIMENSIONS)
  dim_background = size(background, /DIMENSIONS)
    
  tmp_img = read_image_geotiff(image_title, in_orientation, in_geotiff=in_geotiff)
  tmp_img = !null

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
      indx_all = indgen(n_elements(background), /LONG)
    endif
    if (n_channels_background eq 3 and n_channels_active eq 2) then begin
      indx_all = indgen(n_elements(active), /LONG)
    endif
  endif else begin    
;    if (n_elements(active) ne n_elements(background)) then begin
;      print, "Image sizes do not match!"
;    endif  
    if (n_channels_active eq 3 and n_channels_background eq 3) then begin     
      single_channel = reform(active[0, *, *])
      indx_all = indgen(n_elements(single_channel), /LONG)
    endif
    if (n_channels_active eq 2 and n_channels_background eq 2) then begin
      indx_all = indgen(n_elements(active), /LONG)
    endif
     
  endelse

  ; Number of pixels
  count_all = ncol * nrow

  ;Run it - if it is neccessary, divide everything into more tiles;
  sc_tile_size = 5L*10L^6
  nlt = sc_tile_size / ncol  ;the number of rows that can be processed at one moment
  nlt = ncol * nlt            ;the number of pixels to be processed at one moment

  count_rendered_tiles = 0

  FOR i=0L,count_all-1,nlt DO BEGIN
    count_rendered_tiles += 1

    ; Processing the last tile (max size or smaller; only tile)
    IF (i+nlt) GT (nrow*ncol-1) THEN BEGIN
      nlt0 = nlt
      nlt = nrow * ncol - i ;?
      Print, 'Processing last tile...'

    ENDIF ELSE Print, 'Processing tile: ', i/nlt + 1

    indx_ok = indx_all[i:i+nlt-1]   
    active_tile = make_tile(active, indx_ok, ncol)
    background_tile = make_tile(background, indx_ok, ncol)
    
    ; BLEND IMAGES
    top_tile = blend_images(blend_mode, active_tile, background_tile, min_c=min_c, max_c=max_c)
    rendered_tile = render_images(top_tile, background_tile, opacity)

    ; SAVE RESULT
    Save, rendered_tile, File=Strtrim(i, 2)+'blend.sav'

  ENDFOR
  
  ;============================================================================

  count_height = N_elements(indx_all)   ; number of all elements  
  ;rendered_image = Fltarr(count_height)  
  
  indx_all = !null & indx_ok = !null
  active = !null & background = !null
  
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
        rendered_image_out[0, *, line1:line2] = rendered_tile[0, *, *]
        rendered_image_out[1, *, line1:line2] = rendered_tile[1, *, *]
        rendered_image_out[2, *, line1:line2] = rendered_tile[2, *, *]        
      endif else begin
        rendered_image_out[*, line1:line2] = rendered_tile
      endelse
    ENDFOR
  endif else rendered_image_out[*, *] = rendered_tile
  
  write_rendered_image_to_file, p_wdgt_state, image_title, rendered_image_out, geotiff=in_geotiff, out_file=out_file

  return, out_file
end

; Clear all files with certain extension or regex in current folder
;
pro clear_tmp_files, list_regex
    foreach regex_ext, list_regex do begin
      list_files = FILE_SEARCH(regex_ext, /FOLD_CASE)
      if size(list_files, /dimensions) eq 0 then continue
      foreach tmp_file, list_files do begin
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
      if (path_rendered_image EQ [] OR i EQ layers.length-1) then begin    ; OR OR path_rendered_image eq !null Or path_rendered_image eq ''
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
                    
        path_rendered_image = blend_render_tiled(background, active, blend_mode, opacity, image_title, p_wdgt_state, min_c=min_c, max_c=max_c) ; returns path to image!   
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
pro topo_advanced_vis_mixer_tiled_blend_modes, event, log_list
  widget_control, event.top, get_uvalue=p_wdgt_state
  tiling = 1
  in_file_string = (*p_wdgt_state).selection_str

  in_file_list = strsplit(in_file_string, '#', /extract)
  for nF = 0,in_file_list.length-1 do begin
    ; Time start
    start = systime(/seconds)
    
    ; Input file
    in_file = in_file_list[nF]
    print, 'File name:', in_file
    
    ; process with tiling (manual)
    path_final_image = render_all_imgs_tiled(event, in_file)
    
    ; Time stop
    stop = systime(/seconds)
    elapsed = stop - start
    write_blend_log, p_wdgt_state, in_file, tiling, elapsed, log_list
  endfor
end

function blend_tile_iterator
  return, null
end

