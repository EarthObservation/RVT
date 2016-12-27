;=====================================================================================
;=====================================================================================
;=====================================================================================
;=====================================================================================

;+
; NAME:
;
;       Azimuth
;
; PURPOSE:
;
;       Determine the azimuth in the range of [0,2pi).
;
; INPUTS:
;
;       This function needs point coordinates
;        xa,ya,xb,yb
;
; OUTPUTS:
;
;       This procedure outputs the azimuth in radians.
;
; AUTHOR:
;
;       Klemen Zaksek
;       Kristof Ostir
;
; DEPENDENCIES:
;
;       No
;
; MODIFICATION HISTORY:
;
;       Written by Klemen Zaksek, 2004.
;       Implemented in IDL by Kristof Ostir, 2008.
;
;-

FUNCTION Topo_advanced_vis_svf_azimuth, xa, ya, xb, yb

  north = Float(ya - yb) ;y goes down
  east = Float(xb - xa)
  
  IF (north EQ 0) THEN BEGIN
    IF (east GT 0) THEN a = !pi / 2 ELSE BEGIN
      IF (east LT 0) THEN a = 3 * !pi / 2 ELSE a = !VALUES.F_NAN
    ENDELSE
  ENDIF ELSE BEGIN
    a0 = Atan(east/north)
    IF (north GT 0) AND (east GE 0) THEN a = a0 $
    ELSE IF (north LT 0) THEN a = a0 + !pi ELSE a = a0 + 2*!pi
  ENDELSE
  
  Return, a
END

;=====================================================================================
;=====================================================================================
;=====================================================================================
;=====================================================================================

;+
; NAME:
;
;       SkyView_Deter_Move
;
; PURPOSE:
;
;       Determine the movement matrix for Sky-View computation.
;
; INPUTS:
;
;       This procedure needs
;        num_directions - number of directions as input
;        radius_cell - radius to consider in cells (not in meters)
;        ncol - number of columns of the input DEM
;
; OUTPUTS:
;
;       This procedure outputs the movement matrix.
;
; AUTHOR:
;
;       Klemen Zaksek
;       Kristof Ostir
;
; DEPENDENCIES:
;
;       Azimuth
;
; MODIFICATION HISTORY:
;
;       Written by Klemen Zaksek, 2005.
;       Implemented in IDL by Kristof Ostir, 2008.
;       Optimized by Klemen Zaksek, 2013
;
;-

