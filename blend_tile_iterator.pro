; Here is the typical workflow when using tile iterators:



;TODO: make it actually tiled
function normalize_image_tiled, image_path, layer, normalize_image=normalize_image
  active = read_image_geotiff(image_path, (*p_wdgt_state).in_orientation)

  ; if no normalization is needed
  if (keyword_set(normalize_image) eq 0) then $
    return, active

  ; normalization parameters
  normalization = layers[i].normalization
  min = float(layers[i].min)
  max = float(layers[i].max)

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
    normalized_image = normalize_lin(active, norm_min[visualization], norm_max[visualization])
  ; endfor

  return, normalized_image
end

;FUNCTION blend_render_tile_iterator, path_background, path_active, blend_mode, opacity, $
;                                     normalization, min=min, max=max, $
;                                     norm_min=norm_min, norm_max=norm_max, normalize_background=normalize_background
;                                    
;  COMPILE_OPT IDL2
;
;  ; Start the application
;  e = ENVI()
;  
;  ;TODO: e.OpenRaster requires FILEPATH() objects
;  
;  background = e.OpenRaster(path_background)
;
;  ; 1. Create an empty ENVIRaster object with the same number of rows and columns as the source raster.
;  newFile = e.GetTemporaryFilename()
;  blended_image = ENVIRaster(URI=newFile, $
;    NROWS=background.NROWS, $
;    NCOLUMNS=background.NCOLUMNS, $
;    ;NBANDS=max(e.OpenRaster(path_active).NBANDS, e.OpenRaster(path_background).NBANDS), $
;    DATA_TYPE=background.DATA_TYPE)
;    
;  ; Normalize image on active layer
;  path_active_normalized = normalize_image_tiled_envi(path_active, norm_min=norm_min, norm_max=norm_max)
;  
;  ; Background normalizing only when the background is bottom layer image, not previous rendered layer
;  if keyword_set(normalize_background) then path_background_normalized = normalize_image_tiled_envi(path_background, norm_min=norm_min, norm_max=norm_max)
;  
;  ; 2. Create an ENVIRaster object from the source image.  
;  active = e.OpenRaster(path_active_normalized)
;  if keyword_set(normalize_background) then background = e.OpenRaster(path_background_normalized)
;
;  if (background.NROWS ne active.NROWS) or (background.NCOLUMNS ne active.NCOLUMNS) then begin
;    print, 'Error! The images have different dimensions!'
;    return, !null
;  endif
;
;  ; 3. Use ENVIRaster::CreateTileIterator to create a tile iterator object.
;  iterator_background = background.CreateTileIterator()
;  iterator_active = active.CreateTileIterator()
;  
;  if (iterator_background.NTILES ne iterator_active.NTILES) then begin
;    print, 'Error! The images have different number of tiles!'
;    return, !null
;  endif
;   
;  if (blend_mode eq 'Luminosity') then begin
;    get_min_max_luminosity, iterator_active, iterator_background, min_c=min_c, max_c=max_c
;  endif
;
;  ; 4. Use the tile iterator to get tiles of data from the source raster.
;  FOR count=1, iterator_background.NTILES DO BEGIN
;    background = iterator_background.Next()
;    active = iterator_active.Next()
;    count++
;    PRINT,''
;    PRINT, 'Tile Number:'
;    PRINT, count
;
;    ; 5. Perform image-processing tasks on the data.
;    active = normalize_lin(active, norm_min[path_active], norm_max[path_active])
;    if keyword_set(normalize_background) then background = normalize_lin(background, norm_min[path_background], norm_max[path_background])
;    
;    top = blend_images(blend_mode, active, background, min_c=min_c, max_c=max_c)
;    rendered_tile = render_images(top, background, opacity)
;    currentSubRect = iterator_background.CURRENT_SUBRECT
;
;    ; 6. Use the ENVIRaster::SetData method to populate the empty raster with the processed tiles of data.
;    blended_image.SetData, rendered_tile, SUB_RECT=currentSubRect
;  ENDFOR
;
;  ; 7. Use the ENVIRaster::Save method to close the raster for writing and to convert it to read-only mode.
;  blended_image.Save
;
;  ; Display new raster
;  View = e.GetView()
;  Layer = View.CreateLayer(blended_image)
;  
;  return, blended_image
;  
;END



