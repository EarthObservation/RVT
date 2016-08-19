;; docformat = 'rst'   ; i.e. format of the documentation
;
; NAME:
;
;       topo_advanced_vis_raster_mosaic
;
; PURPOSE:
;+
;       This procedure produces GeoTIFF mosaic of input GeoTIFF TIF or TIFF files, listed in the 
;       input string array.
;       (Note: To support other input file formats the topo_advanced_vis_converter would be needed)
;       
;       Filename of output mosaic can be input as keyword, otherwise the name *_mosaic.tif is 
;       selected, residing in the folder of the first file on the list.
;       
;       Mosaicking can be performed on files which overlap (last value is taken), or which have gaps.
;       Mosaicking skipps all files, which are either not found, or do not have geoinformation 
;       (TFW or geotiff tags), or have different resolution.
;       
;       Output mosaic file is written in the same data type as the input files have. Supported data types
;       are Byte, Integer, Float and Unsigned integer.
;       
;       Optinally processing log file can be written (if log filename is given as input parameter).
;       Otherwise the processing log information are printed into the IDL console.
;
; :Categories:
;       Other tools
;
; :Params:
;       file_list: in, required, type=array
;           Input string array containing full path (folder+filename incl. extension)
;           of all files to be mosaicked.
;       log_file: in, optional, type=string
;           Input string containing full path (folder+filename incl. extension)
;           of log file, where mosaicking processing log is written into.
;           If this parameter is not given, the processing log is printed into
;           IDL console.
;
; :Keywords:
;       out_filename: in/out, optional, type=string
;           Input string containing full path (folder+filename incl. extension)
;           of the output mosaic file. If this keyword is not set, then the mosaic file
;           is written to the folder of the first file on the list, with name *_mosaic.tif.
;       error: out, optional, type=string
;           Ouput error string.
;           
; :Uses:
;       read_worldfile
;
; :Examples:
;       An example of procedure call::
;
;           topo_advanced_vis_raster_mosaic, image_components, out_filename=out_dir_and_filename, error=error
;
; :Author:
;       Klemen Cotar (Space-SI)
;
; :Copyright:
;       ZRC SAZU (Novi trg 2, 1000 Ljubljana, Slovenia) & Space-SI (Askerceva 12, 1000 Ljubljana, Slovenia)
;
; :History:
;       1.0  April 2014: Initial version written by Klemen Cotar.
;-
pro topo_advanced_vis_raster_mosaic, file_list, log_file, out_filename=out_filename, error=error, overwrite=overwrite


if n_elements(log_file) gt 0 then begin
  openw, log, log_file, /get_lun, /append
  printf, log, 'Processing started at '+systime()
  start = systime(/seconds)
  printf, log, 'Image mosaicking will be performed on the following images:'
  for i_f=0, n_elements(file_list)-1 do printf, log, '  -> '+file_list[i_f]
  free_lun, log
endif

pixel_size = [0., 0.]
xL = 0.
xR = 0.
yU = 0.
yD = 0.
tif_files = []
n_bands = 1


; File-check: All files exist? All files contain geoinformation? All files have same resolution?
for n=0, n_elements(file_list)-1 do begin
  ;convert all images to GeoTiff files (if input in not tif image file) and read their geotiff informations
  if strpos(strlowcase(file_list[n]), '.tif') eq -1 and strpos(strlowcase(file_list[n]), '.tiff') eq -1 then begin
    if file_test(strmid(file_list[n], 0, strpos(file_list[n], '.', /reverse_searc))+'.tif') eq 1 then begin
      tif_file = strmid(file_list[n], 0, strpos(file_list[n], '.', /reverse_searc))+'.tif'
    endif else begin ; if file is neihter tif nor tiff then convert it to tif
      topo_advanced_vis_converter, file_list[n], 'GeoTIFF', log_file, out_img_file=out_img_file, error=error
      if error eq '' then begin
        tif_file = out_img_file
      endif else continue
    endelse    
  endif else begin
    tif_file =  file_list[n]
  endelse  
  temp = query_tiff(tif_file, image_info, geotiff=geotiff_temp)
  geotiff_type = size(geotiff_temp, /type)
  
  if temp eq 0 then begin
    error = '# FILE SKIPPED FROM MOSAICKING (topo_advanced_vis_raster_mosaic): Image not found '+tif_file
    if n_elements(log_file) gt 0 then begin
      openw, log, log_file, /get_lun, /append
      printf, log, error
      free_lun, log
    endif else print, error
    continue
  endif
  if geotiff_type ne 8 then begin
    ;geotiff is not a structure type, try to read world file
    world_temp = read_worldfile(tif_file, pixels_size_temp, ul_x_temp, ul_y_temp, /to_geotiff)
    if world_temp lt 1 then begin
      error = '# FILE SKIPPED FROM MOSAICKING (topo_advanced_vis_raster_mosaic): No geoinformation found for this image '+tif_file
      if n_elements(log_file) gt 0 then begin
        openw, log, log_file, /get_lun, /append
        printf, log, error
        free_lun, log
      endif else print, error
      continue
    endif
    geotiff_temp = {MODELPIXELSCALETAG: [pixels_size_temp, pixels_size_temp, 0d], $
                    MODELTIEPOINTTAG: [0, 0, 0, ul_x_temp, ul_y_temp, 0]}
  endif
  
  geotiff_orig =geotiff_temp
  
  if temp then begin
    x_size = image_info.dimensions[0]
    y_size = image_info.dimensions[1]
    n_bands = image_info.channels
    image_type = image_info.pixel_type
    if pixel_size[0] eq 0 and pixel_size[1] eq 0 then begin
      pixel_size = geotiff_temp.MODELPIXELSCALETAG[0:1]
      xL = geotiff_temp.MODELTIEPOINTTAG[3]
      xR = geotiff_temp.MODELTIEPOINTTAG[3] + pixel_size[0]*x_size
      yU = geotiff_temp.MODELTIEPOINTTAG[4]
      yD = geotiff_temp.MODELTIEPOINTTAG[4] - pixel_size[1]*y_size
    endif else begin
      if pixel_size[0] eq geotiff_temp.MODELPIXELSCALETAG[0] and pixel_size[1] eq geotiff_temp.MODELPIXELSCALETAG[1] then begin
        xL = xL < (geotiff_temp.MODELTIEPOINTTAG[3])
        xR = xR > (geotiff_temp.MODELTIEPOINTTAG[3] + pixel_size[0]*x_size)
        yU = yU > (geotiff_temp.MODELTIEPOINTTAG[4])
        yD = yD < (geotiff_temp.MODELTIEPOINTTAG[4] - pixel_size[1]*y_size)
      endif else begin
        error = '# MOSAICKING STOPPED (topo_advanced_vis_raster_mosaic): Pixel sizes do not match between the images. '
        if n_elements(log_file) gt 0 then begin
          openw, log, log_file, /get_lun, /append
          printf, log, error
          free_lun, log
        endif else print, error
        continue
      endelse
    endelse
   
  endif   
  tif_files = [tif_files, tif_file]
