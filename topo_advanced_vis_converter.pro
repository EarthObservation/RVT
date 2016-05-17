;+
; NAME:
;
;       Topo_advanced_vis_converter
;
; PURPOSE:
;
;       Using GDAL or other converter procedures convert input image file to selected file format.
;
; INPUTS:
;
;
; KEYWORDS:
;
;
; OUTPUTS:
;
;       Image in the selected output file format. It has the same name and path as the input image, the only difference is in the file extension.
;
; AUTHOR:
;
;       Klemen Cotar
;
; DEPENDENCIES:
;
;       GDAL
;       programrootdir
;       topo_advanced_vis_xyz_to_tiff
;       topo_advanced_vis_asc_to_tiff
;
; MODIFICATION HISTORY:
;
;       1.0  September 2014: Initial version written by Klemen Cotar.
;-
pro topo_advanced_vis_converter , in_img_file, file_format, log_file, out_img_file=out_img_file, lzw_tiff=lzw_tiff, envi_interleave=envi_interleave, $
                                  jp2000_quality=jp2000_quality, jp2000_lossless=jp2000_lossless, jpg_quality=jpg_quality, erdas_compression=erdas_compression,$
                                  erdas_statistics=erdas_statistics, error=error

last_dot = strpos(in_img_file, '.' , /reverse_search)
if last_dot eq -1 or (last_dot gt 0 and strlen(in_img_file)-last_dot ge 6) then begin
  file_path = in_img_file   ;input file has no extension or extensions is very long (>=6) e.q. there is no valid extension or dost is inside filename
  in_img_ext = ''
endif else begin
  file_path = strmid(in_img_file, 0, last_dot)
  in_img_ext = strmid(in_img_file, last_dot+1)  ;get input file extension
endelse

;reset error
error = ''

Get_lun, unit
Openw, unit, log_file, /append
Printf, unit
Printf, unit
Printf, unit
Printf, unit, 'Processing info about conversion of input image'
Printf, unit, '==============================================================================================='
Printf, unit

;set GDAL parameters depending on a selected output file
other_set = ''
case file_format of
  'GeoTIFF':begin
              gdal_of = 'GTiff'     ;format code 
              extension = '.tif'     ;output file extension
              if n_elements(lzw_tiff) gt 0 then begin
                if lzw_tiff then other_set = '-co "COMPRESS=LZW"'$
                else other_set = '-co "COMPRESS=NONE"'                
              endif         ;by deault gdal compression is set to none
            end  
  'ENVI' :  begin
              gdal_of = 'ENVI'
              extension = '.dat'
              if n_elements(envi_interleave) gt 0 then begin
                other_set = '-co "INTERLEAVE='+envi_interleave+'"'
              endif   ;by deault gdal interleave is set to bsq          
            end
  'JP2000' :begin
              gdal_of = 'JP2OpenJPEG'
              extension = '.jp2'
              if n_elements(jp2000_quality) gt 0 then begin
                other_set += '-co "QUALITY='+jp2000_quality+'"'
              endif  ;by deault gdal quality is set to 25
              if n_elements(jp2000_lossless) gt 0 then begin
                if jp2000_lossless then other_set += ' -co "REVERSIBLE=YES"'
              endif  ;by deault gdal reversible for jp2k is set to NO
            end
  'JPG' :   begin
              gdal_of = 'JPEG'
              extension = '.jpg'
              if n_elements(jpg_quality) gt 0 then begin
                other_set = '-co "QUALITY='+jpg_quality+'"'
              endif  ;by deault gdal quality is set to 75
            end
  'ERDAS' : begin
              gdal_of = 'HFA'
              extension = '.img'
              if n_elements(erdas_compression) gt 0 then begin
                if erdas_compression then other_set = '-co "COMPRESSED=YES"' $
                else other_set = '-co "COMPRESSED=NO"'
              endif  ;by deault gdal erdas compression is set to no
              other_set += ' -co "AUX=NO"'
              if n_elements(erdas_statistics) gt 0 then begin
                if erdas_statistics then other_set += ' -co "STATISTICS=YES"' $
                else other_set += ' -co "STATISTICS=NO"'
              endif  ;by deault gdal erdas statisctics is set to no
            end
  'ASCII gridded XYZ' :begin
              gdal_of = 'XYZ'
              extension = '.xyz'
            end
  else: begin
          Printf, unit, 'ERROR: Unknown output format selected!.'
          print, 'ERROR: Unknown output format selected!.'
          goto, finish 
        end
endcase

out_img_file = file_path+extension    ;path+filename for generated output file

Printf, unit, '# Conversion metadata'
Printf, unit, '     Input filename:     '+ in_img_file
Printf, unit, '     Output filename:    '+ out_img_file
Printf, unit, '     Selected format:    '+ file_format
Printf, unit

if strlowcase(in_img_file) eq strlowcase(out_img_file) then begin   ;if input and output files have the same name, no conversion is done 
  Printf, unit, 'WARNING: Input and output files would be the same, no conversion done.'
  print, 'WARNING: Input and output files would be the same, no conversion done.'