FUNCTION Topo_advanced_vis_svf_move, num_directions, radius_cell, ncol

  ; Parameters
  look_angle = 2 * !pi / num_directions
  
  ; Matrix initialization
  move = Fltarr(num_directions, radius_cell+1, 3)
  
  ; For each direction
  FOR dir=0L,(num_directions-1) DO BEGIN
    angle = dir * look_angle
    d = 0.
    x0 = 0L
    y0 = 0L
    xt = x0
    yt = y0
    rad = 0L
    
    ; Determine quadrant number
    IF ((angle GE 0) AND (angle LT !pi/2)) THEN quad = 1 $
    ELSE IF ((angle GE !pi/2) AND (angle LT !pi)) THEN quad = 2 $
    ELSE IF ((angle GE !pi) AND (angle LT 3*!pi/2)) THEN quad = 3 $
    ELSE IF ((angle GE 3*!pi/2) AND (angle LT 2*!pi)) THEN quad = 4

    ; While within range
    WHILE d LE radius_cell DO BEGIN
    
      ; Compute direction
      CASE quad OF
        1: BEGIN
          ; Right
          xa=xt+1L
          ya=yt
          ; Up
          xb=xt
          yb=yt-1L
          ; Diagonal right up
          xc=xt+1L
          yc=yt-1L
        END
        2: BEGIN
          ; Right
          xa=xt+1L
          ya=yt
          ; Diagonal right down
          xb=xt+1L
          yb=yt+1L
          ; Down
          xc=xt
          yc=yt+1L
        END
        3: BEGIN
          ; Left
          xa=xt-1L
          ya=yt
          ; Diagonal left down
          xb=xt-1L
          yb=yt+1L
          ; Down
          xc=xt
          yc=yt+1L
        END
        4: BEGIN
          ; Left
          xa=xt-1L
          ya=yt
          ; Up
          xb=xt
          yb=yt-1L
          ; Diagonal left up
          xc=xt-1L
          yc=yt-1L
        END
      ENDCASE
      
      ; Azimuths of possible movements (nearest neighbor, no interpolation)
      k_a=Topo_advanced_vis_svf_azimuth(x0,y0,xa,ya);
      k_b=Topo_advanced_vis_svf_azimuth(x0,y0,xb,yb);
      k_c=Topo_advanced_vis_svf_azimuth(x0,y0,xc,yc);
      
      ; Minimum difference in angle for new point
      IF (Abs(k_a-angle) LE Abs(k_b-angle)) THEN BEGIN
        IF (Abs(k_a-angle) LE Abs(k_c-angle)) THEN BEGIN
          xt=xa
          yt=ya
        ENDIF ELSE BEGIN
          xt=xc
          yt=yc
        ENDELSE
      ENDIF ELSE BEGIN
        IF (Abs(k_b-angle) LE Abs(k_c-angle)) THEN BEGIN
          xt=xb
          yt=yb
        ENDIF ELSE BEGIN
          xt=xc
          yt=yc
        ENDELSE
      ENDELSE
      
      ; Output
      move[dir,rad,0] = xt - x0
      move[dir,rad,1] = yt - y0
      d = Sqrt((xt-x0)^2 + (yt-y0)^2)
      move[dir,rad,2] = d
      
      ; Next cell
      rad++
      
    ENDWHILE

  ENDFOR

  ; Reformat the radius:
  ; first row tells you, how many valid cells are avialble
  ; below comes the actual radius in cells
  move[*,1:radius_cell,2] = move[*,0:radius_cell-1,2]
  FOR dir = 0,(num_directions-1) DO BEGIN
    tmp = Reform(move[dir,1:radius_cell,2], radius_cell)
    i = Where(tmp GT radius_cell, count)
    IF count THEN $
      move[dir,0,2] = Min(i) $
    ELSE $
      move[dir,0,2] = radius_cell
  ENDFOR
  
  ;Convert 2D index into 1D index
  move_t = Fltarr(num_directions, radius_cell+1, 2)
  move_t[*,*,0] = move[*,*,1] * ncol + move[*,*,0]
  move_t[*,*,1] = move[*,*,2]
  move = move_t
  
  Return, move

END

;=====================================================================================
;=====================================================================================
;=====================================================================================
;=====================================================================================

;+
; NAME:
;
;       SkyView_Compute
;
; PURPOSE:
;
;       Compute the Sky-View Factor.
;
; INPUTS:
;
;       This procedure needs
;        height - elevation (DEM) as 2D array (Ve Exagerration and pixel size already considered)
;        i_valid - index of valid pixels to be processed
;        radius_cell - maximal search radius in pixels/cells (not in meters)
;        radius_min - minimal search radius in pixels/cells (not in meters); for noise reduction
;        num_directions - number of directions as input
;        a_main_direction - main direction of anisotropy
;        a_poly_level - level of polynomial that determines the anisotropy
;        a_min_weight - weight to consider anisotropy (0 -isotropic, 1 no illumination form the direction opposite the main direction)

;        move - matrix of movements
;     deleted   use_nodata - consider no data values
;     deleted   nodata_value - value for no data
;        ver_exag - vertical exaggeration factor
;        ve_degrees - change vertical exaggeration factor due to geographic coordinate sistem
;     deleted   underground - compute for underground values
;     deleted   math_horizon - mathematical horizion
;     deleted   adir_weight - weight to consider anisotropy (0 -isotropic, 1 no illumination form the direction opposite the main direction)
;     deleted   adir_main - main direction of anisotropy
;
;
; OUTPUTS:
;
;       This procedure outputs
;        skyview factor
;        anisotropic skyview factor
;        openess (elevation angle of horizon)
;
; AUTHOR:
;
;       Klemen Zaksek
;       Kristof Ostir
;
; DEPENDENCIES:
;
;       No
;
; MODIFICATION HISTORY:
;
;       Written by Klemen Zaksek, 2005.
;       Implemented in IDL by Kristof Ostir, 2008.
;       Optimized by Klemen Zaksek, 2009.
;       Rewritten (cleaner code + option of anisometric SCF and openess) by Klemen Zaksek, 2013.
;
;-

