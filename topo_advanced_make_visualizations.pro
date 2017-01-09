;pro topo_advanced_make_visualizations, wdgt_state, temp_sav, in_file_string, rvt_version, rvt_issue_year
pro topo_advanced_make_visualizations, p_wdgt_state, temp_sav, in_file_string, rvt_version, rvt_issue_year
  wdgt_state = *p_wdgt_state

  ;=========================================================================================================
  ;=== Setup constnants that cannot be changed by the user =================================================
  ;=========================================================================================================

  ;Vertical exaggeration
  sc_ve_ex = [-1000., 1000.]
  
  ; exaggetarion factor
  ve_floor = sc_ve_ex[0]
  ve_ceil = sc_ve_ex[1]

  ;Hillshading
  sc_hls_sun_a = [0., 360.]            ;solar azimuth angle in degrees
  sc_hls_sun_h = [0, 90.]              ;solar vertical elevation angle in degres

  ;Multiple hillshading
  sc_mhls_n_dir = [4,16,8,32,64,360]   ;number of directions; drop-down menu values: 16,8,32,64; editable!
  sc_mhls_n_dir = [0., 75.]            ;solar vertical elevation angle in degres
  sc_mhls_a_rgb = [315., 15., 75.]     ;azimuth for RGB components
  sc_mhls_n_psc = [3, 5]               ;number of principal componnents to save

  ;Simple local relief model
  sc_slrm_r_max = [10., 50.]           ;radius in pixels

  ;SVF
  sc_svf_n_dir = [4, 16, 8, 32, 360]   ;number of directions; drop-down menu values: 16,8,32; editable!
  sc_svf_r_max = [5., 100.]            ;maximal search radius
  sc_svf_r_min = [0., 10., 20., 40.]   ;minimal search radius as percent of max search radius
  sc_asvf_min = [0.4, 0.1]             ;minimal brightness of the sky for both models
  in_asvf_dir = [0., 360.]             ;main direction of anisotropy in degrees
  sc_asvf_pol = [4, 8]                 ;polynomial level (how fast decreases brightness from the brightes to the darkest point )
  ;anisotropy 0-low 1-high

  ;Conversion to byte - linear, with below defined borders
  sc_hls_ev = [0.00, 1.00]
  sc_svf_ev = [0.6375, 1.00]
  sc_opns_ev = [60, 95.]
  sc_slp_ev = [0., 51.]
  sc_slrm_ev = [-2., 2.]
  sc_skyilu_ev = [0.25, 0.]   ;percent
  sc_ld_ev = [0.5, 1.8]

  ;If input DEM is larger as the size below, do tiling
  sc_tile_size = 5L*10L^6

  ;=========================================================================================================
  ;=== Initialize input parameters by user-selected values =================================================
  ;=========================================================================================================

  ;Initialize input parameters by user-selected values

  ;Overwrite
  overwrite = float(wdgt_state.overwrite)

  ;Vertical exaggeration
  in_ve_ex = float(wdgt_state.ve)                   ;-1000. to 1000.

  ;Hillshading
  in_hls = byte(wdgt_state.hls_use)                 ;1-run, 0-don't run
  in_hls_sun_a = float(wdgt_state.hls_az)           ;solar azimuth angle in degrees
  in_hls_sun_h = float(wdgt_state.hls_el)           ;solar vertical elevation angle in degres
  shadow_use = byte(wdgt_state.shadow_use)

  ;Multiple hillshading + PCA
  in_mhls = byte(wdgt_state.mhls_use)               ;1-run, 0-don't run
  in_mhls_n_dir = fix(wdgt_state.mhls_nd)           ;number of directions
  in_mhls_sun_h = float(wdgt_state.mhls_el)         ;solar vertical elevation angle in degres
  ;in_mhls_rgb = 1                                   ;1-make multiple hillshaing RGB, 0-don't
  in_mhls_pca = byte(wdgt_state.mhls_pca_use)       ;1-run PCA hillshading, 0-don't run
  in_mhls_n_psc = fix(wdgt_state.mhls_pca_nc)       ;number of principal componnents to save

  ;Slope gradient
  in_slp = byte(wdgt_state.slp_use)                 ;1-run, 0-don't run

  ;Simple local relief model
  in_slrm = byte(wdgt_state.slrm_use)               ;1-run, 0-don't run
  in_slrm_r_max = float(wdgt_state.slrm_dist)       ;radius in pixels

  ;SVF + Openness + Negative openness
  in_svf = byte(wdgt_state.svf_use)                 ;1-run, 0-don't run
  in_svf_n_dir = fix(wdgt_state.svf_nd)             ;number of directions
  in_svf_r_max = float(wdgt_state.svf_sr)           ;maximal search radius
  in_svf_noise = fix(wdgt_state.svf_rn)             ;level of noise to remove (0- no removal, 1-low, 2-medium, 3-high)
  in_asvf = byte(wdgt_state.asvf_use)               ;1-run anisotropic SVF, 0-don't run
  in_asvf_level = fix(wdgt_state.asvf_lv)           ;0-low level (2, 0.5), 1-high level (5, 0.2)
  in_asvf_dir = float(wdgt_state.asvf_dr)           ;main direction of anisotropy in degrees
  in_open = byte(wdgt_state.open_use)               ;1-run openess, 0-don't run
  in_open_negative = fix(wdgt_state.open_neg_use)   ;1-compute negative openess, 0-positive

  ;Sky illumination
  in_skyilm = byte(wdgt_state.skyilm_use)
  in_skyilm_shadow = byte(wdgt_state.skyilm_shadow_use)
  in_skyilm_model = wdgt_state.skyilm_model
  in_skyilm_points = wdgt_state.skyilm_points
  in_skyilm_shadow_dist = wdgt_state.skyilm_shadow_dist
  in_skyilm_az = float(wdgt_state.skyilm_az)
  in_skyilm_el = float(wdgt_state.skyilm_el)

  ;Local domination
  in_locald = byte(wdgt_state.locald_use)
  in_locald_min_rad = ulong(wdgt_state.locald_min_rad)
  in_locald_max_rad = ulong(wdgt_state.locald_max_rad)

  ;Get file names stored inside selection panel on top of the GUI
  ;id_selection_panel = widget_info(base_main, find_by_uname='u_selection_panel') ; in_file_string = wdgt_state.selection_str
  if (in_file_string eq '') then begin
    print
    print, '# WARNING: No input files selected. Processing stopped!'
    file_delete, temp_sav, /allow_nonexistent, /quiet
    return
  endif
  in_file_list = strsplit(in_file_string, '#', /extract)
  n_files = n_elements(in_file_list)

  ; Initate progress-bar display (withot cancel button), ...
  statText = 'Generating selected visualizations from selected input files.
  progress_bar = obj_new('progressbar', title='Relief Visualization Toolbox - Progress ...', text=statText, xsize=300, ysize=20, $
    nocancel=1)
  progress_bar -> Start
  ; ... define values to assist the display
  progress_total = in_hls + in_mhls + in_mhls_pca + in_slp + in_slrm + in_svf + in_open + in_asvf + in_open_negative + in_skyilm + in_locald ; number of selected procedures
  progress_step = 100. / progress_total /n_files
  progress_step_image = 100. /n_files
  progress_curr = progress_step / 2
  ; ... and display progress
  ;  ; since prograss-bar has no cancel button, this lines are omitted
  ;  IF progress_bar->CheckCancel() THEN BEGIN
  ;     ok = Dialog_Message('Processing cancelled.')
  ;     progress_bar -> Destroy ; Destroy the progress bar.
  ;     return
  ;  ENDIF
  progress_bar -> Update, progress_curr


  for nF = 0, n_files-1 do begin

    ;Input file
    in_fname = in_file_list[nF]
    in_file = in_fname

    ;========================================================================================================
    ;Start processing metadata TXT file
    ;========================================================================================================
    ;Define metadata filename
    date = Systime(/Julian)
    Caldat, date, Month, Day, Year, Hour, Minute, Second
    IF month LT 10 THEN month = '0' + Strtrim(month,1) ELSE month = Strtrim(month,1)
    IF day LT 10 THEN day = '0' + Strtrim(day,1) ELSE day = Strtrim(day,1)
    IF Hour LT 10 THEN Hour = '0' + Strtrim(Hour,1) ELSE Hour = Strtrim(Hour,1)
    IF Minute LT 10 THEN Minute = '0' + Strtrim(Minute,1) ELSE Minute = Strtrim(Minute,1)
    IF Second LT 10 THEN Second = '0' + Strtrim(Round(Second),1) ELSE Second = Strtrim(Round(Second),1)
    date_time = Strtrim(Year,1) + '-' + month + '-' + day + '_' + hour + '-' + minute + '-' + second

    last_dot = strpos(in_file, '.' , /reverse_search)
    if last_dot eq -1 or (last_dot gt 0 and strlen(in_file)-last_dot ge 6) then out_file = in_file $  ;input file has no extension or extensions is very long (>=6) e.q. there is no valid extension or dost is inside filename
    else out_file = strmid(in_file, 0, last_dot)
    out_file += '_process_log_' + date_time + '.txt'
    ;out_file = strmid(in_file,0,strlen(in_file)-4) + '_process_log_' + date_time + '.txt'
    ;Open metadata ASCII for writing

    ; Write header of the metadata file
    Get_lun, unit
    Openw, unit, out_file, /append
    Printf, unit
    Printf, unit, '==============================================================================================='
    Printf, unit, 'Relief Visualization Toolbox (version ' + rvt_version + '); (c) ZRC SAZU, ' + rvt_issue_year
    Printf, unit, '==============================================================================================='
    Free_lun, unit


    ;=========================================================================================================
    ;Check if input file is TIFF, else convert it
    if strpos(strlowcase(in_file), '.tif') eq -1 and strpos(strlowcase(in_file), '.tiff') eq -1 then begin
      topo_advanced_vis_converter, in_file, 'GeoTIFF', out_file, out_img_file=out_img_file
      in_fname = out_img_file
      in_file = out_img_file
    endif


    ;=========================================================================================================
    ;=== Select input DEM and verify geotiff information =====================================================
    ;=========================================================================================================

    Get_lun, unit
    Openw, unit, out_file, /append
    Printf, unit
    Printf, unit
    Printf, unit
    Printf, unit, 'Processing info about visualizations'
    Printf, unit, '==============================================================================================='
    Free_lun, unit

    ; Open the file and read data
    in_orientation = 1
    in_rotation = 7

    ;wdgt_state.in_orientation = in_orientation
    (*p_wdgt_state).in_orientation = in_orientation

    if file_test(in_fname) eq 0 then begin
      errMsg = 'ERROR: Processing stopped! Selected TIF image was not found. '+ in_fname
      Get_lun, unit
      Openw, unit, out_file, /append
      Printf, unit
      Printf, unit, errMsg
      Printf, unit
      Free_lun, unit
      print, errMsg
      progress_bar -> Update, progress_curr
      progress_curr += progress_step_image
      continue
    endif $
    else begin
      heights = read_image_geotiff(in_fname, in_orientation)
    endelse

    ; Define number of bands
    in_file_dims = size(heights, /dimensions)
    in_nb = n_elements(in_file_dims) > 2 ? in_file_dims[2] : 1
    if (in_nb ne 1) then begin
      errMsg = 'ERROR: Processing stopped! Only one band is allowed for DEM files.'
      Get_lun, unit
      Openw, unit, out_file, /append
      Printf, unit
      Printf, unit, errMsg
      Printf, unit
      Free_lun, unit
      print, errMsg
      progress_bar -> Update, progress_curr
      progress_curr += progress_step_image
      continue
    endif

    ; Extract raster parameters
    heights_min = min(heights)
    heights_max = max(heights)

    in_file_dims = size(heights, /dimensions)  ; due to rotation calculate again
    nrows = in_file_dims[1]
    ncols = in_file_dims[0]

    in_geotiff_elements = n_elements(in_geotiff)
    if (in_geotiff_elements gt 0) then begin  ; in_geotiff defined
      in_geotiff_tags = strlowcase(tag_names(in_geotiff))
      tag_exists = where(in_geotiff_tags eq strlowcase('ModelPixelScaleTag'))
      if (tag_exists[0] eq -1) then begin  ; tif without tag ModelPixelScaleTag
        in_pixel_size = dblarr(2) & in_pixel_size[0] = 1d & in_pixel_size[1] = 1d
        in_crs = 1
      endif else begin
        in_pixel_size = in_geotiff.ModelPixelScaleTag
        ;        if in_pixel_size[0] eq 0 and in_pixel_size [1] eq 0 then begin  ;geotiff with pixelsize eq to 0
        ;          in_pixel_size[0] = 0.02002
        ;          in_pixel_size[1] = 0.02002
        ;        endif
      endelse

      tag_exists = where(in_geotiff_tags eq strlowcase('GTModelTypeGeoKey'))
      if (tag_exists[0] gt -1) then begin ; geotiff with defined tag GTModelTypeGeoKey
        ; possible tag values: 1=projected, 2=geographic lat/lon, 3=geocentric (X,Y,Z)
        in_crs = in_geotiff.GTModelTypeGeoKey
        in_crs = (in_pixel_size[1] gt 0.1) ? 1 : 2
      endif else begin  ; tif file (with tfw), or geotiff without tag GTModelTypeGeoKey
        ; distinction based on pixel size
        in_crs = (in_pixel_size[1] gt 0.1) ? 1 : 2
      endelse

    endif else begin  ; in_geotiff undefined
      in_pixel_size = dblarr(2) & in_pixel_size[0] = 1d & in_pixel_size[1] = 1d
      in_crs = 1
    endelse
    ve_degrees = (in_crs eq 2) ? 1 : 0  ; units Degrees or Meters

    ; Output to IDL console
    print, '     Number of columns: ', strtrim(ncols,2)
    print, '     Number of rows:    ', strtrim(nrows,2)
    print, '     Number of bands:   ', strtrim(in_nb,2)
    if (in_crs eq 2) then begin  ; geographic coordinate system
      print, format='("     Resolution (x, y): ", f0.6, ", ", f0.6)', $
        in_pixel_size[0], in_pixel_size[1]
      wtext_resolution = string(format='("     Resolution (x, y):   ", f0.6, ", ", f0.6)', $
        in_pixel_size[0], in_pixel_size[1])
    endif else begin   ; projected or geocentric coordinate system
      print, format='("     Resolution (x, y): ", f0.1, ", ", f0.1)', $
        in_pixel_size[0], in_pixel_size[1]
      wtext_resolution = string(format='("     Resolution (x, y):   ", f0.1, ", ", f0.1)', $
        in_pixel_size[0], in_pixel_size[1])
    endelse
    resolution = in_pixel_size[1]

    Get_lun, unit
    Openw, unit, out_file, /append
    ;Start writing metadata into the file
    ;DEM
    Printf, unit
    Printf, unit, '# Metadata of the input file'
    Printf, unit, '     Input filename:     ' + in_fname
    Printf, unit, '     Number of columns:  ', Strtrim(ncols,2)
    Printf, unit, '     Number of rows:     ', Strtrim(nrows,2)
    Printf, unit, '     Number of bands:    ', Strtrim(in_nb,2)
    IF (in_crs EQ 2) THEN BEGIN  ; geographic coordinate system
      Printf, unit, format='("     Resolution (x, y):  ", f0.6, ", ", f0.6)', $
        in_pixel_size[0], in_pixel_size[1]
    ENDIF ELSE BEGIN   ; projected or geocentric coordinate system
      Printf, unit, format='("     Resolution (x, y):  ", f0.1, ", ", f0.1)', $
        in_pixel_size[0], in_pixel_size[1]
    ENDELSE


    ;=== Change parameter values that are not within allowed intervals of values =============================

    print
    print, '# Warnings'
    Printf, unit
    Printf, unit, '# Warnings'

    ; Checks for overwrite setting
    if keyword_set(overwrite) eq 0 then begin
      print, '     ! Files with the same name as RVT outputs WILL NOT BE overwritten if they already exist!'
      Printf, unit, '     ! Files with the same name as RVT outputs WILL NOT BE overwritten if they already exist!'
    endif else begin
      print, '     ! Files with the same name as RVT outputs WILL BE overwritten if they already exist!'
      Printf, unit, '     ! Files with the same name as RVT outputs WILL BE overwritten if they already exist!'
    endelse
    ; Checks for Vertical exagerattion
    if in_ve_ex eq 0. then begin
      in_ve_ex = 1.
      print, '     ! Vertical exaggeration was changed to 1.0 (value 0.0 is not allowed)!'
      Printf, unit, '     ! Vertical exaggeration was changed to 1.0 (value 0.0 is not allowed)!'
    endif
    if in_ve_ex lt ve_floor then begin
      in_ve_ex = ve_floor
      print, '     ! Vertical exaggeration was changed to minimal allowed value ' + string(ve_floor, format="(f0.1)") +  '!'
      Printf, unit, '     ! Vertical exaggeration was changed to minimal allowed value ' + string(ve_floor, format="(f0.1)") +  '!'
    endif
    if in_ve_ex gt ve_ceil then begin
      in_ve_ex = ve_ceil
      print, '     ! Vertical exaggeration was changed to maximal allowed value ' + string(ve_ceil, format="(f0.1)") +  '!'
      Printf, unit, '     ! Vertical exaggeration was changed to maximal allowed value ' + string(ve_ceil, format="(f0.1)") +  '!'
    endif
    if ve_degrees eq 1 then begin
      print, '     ! The input DEM is given in geographic cooridnates. To account for the difference between angular and metric unit '
      print, '       the approximate metric pixel resolution is considered in further computation!'
      Printf, unit, '     ! The input DEM is given in geographic cooridnates. To account for the difference between angular and metric unit '
      Printf, unit, '       the approximate metric pixel resolution is considered in further computation!'
    endif

    ; Checks for Analytical hillshading
    if in_hls_sun_a lt 0. or in_hls_sun_a gt 360. then begin
      in_hls_sun_a = 360. < in_hls_sun_a > 0.
      print, '     ! Analytical hillshading: Sun azimuth was trimmed to fit into the allowed interval 0.0-360.0 degrees!'
      Printf, unit, '     ! Analytical hillshading: Sun azimuth was trimmed to fit into the allowed interval 0.0-360.0 degrees!'
    endif
    if in_hls_sun_h lt 0. or in_hls_sun_h gt 360. then begin
      in_hls_sun_h = 90. < in_hls_sun_h > 0.
      print, '     ! Analytical hillshading: Sun elevation angle was trimmed to fit into the allowed interval 0.0-90.0 degrees!'
      Printf, unit, '     ! Analytical hillshading: Sun elevation angle was trimmed to fit into the allowed interval 0.0-90.0 degrees!'
    endif

    ; Checks for Hillshading from multiple directions
    if in_mhls_n_dir lt 4 or in_mhls_n_dir gt 360 then begin
      in_mhls_n_dir = 360 < in_mhls_n_dir > 4
      print, '     ! Hillshading from multiple directions: Number of directions was trimmed to the interval 4-360!'
      Printf, unit, '     ! Hillshading from multiple directions: Number of directions was trimmed to the interval 4-360!'
    endif
    if in_mhls_sun_h lt 0. or in_mhls_sun_h gt 75. then begin
      in_mhls_sun_h = 75. < in_mhls_sun_h > 0.
      print, '     ! Hillshading from multiple directions: Sun elevation angle was trimmed to fit into the allowed interval 0.0-75.0 degrees!'
      Printf, unit, '     ! Hillshading from multiple directions: Sun elevation angle was trimmed to fit into the allowed interval 0.0-75.0 degrees!'
    endif

    ; Checks for PCA: number of principal components to be saved
    if in_mhls_pca then begin
      if in_mhls_n_psc ge in_mhls_n_dir then begin
        in_mhls_n_psc = in_mhls_n_dir - 1
        print, '     ! PCA: Number of principal components was changed into ' + strtrim(in_mhls_n_psc,2) + $
          ' (has to be smaller than number of direction of Hillshading from multiple directions method)!'
        Printf, unit, '     ! PCA: Number of principal components was changed into ' + strtrim(in_mhls_n_psc,2) + $
          ' (has to be smaller than number of direction of Hillshading from multiple directions method)!'
      endif
      if in_mhls_n_psc lt 3 then begin
        in_mhls_n_psc = 3
        print, '     ! PCA: Number of principal components was changed into ' + strtrim(in_mhls_n_psc,2) + $
          ' (i.e. minimal number of direction of Hillshading from multiple directions method)!'
        Printf, unit, '     ! PCA: Number of principal components was changed into ' + strtrim(in_mhls_n_psc,2) + $
          ' (i.e. minimal number of direction of Hillshading from multiple directions method)!'
      endif
    endif

    ; Checks for Simple local relief model
    if in_slrm_r_max lt 10. or in_slrm_r_max gt 50. then begin
      in_slrm_r_max = 50. < in_slrm_r_max > 10.
      print, '     ! Simple local relief model: Radius for trend assessment was trimmed to the allowed interval 10-50 pixels!'
      Printf, unit, '     ! Simple local relief model: Radius for trend assessment was trimmed to the allowed interval 10-50 pixels!'
    endif

    ; Checks for SVF + Openness + Negative openness
    if in_svf_n_dir lt 4 or in_svf_n_dir gt 360 then begin
      in_svf_n_dir = 360 < in_svf_n_dir > 4
      print, '     ! Sky-View Factor: Number of search directions was trimmed to the allowed interval 4-360!'
      Printf, unit, '     ! Sky-View Factor: Number of search directions was trimmed to the allowed interval 4-360!'
    endif
    if in_svf_r_max lt 5 or in_svf_r_max gt 100 then begin
      in_svf_r_max = 100 < in_svf_r_max > 5
      print, '     ! Sky-View Factor: Search radius was trimmed to the allowed interval 5-100 pixels!'
      Printf, unit, '     ! Sky-View Factor: Search radius was trimmed to the allowed interval 5-100 pixels!'
    endif
    if in_asvf_dir lt 0 or in_asvf_dir gt 360 then begin
      in_asvf_dir = 360 < in_asvf_dir > 0
      print, '     ! Anisotropic Sky-View Factor: Main direction of anisotropy was trimmed to the allowed interval 0.0-360.0 degrees!'
      Printf, unit, '     ! Anisotropic Sky-View Factor: Main direction of anisotropy was trimmed to the allowed interval 0.0-360.0 degrees!'
    endif

    ; Close metadata file
    Close, unit

    ;=== Print selected parameter values =============================

    print
    print, '# Selected visualization parameter'
    print, '     Vertical exaggeration factor:  ', in_ve_ex
    ;print, format='("No data value:  ", f0.2)', nodata_value
    print
    print, '# The following visualizations will be performed:  '

    if in_hls then begin
      print, '     > Analytical hillshading'
      print, '          Sun azimuth [deg.]: ', in_hls_sun_a
      print, '          Sun elevation angle [deg.]: ', in_hls_sun_h
    endif

    ;Multiple hillshading + PCA
    if in_mhls then begin
      print, '     > Hillshading from multiple directions'
      print, '          Number of directions: ', in_mhls_n_dir
      print, '          Sun elevation angle [deg.]: ', in_mhls_sun_h
      ;in_mhls_rgb = 1                                   ;1-make multiple hillshaing RGB, 0-don't
    endif
    if in_mhls_pca then begin
      print, '     > PCA of hillshading'
      print, '          Number of components to save: ', in_mhls_n_psc
      print, '          Note: Components are taken from the Hillshading from multiple directions method'
      print, '          and are prepared with the following parameters:'
      print, '               Number of directions: ', in_mhls_n_dir
      print, '               Sun elevation angle [deg.]: ', in_mhls_sun_h
    endif

    ;Slope gradient
    if in_slp then begin
      print, '     > Slope gradient'
      print, '          Note: No parameters required.'
    endif

    ;Simple local relief model
    if in_slrm then begin
      print, '     > Simple local relief model'
      print, '          Radius for trend assessment [pixels]: ', in_slrm_r_max
    endif

    ;SVF + Openness + Negative openness
    if in_svf then begin
      print, '     > Sky-View Factor'
      print, '          Number of search directions: ', in_svf_n_dir
      print, '          Search radius [pixels]: ', in_svf_r_max
      case in_svf_noise of
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        else: str_in_svf_noise = 'no removal'
      endcase
      print, '          Level of noise removal:       ', str_in_svf_noise
    endif
    if in_asvf then begin
      print, '     > Anisotropic Sky-View Factor'
      case in_asvf_level of
        1: str_in_asvf_level = 'low'
        2: str_in_asvf_level = 'high'
        else: str_in_asvf_level = 'no removal'
      endcase
      print, '          Level of anisotropy:       ', str_in_asvf_level
      print, '          Main direction of anisotropy [degrees]:       ', in_asvf_dir
      print, '          Note: Other parameters are taken from the Sky-View Factor method:'
      print, '               Number of search directions: ', in_svf_n_dir
      print, '               Search radius [pixels]: ', in_svf_r_max
      case in_svf_noise of
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        else: str_in_svf_noise = 'no removal'
      endcase
      print, '               Level of noise removal:       ', str_in_svf_noise
    endif
    if in_open then begin
      print, '     > Openness - Positive'
      print, '          Note: Parameters are taken from the Sky-View Factor method:'
      print, '               Number of search directions: ', in_svf_n_dir
      print, '               Search radius [pixels]: ', in_svf_r_max
      case in_svf_noise of
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        else: str_in_svf_noise = 'no removal'
      endcase
      print, '               Level of noise removal:       ', str_in_svf_noise
    endif
    if in_open_negative then begin
      print, '     > Openness - Negative'
      print, '          Note: Parameters are taken from the Sky-View Factor method:'
      print, '               Number of search directions: ', in_svf_n_dir
      print, '               Search radius [pixels]: ', in_svf_r_max
      case in_svf_noise of
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        else: str_in_svf_noise = 'no removal'
      endcase
      print, '               Level of noise removal:       ', str_in_svf_noise
    endif
    if in_skyilm then begin
      print, '     > Sky illumination'
      print, '          Sky model: ', in_skyilm_model
      print, '          Number of sampling points: ', in_skyilm_points
      if in_skyilm_shadow then begin
        print, '          Note: Shadow modelling enabled.'
        print, '               Sun azimuth [deg.]: ', in_skyilm_az
        print, '               Sun elevation angle [deg.]: ', in_skyilm_el
      endif $
      else print, '          Note: Shadow modelling disabled.'
    endif
    if in_locald then begin
      print, '     > Local dominance'
      print, '          Minimum radius: ', in_locald_min_rad
      print, '          Maximum radius: ', in_locald_max_rad
    endif



    ;========================================================================================================
    ;=== Start processing  ==================================================================================
    ;========================================================================================================

    ; Array of output files
    output_files_array = hash()

    starttime = Systime(/seconds)
    Print
    Print
    Print, '# Computation started at  ', Systime()

    ; Main part of the program

    ;Correct vertical scale if data are not projected (unprojected lon, lat data)
    heights = Float(heights) * in_ve_ex
    IF (ve_degrees) THEN  resolution = 111300. * resolution

    ;Correct filename
    len_in_file = Strlen(in_file)
    in_file = Strmid(in_file, 0, len_in_file-4)     ;preffix to add proccessing parameters
    str_ve = '_Ve' + String(in_ve_ex, Format='(F0.1)')  ;vertical exageration
    IF in_ve_ex EQ 1. then str_ve = ''

    ;save tiff that was multiplied by vertical exageration
    if in_ve_ex ne 1. then begin
      out_file_ve = in_file + str_ve + '.tif'
      if keyword_set(overwrite) eq 0 and file_test(out_file_ve) eq 1 then $
        print, ' Image already exists ('+out_file_ve+')' $
      else $
        write_tiff, out_file_ve, heights, compression=1, /float, geotiff=in_geotiff
    endif

    ;Hillshading
    IF in_hls EQ 1 THEN BEGIN
      out_file_hls = in_file + '_HS_A' + Strtrim(Long(in_hls_sun_a), 2) + '_H' + Strtrim(Long(in_hls_sun_h), 2) + str_ve
      output_files_array += hash('Analytical hillshading', out_file_hls)
      Topo_advanced_vis_hillshade, out_file_hls, in_geotiff, $
        heights, resolution, $                ;relief
        in_hls_sun_a, in_hls_sun_h, $                   ;solar position
        sc_hls_ev, $
        overwrite=overwrite
      ; ... display progress
      out_file_shadow_only = in_file + '_shadow_A' + Strtrim(Long(in_hls_sun_a), 2) + '_H' + Strtrim(Long(in_hls_sun_h), 2) + str_ve
      if shadow_use then begin
        Topo_advanced_vis_skyillumination, out_file_shadow_only, in_geotiff,$
          heights, resolution, $
          '', '', '', '', $
          in_hls_sun_a, in_hls_sun_h, /shadow_only, $
          overwrite=overwrite
      endif
      progress_bar -> Update, progress_curr
      progress_curr += progress_step < 100
    ENDIF

    ;Multiple hillshading
    IF in_mhls EQ 1 THEN BEGIN
      out_file_mhls = in_file + '_MULTI-HS_D' + Strtrim(Long(in_mhls_n_dir), 2) + '_H' + Strtrim(Long(in_mhls_sun_h), 2) + str_ve
      output_files_array += hash('Hillshading from multiple directions', out_file_mhls + '_RGB')
      Topo_advanced_vis_multihillshade, out_file_mhls, in_geotiff, $
        heights, resolution, $                ;relief
        in_mhls_n_dir, in_mhls_sun_h, $                 ;solar position
        sc_mhls_a_rgb, sc_hls_ev , $       ;directions for RGB outputRGB
        overwrite=overwrite
      ; ... display progress
      progress_bar = obj_new('progressbar', title='Relief Visualization Toolbox - Progress ...', text=statText, xsize=300, ysize=20, $
        nocancel=1, /start, percent = fix(progress_curr<100))
      progress_curr += progress_step
    ENDIF

    ;PCA hillshading
    IF in_mhls_pca EQ 1 THEN BEGIN
      out_file_mhls_pca = in_file + '_PCA_D' + Strtrim(Long(in_mhls_n_dir), 2) + '_H' + Strtrim(Long(in_mhls_sun_h), 2) + str_ve
      output_files_array += hash('PCA of hillshading', out_file_mhls_pca + '_RGB')
      Topo_advanced_vis_PCAhillshade, out_file_mhls_pca, in_geotiff, $
        heights, resolution, $     ;relief
        in_mhls_n_dir, in_mhls_sun_h, $  ;solar position
        in_mhls_n_psc, sc_hls_ev, $     ;number of PCs to save
        overwrite=overwrite
      ; ... display progress
      progress_bar -> Update, progress_curr
      progress_curr += progress_step
    ENDIF

    ;Slope
    IF in_slp EQ 1 THEN BEGIN
      out_file_slp = in_file + '_SLOPE' + str_ve
      output_files_array += hash('Slope gradient', out_file_slp)
      topo_advanced_vis_gradient, out_file_slp, in_geotiff, $
        heights, resolution, $                    ;relief
        sc_slp_ev, $
        overwrite=overwrite
      ; ... display progress
      progress_bar -> Update, progress_curr
      progress_curr += progress_step
    ENDIF

    ;Local releif
    IF in_slrm EQ 1 THEN BEGIN
      out_file_slrm = in_file + '_SLRM_R' + Strtrim(Long(in_slrm_r_max), 2) + str_ve
      output_files_array += hash('Simple local relief model', out_file_slrm)
      topo_advanced_vis_localrelief, out_file_slrm, in_geotiff, $
        heights, resolution, $                    ;relief
        in_slrm_r_max, sc_slrm_ev, $
        overwrite=overwrite
      ; ... display progress
      progress_bar -> Update, progress_curr
      progress_curr += progress_step
    ENDIF

    ;SVF / anisotropic SVF / openess
    IF in_svf+in_open+in_asvf NE 0 THEN BEGIN
      CASE in_svf_noise OF
        0: str_noise = ''
        1: str_noise = '_NRlow'
        2: str_noise = '_NRmedium'
        3: str_noise = '_NRstrong'
      ENDCASE
      CASE in_asvf_level OF
        1: str_aniso = '_AIlow'
        2: str_aniso = '_AIstrong'
      ENDCASE
      out_file_svf = [in_file + '_SVF_R' + Strtrim(Round(in_svf_r_max), 2) + '_D' + Strtrim(in_svf_n_dir, 2) + str_noise + str_ve, $
        in_file + '_SVF-A_R' + Strtrim(Round(in_svf_r_max), 2) + '_D' + Strtrim(in_svf_n_dir, 2) + '_A' + Strtrim(round(in_asvf_dir), 2) + str_aniso + str_noise + str_ve, $
        in_file + '_OPEN-POS_R' + Strtrim(Round(in_svf_r_max), 2) + '_D' + Strtrim(in_svf_n_dir, 2) + str_noise + str_ve]
      if in_svf NE 0 then output_files_array += hash('Sky-View Factor', out_file_svf[0])
      if in_asvf NE 0 then output_files_array += hash('Anisotropic Sky-View Factor', out_file_svf[1])
      if in_open NE 0 then output_files_array += hash('Openness - Positive', out_file_svf[2])
      Topo_advanced_vis_svf, out_file_svf, in_svf, in_open, in_asvf, in_geotiff, $
        heights, resolution, $                    ;elevation
        in_svf_n_dir, in_svf_r_max, $                       ;search dfinition
        in_svf_noise, sc_svf_r_min, $                       ;noise
        sc_tile_size, sc_svf_ev, sc_opns_ev, $              ;tile size
        in_asvf_dir, in_asvf_level, sc_asvf_min, sc_asvf_pol, $    ;anisotropy
        overwrite=overwrite
      ; ... display progress
      progress_bar -> Update, progress_curr
      progress_curr += progress_step*(in_svf+in_open+in_asvf)
    ENDIF

    ;Negative openess
    IF in_open_negative EQ 1 THEN BEGIN
      CASE in_svf_noise OF
        0: str_noise = ''
        1: str_noise = '_NRlow'
        2: str_noise = '_NRmedium'
        3: str_noise = '_NRstrong'
      ENDCASE
      CASE in_asvf_level OF
        1: str_aniso = '_AIlow'
        2: str_aniso = '_AIstrong'
      ENDCASE
      heights = heights * (-1.)
      out_file_no = ['', '', in_file + '_OPEN-NEG_R' + Strtrim(Round(in_svf_r_max), 2) + '_D' + Strtrim(in_svf_n_dir, 2) + str_noise + str_ve]
      output_files_array += hash('Openness - Negative', out_file_no[2])
      Topo_advanced_vis_svf, out_file_no, 0, 1, 0, in_geotiff, $
        heights, resolution, $                    ;elevation
        in_svf_n_dir, in_svf_r_max, $                       ;search dfinition
        in_svf_noise, sc_svf_r_min, $                       ;noise
        sc_tile_size, sc_svf_ev, sc_opns_ev, $              ;tile size
        in_asvf_dir, in_asvf_level, sc_asvf_min, sc_asvf_pol, $    ;anisotropy
        overwrite=overwrite
      ; ... display progress
      progress_bar -> Update, progress_curr
      progress_curr += progress_step*(in_svf+in_open+in_asvf)
    ENDIF

    ;Sky illumination
    IF in_skyilm EQ 1 THEN BEGIN
      out_file_skyilm = in_file + '_SIM_' +in_skyilm_model + '_' + in_skyilm_points+'sp'
      ;set minimum shadow distance
      if ulong(in_skyilm_shadow_dist) lt 5 then in_skyilm_shadow_dist = '5'
      ;round to whole numbers
      in_skyilm_shadow_dist = strtrim(ulong(in_skyilm_shadow_dist),2)
      if in_skyilm_shadow_dist eq 'unlimited' then out_file_skyilm += '_'+in_skyilm_shadow_dist+'_px' $
      else out_file_skyilm += '_'+in_skyilm_shadow_dist+'px'

      output_files_array += hash('Sky illumination', out_file_skyilm)
      if in_skyilm_shadow then begin
        Topo_advanced_vis_skyillumination, out_file_skyilm, in_geotiff,$
          heights, resolution, $
          in_skyilm_model, in_skyilm_points, in_skyilm_shadow_dist,$
          sc_skyilu_ev, $
          in_skyilm_az, in_skyilm_el, $
          overwrite=overwrite
      endif else begin
        Topo_advanced_vis_skyillumination, out_file_skyilm, in_geotiff,$
          heights, resolution, $
          in_skyilm_model, in_skyilm_points, in_skyilm_shadow_dist,$
          sc_skyilu_ev, $
          overwrite=overwrite
      endelse
      progress_bar -> Update, progress_curr
      progress_curr += progress_step*(in_skyilm)
    ENDIF

    ;Local dominance
    IF in_locald EQ 1 THEN BEGIN
      out_file_ld = in_file + '_LD_R_M'+strtrim(in_locald_min_rad,2)+'-'+strtrim(in_locald_max_rad,2)+'_DI1_A15_OH1.7' + str_ve
      output_files_array += hash('Local dominance', out_file_ld)
      topo_advanced_vis_local_dominance, out_file_ld, in_geotiff, $
        heights, sc_ld_ev, $
        min_rad=in_locald_min_rad, max_rad=in_locald_max_rad, $  ;input visualization parameters
        overwrite=overwrite
      ; ... display progress
      progress_bar -> Update, progress_curr
      progress_curr += progress_step
    ENDIF

    ; Save output files hashmap
    ;wdgt_state.output_files_array = output_files_array
    (*p_wdgt_state).output_files_array = hash(in_file, output_files_array)
    ;(*p_wdgt_state).output_files_array = hash(in_fname, output_files_array)
    print, 'File name, key put in hash: ', in_file

    ; End processing
    endtime = Systime(/seconds)
    Print
    Print, '# Computation finished at ', Systime()
    Print, format='("# Computation time ", I3.2, ":", I2.2, ":", F0.1)', (endtime-starttime)/3600,$
      ((endtime-starttime)/60) MOD 60, (endtime-starttime) MOD 60
    Print
    Print, '# Processing logfile: ', out_file
    Print, '------------------------------------------------------------------------------------------------------'


    ;========================================================================================================
    ;Write processing metadata into TXT metafile
    ;========================================================================================================
    ;Start writing processing metadata into the file
    Openw, unit, out_file, /append
    ;Outputs
    Printf, unit
    Printf, unit, '# Selected visualization parameter'
    Printf, unit, '     Vertical exaggeration factor:  ', in_ve_ex
    Printf, unit
    Printf, unit, '# The following visualizations have been performed:  '
    ;Hillshade
    IF in_hls THEN BEGIN
      Printf, unit
      Printf, unit, '     Analytical hillshading --------------------------------------------------------'
      Printf, unit, '          Sun azimuth [deg.]: ', in_hls_sun_a
      Printf, unit, '          Sun elevation angle [deg.]: ', in_hls_sun_h
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_hls + '.tif'
      Printf, unit, '          >> Output file 2 (linear histogram stretch between 0 and 1 for 8-bit output): '
      Printf, unit, '              ' + out_file_hls + '_8bit.tif'
      if shadow_use then begin
        Printf, unit, '          >> Output file 3 (binary shadow image): '
        Printf, unit, '              ' + out_file_shadow_only + '.tif'
      endif
    ENDIF
    ;Multiple hillshading + PCA
    IF in_mhls THEN BEGIN
      Printf, unit
      Printf, unit, '     Hillshading from multiple directions ------------------------------------------'
      Printf, unit, '          Number of directions: ', in_mhls_n_dir
      Printf, unit, '          Sun elevation angle [deg.]: ', in_mhls_sun_h
      Printf, unit, '          >> Output file 1 (each band corresponds to shading from one direction; linear histogram strech between 0 and 1): '
      Printf, unit, '              ' + out_file_mhls + '.tif'
      Printf, unit, '          >> Output file 2 (RGB; Red-315°, Green-15°, Blue-75°; linear histogram strech between 0 and 1): '
      Printf, unit, '              ' + out_file_mhls + '_RGB.tif'
    ENDIF
    IF in_mhls_pca THEN BEGIN
      Printf, unit
      Printf, unit, '     PCA of hillshading ------------------------------------------------------------'
      Printf, unit, '          Number of components to save: ', in_mhls_n_psc
      Printf, unit, '          Note: Components are taken from the Hillshading from multiple directions method'
      Printf, unit, '          and are prepared with the following parameters:'
      Printf, unit, '               Number of directions: ', in_mhls_n_dir
      Printf, unit, '               Sun elevation angle [deg.]: ', in_mhls_sun_h
      Printf, unit, '          >> Output file 1 (each band corresponds to one PC): '
      Printf, unit, '              ' + out_file_mhls_pca + '.tif'
      Printf, unit, '          >> Output file 2 (RGB; Red-PC1, Green-PC2, Blue-PC3; histogram equal. with 2% cut-off for 8-bit output): '
      Printf, unit, '              ' + out_file_mhls_pca + '_RGB.tif'
    ENDIF
    ;Slope gradient
    IF in_slp THEN BEGIN
      Printf, unit
      Printf, unit, '     Slope gradient ----------------------------------------------------------------'
      Printf, unit, '          Note: No parameters required.'
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_slp + '.tif'
      Printf, unit, '          >> Output file 2 (linear histogram stretch between 0 and 51° for 8-bit output): '
      Printf, unit, '              ' + out_file_slp + '_8bit.tif'
    ENDIF
    ;Simple local relief model
    IF in_slrm THEN BEGIN
      Printf, unit
      Printf, unit, '     Simple local relief model -----------------------------------------------------'
      Printf, unit, '          Radius for trend assessment [pixels]: ', in_slrm_r_max
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_slrm + '.tif'
      Printf, unit, '          >> Output file 2 (histogram equal. with 2% cut-off for 8-bit output): '
      Printf, unit, '              ' + out_file_slrm + '_8bit.tif'
    ENDIF
    ;SVF + Openness + Negative openness
    IF in_svf THEN BEGIN
      Printf, unit
      Printf, unit, '     Sky-View Factor ---------------------------------------------------------------'
      Printf, unit, '          Number of search directions: ', in_svf_n_dir
      Printf, unit, '          Search radius [pixels]: ', in_svf_r_max
      CASE in_svf_noise OF
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        ELSE: str_in_svf_noise = 'no removal'
      ENDCASE
      Printf, unit, '          Level of noise removal:       ', str_in_svf_noise
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_svf[0] + '.tif'
      Printf, unit, '          >> Output file 2 (linear histogram stretch between 0.64 and 1.00 for 8-bit output): '
      Printf, unit, '              ' + out_file_svf[0] + '_8bit.tif'
    ENDIF
    IF in_asvf THEN BEGIN
      Printf, unit
      Printf, unit, '     Anisotropic Sky-View Factor ---------------------------------------------------'
      CASE in_asvf_level OF
        1: str_in_asvf_level = 'low'
        2: str_in_asvf_level = 'high'
        ELSE: str_in_asvf_level = 'no removal'
      ENDCASE
      Printf, unit, '          Level of anisotropy:       ', str_in_asvf_level
      Printf, unit, '          Main direction of anisotropy [degrees]:       ', in_asvf_dir
      Printf, unit, '          Note: Other parameters are taken from the Sky-View Factor method:'
      Printf, unit, '               Number of search directions: ', in_svf_n_dir
      Printf, unit, '               Search radius [pixels]: ', in_svf_r_max
      CASE in_svf_noise OF
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        ELSE: str_in_svf_noise = 'no removal'
      ENDCASE
      Printf, unit, '               Level of noise removal:       ', str_in_svf_noise
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_svf[1] + '.tif'
      Printf, unit, '          >> Output file 2 (histogram equal. with 2% cut-off for 8-bit output): '
      Printf, unit, '              ' + out_file_svf[1] + '_8bit.tif'
    ENDIF
    IF in_open THEN BEGIN
      Printf, unit
      Printf, unit, '     Openness - Positive -----------------------------------------------------------'
      Printf, unit, '          Note: Parameters are taken from the Sky-View Factor method:'
      Printf, unit, '               Number of search directions: ', in_svf_n_dir
      Printf, unit, '               Search radius [pixels]: ', in_svf_r_max
      CASE in_svf_noise OF
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        ELSE: str_in_svf_noise = 'no removal'
      ENDCASE
      Printf, unit, '               Level of noise removal:       ', str_in_svf_noise
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_svf[2] + '.tif'
      Printf, unit, '          >> Output file 2 (linear histogram stretch between 60° and 95° for 8-bit output): '
      Printf, unit, '              ' + out_file_svf[2] + '_8bit.tif'
    ENDIF
    IF in_open_negative THEN BEGIN
      Printf, unit
      Printf, unit, '     Openness - Negative -----------------------------------------------------------'
      Printf, unit, '          Note: Parameters are taken from the Sky-View Factor method:'
      Printf, unit, '               Number of search directions: ', in_svf_n_dir
      Printf, unit, '               Search radius [pixels]: ', in_svf_r_max
      CASE in_svf_noise OF
        1: str_in_svf_noise = 'low'
        2: str_in_svf_noise = 'medium'
        3: str_in_svf_noise = 'high'
        ELSE: str_in_svf_noise = 'no removal'
      ENDCASE
      Printf, unit, '               Level of noise removal:       ', str_in_svf_noise
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_no[2] + '.tif'
      Printf, unit, '          >> Output file 2 (linear histogram stretch between 60° and 95° for 8-bit output): '
      Printf, unit, '              ' + out_file_no[2] + '_8bit.tif'
    ENDIF
    if in_skyilm then begin
      Printf, unit, '     > Sky illumination'
      Printf, unit, '          Sky model: ', in_skyilm_model
      Printf, unit, '          Number of sampling points: ', in_skyilm_points
      Printf, unit, '          Maximum search radius for calculation of shadows: ', in_skyilm_shadow_dist
      ;      if in_skyilm_shadow then begin
      ;        Printf, unit, '          Note: Shadow modelling enabled.'
      ;        Printf, unit, '               Sun azimuth [deg.]: ', in_skyilm_az
      ;        Printf, unit, '               Sun elevation angle [deg.]: ', in_skyilm_el
      ;      endif $
      ;      else Printf, unit, '          Note: Shadow modelling disabled.'
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_skyilm + '.tif'
      Printf, unit, '          >> Output file 2 (linear histogram stretch with lower '+string(sc_skyilu_ev[0],format="(f3.1)")+'% and upper '+string(sc_skyilu_ev[1],format="(f3.1)")+'% values cut-off for 8-bit output):'
      Printf, unit, '              ' + out_file_skyilm + '_8bit.tif'
    endif
    if in_locald then begin
      Printf, unit, '     > Local dominance'
      Printf, unit, '          Minimum radius: ', in_locald_min_rad
      Printf, unit, '          Maximum radius: ', in_locald_max_rad
      Printf, unit, '          >> Output file 1 (without results manipulation): '
      Printf, unit, '              ' + out_file_ld + '.tif'
      Printf, unit, '          >> Output file 2 (linear histogram stretch between '+string(sc_ld_ev[0], format="(f3.1)")+' and '+string(sc_ld_ev[1], format="(f3.1)")+' for 8-bit output):'
      Printf, unit, '              ' + out_file_ld + '_8bit.tif'
    endif

    ; Computation time
    Printf, unit
    Printf, unit, format='("# Computation time ", I3.2, ":", I2.2, ":", F0.1)', (endtime-starttime)/3600,$
      ((endtime-starttime)/60) MOD 60, (endtime-starttime) MOD 60
    ;Close metadata file
    Free_lun, unit
  endfor
  
  ; End display progress
  progress_bar -> Destroy
  
  PRINT, 'Memory used: ', MEMORY(/CURRENT)
  
end