; Rendering across all layers - from last to first layer
;
; layers - from wdgt_state
; path_images - array of images
;          Each image is either:
;          (1) rendered image of visualization + blending or
;          (2) original image (if vis EQ '<none>' for that layer), according to path from array of images
;
function render_all_images_tiled, event, in_file
    widget_control, event.top, get_uvalue=p_wdgt_state
    layers = (*p_wdgt_state).current_combination.layers
 
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
        normalize_active = visualization EQ '<custom>'
        normalize_background = (path_background eq paths_images[i]) and visualization NE '<custom>' ; paths_images[visualization]
        
        active = normalize_image_tiled(path_active, layer[i], normalize_image=normalize_active)
        background = normalize_image_tiled(path_background, layer[i+1], normalize_image=normalize_background)
        
        ; Blending parameters
        blend_mode = layers[i].blend_mode
        opacity = layers[i].opacity                    
                
        path_rendered_image = blend_render_tiled(path_background, path_active, blend_mode, opacity) ; returns path to image!
      endelse
    endfor
      
    return, path_rendered_image
end

; For every input file
pro mixer_render_layered_images_tiled, event, in_file
  widget_control, event.top, get_uvalue=p_wdgt_state

  layers = (*p_wdgt_state).current_combination.layers
  paths_images = mixer_get_paths_to_input_files(event, in_file)

  ; Rendering in order
  path_final_image = render_all_images_tiled(layers, paths_images)

  ; ; Save image to file
  ; write_rendered_image_to_file, p_wdgt_state, in_file, final_image
  ;TODO: Above replace with Rename path_final_image to in_file
end

; TILED VERSION OF topo_advanced_vis_mixer_blend_modes
pro topo_advanced_vis_mixer_blend_modes_tiled, event
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
    render_all_images_tiled, event, in_file
  endfor
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
FUNCTION blend_render_tiled, background, active, blend_mode, opacity
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
  size_image = Size(background)
  ; columns and lines/rows
  ncol = size_image[size_image.length-2]
  nrow = size_image[size_image.length-1]
    
  ;TMP
  test123
  
  if (n_channels_active ne n_channels_background) then begin
    indx_active = Where(active NE Nan)
    indx_background = Where(background NE Nan)
  endif else begin
    
    indx_all = Where(active NE Nan, count_all)
    indx_active = array_indices(active)
    indx_background = array_indices(background)
  endelse   
  
  ; Number of pixels
  count_all = ncol * nrow
  indx_all = image[*] ; 2D array -> 1D array
  

  ;Run it - if it is neccessary, divide everything into more tiles;
  nlt = sc_tile_size / ncol   ;the number of rows that can be processed at one moment
  nlt = ncol * nlt            ;the number of pixels to be processed at one moment
  ;n_tiles = ceil(float(nrow) / float(nlt))  ;the number of all tiles
  
  FOR i=0L,count_all-1,nlt DO BEGIN
    
    ; Processing the last tile (max size or smaller; only tile)
    IF (i+nlt) GT (nrow*ncol-1) THEN BEGIN
      nlt0 = nlt
      nlt = nrow*ncol - i
      Print, 'Processing last tile...'
      
    ENDIF ELSE Print, 'Processing tile: ', i/nlt + 1
  
    indx_ok = indx_all[i:i+nlt-1]
    
    active_tile = active[indx_ok]
    background_tile = background[indx_ok]
                   
    line1 = indx_ok[0]/Long(ncol+2*in_svf_r_max) - in_svf_r_max
    line2 = indx_ok[nlt-1]/Long(ncol+2*in_svf_r_max) + in_svf_r_max
    indx_ok = indx_all[i:i+nlt-1] - indx_all[i] + Long((ncol+2L*in_svf_r_max+1L) * in_svf_r_max)
    dem_ok = dem[*,line1:line2]
    
    
    indx_ok = indx_all[i:i+nlt-1]
    line1 = indx_ok[0]/Long(ncol+2*in_svf_r_max) - in_svf_r_max
    line2 = indx_ok[nlt-1]/Long(ncol+2*in_svf_r_max) + in_svf_r_max
    indx_ok = indx_all[i:i+nlt-1] - indx_all[i] + Long((ncol+2L*in_svf_r_max+1L) * in_svf_r_max)   ;correct to correspond just to subset dem_ok
    dem_ok = dem[*,line1:line2]
    
