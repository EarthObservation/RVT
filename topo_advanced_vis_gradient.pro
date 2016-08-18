;+
; NAME:
;
;       Topo_advanced_vis_shade
;
; PURPOSE:
;
;       Compute terain gradient - slope in degrees
;
; INPUTS:
;
;       This procedure needs
;        in_file - path+filename of input DEM to save the outputs
;        geotiff - geotiff structure of the input/output
;        dem - elvation data
;        resolution - spatial resolution of DEM
;        in_ve_ex - vertical exageration
;        sc_slp_ex - extreme values for 8-bit conversion
;
;
; OUTPUTS:
;
;       Written 8-bit GEOTIFF files for SVF, anisotropic SVF or openess
;
; AUTHOR:
;
;       Klemen Zaksek
;
; DEPENDENCIES:
;
;       topo_advanced_vis_slope
;
; MODIFICATION HISTORY:
;
;       Written by Klemen Zaksek, 2013.
;
;-

PRO topo_advanced_vis_gradient, in_file, geotiff, $
    dem, resolution, $                    ;relief
    sc_slp_ev, $
    overwrite=overwrite
  
  ;Slope & Aspect
  topo_advanced_vis_slope, dem, resolution, DEM_SLOPE=slope_dem, DEM_ASPECT=aspect_dem, /degree
  
  ;Write results
  out_file = in_file + '.tif'
  if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 $
    print, ' Image already exists ('+out_file+')'
  else $
    Write_tiff, out_file, slope_dem, compression=1, geotiff=geotiff, /float
;  Write_tiff, in_file + '_aspect.tif', aspect_dem, compression=1, geotiff=geotiff, /float
  slope_dem = 255 - Bytscl(slope_dem, max=sc_slp_ev[1], min=sc_slp_ev[0])
  out_file = in_file + '_8bit.tif'
  if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 $
    print, ' Image already exists ('+out_file+')'
  else $
    Write_tiff, out_file, slope_dem, compression=1, geotiff=geotiff
  slope_dem = !null & aspect_dem = !null
  
END
