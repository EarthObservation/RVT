;+
; NAME:
;
;       Topo_advanced_vis_asc_to_tiff
;
; PURPOSE:
;
;       Convert the ArcInfo Gridded ascii file to GeoTIFF.
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
;       1.0  October 2014: Initial version written by Klemen Cotar.
;-
pro topo_advanced_vis_asc_to_tiff, in_img_file, $       ;input path+filename file
                                   error = error, $       ;output error messages
                                   out_img_file = out_img_file, $     ;output path+filename file
                                   lzw_tiff=lzw_tiff, overwrite=overwrite      ;input keyword to enable/disable LZW compression when writing TIFF file

start = systime(/seconds)  
last_dot = strpos(in_img_file, '.' , /reverse_search)
out_img_file = strmid(in_img_file, 0, last_dot) + '.tif'

if n_elements(lzw_tiff) ne 0 then begin   ;check if compression is enabled
  if lzw_tiff then compressionValue = 1 $
  else compressionValue = 0
endif else compressionValue = 0

error = ''
nan_value_from_gdal = '1.#QNAN'

asc_nlines = file_lines(in_img_file)    ;number of lines in xyz file
asc_file_lines = strarr(asc_nlines)    ;prepare string array in which file will be read
openr, u_in, in_img_file, /get_lun
readf, u_in, asc_file_lines         ;read all lines freom xyz file
free_lun, u_in

header = 1
n_line = 0UL
while header do begin
  header = 0
  if strpos(strlowcase(asc_file_lines[n_line]), 'ncols') gt -1 then begin
    ncols = strsplit(asc_file_lines[n_line], ' ', /extract)
    ncols = long(ncols[1])
    header = 1
  endif
  if strpos(strlowcase(asc_file_lines[n_line]), 'nrows') gt -1 then begin
    nrows = strsplit(asc_file_lines[n_line], ' ', /extract)
    nrows = long(nrows[1])
    header = 1
  endif
  if strpos(strlowcase(asc_file_lines[n_line]), 'xllcorner') gt -1 then begin
    xllcorner = strsplit(asc_file_lines[n_line], ' ', /extract)
    xllcorner = float(xllcorner[1])
    header = 1
  endif
  if strpos(strlowcase(asc_file_lines[n_line]), 'yllcorner') gt -1 then begin
    yllcorner = strsplit(asc_file_lines[n_line], ' ', /extract)
    yllcorner = float(yllcorner[1])
    header = 1
  endif
  if strpos(strlowcase(asc_file_lines[n_line]), 'xllcenter') gt -1 then begin
    xllcenter = strsplit(asc_file_lines[n_line], ' ', /extract)
    xllcenter = float(xllcenter[1])
    header = 1
  endif
  if strpos(strlowcase(asc_file_lines[n_line]), 'yllcenter') gt -1 then begin
    yllcenter = strsplit(asc_file_lines[n_line], ' ', /extract)
    yllcenter = float(yllcenter[1])
    header = 1
  endif
  if strpos(strlowcase(asc_file_lines[n_line]), 'nodata_value') gt -1 then begin
    NODATA_value = strsplit(asc_file_lines[n_line], ' ', /extract)
    NODATA_value = float(NODATA_value[1])
    header = 1
  endif
  if strpos(strlowcase(asc_file_lines[n_line]), 'cellsize') gt -1 then begin
    cellsize = strsplit(asc_file_lines[n_line], ' ', /extract)
    cellsize = float(cellsize[1])
    header = 1
  endif
  if strpos(strlowcase(asc_file_lines[n_line]), 'dx') gt -1 then begin
    dx = strsplit(asc_file_lines[n_line], ' ', /extract)
    dx = float(dx[1])
    header = 1
  endif
  if strpos(strlowcase(asc_file_lines[n_line]), 'dy') gt -1 then begin
    dy = strsplit(asc_file_lines[n_line], ' ', /extract)
    dy = float(dy[1])
    header = 1
  endif
  n_line += 1 
endwhile

if n_elements(ncols) eq 0 or n_elements(nrows) eq 0 then error = 'Not enough meta parameters found for ArcGrid'

if error eq '' then begin
  out_img = make_array(ncols, nrows, /float, value = 0)
  out_img_line = 0
  for n = n_line-1, asc_nlines-1 do begin
    line = asc_file_lines[n]    
    line = strsplit(line, ' ', /extract)
    line[where(line  eq nan_value_from_gdal)] = !Values.F_NaN
    line = float(line)
;    print, size(line, /dimensions), out_img_line
    out_img[*, out_img_line] = line
    out_img_line += 1
  endfor
  
  ;NODATA value handling
  if n_elements(NODATA_value) gt 0 then out_img[where(out_img eq NODATA_value)] = !Values.F_NaN
  
  ;create geotiff data
  if n_elements(dx) eq 0 and n_elements(dy) eq 0 then begin
    dx = cellsize
    dy = cellsize
  endif
  ;if center of the ll pixel is set in header, calculate position of the ll corner of the pixel
  if n_elements(xllcenter) eq 1 and n_elements(yllcenter) eq 1 then begin
    xllcorner = xllcenter - dx/2
    yllcorner = yllcenter - dy/2
  endif  
  ;check if geodata coordinates are meaningful
  if dx eq 1 and dy eq 1 and xllcorner eq 0 and yllcorner eq -1*nrows then begin
    if keyword_set(overwrite) eq 0 and file_test(out_img_file) eq 1 then $
      print, ' Image already exists ('+out_img_file+')' $
    else $
      write_tiff, out_img_file, out_img, compression = compressionValue, /float
;    print, 'equal to zero'
  endif else begin
    out_geotiff = { $
      ModelPixelScaleTag: [dx, dy, 0d], $  ; pixelsize
      ModelTiepointTag: [0, 0, 0, xllcorner, yllcorner+nrows*dy, 0], $   ; coordinates of UL corner - presuming that coordinates in asc file indicate the ll corner of the pixel
      ProjLinearUnitsGeoKey: 9001  $   ;  == Linear_Meter
    }
    if keyword_set(overwrite) eq 0 and file_test(out_img_file) eq 1 then $
      print, ' Image already exists ('+out_img_file+')' $
    else $
      write_tiff, out_img_file, out_img, geotiff = out_geotiff, compression = compressionValue, /float
  endelse 
  
endif

print, error

stop = systime(/seconds)
print, 'Time [min] to convert asc: ',(stop-start)/60.
end