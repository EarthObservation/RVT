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
;       Maja Somrak (ZRC SAZU)
;
; :Copyright:
;       ZRC SAZU (Novi trg 2, 1000 Ljubljana, Slovenia) & Space-SI (Askerceva 12, 1000 Ljubljana, Slovenia)
;
; :History:
;       December 2016
;-

pro write_image_to_geotiff, overwrite, out_file, image_out
  if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
    print, ' Image already exists ('+out_file+')' $
  else $
    Write_tiff, out_file, image_out, compression=1, geotiff=geotiff
end

pro write_image_to_geotiff_float, overwrite, out_file, image_out
  if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
    print, ' Image already exists ('+out_file+')' $
  else $
    Write_tiff, out_file, image_out, compression=1, geotiff=geotiff, /float
end

pro write_image_to_geotiff_bits_per_sample, overwrite, out_file, image_out, bits
  if keyword_set(overwrite) eq 0 and file_test(out_file) eq 1 then $
    print, ' Image already exists ('+out_file+')' $
  else $
    write_tiff, out_file, image_out, bits_per_sample=bits, geotiff=geotiff, compression=1
end

function read_image_geotiff, in_file, in_orientation

  if file_test(in_file) eq 0 then begin
    errMsg = 'ERROR: Processing stopped! Selected TIF image was not found. '+ in_file
    print, errMsg
    return, 0
  endif $
  else begin
    read_image = read_tiff(in_file, orientation=in_orientation, geotiff=in_geotiff)
    if size(in_geotiff, /type) ne 8 then begin
      ;geotiff is not a structure type, try to read world file
      world_temp = read_worldfile_2(in_file, /to_geotiff)
      if world_temp gt 1 then begin
        in_geotiff = {MODELPIXELSCALETAG: [pixels_size_temp, pixels_size_temp, 0d], $
          MODELTIEPOINTTAG: [0, 0, 0, ul_x_temp, ul_y_temp, 0]}
      endif
    endif

    return, read_image
  endelse
end