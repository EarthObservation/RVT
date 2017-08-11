; Here is the typical workflow when using tile iterators:

pro get_min_max_luminosity_tiled, iterator_active, iterator_background, min_c=min_c, max_c=max_c
  FOR count=1, iterator_background.NTILES DO BEGIN
    ; next tile
    background = iterator_background.Next()
    active = iterator_active.Next()

    ; float representation
    background = RGB_to_float(background)
    active = RGB_to_float(active)

    ; luminosity
    lum = lum(active) - lum(background)

    ; from luminosity blend loop
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

    ; from clip_color
    R = reform(c[0, *, *])
    G = reform(c[1, *, *])
    B = reform(c[2, *, *])

    min_tile = min([R, G, B])
    max_tile = max([R, G, B])

    if (isa(min_c, /null)) then min_c = min_tile else min_c = min(min_tile, min_c)
    if (isa(max_c, /null)) then max_c = max_tile else max_c = max(max_tile, max_c)
  endfor
end

function normalize_image_tiled, image_path, visualization, normalization, norm_min=norm_min, norm_max=norm_max, min=min, max=max
  
  raster_image = e.OpenRaster(image_path)
  iterator_image = raster_image.CreateTileIterator()
  
  ; Create a new raster
  newFile = e.GetTemporaryFilename()
  normalized_image_name = ENVIRaster(URI=newFile, $
    NROWS=OrigRaster.NROWS, $
    NCOLUMNS=OrigRaster.NCOLUMNS, $
    NBANDS=OrigRaster.NBANDS, $
    DATA_TYPE=OrigRaster.DATA_TYPE)
  
  
  ; PARAMETERS:
  ; for percentual normalization
  if (normalization EQ 'Perc') then begin
    perc = max
    if(perc GT 0.5 AND perc LT 100.0001) then perc = perc / 100.0
    
    min_values = []
    max_values = []
    
    ; find min, max for linear normalization
    FOR count=1, iterator_image.NTILES DO BEGIN
      image_tile = iterator_image.Next()
      distribution = cgPercentiles(image_tile, Percentiles=[perc, 1.0-perc])
      min_values = [ min_values, distribution[0] ]
      max_values = [ max_values, distribution[1] ]
    endfor
    
    norm_min[visualization] = mean(min_values, /nan)
    norm_max[visualization] = mean(max_values, /nan)
    
  endif else begin
  ; for linear normalization
    norm_min[visualization] = min
    norm_max[visualization] = max    
  endelse

  ; NORMALIZE
  FOR count=1, iterator_image.NTILES DO BEGIN
    ; next tile
    image_tile = iterator_image.Next()
    ; process
    normalized_tile = normalize_lin(image, norm_min[visualization], norm_max[visualization])    
    ; 
    currentSubRect = tileIterator.CURRENT_SUBRECT
    normalized_image_name.SetData, normalized_tile, SUB_RECT=currentSubRect
  endfor
  
  normalized_image_name.Save

  ; Display new raster
  View = e.GetView()
  Layer = View.CreateLayer(normalized_image_name)

  return, normalized_image_name
end

FUNCTION blend_render_tile_iterator, path_background, path_active, blend_mode, opacity, $
                                     normalization, min=min, max=max, $
                                     norm_min=norm_min, norm_max=norm_max, normalize_background=normalize_background
  COMPILE_OPT IDL2

  ; Start the application
  e = ENVI()

  ; Select input data
  ; file = FILEPATH('qb_boulder_pan', ROOT_DIR=e.ROOT_DIR, SUBDIRECTORY = ['data'])

  if (background.NROWS ne active.NROWS) or (background.NCOLUMNS ne active.NCOLUMNS) then begin
    print, 'Error! The images have different dimensions!'
    return, !null
  endif

  ; 2. Create an empty ENVIRaster object with the same number of rows and columns as the source raster.
  newFile = e.GetTemporaryFilename()
  blended_image = ENVIRaster(URI=newFile, $
    NROWS=background.NROWS, $
    NCOLUMNS=background.NCOLUMNS, $
    NBANDS=max(background.NBANDS, active.NBANDS), $
    DATA_TYPE=background.DATA_TYPE)
    
  ; Normalize image on active layer
  path_active_normalized = normalize_image_tiled(path_active, norm_min=norm_min, norm_max=norm_max)
  
  ; Background normalizing only when the background is bottom layer image, not previous rendered image
  if keyword_set(normalize_background) then path_background_normalized = normalize_image_tiled(path_background, norm_min=norm_min, norm_max=norm_max)
  
  ; 1. Create an ENVIRaster object from the source image.  
  active = e.OpenRaster(path_active_normalized)
  if keyword_set(normalize_background) then background = e.OpenRaster(path_background_normalized) $
  else background = e.OpenRaster(path_background)

  ; 3. Use ENVIRaster::CreateTileIterator to create a tile iterator object.
  iterator_background = background_or.CreateTileIterator()
  iterator_active = active_or.CreateTileIterator()
  
  if (iterator_background.NTILES ne iterator_active.NTILES) then begin
    print, 'Error! The images have different number of tiles!'
    return, !null
  endif
   
  if (blend_mode eq 'Luminosity') then begin
    get_min_max_luminosity, iterator_active, iterator_background, min_c=min_c, max_c=max_c
  endif

  ; 4. Use the tile iterator to get tiles of data from the source raster.
  FOR count=1, iterator_background.NTILES DO BEGIN
    background = iterator_background.Next()
    active = iterator_active.Next()
    count++
    PRINT,''
    PRINT, 'Tile Number:'
    PRINT, count

    ; 5. Perform image-processing tasks on the data.
    active = normalize_lin(active, norm_min[path_active], norm_max[path_active])
    if keyword_set(normalize_background) then background = normalize_lin(background, norm_min[path_background], norm_max[path_background])
    
    top = blend_images(blend_mode, active, background, min_c=min_c, max_c=max_c)
    rendered_tile = render_images(top, background, opacity)
    currentSubRect = iterator_background.CURRENT_SUBRECT

    ; 6. Use the ENVIRaster::SetData method to populate the empty raster with the processed tiles of data.
    blended_image.SetData, rendered_tile, SUB_RECT=currentSubRect
  ENDFOR

  ; 7. Use the ENVIRaster::Save method to close the raster for writing and to convert it to read-only mode.
  blended_image.Save

  ; Display new raster
  View = e.GetView()
  Layer = View.CreateLayer(blended_image)
  
  return, blended_image
  
