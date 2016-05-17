;+
; NAME:
;    TOPO_MORPH_SLOPE
;
; :Description:
;    Procedure can return terrain slope and aspect in radian units (default) or in alternative untis (if specified).
;    Slope is defined as 0 for Hz plane and pi/2 for vertical plane.
;    Aspect iz defined as geographic azimuth: clockwise increasing, 0 or 2pi for the North direction.
;    Currently applied finite diference method.
;
; :Returns:
;    If keyword DEM_SLOPE is specified, than terrain slope.
;    If keyword DEM_ASPECT is specified, than terrain aspect.
;
; :Params:
;    DEM         elevation written as 2D array
;    RESOLUTION  spatial resolution of the DEM
;
; :Keywords:
;    DEM_SLOPE   output terrain slope
;    DEM_ASPECT  output terrain aspect
;    PERCENT     output terrain slope in percent (0% for HZ surface, 100% for 45 degree tilted plane)
;    DEGREE      output terrain slope and aspect in degrees
;    VE_FACTOR   concider vertical exagerration factor (must be greater than 0)
;
; :Requires:
;    No dependencies!
;
; :Author: Klemen Zaksek (klemen.zaksek@zmaw.de)
; 2011
;-

PRO topo_advanced_vis_slope, dem_all, resolution, DEM_SLOPE=slope_all, DEM_ASPECT=aspect_all, PERCENT=percent, DEGREE=degree, VE_FACTOR=ve_factor

  ;Approximate maximal number of pixels allowed being processed at a time because of the RAM issues
  ;1e7 pixels are suitable for 8GB systems if the input DEM is not much larger than 300 MP
  n_max_points = Long(1e7)
  
  Print, 'Estimating the terrain slope and aspect...'
  starttime = Systime(/seconds)
  ;Check parameters
  dem_all = Float(dem_all)   ;transform elevations that a pixel has the resolution of 1
  IF  (N_params() EQ 0) THEN Message, 'Usage: output = TOPO_SLOPE(dem, [DEM_ASPECT=aspect], [PERCENT=percent], [DEGREE=degree], [VE_FACTOR=ve_factor])'
  IF  (N_params() GT 4) THEN Message, 'Usage: output = TOPO_SLOPE(dem, [DEM_ASPECT=aspect], [PERCENT=percent], [DEGREE=degree], [VE_FACTOR=ve_factor])'
  s_dem = Size(dem_all)
  IF  (s_dem[0] NE 2) THEN Message, 'Input DEM must be a 2D array!'
  IF  Keyword_set(ve_factor) THEN BEGIN
    IF ve_factor LE 0. THEN Message, 'Vertical exagerration must be positive number!'
  ENDIF ELSE BEGIN
    IF  ((Size(ve_factor))[0] NE 0) THEN Message, 'Vertical exagerration must be a scalar!'
    ve_factor = 0.
  ENDELSE
  IF  (Keyword_set(percent) AND Keyword_set(degree)) THEN BEGIN
    Print, 'Using both PERCENT and DEGREE keyword causes the output to be computed in degrees.'
    percent = 0
  ENDIF
  
  ;Consider the vertical exagerration
  IF  ve_factor NE 0. THEN dem_all *= ve_factor
  
  ;In the case the grid is too large, process not more than approximate n_max_points at a time;
  ;process only n_max_lin lines at a time.
  n_max_lin = Floor(n_max_points / s_dem[1])
  slope_all = Make_array(s_dem[1], s_dem[2])
  aspect_all = Make_array(s_dem[1], s_dem[2])
  l = s_dem[1] * s_dem[2]
  FOR i=0L,(s_dem[2]-1),n_max_lin DO BEGIN
    
    Print, '...', i, ' of ', s_dem[2]
    ;Last iteration usually contains less than n_max_lin
    IF (i+n_max_lin) GT (s_dem[2]-1) THEN n_max_lin = s_dem[2] - i
    IF n_max_lin eq 1 then continue
    
    ;Subset you work on has to contain additional row of data
    lin1 = i-1
    lin2 = i+n_max_lin
    n_lin = n_max_lin+1
    if lin1 eq -1 then begin
      lin1 = 0
      n_lin = n_lin - 1
    endif
    if lin2 eq s_dem[2] then begin
      lin2 = s_dem[2]-1
      n_lin = n_lin - 1
    endif
    dem = dem_all[*,lin1:lin2]
    
    ;Derivates in X and Y direction
    dzdx = (Shift(dem,1,0) - Shift(dem,-1,0)) * 0.5 / Float(resolution)
    dzdy = (Shift(dem,0,-1) - Shift(dem,0,1)) * 0.5 / Float(resolution)
    tan_slope = Sqrt(dzdx^2 + dzdy^2)
    
    ;Compute slope
    IF Keyword_set(percent) THEN slope = tan_slope * 100. $     ;output in percent
    ELSE slope = Atan(tan_slope)                                ;output in radians
    IF Keyword_set(degree) THEN slope = slope * !radeg
    
    ;Compute Aspect
    ;http://webhelp.esri.com/arcgisdesktop/9.2/index.cfm?TopicName=How%20Aspect%20works
    ;Aspect identifies the downslope direction of the maximum rate of change in value from each cell to its neighbors:
    ;     0
    ; 270   90
    ;    180
    aspect = Make_array(s_dem[1], n_lin)
    indx_0 = Where(dzdy EQ 0, count_0)                    ;important for numeric stability - where dzdy zero is, make tangens to really high value
    dzdy[indx_0] = 10.^(-9)
    tan_xy = dzdx / dzdy
    ;Correct the quadrant
    tan_xy = Atan(tan_xy)
    indx_1 = Where((dzdx GE 0) AND (dzdy GT 0), count_1)  ;first quadrant (0 <= a < pi/2)
    IF count_1 GT 0 THEN aspect[indx_1] = tan_xy[indx_1]
    indx_23 = Where(dzdy LT 0, count_23)                  ;second and third quadrant (pi/2 < a < 3pi/2)
    IF count_23 GT 0 THEN aspect[indx_23] = tan_xy[indx_23] + !pi
    indx_4 = Where((dzdx LT 0) AND (dzdy GT 0), count_4)  ;first quadrant (3pi/2 < a < 2pi)
    IF count_4 GT 0 THEN aspect[indx_4] = tan_xy[indx_4] + 2*!pi
    
    ;Return results to the output array
    slope_all[*,lin1+1:lin2-1] = slope[*,1:(n_lin-1)]
    aspect_all[*,lin1+1:lin2-1] = aspect[*,1:(n_lin-1)]
    
  ENDFOR
  dem = !null
  slope = !null
  aspect = !null
    
  ;Consider degree keyword by aspect
  IF Keyword_set(degree)THEN aspect_all = aspect_all * !radeg
  
  ;Consider nodata values
  indx_nodata = [Lindgen(s_dem[1]), $             ;filter out first line
    Lindgen(s_dem[1])+(s_dem[2]-1)*(s_dem[1]), $  ;filter last first line
    (Lindgen(s_dem[2]-2)+1)*(s_dem[1]), $         ;filter out left most coloumn
    (Lindgen(s_dem[2]-2)+2)*(s_dem[1])-1]         ;filter out right most coloumn
  slope_all[indx_nodata] = -1
  aspect_all[indx_nodata] = -1
  
  Print, 'Seconds took to compute the slope: ', Systime(/seconds)-starttime
  
END
