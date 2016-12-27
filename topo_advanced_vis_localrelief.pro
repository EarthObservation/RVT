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

PRO topo_advanced_vis_localrelief, in_file, geotiff, $
    dem, resolution, $                    ;relief
    in_slrm_r_max, sc_slrm_ev, $
    overwrite=overwrite
  
  idx_background = where(dem lt -10000 or dem gt 20000, n_idx_background)
  if n_idx_background gt 0 then begin
    dem_temp = Double(dem)
    dem_temp[idx_background] = !Values.F_NaN
  endif else dem_temp = dem
  ;Difference from trend
  ; gaussian gilter
  ;diff = Float(dem_temp - Gauss_smooth(Double(dem_temp), /EDGE_TRUNCATE, WIDTH=in_slrm_r_max*2.))
  ; mean filter
  diff = Float(dem_temp - smooth(Double(dem_temp), in_slrm_r_max*2., /EDGE_TRUNCATE, /nan)) ;if width is even number +1 will be added to the width size
  ;Write results
  out_file = in_file + '.tif'
  
  write_image_to_geotiff_float, overwrite, out_file, diff
;  if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
;    print, ' Image already exists ('+out_file+')' $
;  else $
;    Write_tiff, out_file, diff, compression=1, geotiff=geotiff, /float
    
  diff = HIST_EQUAL(diff, percent=2, binsize=0.05)
  out_file = in_file + '_8bit.tif'
  
  write_image_to_geotiff, overwrite, out_file, diff
;  if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
;    print, ' Image already exists ('+out_file+')' $
;  else $
;    Write_tiff, out_file, diff, compression=1, geotiff=geotiff

  diff = !null
  
END
