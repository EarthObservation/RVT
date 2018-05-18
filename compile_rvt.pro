pro compile_rvt

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;                         !!!! OPOZORILO !!!!
;    Preden greš kompajlirat zadevo klikni na Reset gumb v orodni vrstici
;    ali poženi ukaz .full v ukazni vrstici, ker programsko nisem našel 
;    ekvivaletenega ukaza temu. Če ne narediš ti bo v .sav shranilo še vse 
;    procedure in funkcije, ki si jih do tedaj kaj uporabljal/skompajlal.
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


; nastavi lokacijo kjer se nakahaj koda in vse ostale stvari (parametri, gdal...)
gdal_dir = 'C:\Code\GitHub\RVT-IDL\GDAL\' ;'f:\IDLWorkspace\RVT-IDL\GDAL\'
rvt_dir = 'C:\Code\GitHub\RVT-IDL\' ; 'f:\IDLWorkspace\RVT-IDL\'
coyote_dir = 'C:\Code\GitHub\coyote\'
param_dir = rvt_dir + 'settings\'

cd, coyote_dir
resolve_routine, 'cgErrorMsg', /is_function
resolve_routine, 'convert_to_type', /is_function
resolve_routine, 'cgPercentiles', /is_function
resolve_routine, 'cgScaleVector', /is_function
resolve_routine, 'fpufix', /is_function

cd, rvt_dir
resolve_routine, 'logger__define'
resolve_routine, 'programrootdir', /is_function
resolve_routine, 'format_string', /is_function
resolve_routine, 'get_settings', /is_function
resolve_routine, 'progressbar__define'
resolve_routine, 'topo_advanced_vis_asc_to_tiff'
resolve_routine, 'topo_advanced_vis_converter'
resolve_routine, 'topo_advanced_vis_gradient'
resolve_routine, 'topo_advanced_vis_hillshade', /COMPILE_FULL_FILE
resolve_routine, 'topo_advanced_vis_localrelief'
;resolve_routine, 'blend_tile_iterator', /is_function, /COMPILE_FULL_FILE
;resolve_routine, 'RGB_to_sRGB', /is_function, /COMPILE_FULL_FILE
resolve_routine, 'RGB_to_HSP', /is_function, /COMPILE_FULL_FILE
resolve_routine, 'topo_advanced_normalization', /is_function, /COMPILE_FULL_FILE
resolve_routine, 'topo_advanced_vis_mixer_options_data', /COMPILE_FULL_FILE
resolve_routine, 'read_worldfile', /is_function
resolve_routine, 'image_access', /COMPILE_FULL_FILE
resolve_routine, 'blend_tile_iterator', /is_function, /COMPILE_FULL_FILE

resolve_routine, 'topo_advanced_vis_mixer_blend_modes', /COMPILE_FULL_FILE
resolve_routine, 'topo_advanced_vis_mixer', /COMPILE_FULL_FILE
resolve_routine, 'topo_advanced_vis_multihillshade', /COMPILE_FULL_FILE
resolve_routine, 'topo_advanced_vis_pcahillshade', /COMPILE_FULL_FILE
resolve_routine, 'topo_advanced_vis_skyillumination'
resolve_routine, 'topo_advanced_vis_slope'
resolve_routine, 'topo_advanced_vis_svf'
resolve_routine, 'topo_advanced_vis_xyz_to_tiff'
resolve_routine, 'topo_morph_shade', /is_function
;resolve_routine, 'read_worldfile', /is_function
resolve_routine, 'topo_advanced_vis_raster_mosaic'
;resolve_routine, 'image_access', /COMPILE_FULL_FILE
resolve_routine, 'topo_advanced_make_visualizations', /COMPILE_FULL_FILE
resolve_routine, 'topo_advanced_vis', /COMPILE_FULL_FILE
resolve_routine, 'unit_test_mixer', /COMPILE_FULL_FILE

resolve_all, /continue_on_error, skip_routines='envi'
save, /routines, filename='topo_advanced_vis.sav'

;naredi pripadajoči exe
out_subdir = 'RVT_2.3_Win64'
;file_delete, rvt_dir + out_subdir, /allow_nonexistent, /quiet, /recursive
make_rt, out_subdir, rvt_dir, savefile=rvt_dir+'topo_advanced_vis.sav', /overwrite, /win64

;izbriši nezaželjene datoteke iz izdelane daotekte
;delete_files_topo_advanced_vis, rvt_dir + out_subdir
;file_delete, 'topo_advanced_vis.sav', /allow_nonexistent, /quiet
;dodaj vse potrebne datoteke zraven
file_copy, gdal_dir, rvt_dir + out_subdir + '\GDAL\', /recursive, /allow_same, /overwrite
file_copy, param_dir, rvt_dir + out_subdir + '\settings\', /recursive, /allow_same, /overwrite
;nastavi prikaz dialoga na false
ini_file = rvt_dir + out_subdir + '\' + out_subdir + '.ini'
nlines = file_lines(ini_file)
lines = make_array(nlines, /string)
openr, ini, ini_file, /get_lun
readf, ini, lines
free_lun, ini
for i_l=0, n_elements(lines)-1 do begin
  if strpos(lines[i_l], 'Show') ge 0 then begin
    lines[i_l] = 'Show=False'
  endif
endfor
openw, ini, ini_file, /get_lun
for i_l=0, n_elements(lines)-1 do printf, ini, lines[i_l]
free_lun, ini
;naredi zip, ga zbriše pred tem če že obstaja
zip_out = rvt_dir + out_subdir + '.zip'
;file_delete, zip_out, /allow_nonexistent, /quiet
file_zip, rvt_dir + out_subdir, zip_out

;teh dveh pa verjetno ne rabimo več ali pač
;make_rt, 'RVT_1.3_Win32', rvt_dir, savefile='topo_advanced_vis.sav', /overwrite, /win32
;make_rt, 'RVT_1.3_Lin64', rvt_dir, savefile='topo_advanced_vis.sav', /overwrite, /lin64

end