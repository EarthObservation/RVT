;+
; NAME:
;
;       Topo_advanced_vis_hillshade
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
; KEYWORDS:
;       
;       suppres_output - if set output GeoTIFF result file is not written
;       cosi - result of hillshade computation
;
; OUTPUTS:
;
;       Written 8-bit GEOTIFF files for SVF, anisotropic SVF or openess.
;       If suppress_output is set, result of the computation is given as cosi 
;       keyword, otherwise cosi is set to !Null.
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
;       1.0  Written by Klemen Zaksek, 2013.
;       1.1  September 2014: Suppress_output and cosi keywords added to the procedure
;-

function calculate_hillshade, geotiff, $
                    dem, resolution, $                    ;relief
                    in_hls_sun_a0, in_hls_sun_h0, $                 ;solar position
                    sc_hls_ev, $
                    suppress_output = suppress_output, $ ;
                    cosi = cosi  ;result of hillsh

  ;Slope & Aspect
  topo_advanced_vis_slope, dem, resolution, DEM_SLOPE=slope_dem, DEM_ASPECT=aspect_dem

  ;Convert solar position to radians
  in_hls_sun_a = in_hls_sun_a0 / !radeg
  in_hls_sun_h = in_hls_sun_h0 / !radeg

  ;Convert to solar zenith angle
  in_hls_sun_z = !pi*0.5 - in_hls_sun_h

  ;Compute solar incidence angle
  cosi = cos(in_hls_sun_z) * cos(slope_dem) + sin(in_hls_sun_z) * sin(slope_dem) * cos(aspect_dem-in_hls_sun_a)
  slope_dem = !null & aspect_dem = !null

  return, cosi
end

PRO Topo_advanced_vis_hillshade, in_file, geotiff, $
    dem, resolution, $                    ;relief
    in_hls_sun_a0, in_hls_sun_h0, $       ;solar position
    sc_hls_ev, $
    suppress_output = suppress_output, $ ; 
    cosi = cosi, $  ;result of hillshade computation, is equal to !Null if suppress_output is not set    
    overwrite=overwrite
  
      
  ; Hillshade ---------------------------------------------------------------------------------
  cosi = calculate_hillshade(geotiff, $
                              dem, resolution, $                    ;relief
                              in_hls_sun_a0, in_hls_sun_h0, $       ;solar position
                              sc_hls_ev, $
                              suppress_output = suppress_output, $ ;
                              cosi = cosi)  ;result of hillsh                       ;result of hillsh
  
  ;Write results
  if keyword_set(suppress_output) eq 0 then begin
    
    out_file = in_file + '.tif'  
    write_image_to_geotiff_float, overwrite, out_file, cosi
      
      
    ; Hillshade, 8 bit -------------------------------------------------------------------------
    cosi = Bytscl(cosi, max=sc_hls_ev[1], min=sc_hls_ev[0])
    
    out_file = in_file + '_8bit.tif'
    write_image_to_geotiff, overwrite, out_file, cosi
      
    ; Free up space ----------------------------------------------------------------------------
    cosi = !null
  endif  
  
END
