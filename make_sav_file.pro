pro make_sav_file
  ; nastavi lokacijo kjer se nakahaj koda in vse ostale stvari (parametri, gdal...)
  gdal_dir = 'C:\Code\GitHub\RVT-IDL\GDAL\' ;'f:\IDLWorkspace\RVT-IDL\GDAL\'
  rvt_dir = 'C:\Code\GitHub\RVT-IDL\' ; 'f:\IDLWorkspace\RVT-IDL\'
  coyote_dir = 'C:\Code\GitHub\coyote'
  param_dir = rvt_dir + 'settings\'

  save, /routines, filename='topo_advanced_vis.sav'
  
  ;naredi pripadajoči exe
  out_subdir = 'RVT_1.3_Win64'
  file_delete, rvt_dir + out_subdir, /allow_nonexistent, /quiet, /recursive
  make_rt, out_subdir, rvt_dir, savefile='topo_advanced_vis.sav', /overwrite, /win64
  ;izbriši nezaželjene datoteke iz izdelane daotekte
  delete_files_topo_advanced_vis, rvt_dir + out_subdir
  file_delete, 'topo_advanced_vis.sav', /allow_nonexistent, /quiet
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
  file_delete, zip_out, /allow_nonexistent, /quiet
  file_zip, rvt_dir + out_subdir, zip_out
end