FUNCTION Topo_advanced_vis_svf_compute, height, i_valid, $
    radius_cell, radius_min, num_directions, $
    a_main_direction, a_poly_level, a_min_weight, $
    svf=svf, asvf=asvf, opns=opns
    
  ; Directional step
  dir_step = 2*!PI/Float(num_directions)
  
  ; Vector of movement
  size_height = Size(height)
  ncol = size_height[1]               ;number of columns
  count_height = N_elements(i_valid)  ;number of all elements
  move = Topo_advanced_vis_svf_move(num_directions, radius_cell, ncol)
  
  ;Initialize the outputs
  IF Arg_present(svf) THEN svf = Fltarr(count_height)
  IF Arg_present(opns) THEN opns = Fltarr(count_height)
  IF Arg_present(asvf) THEN BEGIN
    asvf = Dblarr(count_height)
    w_m = Double(a_min_weight)              ;Compute weights for anisotropic SVF
    w_a = Double(a_main_direction / !radeg)
    weight = Dindgen(num_directions) * dir_step
    weight = Float((1.-w_m) * (Cos((weight-w_a)/2.))^a_poly_level + w_m)
  ENDIF
  
  ; Look into each direction...
  FOR dir = 0L, num_directions-1 DO BEGIN
  
    ;Reset maximum at each iteration - at each new direction
    max_slope = Fltarr(count_height) - 1000.
    
    ; ... and to the search radius - this depends on the direction - radius is written in the first row of MOVE
    FOR rad = 1, move[dir,0,1] DO BEGIN
    
      ; Ignore radius if smaller than the minimal defined radius
      IF radius_min GE move[dir,rad,1] THEN CONTINUE
      
      ; Search for max (sky)
      max_slope = max_slope > ((height[i_valid + Long(move[dir,rad-1,0])] - height[i_valid]) / move[dir,rad,1])

    ENDFOR
    
    ; Set the lowest possible horizon to 0 by SVF but not by openess
    max_slope = Atan(max_slope)
    IF Arg_present(opns) THEN opns = opns + max_slope
    IF Arg_present(svf) THEN svf = svf + (1. - Sin(max_slope > 0.))
    IF Arg_present(asvf) THEN asvf = asvf + (1. - Sin(max_slope > 0.)) * weight[dir]
  ENDFOR
  
  ; Normalize to the number of directions / weights
  IF Arg_present(svf) THEN svf = svf / num_directions
  IF Arg_present(asvf) THEN asvf = asvf / Total(weight)
  IF Arg_present(opns) THEN opns = !pi*0.5 - (opns/num_directions)
  
  ; Finished successfully
  Return, 1
  
END

;=====================================================================================
;=====================================================================================
;=====================================================================================
;=====================================================================================


;+
; NAME:
;
;       Topo_advanced_vis_svf
;
; PURPOSE:
;
;       Wraper for computation the Sky-View Factor. It reads the data and provides the to the further procedure and writes the outputs.
;
; INPUTS:
;
;       This procedure needs
;        in_file - path+filename of input DEM to save the outputs
;        in_svf - compute SVF (1) or not (0)?
;        in_opns - compute OPENESS (1) or not (0)?
;        geotiff - geotiff tags
;        dem - input DEM (original) as 2D array
;        resolution - pixel resolution
;        in_ve_ex - vertical exagerration
;        in_svf_n_dir - number of search directions
;        in_svf_r_max - maximal search radius in pixels
;        in_svf_noise - the level of noise to remove (0-3)
;        sc_svf_r_min - the portion (percent) of the maximal search radius to ignore in horizon estimation; for each noise level
;        sc_tile_size - settings of the largest possible tile that can be processend at once ( number of pixels)
;        sc_svf_ev - extreme values for SVF from float to 8-bit coversion
;        sc_opns_ev - extreme values for SVF from float to 8-bit coversion
;        in_asvf - copmpute anisotropic SVF (not -1; the value is then the main direction of anisotropy in degrees) or not (-1)?
;        in_asvf_level - level of anisotropy (low-0 or high-1)
;        sc_asvf_min level of polynomial that determines the anisotropy
;        a_min_weight - weight to consider anisotropy (0 -isotropic, 1 no illumination form the direction opposite the main direction)
;        sc_asvf_pol - level of polynomial that determines the anisotropy
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
;       No
;
; MODIFICATION HISTORY:
;
;       Written by Klemen Zaksek, 2013.
;
;-