endif else begin  
  
  if strlowcase(in_img_ext) eq 'xyz' or strlowcase(in_img_ext) eq 'txt' or strlowcase(in_img_ext) eq 'asc' then begin    ;GDAL has very strict rules about xyz format, call custom function to do conversion
    topo_advanced_vis_asc_to_tiff, in_img_file, error = xyz_error, out_img_file = xyz_out_img_file, lzw_tiff=lzw_tiff
    Printf, unit, xyz_error    
    if xyz_error ne '' then begin
      topo_advanced_vis_xyz_to_tiff, in_img_file, error = xyz_error, out_img_file = xyz_out_img_file, lzw_tiff=lzw_tiff
      Printf, unit, xyz_error
    endif    
    if xyz_error ne '' then begin
      error = xyz_error
      goto, finish
    endif
    
    in_img_file = xyz_out_img_file    ;needed if conversion to any format other than tiff was selected
  endif
      
  if file_format eq 'GeoTIFF' and (strlowcase(in_img_ext) eq 'xyz' or strlowcase(in_img_ext) eq 'txt' or strlowcase(in_img_ext) eq 'asc') then out_img_file = xyz_out_img_file $    
  else begin
    gdalDir = programrootdir()+'GDAL\'
    if file_test(gdalDir, /directory) eq 0 then begin  ;check if gdal is present in main program folder
      Printf, unit, 'ERROR: GDAL folder not found: '+gdalDir
      print, 'ERROR: GDAL folder not found: '+gdalDir
    endif else begin
      gdal_call = '"'+gdalDir+'gdal_translate.exe" -q -of '+gdal_of+' '+other_set+' "'+in_img_file+'" "'+out_img_file+'"'   ;compose gdal command line call
      spawn, gdal_call, output, error, /noshell
      
      Printf, unit, error[0]
      if error[0] ne '' and extension eq '.jpg' then begin
        if strpos(error[0], "driver doesn't support data type") gt 0 then begin
          ;conversion to jpg supports only 8-bit input data
        endif
        if strpos(error[0], "bands.  Must be") gt 0 then begin   
          ;conversion to jpg supports only 1 or 3 (4) bands in input/output file
          nb = strmid(error[0], strpos(error[0], 'support')+7, strpos(error[0], 'bands') - (strpos(error[0], 'support')+7))  ;get number of input bands from returned error
          nb = fix(strcompress(nb, /remove_all))
          if nb gt 1 and nb lt 3 then begin   
            ;new gdal call if input file had less than 3 bands
            gdal_call = '"'+gdalDir+'gdal_translate.exe" -b 1 -q -of '+gdal_of+' '+other_set+' "'+in_img_file+'" "'+out_img_file+'"'
            spawn, gdal_call, output, error, /noshell
            Printf, unit, 'WARNING: Only band 1 was selected for conversion.'
            print, 'WARNING: Only band 1 was selected for conversion.'
          endif
          if nb gt 3 then begin
            ;new gdal call if input file had equal or more than 3 bands
            gdal_call = '"'+gdalDir+'gdal_translate.exe" -b 1 -b 2 -b 3 -q -of '+gdal_of+' '+other_set+' "'+in_img_file+'" "'+out_img_file+'"'
            spawn, gdal_call, output, error, /noshell
            Printf, unit, 'WARNING: Only bands 1, 2 and 3 were selected for conversion.'
            print, 'WARNING: Only bands 1, 2 and 3 were selected for conversion.'        
          endif              
        endif
      endif
      
      ;gdal does not add mapinfo to output envi file if Arbitrary (no projection defined) map is defined in geotiff
      if (strlowcase(in_img_ext) eq 'xyz' or  strlowcase(in_img_ext) eq 'tif' or strlowcase(in_img_ext) eq 'tiff') and file_format eq 'ENVI' then begin
        openr, hdr, file_path+'.hdr', /get_lun
        map_info_incl = 0  ;check if map info is already included in hdr file
        while not(eof(hdr)) do begin
          line = ''
          readf, hdr, line
          if strpos(line, 'map info') ne -1 then begin
            map_info_incl = 1
            break
          endif
        endwhile        
        free_lun, hdr
        ;print, 'map info', map_info_incl
        
        if map_info_incl eq 0 then begin 
          result = query_tiff(in_img_file, geotiff=geotiff)
          geotiff_type = size(geotiff, /type)
          if geotiff_type eq 8 then begin    ;check if input tiff even has geotiff information - type eq to structure
            openw, hdr, file_path+'.hdr', /get_lun, /append
            printf, hdr, 'map info = {Arbitrary, 1.0000, 1.0000,'+string(geotiff.MODELTIEPOINTTAG[3])+','+string(geotiff.MODELTIEPOINTTAG[4])+' , '+string(geotiff.MODELPIXELSCALETAG[0])+', '+string(geotiff.MODELPIXELSCALETAG[1])+', 1, units=Meters}'
            free_lun, hdr
          endif  
        endif       
        
      endif
      
;      Printf, unit
;      Printf, unit, '     GDAL call string:     '+ gdal_call
    endelse    
  endelse
    
endelse

;remove unnecessary aux.xml files when converting
if file_test(in_img_file+'.aux.xml') then file_delete, in_img_file+'.aux.xml'   ;generated when statistics is turned on
if file_test(out_img_file+'.aux.xml') then file_delete, out_img_file+'.aux.xml'

finish:
free_lun, unit
end