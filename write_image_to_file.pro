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