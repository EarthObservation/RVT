;+
; NAME:
;
;       Topo_advanced_vis_xyz_to_tiff
;
; PURPOSE:
;
;       Convert the XYZ Gridded ascii file to GeoTIFF.
;
; INPUTS:
;
;
; KEYWORDS:
;
;       lzw_tiff - if set LZW compresion is enabled when writing GeoTIFF file
;
; OUTPUTS:
;
;       Float GEOTIFF file.
;
; AUTHOR:
;
;       Klemen Cotar
;
; DEPENDENCIES:
;
;       topo_advanced_vis_hillshade
;
; MODIFICATION HISTORY:
;
;       1.0  September 2014: Initial version written by Klemen Cotar.
;       1.1  April 2015: Added support for reading Slovenian lidar data (data points separated by semicolon instead of whitespace or tabulator and gridded unevenlly)
;-
pro topo_advanced_vis_xyz_to_tiff, in_img_file, $       ;input path+filename file
                                   error = error, $       ;output error messages
                                   out_img_file = out_img_file, $     ;output path+filename file
                                   lzw_tiff=lzw_tiff      ;input keyword to enable/disable LZW compression when writing GeoTIFF file
;in_img_file = 'f:\Sat_posnetki\DMR.xyz'
;in_img_file = 'D:\lidar_test\GK1_505_104.asc'

start = systime(/seconds)  
last_dot = strpos(in_img_file, '.' , /reverse_search)
out_img_file = strmid(in_img_file, 0, last_dot) + '.tif'

if n_elements(lzw_tiff) ne 0 then begin   ;check if compression is enabled
  if lzw_tiff then compressionValue = 1 $
  else compressionValue = 0
endif else compressionValue = 1

error = ''
xCol = 0    ;which column (-1) inside xyz file represent x coordinate
yCol = 1    ;which column (-1) inside xyz file represent y coordinate
zCol = 2

nlines = file_lines(in_img_file)    ;number of lines in xyz file
xyz_file_lines = strarr(nlines)    ;prepare string array in which file will be read
openr, u_in, in_img_file, /get_lun
readf, u_in, xyz_file_lines         ;read all lines freom xyz file
free_lun, u_in

x=make_array(nlines, /double, value=!Values.F_NAN)
y=make_array(nlines, /double, value=!Values.F_NAN)
z=make_array(nlines, /float, value=!Values.F_NAN)   ;are those values really allways in float ??

ndifx = 0
ndify = 0
xdifftry = 0
ydifftry = 0

;try to determine the correct data delimiter for this file
line = xyz_file_lines[0]
if n_elements(strsplit(line, ' ', /extract)) eq 3 then data_delimiter = ' '
if n_elements(strsplit(line, ';', /extract)) eq 3 then data_delimiter = ';'
if n_elements(strsplit(line, ',', /extract)) eq 3 then data_delimiter = ','
if n_elements(data_delimiter) eq 0 then data_delimiter = ' ' ;default delimiter setting if all checks for proper one fail

for n = 0UL, nlines-1 do begin
  line = xyz_file_lines[n]
  if line eq '0;0;0.00' then begin
    continue
  endif
  ;TO-DO, first line may be file header and not actual coordinates
  line = strsplit(line, data_delimiter, /extract)
  x[n]=double(line[xCol])
  y[n]=double(line[yCol])
  z[n]=float(line[zCol])  
endfor  

idx_valid = where(finite(x), n_valid)
if n_valid gt 0 then begin
  x = x[idx_valid]
  y = y[idx_valid]
  z = z[idx_valid]
endif

x_orig = x
y_orig = y
  
max_empty_lines = 2
x_skip = 0 & check_x = 1
y_skip = 0 & check_y = 1
x_round_factor = 10000l
y_round_factor = 10000l
repeat_check_gridded:
error = ''
xUniq = long64(x[uniq(x, sort(x))] * x_round_factor)  ;magija da ni potrebno operitat z nedoločenostmi pri float koordinatah.
yUniq = long64(y[uniq(y, sort(y))] * y_round_factor)
xUniq = xUniq[uniq(xUniq, sort(xUniq))]
yUniq = yUniq[uniq(yUniq, sort(yUniq))]

;check if distances between x and y coordinates are equal
if keyword_set(check_x) then begin
  dx1 = abs(xUniq[0] - xUniq[1])
  for ix = 1L, n_elements(xUniq)-2 do begin  
    dx2 = abs(xUniq[ix] - xUniq[ix+1])
    if dx1 eq dx2 then dx = dx1 / float(x_round_factor) $
    else begin
      if dx2 mod dx1 ne 0 or x_skip gt max_empty_lines then begin
        ;Check if some lines are missing. Dx2 is multipler of dx1 and only one line can be skipped
        error = ' X coordinate not gridded.'
        break
      endif else x_skip +=1
    endelse
  endfor
