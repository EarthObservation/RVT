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
    in_slrm_r_max, sc_slrm_ev
  
  ;Difference from trend
  diff = Float(dem - Gauss_smooth(Double(dem), /EDGE_TRUNCATE, WIDTH=in_slrm_r_max*2.))
  ; spremeni filter iz gauss v mean filter
  
  ;Write results
  out_file = in_file + '.tif'
  Write_tiff, out_file, diff, compression=1, geotiff=geotiff, /float
  diff = HIST_EQUAL(diff, percent=2)
  out_file = in_file + '_8bit.tif'
  Write_tiff, out_file, diff, compression=1, geotiff=geotiff
  diff = !null
  
END
