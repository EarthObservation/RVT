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

function calculate_multihillshade, geotiff, $
                          dem, resolution, $                    ;relief
                          in_mhls_n_dir, in_hls_sun_z, $       ;solar position
                          sc_mhls_a_rgb, sc_hls_ev, $
                          slope_dem, aspect_dem

    ;Initialize results
    size_dem = size(dem)
    cosi_all = bytarr(in_mhls_n_dir, size_dem[1], size_dem[2])

    ;Do for every direction
    FOR i=0,in_mhls_n_dir-1 DO BEGIN

      ;Convert solar position to radians
      in_hls_sun_a = Float(2D*!pi / in_mhls_n_dir * i)

      ;Compute solar incidence angle
      cosi = cos(in_hls_sun_z) * cos(slope_dem) + sin(in_hls_sun_z) * sin(slope_dem) * cos(aspect_dem-in_hls_sun_a)

      ;Result
      cosi_all[i,*,*] = Bytscl(cosi, max=sc_hls_ev[1], min=sc_hls_ev[0])

    ENDFOR
    
  cosi = !null ;& aspect_dem = !null
  
  return, cosi_all
end

function calculate_RGB_from_multihillshade, cosi_all, dem, resolution, $        ;relief
                          in_mhls_n_dir, in_hls_sun_z, $                       ;solar position
                          sc_mhls_a_rgb, sc_hls_ev, $
                          slope_dem, aspect_dem

  ;Initialize results
  size_dem = size(dem)

  ;For 8-bit do an RGB
  cosi_all = bytarr(3, size_dem[1], size_dem[2])
  FOR i=0,2 DO BEGIN
    in_hls_sun_a = sc_mhls_a_rgb[i] / !radeg
    cosi = cos(in_hls_sun_z) * cos(slope_dem) + sin(in_hls_sun_z) * sin(slope_dem) * cos(aspect_dem-in_hls_sun_a)
    cosi_all[i,*,*] = Bytscl(cosi, max=sc_hls_ev[1], min=sc_hls_ev[0])
  ENDFOR

  return, cosi_all
end

PRO Topo_advanced_vis_multihillshade, in_file, geotiff, $
    dem, resolution, $                              ;relief
    in_mhls_n_dir, in_hls_sun_h0, $                 ;solar position
    sc_mhls_a_rgb, sc_hls_ev, $                     ;directions for RGB outputRGB
    overwrite=overwrite

  ;Slope & Aspect
  topo_advanced_vis_slope, dem, resolution, DEM_SLOPE=slope_dem, DEM_ASPECT=aspect_dem
  
  ;Convert to solar zenith angle
  in_hls_sun_h = in_hls_sun_h0 / !radeg
  in_hls_sun_z = !pi*0.5 - in_hls_sun_h
  
  ; Hillshading from multiple directions ---------------------------------------------------
  multihillshade_image = calculate_multihillshade(geotiff, $
                                                  dem, resolution, $                  ;relief
                                                  in_mhls_n_dir, in_hls_sun_z, $       ;solar position
                                                  sc_mhls_a_rgb, sc_hls_ev, $
                                                  slope_dem, aspect_dem)
  
  ;Write results
  out_file = in_file + '.tif'
  write_image_to_geotiff, overwrite, out_file, multihillshade_image, geotiff=geotiff

  ;cosi = !null & cosi_all = !null
   
  ; Hillshading from multiple directions - RGB ----------------------------------------------
  multihillshade_RGB = calculate_RGB_from_multihillshade(multihillshade_image, dem, resolution, $        ;relief
                                                         in_mhls_n_dir, in_hls_sun_z, $                 ;solar position
                                                         sc_mhls_a_rgb, sc_hls_ev, $
                                                         slope_dem, aspect_dem)

  ; Write
  out_file = in_file + '_RGB.tif'
  write_image_to_geotiff, overwrite, out_file, multihillshade_RGB, geotiff=geotiff
    
    
  ; Free up space ---------------------------------------------------------------------------
  multihillshade_image = !null & multihillshade_RGB = !null
  
END



