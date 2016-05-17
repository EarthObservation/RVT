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
;       This function needs point coordinates - not a vector operation
;       xa, ya, xb, yb
;       a stands for the first (stand) point
;       b stands for the second (view) point
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
;       Corrected by Klemen Zaksek, 2012.
;
;-

function topo_morph_shade_azimuth, xa, ya, xb, yb

  north = float(ya - yb) ;y goes down, x goes left, just like IDL array indexes!!!!
  east = float(xb - xa); * cos(0.8)
  
  ;for the case that the north-south difference is zero
  if (north eq 0) then begin
    if (east gt 0) then a = !pi / 2 else begin
      if (east lt 0) then a = 3 * !pi / 2 else begin
        a = 0
        print, 'You have estimated an azimuth based on two identical points, which makes no sense... returning 0!'
      endelse
    endelse
    return, a
  endif
  
  ;normal case
  a0 = atan(east/north)
  if (north gt 0) and (east ge 0) then a = a0 $
  else if (north lt 0) then a = a0 + !pi else a = a0 + 2*!pi
  return, a
  
end


function topo_morph_shade_move, d_max, angle

  ;Initialization
  move = dblarr(3,d_max+1)
  d = 0.
  x0 = 0L
  y0 = 0L
  xt = x0
  yt = y0
  rad = 0L

  ; Determine quadrant number
  if ((angle ge 0) and (angle lt !pi/2)) then quad = 1 $
  else if ((angle ge !pi/2) and (angle lt !pi)) then quad = 2 $
  else if ((angle ge !pi) and (angle lt 3*!pi/2)) then quad = 3 $
  else if ((angle ge 3*!pi/2) and (angle lt 2*!pi)) then quad = 4

  ; While within range
  while d le d_max do begin
  
    ; Compute direction
    case quad of
      1: begin
        ; Right
        xa=xt+1L
        ya=yt
        ; Up
        xb=xt
        yb=yt-1L
        ; Diagonal right up
        xc=xt+1L
        yc=yt-1L
      end
      2: begin
        ; Right
        xa=xt+1L
        ya=yt
        ; Diagonal right down
        xb=xt+1L
        yb=yt+1L
        ; Down
        xc=xt
        yc=yt+1L
      end
      3: begin
        ; Left
        xa=xt-1L
        ya=yt
        ; Diagonal left down
        xb=xt-1L
        yb=yt+1L
        ; Down
        xc=xt
        yc=yt+1L
      end
      4: begin
        ; Left
        xa=xt-1L
        ya=yt
        ; Up
        xb=xt
        yb=yt-1L
        ; Diagonal left up
        xc=xt-1L
        yc=yt-1L
      end
    endcase
  
    ; Azimuths of possible movements (nearest neighbor, no interpolation)
    k_a=topo_morph_shade_azimuth(x0,y0,xa,ya);
    k_b=topo_morph_shade_azimuth(x0,y0,xb,yb);
    k_c=topo_morph_shade_azimuth(x0,y0,xc,yc);
  
    ; Minimum difference in angle for new point
    if (abs(k_a-angle) le abs(k_b-angle)) then begin
      if (abs(k_a-angle) le abs(k_c-angle)) then begin
        xt=xa
        yt=ya
      endif else begin
        xt=xc
        yt=yc
      endelse
    endif else begin
      if (abs(k_b-angle) le abs(k_c-angle)) then begin
        xt=xb
        yt=yb
      endif else begin
        xt=xc
        yt=yc
      endelse
    endelse
  
    ; Output
    move[0,rad] = xt - x0
    move[1,rad] = yt - y0
    d = sqrt((xt-x0)^2 + (yt-y0)^2)
    move[2,rad] = d
  
    ; Next cell
    rad++
  
  endwhile
  
  move = move[*,0:rad-1]
  return, move
  
end
;
;
;+
; NAME:
;
;       TOPO_MORPH_SHADE.PRO
;
; PURPOSE:
;
;       Compute topographic corrections
;
; INPUTS:
;
;       height      elevation (2D matrix)
;       sol_z       solar zenith angle in radians (0 for vertical and pi/2 for horizontal surface)
;       sol_a       solar azimuth angle
;       d_max       maximum search distance in pixel
;
; OUTPUTS:
;
;       This procedure determines those cells that are in its own (hillshade) or thrown (cast shade) shadow
;
; AUTHOR:
;
; DEPENDENCIES:
;
;
; MODIFICATION HISTORY:
;
;-

FUNCTION topo_morph_shade, height, sol_z, sol_a, d_max, ncols, nrows, resolution

;  print, 'Estimating the mask of shaded areas... d_max: '+strcompress(d_max,/remove_all)
  starttime = SYSTIME(/seconds)
  
  ;initialize the results
  mask = bytarr(ncols+2.*d_max, nrows+2.*d_max)
  mask[d_max:(ncols+d_max-1), d_max:(nrows+d_max-1)] = 1
  i_valid = where(mask eq 1, count_valid) 
  tmp = fltarr(ncols+2.*d_max, nrows+2.*d_max)
  tmp[d_max:(ncols+d_max-1), d_max:(nrows+d_max-1)] = height
  height = tmp
  tmp = !null
  
  ;determine the direction of mowement
  move = topo_morph_shade_move(d_max, sol_a)
  move_s = size(move)
  move1di = lonarr(move_s[2])
  move1di = long(move[1,*]) * long(ncols+2.*d_max) + long(move[0,*])    ;convert to 1D index
  move1dd = float(move[2,*])

  ;set the maximal allowed horizon angle (if it is greater, then the area in in the shadow)
  max_slope = 0.

  for rad = 0, move_s[2]-1 do begin
      max_slope = max_slope > ((height[i_valid + move1di[rad]] - height[i_valid]) / move1dd[rad])
  endfor  
  
  ;update mask
  max_slope = atan(max_slope / resolution)
  indx_mask = where(max_slope gt (!pi*0.5 - sol_z), count_mask)
  if count_mask gt 0 then mask[i_valid[indx_mask]] = 0
  mask = mask[d_max:(ncols+d_max-1), d_max:(nrows+d_max-1)]
  
  PRINT, 'Seconds took to compute the shades: ', SYSTIME(/seconds)-starttime
  
  RETURN, mask
  
END