;  print, geotiff_temp
;  print, xL, xR, yU, yD
endfor 
 
;if z_size =  
geotiff_out = geotiff_orig
geotiff_out.MODELTIEPOINTTAG[3:4] = [xL, yU]

if (image_type eq 1) then mosaic_img = make_array(ceil((xR-xL)/pixel_size[0]), ceil((yU-yD)/pixel_size[1]), n_bands, /byte)
if (image_type eq 2) then mosaic_img = make_array(ceil((xR-xL)/pixel_size[0]), ceil((yU-yD)/pixel_size[1]), n_bands, /integer)
if (image_type eq 4) then mosaic_img = make_array(ceil((xR-xL)/pixel_size[0]), ceil((yU-yD)/pixel_size[1]), n_bands, /float, value=-999)
if (image_type eq 12) then mosaic_img = make_array(ceil((xR-xL)/pixel_size[0]), ceil((yU-yD)/pixel_size[1]), n_bands, /uint)
mosaic_size = 1.*size(mosaic_img, /dimensions)


; Mosaicking
print, 'Mosaicking started'
for n=0., n_elements(tif_files)-1 do begin
  for b=0., n_bands-1 do begin
    geotiff_in = !null
    img = read_tiff(tif_files[n], geotiff=geotiff_in, channel=b)       
    if b eq 0 then begin
      if size(geotiff_in, /type) ne 8 then begin
        ;geotiff is not a structure type, try to read world file
        world_temp = read_worldfile(tif_files[n], pixels_size_temp, ul_x_temp, ul_y_temp, /to_geotiff) 
        geotiff_in = {MODELPIXELSCALETAG: [pixels_size_temp, pixels_size_temp, 0d], $
                      MODELTIEPOINTTAG: [0, 0, 0, ul_x_temp, ul_y_temp, 0]}       
      endif
      x_offset = (geotiff_in.MODELTIEPOINTTAG[3] - xL)/pixel_size[0]
      y_offset = (yU - geotiff_in.MODELTIEPOINTTAG[4])/pixel_size[1]
      print, x_offset, y_offset
      idx_bad_orig = where(~(finite(img)) or img le 0, n_bad)
      if n_bad gt 0 then begin
        x_y_bad = array_indices(img, idx_bad_orig)
        x_bad = x_y_bad[0,*]+x_offset
        y_bad = x_y_bad[1,*]+y_offset
        x_y_bad = !null
      endif
    endif
    if n_bad gt 0 then begin
      idx_bad_mosaick = x_bad + y_bad*mosaic_size[0]+ b*mosaic_size[0]*mosaic_size[1] 
      bad_temp = mosaic_img[idx_bad_mosaick]
    endif
    mosaic_img[round(x_offset), round(y_offset),b] = img
    if n_bad gt 0 then mosaic_img[idx_bad_mosaick] = bad_temp
  endfor
endfor

if n_elements(out_filename) eq 0 then out_filename = strmid(tif_files[0], 0, strpos(tif_files[0], '.tif', /reverse_search))+'_mosaic.tif'

if keyword_set(overwrite) eq 0 and file_test(out_filename) eq 1 then $
  print, ' Image already exists ('+out_filename+')' $
else begin
  if (image_type eq 1) then write_tiff, out_filename, mosaic_img, planarconfig=2, geotiff = geotiff_out, compression=1, bits_per_sample=8
  if (image_type eq 2) then write_tiff, out_filename, mosaic_img, planarconfig=2, geotiff = geotiff_out, compression=1, /short, /signed
  if (image_type eq 4) then write_tiff, out_filename, mosaic_img, planarconfig=2, geotiff = geotiff_out, compression=1, /float
  if (image_type eq 12) then write_tiff, out_filename, mosaic_img, planarconfig=2, geotiff = geotiff_out, compression=1, /short
endelse

if n_elements(log_file) gt 0 then begin
  openw, log, log_file, /get_lun, /append
  printf, log, 'Total processing time: '+string((systime(/seconds)-start)/60.)+ ' minutes.'
  free_lun, log
endif
end