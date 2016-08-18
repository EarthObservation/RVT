;+
; NAME:
;
;       Topo_advanced_vis_skyillumination
;
; PURPOSE:
;
;       Compute Sky illumination
;
; INPUTS:
;
;
; KEYWORDS:
;
;
; OUTPUTS:
;
;       Written 8-bit GEOTIFF files for SVF, anisotropic SVF or openess.
;
; AUTHOR:
;
;       Klemen Cotar
;
; DEPENDENCIES:
;
;       topo_advanced_vis_hillshade
;       topo_morph_shade
;       programrootdir
;
; MODIFICATION HISTORY:
;
;       1.0  October 2014: Initial version written by Klemen Cotar.
;-

PRO Topo_advanced_vis_skyillumination, in_file, geotiff, $
                                    dem, resolution,$                    ;relief  
                                    sky_model, sampling_points, shadow_dist, $                                    
                                    sc_skyilu_ev, $
                                    shadow_az, shadow_el, shadow_only=shadow_only, $
                                    overwrite=overwrite
;!EXCEPT=0

novalues = where(dem lt 0)
dem[novalues] = !Values.F_NaN
;determine the max search distance in pixels
h_min = min(dem, max=h_max, /nan)
dh = h_max - h_min
;print, h_max, h_min
dem_size = size(dem, /dimensions)
dem[novalues] = 0

if n_elements(shadow_az) eq 1 and n_elements(shadow_el) eq 1 then begin
  sh_z = !pi/2 - shadow_el/!radeg
  sh_az = shadow_az/!radeg
  d_max = 1.
  d_max = round(d_max * dh * tan(sh_z) / resolution)
  dem_tmp = dem
  out_shadow_img = topo_morph_shade(dem_tmp, sh_z, sh_az, d_max, dem_size[0], dem_size[1], resolution)
;  out_shadow_img = morph_open(out_shadow_img, [[1,1,1],[1,1,1],[1,1,1]])
endif

if keyword_set(shadow_only) then begin
  dem[novalues] = !Values.F_NaN
  if n_elements(out_shadow_img) gt 0 then begin
    if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
      print, ' Image already exists ('+out_file+')' $
    else $
      write_tiff, in_file+'.tif', out_shadow_img, bits_per_sample=1, geotiff=geotiff, compression=1
  endif
endif else begin
  scale_lower = sc_skyilu_ev[0]   ;percent
  scale_upper = sc_skyilu_ev[1]   ;percent
  root = programrootdir()
  
  openr, hill_set, root+'settings\'+sky_model+'_'+sampling_points+'sp.txt',/get_lun
  
  out_skyillumination_img = make_array(dem_size[0], dem_size[1], /float, value = 0)
    
  while not(eof(hill_set)) do begin
    d_max = 1.       ;coefficient between 0 and 1 that limits the max possible search distance
    line = ''
    readf, hill_set, line
    line = strsplit(line, ',', /extract)
  
    azim = float(line[0])
    elev = float(line[1])
    weight = float(line[2])
    topo_advanced_vis_hillshade, '', geotiff, dem, resolution, azim, elev, /suppress_output, cosi=cosi
    
    sh_z = !pi/2 - elev/!radeg
    sh_az = azim/!radeg
    d_max = round(d_max * dh * tan(sh_z) / resolution)
      
  ;  print, elev, azim
  ;  print, sh_z, sh_az, d_max
  ;  d_max = 0    ;force shadow calculation skipping
  ;  print, azim, elev, d_max
  
    if d_max gt 1 then begin  ;!!! NOTE when d_max is eq 1, topo_morph_shade sometimes can not calculate shadows and returns an error !!!
      if shadow_dist ne 'unlimited' then d_max = d_max < uint(shadow_dist)    
      dem_tmp = dem
      out_shadow_img = topo_morph_shade(dem_tmp, sh_z, sh_az, d_max, dem_size[0], dem_size[1], resolution)
      out_skyillumination_img += cosi * out_shadow_img * weight
    endif else begin
      out_skyillumination_img += cosi * weight
    endelse
    
  endwhile
  free_lun, hill_set
  cosi = !Null
  
  if n_elements(shadow_az) eq 1 and n_elements(shadow_el) eq 1 then begin 
    out_skyillumination_img = 0.8 * out_skyillumination_img + 0.2 * out_shadow_img
  endif
  
  ;Write result
  dem[novalues] = !Values.F_NaN
  out_file = in_file + '.tif'
  if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
    print, ' Image already exists ('+out_file+')' $
  else $
    Write_tiff, out_file, out_skyillumination_img, compression=1, geotiff=geotiff, /float
  
  ;determine lower and upper cut-off value for scaling when conerting to 8-bit image
  total_points = dem_size[0] * dem_size[1]
  bin = 0.01
  img_hist = histogram(out_skyillumination_img, binsize=bin)
  n_hist = n_elements(img_hist)
  
  ;lower value
  pixels = 0L
  n_hist_pixels = 0L
  while pixels lt total_points*scale_lower/100. do begin
    pixels += img_hist[n_hist_pixels]
    n_hist_pixels += 1
  endwhile
  min_scale_val = min(out_skyillumination_img) + n_hist_pixels*bin
  
  ;upper value
  pixels = 0L
  n_hist_pixels = n_hist-1
  while pixels lt total_points*scale_upper/100. do begin
    pixels += img_hist[n_hist_pixels]
    n_hist_pixels -= 1
  endwhile
  max_scale_val = min(out_skyillumination_img) + n_hist_pixels*bin
  
  ;print, min_scale_val, max_scale_val
  
  ;write 8-bit image
  out_skyillumination_img_8bit = Bytscl(out_skyillumination_img, max=max_scale_val, min=min_scale_val)
  out_file = in_file + '_8bit.tif'
  if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
    print, ' Image already exists ('+out_file+')' $
  else $
    Write_tiff, out_file, out_skyillumination_img_8bit, compression=1, geotiff=geotiff
  cosi = !null
endelse
END