endif

if keyword_set(check_y) then begin
  dy1 = abs(yUniq[0] - yUniq[1])
  for iy = 1L, n_elements(yUniq)-2 do begin  
    dy2 = abs(yUniq[iy] - yUniq[iy+1])
    if dy1 eq dy2 then dy = dy1 / float(y_round_factor) $
    else begin
      if dy2 mod dy1 ne 0 or y_skip gt max_empty_lines then begin
        ;Check if some lines are missing. Dy2 is multipler of dy1
        error += ' Y coordinate not gridded.'
        break
      endif else y_skip += 1
    endelse
  endfor
endif

print, error
if error ne '' and (x_round_factor gt 1. and y_round_factor gt 1.) then begin
  if strpos(error, ' X coordinate') ge 0 then begin    
    check_x = 1
    x_rounded = 1
    x_round_factor /= 10l
  endif else check_x = 0
  if strpos(error, ' Y coordinate') ge 0 then begin
    check_y = 1
    y_rounded = 1
    y_round_factor /= 10l
  endif else check_y = 0  
  x_skip = 0
  y_skip = 0
  error = ''
  goto, repeat_check_gridded
endif

;print, 'Difference', dx, dy

if error eq '' then begin

  if keyword_set(x_rounded) then x = long64(x_orig * x_round_factor)/float(x_round_factor)
  if keyword_set(y_rounded) then y = long64(y_orig * y_round_factor)/float(y_round_factor)
  
  xMax = max(x, min = xMin, /Nan)
  yMax = max(y, min = yMin, /Nan)
  
  nX = (xMax-xMin)/dx     ;number of fields in x direction
  nY = (yMax-yMin)/dy
  print, 'X', xMin, xMax
  print, 'Y', yMin, yMax
  print, 'Size', nx, ny
  
  out_img = make_array(nx+1, ny+1, /float, value=-999)
  x = (x-xMin)/dx   ;convert x metric values to array coordinates 
  y = (y-yMin)/dy
  ;change y coordinates so that the smallest value is in the LL corner, not in UL corner
  y = abs(y - 2*ny + ny)
  out_img[round(x),round(y)] = z
  
  if keyword_set(x_rounded) or keyword_set(y_rounded) then begin
    ;get most common value for x and y coordinates
    x_Min = median(x_orig)
    y_Max = median(y_orig)
    coord = where((x_orig-x_Min)^2+(y_orig-y_Max)^2 eq 0)
    x_Min -= dx*x[coord]
    y_max += dy*y[coord]
  endif
  
  ; Produce basic geotiff information
  out_geotiff = { $
    ModelPixelScaleTag: [dx, dy, 0d], $  ; pixelsize
    ModelTiepointTag: [0, 0, 0, xMin - dx/2, yMax + dy/2, 0], $   ; coordinates of UL corner - presuming that coordinates in xyz file indicate the center of the pixel
    ProjLinearUnitsGeoKey: 9001  $   ;  == Linear_Meter
  } 
  print, xMin - dx/2, yMax + dy/2
  
  write_tiff, out_img_file, out_img, geotiff = out_geotiff, compression = compressionValue, /float 
endif

stop = systime(/seconds)
print, 'Time [min] to convert xyz: ',(stop-start)/60.
end

;obsolete old code for checking if file is properly gridded insisde for loop
;
;  ;check if distances between x coordinates are equal
;  if n gt 1 and ndifx lt 2 then begin   ;start checking at second line in xyz file
;    if x[n] ne x[n-1] then begin      ;make sure you have two different x values
;      if ndifx eq 0 then begin
;        dx = abs(x[n] - x[n-1])     ;calculate first distance
;        ndifx ++
;      endif else begin
;        if dx ne abs(x[n] - x[n-1]) then begin   ;check if second distance is the same as first
;          if xdifftry eq 1 then begin
;            error = 'X coordinate not gridded.'
;            break
;          endif else xdifftry++
;        endif $
;        else ndifx ++
;      endelse
;    endif
;  endif
;
;  ;check if distances between y coordinates are equal
;  if n gt 1 and ndify lt 2 then begin
;    if y[n] ne y[n-1] then begin
;      if ndify eq 0 then begin
;        dy = abs(y[n] - y[n-1])
;        ndify ++
;      endif else begin
;        if dy ne abs(y[n] - y[n-1]) then begin
;          if ydifftry eq 1 then begin  ;have multiple trys for checking if y is gridded properly, you may have encauntered a line break between two values
;            error = 'Y coordinate not gridded.'
;            break
;          endif else ydifftry++
;        endif $
;        else ndify ++
;      endelse
;    endif
;  endif