PRO Topo_advanced_vis_svf, in_file, in_svf, in_opns, in_asvf, geotiff, $
    dem, resolution, $                        ;relief
    in_svf_n_dir, in_svf_r_max, $                       ;search definition
    in_svf_noise, sc_svf_r_min, $                       ;noise
    sc_tile_size, sc_svf_ev, sc_opns_ev, $              ;tile size
    in_asvf_dir, in_asvf_level, sc_asvf_min, sc_asvf_pol,$;anisotropy
    overwrite=ovverwrite
  
  ;Time
  ttt = Systime(1)  
  ;Vertical exagerration and pixel size
  dem = dem / resolution
  
  ;Incrase edge - visualization goes to edge, so mirror them, leave blank corners
  size_dem = Size(dem)
  ncol = size_dem[1]
  nlin = size_dem[2]
  tmp = Make_array(ncol+2L*in_svf_r_max, nlin+2L*in_svf_r_max)
  ;prepare indx for output
  tmp[in_svf_r_max:ncol+in_svf_r_max-1L, in_svf_r_max:nlin+in_svf_r_max-1L] = 1
  indx_all = Where(tmp EQ 1, count_all)
  ;fill centre
  tmp[in_svf_r_max:ncol+in_svf_r_max-1L, in_svf_r_max:nlin+in_svf_r_max-1L] = dem