;    IF in_svf EQ 1 THEN BEGIN
;      IF in_opns EQ 1 THEN BEGIN
;        IF in_asvf EQ 1 THEN BEGIN
;          ;SVF, ASVF, OPNS
;          svf_processed = Topo_advanced_vis_svf_compute( $
;            dem_ok, indx_ok, $
;            in_svf_r_max, in_svf_r_min, in_svf_n_dir, $
;            in_asvf_dir, in_poly_level, in_min_weight,$
;            svf=svf, asvf=asvf, opns=opns)
;          Save, svf, File=Strtrim(i, 2)+'svf.sav'
;          Save, asvf, File=Strtrim(i, 2)+'asvf.sav'
;          Save, opns, File=Strtrim(i, 2)+'opns.sav'
;        ENDIF ELSE BEGIN
;          ;SVF, OPNS
;          svf_processed = Topo_advanced_vis_svf_compute( $
;            dem_ok, indx_ok, $
;            in_svf_r_max, in_svf_r_min, in_svf_n_dir, $
;            svf=svf, opns=opns)
;          Save, svf, File=Strtrim(i, 2)+'svf.sav'
;          Save, opns, File=Strtrim(i, 2)+'opns.sav'
;        ENDELSE
;      ENDIF ELSE BEGIN
;        IF in_asvf EQ 1 THEN BEGIN
;          ;SVF, ASVF
;          svf_processed = Topo_advanced_vis_svf_compute( $
;            dem_ok, indx_ok, $
;            in_svf_r_max, in_svf_r_min, in_svf_n_dir, $
;            in_asvf_dir, in_poly_level, in_min_weight,$
;            svf=svf, asvf=asvf)
;          Save, svf, File=Strtrim(i, 2)+'svf.sav'
;          Save, asvf, File=Strtrim(i, 2)+'asvf.sav'
;        ENDIF ELSE BEGIN
;          ;SVF
;          svf_processed = Topo_advanced_vis_svf_compute( $
;            dem_ok, indx_ok, $
;            in_svf_r_max, in_svf_r_min, in_svf_n_dir, $
;            svf=svf)
;          Save, svf, File=Strtrim(i, 2)+'svf.sav'
;        ENDELSE
;      ENDELSE
;    ENDIF ELSE BEGIN
;      IF in_opns EQ 1 THEN BEGIN
;        IF in_asvf EQ 1 THEN BEGIN
;          ;ASVF, OPNS
;          svf_processed = Topo_advanced_vis_svf_compute( $
;            dem_ok, indx_ok, $
;            in_svf_r_max, in_svf_r_min, in_svf_n_dir, $
;            in_asvf_dir, in_poly_level, in_min_weight,$
;            asvf=asvf, opns=opns)
;          Save, asvf, File=Strtrim(i, 2)+'asvf.sav'
;          Save, opns, File=Strtrim(i, 2)+'opns.sav'
;        ENDIF ELSE BEGIN
;          ;OPNS
;          svf_processed = Topo_advanced_vis_svf_compute( $
;            dem_ok, indx_ok, $
;            in_svf_r_max, in_svf_r_min, in_svf_n_dir, $
;            opns=opns)
;          Save, opns, File=Strtrim(i, 2)+'opns.sav'                                    ;negative
;        ENDELSE
;      ENDIF ELSE BEGIN
;        IF in_asvf EQ 1 THEN BEGIN
;          ;ASVF
;          svf_processed = Topo_advanced_vis_svf_compute( $
;            dem_ok, indx_ok, $
;            in_svf_r_max, in_svf_r_min, in_svf_n_dir, $
;            in_asvf_dir, in_poly_level, in_min_weight,$
;            asvf=asvf)
;          Save, asvf, File=Strtrim(i, 2)+'asvf.sav'
;        ENDIF
;      ENDELSE
;    ENDELSE
  ENDFOR
  indx_all = !null & indx_ok = !null

  ;============================================================================

  ;Merge and write results
  ;SVF
  IF N_elements(svf) GT 0 THEN BEGIN
    svf_out = Make_array(ncol, nrow)
    nlt = nlt0
    FOR i=0L,count_all-1,nlt DO BEGIN
      IF (i+nlt) GT (nrow*ncol-1) THEN nlt = nrow*ncol - i
      Restore, Strtrim(i, 2)+'svf.sav'
      File_delete, Strtrim(i, 2)+'svf.sav', /ALLOW_NONEXISTENT
      line1 = i/Long(ncol)
      line2 = (i+nlt-1L)/Long(ncol)
      svf_out[*, line1:line2] = svf
    ENDFOR
    out_file = in_file[0] + '.tif'
  endif
  
  return, null
end

function blend_tile_iterator
  return, null
end

