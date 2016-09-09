;+
; NAME:
;
;       Topo_advanced_vis_local_dominance
;
; PURPOSE:
;
;       Compute Local Dominance dem visualization. 
;       
;       Adapted from original version that is part of the Lidar Visualisation Toolbox LiVT developed by Ralf Hesse.
;
; INPUTS:
;
;       This procedure needs
;        in_file - path+filename of input DEM to save the outputs
;        geotiff - geotiff tags
;        dem - input DEM (original) as 2D array
;        sc_ld_ev - minimum and maximum thresholds used for the conversion from float to 8bit image
;        min_rad - minimum radial distance (in pixels) at which the algorithm starts with visualization computation
;        max_rad - maximum radial distance (in pixels) at which the algorithm ends with visualization computation
;        rad_inc - radial distance steps in pixels
;        angular_res - angular step for determination of number of angular directions
;        observer_height - height at which we observe the terrain
;        overwrite - determines if results are written to disk if file with the same name already exits
;
; OUTPUTS:
; 
;       Written float GEOTIFF file for local dominance
;
; AUTHOR:
;
;       Klemen Cotar
;
; DEPENDENCIES:
;
;       None
;
; MODIFICATION HISTORY:
;
;       1.0  September 2016: Initial version written by Klemen Cotar.
;
;-

PRO Topo_advanced_vis_local_dominance, in_file, geotiff, $
                                       dem, $     ;relief
                                       sc_ld_ev, $  ;linear scaling parameters
                                       min_rad=min_rad, max_rad=max_rad, rad_inc=rad_inc, angular_res=angular_res, observer_height=observer_height, $  ;input visualization parameters
                                       overwrite=overwrite


;set default values of parameters if they are not set by user
if n_elements(min_rad) eq 0 then min_rad = 2
if n_elements(max_rad) eq 0 then max_rad = 5
if n_elements(rad_inc) eq 0 then rad_inc = 1
if n_elements(angular_res) eq 0 then angular_res = 15
if n_elements(observer_height) eq 0 then observer_height = 1.7
if n_elements(sc_ld_ev) lt 2 then sc_ld_ev = [0.5, 1.8]

;create vector with possible distances
n_dist = ulong((max_rad-min_rad)/rad_inc + 1)
distances = uindgen(n_dist, increment = rad_inc)+min_rad

;create vector with possible angles
n_ang = ulong(359/angular_res + 1)
angles = uindgen(n_ang, increment = angular_res)

;determine total area within radius range
norma = total((1d * observer_height / distances) * (2 * distances + rad_inc)) * n_ang

;image shifts
n_shifts = n_elements(distances) * n_elements(angles)
x_t = reform(distances # cos(angles/!radeg), n_shifts)
y_t = reform(distances # sin(angles/!radeg), n_shifts)
;round the shifts to the whole pixel values
x_t_p = round(x_t)
y_t_p = round(y_t)
;distance vector and factor that will be used later
distances = reform(distances # replicate(1, n_ang), n_shifts)
dist_factr = (2*distances + rad_inc)

ld_img_out = dem*0
for i_s=0, n_shifts-1 do begin
  dem_moved = shift(dem, x_t_p[i_s], y_t_p[i_s])
  idx_lower = where(dem + observer_height gt dem_moved, n_idx_lower)
  if n_idx_lower gt 0 then begin
    ld_img_out[idx_lower] += (dem[idx_lower] + observer_height - dem_moved[idx_lower]) / distances[i_s] * dist_factr[i_s]
  endif
endfor
ld_img_out /= norma

;;mask out image borders
;ld_img_out[*,0:max_rad-1] = 0
;ld_img_out[0:max_rad-1,*] = 0
;ld_img_out[*,-1l*max_rad:-1] = 0
;ld_img_out[-1l*max_rad:-1,*] = 0

out_file = in_file+'.tif'
if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
  print, ' Image already exists ('+out_file+')' $
else $
  write_tiff, out_file, ld_img_out, compression=1, /float, geotiff=geotiff
  
ld_img_out_8bit = bytscl(ld_img_out, min=sc_ld_ev[0], max=sc_ld_ev[1])
out_file = in_file+'_8bit.tif'
if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
  print, ' Image already exists ('+out_file+')' $
else $
  write_tiff, out_file, ld_img_out_8bit, compression=1, bits_per_sample=8, geotiff=geotiff

end