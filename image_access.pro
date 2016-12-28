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

function read_image_geotiff, in_file, $
                             in_orientation, $
                             pixels_size_temp, $
                             ul_x_temp, ul_y_temp

  if file_test(in_file) eq 0 then begin
    errMsg = 'ERROR: Processing stopped! Selected TIF image was not found. '+ in_file
    print, errMsg
    return, 0
  endif $
  else begin
    read_image = read_tiff(in_file, orientation=in_orientation, geotiff=in_geotiff)
    if size(in_geotiff, /type) ne 8 then begin
      ;geotiff is not a structure type, try to read world file
      world_temp = read_worldfile(in_file, pixels_size_temp, ul_x_temp, ul_y_temp, /to_geotiff)
      if world_temp gt 1 then begin
        in_geotiff = {MODELPIXELSCALETAG: [pixels_size_temp, pixels_size_temp, 0d], $
          MODELTIEPOINTTAG: [0, 0, 0, ul_x_temp, ul_y_temp, 0]}
      endif
    endif

    return, read_image
  endelse
end