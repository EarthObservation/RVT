;+
; NAME:
;
;       Topo_advanced_vis_shade
;
; PURPOSE:
;
;       Compute hillshades
;
; INPUTS:
;
;       This procedure needs
;        in_file - path+filename of input DEM to save the outputs
;        in_hls_sun_a - solar azumuth angle (clockwise from North)in degrees
;        in_hls_sun_h - solar vertical angle (above the horizon) in gegrees
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

PRO Topo_advanced_vis_PCAhillshade, in_file, geotiff, $
    dem, resolution, $     ;relief
    in_mhls_n_dir, in_hls_sun_h0, $  ;solar position
    in_mhls_n_psc, sc_hls_ev,$         ;number of PCs to save
    overwrite=overwrite
  
  ;Slope & Aspect
  Topo_advanced_vis_slope, dem, resolution, DEM_SLOPE=slope_dem, DEM_ASPECT=aspect_dem 
  
  ;Convert to solar zenith angle
  in_hls_sun_h = in_hls_sun_h0 / !radeg
  in_hls_sun_z = !pi*0.5 - in_hls_sun_h
  
  ;Initialize results
  size_dem = Size(dem)
  ncol = size_dem[1]
  nlin = size_dem[2]
  
  idx_valid = where(slope_dem ge 0., n_idx_valid)  ;can not be a negative number (this can happen if there are NaN values in DEM data)
  
  cosi_all = Make_array(size_dem[-1] < n_idx_valid, in_mhls_n_dir)   
   
  ;Do for every direction
  FOR i=0,in_mhls_n_dir-1 DO BEGIN
  
    ;Convert solar position to radians
    in_hls_sun_a = Float(2D*!pi / in_mhls_n_dir * i)
    
    ;Compute solar incidence angle
    cosi = cos(in_hls_sun_z) * cos(slope_dem) + sin(in_hls_sun_z) * sin(slope_dem) * cos(aspect_dem-in_hls_sun_a) 
    
    ;Add to average
    cosi_all[*,i] = (cosi - Mean(cosi, /nan))[idx_valid]

  ENDFOR
  slope_dem = !null & aspect_dem = !null & cosi = !null
  
  ;Covariance
  cosi_all = Transpose(cosi_all)
  covMatrix = Correlate(cosi_all, /COVARIANCE);, /DOUBLE)
  
  ;Eigenvectors
  eigenvalues = Eigenql(covMatrix, EIGENVECTORS=eigenvectors, /DOUBLE)
  Print, 'Eigenvalues in promile:'
  Print, round(eigenvalues / total(eigenvalues) * 1000.)
  
  ;Transform back
  finalData_temp = Transpose(eigenvectors[*,0:in_mhls_n_psc-1] ## Transpose(cosi_all))
  cosi_all = !null
  finalData = make_array(in_mhls_n_psc, ncol, nlin, /float, value=!Values.F_NaN)
  for i_out=0ul, in_mhls_n_psc-1 do begin
    finalBand = make_array(ncol, nlin, /float, value=!Values.F_NaN)
    finalBand[idx_valid] = finalData_temp[i_out,*]
    finalData[i_out,*,*] = finalBand
  endfor 
  finalData_temp = !null & finalBand = !null
  
  ;Write results
  out_file = in_file + '.tif'
  if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
    print, ' Image already exists ('+out_file+')' $
  else $
    Write_tiff, out_file, finalData, compression=1, geotiff=geotiff, /float
  
  ;For 8-bit do an RGB
  finalRGB = bytarr(3, ncol, nlin)
  FOR i=0,2 DO BEGIN
    finalRGB[i,*,*] = Hist_equal(Reform(finalData[i,*,*]),percent=2)
  ENDFOR
  out_file = in_file + '_RGB.tif'
  if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
    print, ' Image already exists ('+out_file+')' $
  else $
    Write_tiff, out_file, finalRGB, compression=1, geotiff=geotiff
  finalRGB = !null & finalData = !null
  
END
