pro topo_advanced_vis__RUN_IDL

  ;############################################################################
  ;INPUT PARAMETERS to be read from GUI (this are also default values)
  
  ;Input file
  in_file = 'D:\_arhiv\ZRC\2007\Sky\Kobarid\dmr4.tif'
  
  ;Vertical exagerattion
  in_ve_ex = 1.
  ve_degrees = 0.
  
  ;Hillshading
  in_hls = 1            ;1-run, 0-don't run
  in_hls_sun_a = 315.   ;solar azimuth angle in degrees
  in_hls_sun_h = 35.    ;solar vertical elevation angle in degres
  
  ;Multiple hillshading
  in_mhls = 0           ;1-run, 0-don't run
  in_mhls_n_dir = 16.   ;number of directions
  in_mhls_sun_h = 35.   ;solar vertical elevation angle in degres
  in_mhls_rgb = 1       ;1-make multiple hillshaing RGB, 0-don't
  in_mhls_pca = 0       ;1-run PCA hillshading, 0-don't run
  in_mhls_n_psc = 3     ;number of principal componnents to save
  
  ;Slope gradient
  in_slp = 1            ;1-run, 0-don't run
  
  ;Simple local relief model
  in_slrm = 0           ;1-run, 0-don't run
  in_slrm_r_max = 20.   ;radius in pixels
  
  ;SVF
  in_svf = 1            ;1-run, 0-don't run
  in_svf_n_dir = 16     ;number of directions
  in_svf_r_max = 10.    ;maximal search radius
  in_svf_noise = 0      ;level of noise to remove (0- no removal, 1-low, 2-medium, 3-high)
  in_asvf = 1.          ;1-run anisotropic SVF, 0-don't run
  in_asvf_dir = 315.    ;value between 0 and 360-run anisotropic SVF with strongest brightness in this azimuth, -1-don't run
  in_asvf_level = 1     ;1-low level (2, 0.5), 2-high level (5, 0.2)
  in_open = 1           ;1-run openess, 0-don't run
  in_open_negative = 0  ;1-compute negative openess, 0-positive
  
  ;############################################################################
  ;Setup constnants that cannot be changed by the user
  
  ;Vertical exagerattion
  sc_ve_ex = [-10., 10.]
  
  ;Hillshading
  sc_hls_sun_a = [0., 360.]            ;solar azimuth angle in degrees
  sc_hls_sun_h = [0, 90.]              ;solar vertical elevation angle in degres
  
  ;Multiple hillshading
  sc_mhls_n_dir = [4,16,8,32,64,360]   ;number of directions; drop-down menu values: 16,8,32,64; editable!
  sc_mhls_n_dir = [0., 75.]            ;solar vertical elevation angle in degres
  sc_mhls_a_rgb = [315., 15., 75.]     ;azimuth for RGB components
  sc_mhls_n_psc = [3, 5]               ;number of principal componnents to save
  
  ;Simple local relief model
  sc_slrm_r_max = [5., 50.]           ;radius in pixels
  
  ;SVF
  sc_svf_n_dir = [4, 16, 8, 32, 360]   ;number of directions; drop-down menu values: 16,8,32; editable!
  sc_svf_r_max = [5., 100.]            ;maximal search radius
  sc_svf_r_min = [0., 10., 20., 40.]   ;minimal search radius as percent of max search radius
  sc_asvf_min = [0.4, 0.1]             ;minimal brightness of the sky for both models
  in_asvf_dir = [0., 360.]             ;main direction of anisotropy in degrees
  sc_asvf_pol = [4, 8]                 ;polynomial level (how fast decreases brightness from the brightes to the darkest point )
  
  ;Conversion to byte - linear, with below defined borders
  sc_hls_ev = [0.00, 1.00]
  sc_svf_ev = [0.6375, 1.00]
  sc_opns_ev = [-12.5, 30.]
  sc_slp_ev = [0., 51.]
  sc_slrm_ev = [-2., 2.]
  
  ;If input DEM is larger as the size below, do tiling
  sc_tile_size = 5L*10L^6
  
  ;Read input data
  heights = read_tiff(in_file, geotiff=in_geotiff)
  resolution = (in_geotiff.ModelPixelScaleTag)[0]
  
  ;############################################################################
  ; Main part of the program
  ;Correct vertical scale if data are not projected (unprojected lon, lat data)
  heights = Float(heights) * in_ve_ex
  IF (ve_degrees) THEN  resolution = 111300. * resolution
  
  ;Correct filename
  len_in_file = Strlen(in_file)
  in_file = Strmid(in_file, 0, len_in_file-4)     ;preffix to add proccessing parameters
  str_ve = '_Ve' + String(in_ve_ex, Format='(F4.1)')  ;vertical exageration
  IF in_ve_ex EQ 1. then str_ve = ''
  
  ;Hillshading
  IF in_hls EQ 1 THEN BEGIN
    out_file_hls = in_file + '_HS_A' + Strtrim(Long(in_hls_sun_a), 2) + '_H' + Strtrim(Long(in_hls_sun_h), 2) + str_ve
    Topo_advanced_vis_hillshade, out_file_hls, in_geotiff, $
      heights, resolution, $                ;relief
      in_hls_sun_a, in_hls_sun_h, $                   ;solar position
      sc_hls_ev
  ENDIF
  
  ;Multiple hillshading
  IF in_mhls EQ 1 THEN BEGIN
    out_file_mhls = in_file + '_MULTI-HS_D' + Strtrim(Long(in_mhls_n_dir), 2) + '_H' + Strtrim(Long(in_mhls_sun_h), 2) + str_ve
    Topo_advanced_vis_multihillshade, out_file_mhls, in_geotiff, $
      heights, resolution, $                ;relief
      in_mhls_n_dir, in_mhls_sun_h, $                 ;solar position
      sc_mhls_a_rgb, sc_hls_ev                        ;directions for RGB outputRGB
  ENDIF
  
  ;PCA hillshading
  IF in_mhls_pca EQ 1 THEN BEGIN
    out_file_mhls_pca = in_file + '_PCA_D' + Strtrim(Long(in_mhls_n_dir), 2) + '_H' + Strtrim(Long(in_mhls_sun_h), 2) + str_ve
    Topo_advanced_vis_PCAhillshade, out_file_mhls_pca, in_geotiff, $
        heights, resolution, $     ;relief
        in_mhls_n_dir, in_mhls_sun_h, $  ;solar position
        in_mhls_n_psc, sc_hls_ev         ;number of PCs to save
  ENDIF
  
  ;Slope
  IF in_slp EQ 1 THEN BEGIN
    out_file_slp = in_file + '_SLOPE' + str_ve
    topo_advanced_vis_gradient, out_file_slp, in_geotiff, $
      heights, resolution, $                    ;relief
      sc_slp_ev
  ENDIF
  
  ;Local releif
  IF in_slrm EQ 1 THEN BEGIN
    out_file_slrm = in_file + '_SLRM_R' + Strtrim(Long(in_slrm_r_max), 2) + str_ve
    topo_advanced_vis_localrelief, out_file_slrm, in_geotiff, $
      heights, resolution, $                    ;relief
      in_slrm_r_max, sc_slrm_ev
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
    Topo_advanced_vis_svf, out_file_svf, in_svf, in_open, in_asvf, in_geotiff, $
      heights, resolution, $                    ;elevation
      in_svf_n_dir, in_svf_r_max, $                       ;search dfinition
      in_svf_noise, sc_svf_r_min, $                       ;noise
      sc_tile_size, sc_svf_ev, sc_opns_ev, $              ;tile size
      in_asvf_dir, in_asvf_level, sc_asvf_min, sc_asvf_pol    ;anisotropy
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
    Topo_advanced_vis_svf, out_file_no, 0, 1, 0, in_geotiff, $
        heights, resolution, $                    ;elevation
        in_svf_n_dir, in_svf_r_max, $                       ;search dfinition
        in_svf_noise, sc_svf_r_min, $                       ;noise
        sc_tile_size, sc_svf_ev, sc_opns_ev, $              ;tile size
        in_asvf_dir, in_asvf_level, sc_asvf_min, sc_asvf_pol    ;anisotropy
  ENDIF
    

end