;  ;fill above
;  tmp[in_svf_r_max:ncol+in_svf_r_max-1L, 0:in_svf_r_max-1L] = Reverse(dem[*, 0:in_svf_r_max-1L], 2)
;  ;fill below
;  tmp[in_svf_r_max:ncol+in_svf_r_max-1L, in_svf_r_max+nlin:2*in_svf_r_max+nlin-1L] = Reverse(dem[*, nlin-in_svf_r_max:nlin-1L], 2)
;  ;fill left
;  tmp[0:in_svf_r_max-1L, in_svf_r_max:nlin+in_svf_r_max-1L] = Reverse(dem[0:in_svf_r_max-1L, *], 1)
;  ;fill right
;  tmp[in_svf_r_max+ncol:2*in_svf_r_max+ncol-1L, in_svf_r_max:nlin+in_svf_r_max-1L] = Reverse(dem[0:in_svf_r_max-1L, *], 1)
  ;final dem with increased edges
  dem = tmp
  tmp = !null
  
  ;mininmal serach radius depends on the noise level
  in_svf_r_min = in_svf_r_max * sc_svf_r_min[in_svf_noise]*0.01
  
  ;set anisotropy parameters
  IF in_asvf EQ 1 THEN BEGIN
    in_poly_level = sc_asvf_pol[in_asvf_level-1]
    in_min_weight = sc_asvf_min[in_asvf_level-1]
  ENDIF
  
  ;============================================================================
  ;Run it - if it is neccessar, divide everything into more tiles;
  ;determine first, how many lines corespond to one tile
  nlt = sc_tile_size / ncol   ;the number of rows that can be processed at one moment
  nlt = ncol * nlt            ;the number of pixels to be processed at one moment
  ;n_tiles = ceil(float(nlin) / float(nlt))  ;the number of all tiles
  FOR i=0L,count_all-1,nlt DO BEGIN
    IF (i+nlt) GT (nlin*ncol-1) THEN BEGIN   ;the last tile (the only one if it is small) is usually smaller than the maximal size
      nlt0 = nlt
      nlt = nlin*ncol - i
      Print, 'Processing last tile...'
    ENDIF ELSE Print, 'Processing tile: ', i/nlt + 1
    indx_ok = indx_all[i:i+nlt-1]
    line1 = indx_ok[0]/Long(ncol+2*in_svf_r_max) - in_svf_r_max
    line2 = indx_ok[nlt-1]/Long(ncol+2*in_svf_r_max) + in_svf_r_max
    indx_ok = indx_all[i:i+nlt-1] - indx_all[i] + Long((ncol+2L*in_svf_r_max+1L) * in_svf_r_max)   ;correct to correspond just to subset dem_ok
    dem_ok = dem[*,line1:line2]
    IF in_svf EQ 1 THEN BEGIN
      IF in_opns EQ 1 THEN BEGIN
        IF in_asvf EQ 1 THEN BEGIN
          ;SVF, ASVF, OPNS
          svf_processed = Topo_advanced_vis_svf_compute( $
            dem_ok, indx_ok, $
            in_svf_r_max, in_svf_r_min, in_svf_n_dir, $
            in_asvf_dir, in_poly_level, in_min_weight,$
            svf=svf, asvf=asvf, opns=opns)
          Save, svf, File=Strtrim(i, 2)+'svf.sav'
          Save, asvf, File=Strtrim(i, 2)+'asvf.sav'
          Save, opns, File=Strtrim(i, 2)+'opns.sav'
        ENDIF ELSE BEGIN
          ;SVF, OPNS
          svf_processed = Topo_advanced_vis_svf_compute( $
            dem_ok, indx_ok, $
            in_svf_r_max, in_svf_r_min, in_svf_n_dir, $
            svf=svf, opns=opns)
          Save, svf, File=Strtrim(i, 2)+'svf.sav'
          Save, opns, File=Strtrim(i, 2)+'opns.sav'
        ENDELSE
      ENDIF ELSE BEGIN
        IF in_asvf EQ 1 THEN BEGIN
          ;SVF, ASVF
          svf_processed = Topo_advanced_vis_svf_compute( $
            dem_ok, indx_ok, $
            in_svf_r_max, in_svf_r_min, in_svf_n_dir, $
            in_asvf_dir, in_poly_level, in_min_weight,$
            svf=svf, asvf=asvf)
          Save, svf, File=Strtrim(i, 2)+'svf.sav'
          Save, asvf, File=Strtrim(i, 2)+'asvf.sav'
        ENDIF ELSE BEGIN
          ;SVF
          svf_processed = Topo_advanced_vis_svf_compute( $
            dem_ok, indx_ok, $
            in_svf_r_max, in_svf_r_min, in_svf_n_dir, $
            svf=svf)
          Save, svf, File=Strtrim(i, 2)+'svf.sav'
        ENDELSE
      ENDELSE
    ENDIF ELSE BEGIN
      IF in_opns EQ 1 THEN BEGIN
        IF in_asvf EQ 1 THEN BEGIN
          ;ASVF, OPNS
          svf_processed = Topo_advanced_vis_svf_compute( $
            dem_ok, indx_ok, $
            in_svf_r_max, in_svf_r_min, in_svf_n_dir, $
            in_asvf_dir, in_poly_level, in_min_weight,$
            asvf=asvf, opns=opns)
          Save, asvf, File=Strtrim(i, 2)+'asvf.sav'
          Save, opns, File=Strtrim(i, 2)+'opns.sav'
        ENDIF ELSE BEGIN
          ;OPNS
          svf_processed = Topo_advanced_vis_svf_compute( $
            dem_ok, indx_ok, $
            in_svf_r_max, in_svf_r_min, in_svf_n_dir, $
            opns=opns)
          Save, opns, File=Strtrim(i, 2)+'opns.sav'                                    ;negative
        ENDELSE
      ENDIF ELSE BEGIN
        IF in_asvf EQ 1 THEN BEGIN
          ;ASVF
          svf_processed = Topo_advanced_vis_svf_compute( $
            dem_ok, indx_ok, $
            in_svf_r_max, in_svf_r_min, in_svf_n_dir, $
            in_asvf_dir, in_poly_level, in_min_weight,$
            asvf=asvf)
          Save, asvf, File=Strtrim(i, 2)+'asvf.sav'
        ENDIF
      ENDELSE
    ENDELSE
  ENDFOR
  indx_all = !null & indx_ok = !null
  
  ;============================================================================
  
  ;Merge and write results
  ;SVF
  IF N_elements(svf) GT 0 THEN BEGIN
    svf_out = Make_array(ncol, nlin)
    nlt = nlt0
    FOR i=0L,count_all-1,nlt DO BEGIN
      IF (i+nlt) GT (nlin*ncol-1) THEN nlt = nlin*ncol - i
      Restore, Strtrim(i, 2)+'svf.sav'
      File_delete, Strtrim(i, 2)+'svf.sav', /ALLOW_NONEXISTENT
      line1 = i/Long(ncol)
      line2 = (i+nlt-1L)/Long(ncol)
      svf_out[*, line1:line2] = svf
    ENDFOR
    out_file = in_file[0] + '.tif'
    
     write_image_to_geotiff_float, overwrite, out_file, svf_out