END


; TODO: paths_images (dictionary), try to use mixer_get_paths_to_input_files(event, source_image_file)
function render_all_images_tiled, layers, paths_images, normalization, min=min, max=max

    norm_min = hash()
    norm_max = hash()

    for i=layers.length-1,0,-1 do begin
      ; if current layer has no visualization applied, skip
      visualization = layers[i].vis
      if (visualization EQ '<none>') then continue

      ; if current layer has visualization applied, but there has been no rendering of images yet,
      ; then current layer will be the initial value of rendered_image
      if (path_rendered_image EQ []) then begin
        path_rendered_image = paths_images[visualization] ; TO-DO: to path
        continue
      endif else begin
        ; if current layer has visualization applied, render it as active layer, where old rendered_image is background layer
        path_active = paths_images[visualization] ; TO-DO: to image_path
        path_background = path_rendered_image ; this will be image path when returned from 
        normalize_background = path_background eq paths_images[visualization]
        blend_mode = layers[i].blend_mode
        opacity = layers[i].opacity  
        
        path_rendered_image = blend_render_tile_iterator(path_background, path_active, blend_mode, opacity, $ 
                                                         normalization, min=min, max=max, $
                                                         norm_min=norm_min, norm_max=norm_max, normalize_background=normalize_background)
      endelse
    endfor
      
    return, path_rendered_image
end


; For every input file
pro mixer_render_layered_images_tiled, event, in_file
  widget_control, event.top, get_uvalue=p_wdgt_state

  layers = (*p_wdgt_state).current_combination.layers
  paths_images = (*p_wdgt_state).mixer_layer_filepaths[i] ; (*p_wdgt_state).mixer_layer_images

  normalization = layers[i].normalization
  min = float(layers[i].min)
  max = float(layers[i].max)

  ; Rendering in order
  path_final_image = render_all_images_tiled(layers, paths_images, normalization, min=min, max=max)

  ; ; Save image to file
  ; write_rendered_image_to_file, p_wdgt_state, in_file, final_image
  ; TODO: Above replace with Rename path_final_image to in_file
end

pro topo_advanced_vis_mixer_blend_modes_tiled, event
  widget_control, event.top, get_uvalue=p_wdgt_state
  in_file_string = (*p_wdgt_state).selection_str

  in_file_list = strsplit(in_file_string, '#', /extract)
  for nF = 0,in_file_list.length-1 do begin
    ; Input file
    in_file = in_file_list[nF]
    print, 'File name:', in_file

    ; process with tiling
    mixer_render_layered_images_tiled, event, in_file

  endfor
end

;pro topo_advanced_tiling
;
;  ;Run it - if it is neccessary, divide everything into more tiles;
;  ;determine first, how many lines corespond to one tile
;  nlt = sc_tile_size / ncol   ;the number of rows that can be processed at one moment
;  nlt = ncol * nlt            ;the number of pixels to be processed at one moment
;  ;n_tiles = ceil(float(nlin) / float(nlt))  ;the number of all tiles
;  FOR i=0L,count_all-1,nlt DO BEGIN
;    IF (i+nlt) GT (nlin*ncol-1) THEN BEGIN   ;the last tile (the only one if it is small) is usually smaller than the maximal size
;      nlt0 = nlt
;      nlt = nlin*ncol - i
;      Print, 'Processing last tile...'
;    ENDIF ELSE Print, 'Processing tile: ', i/nlt + 1
;    indx_ok = indx_all[i:i+nlt-1]
;    line1 = indx_ok[0]/Long(ncol+2*in_svf_r_max) - in_svf_r_max
;    line2 = indx_ok[nlt-1]/Long(ncol+2*in_svf_r_max) + in_svf_r_max
;    indx_ok = indx_all[i:i+nlt-1] - indx_all[i] + Long((ncol+2L*in_svf_r_max+1L) * in_svf_r_max)   ;correct to correspond just to subset dem_ok
;    dem_ok = dem[*,line1:line2]
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
;  ENDFOR
;  indx_all = !null & indx_ok = !null
;
;  ;============================================================================
;
;  ;Merge and write results
;  ;SVF
;  IF N_elements(svf) GT 0 THEN BEGIN
;    svf_out = Make_array(ncol, nlin)
;    nlt = nlt0
;    FOR i=0L,count_all-1,nlt DO BEGIN
;      IF (i+nlt) GT (nlin*ncol-1) THEN nlt = nlin*ncol - i
;      Restore, Strtrim(i, 2)+'svf.sav'
;      File_delete, Strtrim(i, 2)+'svf.sav', /ALLOW_NONEXISTENT
;      line1 = i/Long(ncol)
;      line2 = (i+nlt-1L)/Long(ncol)
;      svf_out[*, line1:line2] = svf
;    ENDFOR
;    out_file = in_file[0] + '.tif'
;
;
;
;end
;

