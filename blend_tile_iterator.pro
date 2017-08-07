; Here is the typical workflow when using tile iterators:

pro get_min_max_luminosity, iterator_background, iterator_active, min_c=min_c, max_c=max_c
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

PRO blend_tile_iterator, file1, file2, blend_mode, opacity
  COMPILE_OPT IDL2

  ; Start the application
  e = ENVI()

  ; Select input data
  ; file = FILEPATH('qb_boulder_pan', ROOT_DIR=e.ROOT_DIR, SUBDIRECTORY = ['data'])

  ; 1. Create an ENVIRaster object from the source image.
  background = e.OpenRaster(file1)
  active = e.OpenRaster(file2)
  
  if (background.NROWS ne active.NROWS) or (background.NCOLUMNS ne active.NCOLUMNS) then begin
    print, 'Error! The images have different dimensions!'
    return
  endif

  ; 2. Create an empty ENVIRaster object with the same number of rows and columns as the source raster.
  newFile = e.GetTemporaryFilename()
  blended_image = ENVIRaster(URI=newFile, $
    NROWS=background.NROWS, $
    NCOLUMNS=background.NCOLUMNS, $
    NBANDS=max(background.NBANDS, active.NBANDS), $
    DATA_TYPE=background.DATA_TYPE)

  ; 3. Use ENVIRaster::CreateTileIterator to create a tile iterator object.
  iterator_background = background.CreateTileIterator()
  iterator_active = active.CreateTileIterator()
  
  if (iterator_background.NTILES ne iterator_active.NTILES) then begin
    print, 'Error! The images have different number of tiles!'
    return
  endif
   
  if (blend_mode eq 'Luminosity') then begin
    get_min_max_luminosity, iterator_background, iterator_active, min_c=min_c, max_c=max_c
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

        
    top = blend_images(blend_mode, active, background, min_c=min_c, max_c=max_c)
    rendered_tile = render_images(top, background, opacity)
    currentSubRect = tileIterator.CURRENT_SUBRECT

    ; 6. Use the ENVIRaster::SetData method to populate the empty raster with the processed tiles of data.
    blended_image.SetData, rendered_tile, SUB_RECT=currentSubRect
  ENDFOR

  ; 7. Use the ENVIRaster::Save method to close the raster for writing and to convert it to read-only mode.
  blended_image.Save

  ; Display new raster
  View = e.GetView()

  Layer = View.CreateLayer(EdgeDogRaster)
END


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