;    if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
;      print, ' Image already exists ('+out_file+')' $
;    else $
;      Write_tiff, out_file, svf_out, compression=1, geotiff=geotiff, /float

    svf_out = Bytscl(svf_out, max=sc_svf_ev[1], min=sc_svf_ev[0])
    out_file = in_file[0] + '_8bit.tif'
    
    write_image_to_geotiff, overwrite, out_file, svf_out
;    if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
;      print, ' Image already exists ('+out_file+')' $
;    else $
;      Write_tiff, out_file, svf_out, compression=1, geotiff=geotiff      

    svf_out = !null & svf = !null

  ENDIF

  ;ASVF
  IF N_elements(asvf) GT 0 THEN BEGIN
    asvf_out = Make_array(ncol, nlin)
    nlt = nlt0
    FOR i=0L,count_all-1,nlt DO BEGIN
      IF (i+nlt) GT (nlin*ncol-1) THEN nlt = nlin*ncol - i
      Restore, Strtrim(i, 2)+'asvf.sav'
      File_delete, Strtrim(i, 2)+'asvf.sav', /ALLOW_NONEXISTENT
      line1 = i/Long(ncol)
      line2 = (i+nlt-1L)/Long(ncol)
      asvf_out[*, line1:line2] = asvf
    ENDFOR
    out_file = in_file[1] + '.tif'
    
    write_image_to_geotiff_float, overwrite, out_file, asvf_out
;    if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
;      print, ' Image already exists ('+out_file+')' $
;    else $
;      Write_tiff, out_file, asvf_out, compression=1, geotiff=geotiff, /float

    asvf_out = Hist_equal(asvf_out, percent=2);Bytscl(asvf_out, max=sc_svf_ev[1], min=sc_svf_ev[0])
    out_file = in_file[1] + '_8bit.tif'
    
    write_image_to_geotiff, overwrite, out_file, asvf_out
;    if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
;      print, ' Image already exists ('+out_file+')' $
;    else $
;      Write_tiff, out_file, asvf_out, compression=1, geotiff=geotiff
    asvf_out = !null & asvf = !null
  ENDIF
  
  ;OPENESS
  IF N_elements(opns) GT 0 THEN BEGIN
    opns_out = Make_array(ncol, nlin)
    nlt = nlt0
    FOR i=0L,count_all-1,nlt DO BEGIN
      IF (i+nlt) GT (nlin*ncol-1) THEN nlt = nlin*ncol - i
      Restore, Strtrim(i, 2)+'opns.sav'
      File_delete, Strtrim(i, 2)+'opns.sav', /ALLOW_NONEXISTENT
      line1 = i/Long(ncol)
      line2 = (i+nlt-1L)/Long(ncol)
      opns_out[*, line1:line2] = opns
    ENDFOR
    opns_out = opns_out * !radeg
    out_file = in_file[2] + '.tif'
    
    write_image_to_geotiff_float, overwrite, out_file, opns_out
;    if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
;      print, ' Image already exists ('+out_file+')' $
;    else $
;      Write_tiff, out_file, opns_out, compression=1, geotiff=geotiff, /float

    opns_out = Bytscl(opns_out, max=sc_opns_ev[1], min=sc_opns_ev[0])
    out_file = in_file[2] + '_8bit.tif'
    
    write_image_to_geotiff, overwrite, out_file, opns_out
;    if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
;      print, ' Image already exists ('+out_file+')' $
;    else $
;      Write_tiff, out_file, opns_out, compression=1, geotiff=geotiff
      
    opns_out = !null & opns = !null
  ENDIF    

  Print, 'Time [s] to complete: ', (Systime(1) - ttt)
  
  ;Restore DEM to original extent
  dem = dem[in_svf_r_max:ncol+in_svf_r_max-1L, in_svf_r_max:nlin+in_svf_r_max-1L]
   
END