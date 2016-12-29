;; docformat = 'rst'   ; i.e. format of the documentation
;
; NAME:
;       read_worldfile
;
; PURPOSE:
;+
;       This function reads the worldfile that corresponds to the image filename,
;       and as parameters returns all three parameters (pixelsize, UL cocrdinates).
;       The return value of the function is 1 if processing went ok, or 0 if 
;       worldfile was not found.
;       
;       It can return also UL coordinates shifted for half pixel (i.e. compliant 
;       with geotiff tags. 
;       Note: TFW carries coordinates of the center of the UL pixel,
;       while geotiff carries coordinates of the UL corner of the UL pixel.
;       
;       Procedure gives output also if image file does not exist at all. 
;
; :Categories:
;       Utilities
;
; :Params:
;       filename: in, required, type=string
;           Input string containing full path (folder+filename incl. extension)
;           of the input raster, or of the input world file.
;       pixelsize: out, required, type=float
;           Output float number containing resolution of the input raster.
;       ul_x: out, required, type=double
;           Output double number containing X (East) coordinate of UL corner.
;       ul_y: out, required, type=double
;           Output double number containing Y (North) coordinate of UL corner.
;
; :Keywords:
;       to_geotiff: in, optional
;           If this keyword is set, procedure applies half pixel shift the read UL coordinates,
;           so the returned coordinates are suitable for direct use in geotiff tags.
;
; :Examples:
;       Examples of function calls::
;
;           read_worldfile, filename, resolution, mosaic_x_ul, mosaic_y_ul
;           raad_worldfile, 'e:\test.tif', resolution, ul_x_tag, ul_y_tag, /to_geotiff
;
; :Author:
;       Peter Pehani (ZRC SAZU)
;
; :Copyright:
;       ZRC SAZU (Novi trg 2, 1000 Ljubljana, Slovenia) & Space-SI (Askerceva 12, 1000 Ljubljana, Slovenia)
;
; :History:
;       October 2014
;-
function read_worldfile, filename, pixelsize, ul_x, ul_y, to_geotiff=to_geotiff

  process_ok = 0
  
  ; Define extension of the worldfile
  image_ext = strmid(filename, 2, 3, /reverse_offset)
  case image_ext of
    'tif': out_filename_ext = 'tfw'
    'tfw': out_filename_ext = 'tfw'
    'jpg': out_filename_ext = 'jgw'
    'jgw': out_filename_ext = 'jgw'
    'jp2': out_filename_ext = 'j2w'
    'j2w': out_filename_ext = 'j2w'
    else: process_ok = -1
  endcase
  
  if (process_ok gt -1) then begin

    tfw_filename = strmid(filename,0, strlen(filename)-3) + out_filename_ext
    if file_test(tfw_filename) then begin
      ; Read location and pixelsize from worldfile
      openr, tfw_lun, tfw_filename, /get_lun
      in_tfw = dblarr(6)
      line_num = 0
      line = ''
      ;while ~eof(tfw_lun) do begin
      while (line_num lt 6) do begin
        readf, tfw_lun, line
        in_tfw[line_num] = line
        line_num++
      end
      free_lun, tfw_lun
      ; Fill output parameters
      process_ok = 1
      pixelsize = in_tfw[0] 
      ul_x = in_tfw[4] 
      ul_y = in_tfw[5]
    endif else begin
      process_ok = 0  ; when tfw_filename was not found
    endelse
  endif else begin
    process_ok = 0  ; when image_ext was not matched
  endelse
  
  ; Prepare UL coordinates for use geotiff tags (i.e. shift them for half pixel)
  if (process_ok eq 1) and keyword_set(to_geotiff) then begin
    ul_x -= 0.5d*pixelsize ; move for -1/2 pixel
    ul_y += 0.5d*pixelsize ; move for +1/2 pixel
  endif

  return, process_ok
  
end


function read_worldfile_2, filename, to_geotiff=to_geotiff

  process_ok = 0

  ; Define extension of the worldfile
  image_ext = strmid(filename, 2, 3, /reverse_offset)
  case image_ext of
    'tif': out_filename_ext = 'tfw'
    'tfw': out_filename_ext = 'tfw'
    'jpg': out_filename_ext = 'jgw'
    'jgw': out_filename_ext = 'jgw'
    'jp2': out_filename_ext = 'j2w'
    'j2w': out_filename_ext = 'j2w'
    else: process_ok = -1
  endcase

  if (process_ok gt -1) then begin

    tfw_filename = strmid(filename,0, strlen(filename)-3) + out_filename_ext
    if file_test(tfw_filename) then begin
      ; Read location and pixelsize from worldfile
      openr, tfw_lun, tfw_filename, /get_lun
      in_tfw = dblarr(6)
      line_num = 0
      line = ''
      ;while ~eof(tfw_lun) do begin
      while (line_num lt 6) do begin
        readf, tfw_lun, line
        in_tfw[line_num] = line
        line_num++
      end
      free_lun, tfw_lun
      ; Fill output parameters
      process_ok = 1
      pixelsize = in_tfw[0]
      ul_x = in_tfw[4]
      ul_y = in_tfw[5]
    endif else begin
      process_ok = 0  ; when tfw_filename was not found
    endelse
  endif else begin
    process_ok = 0  ; when image_ext was not matched
  endelse

  ; Prepare UL coordinates for use geotiff tags (i.e. shift them for half pixel)
  if (process_ok eq 1) and keyword_set(to_geotiff) then begin
    ul_x -= 0.5d*pixelsize ; move for -1/2 pixel
    ul_y += 0.5d*pixelsize ; move for +1/2 pixel
  endif

  return, process_ok

end