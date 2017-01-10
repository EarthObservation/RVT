; +
; 
; TESTING
; 
; 
; 
; 
; 
; -
;

function gen_combination_in_widgets, event
  widget_control, event.top, get_uvalue=p_wdgt_state
  
  vis_list
  
  foreach visualization, (*p_wdgt_state).vis_droplist begin
    ; layer 1
    
    ; layer 2
    
  endforeach
  

  return, 
end

pro unit_test_mixer, event
   
   ; Compile
   ;compile_opt
   ;on_error, 2
   
   input = gen_combination_in_widgets(event)
   expect = 
   result = 
   
   if result ne expect then begin
     message, 'Mixer processing produced errors during runtime!'
   endif
   if result eq expect then begin
     message, 'Mixer works as expected, please check log file and output images for errors.'
   endif
   
end

pro test_convert_to_string_null
  compile_opt idl2
  on_error, 2

  input = !NULL
  expect = '!NULL'
  result = convert_to_string(input)

  if result ne expect then begin
    message, 'Converting number failed.'
  endif
end

pro test_convert_to_string_object
  compile_opt idl2
  on_error, 2

  input = hash('a',1,'b',2,'c',3)
  expect = '{"c":3,"a":1,"b":2}'
  result = convert_to_string(input)

  if result ne expect then begin
    message, 'Converting number failed.'
  endif
end

pro test_convert_to_string
  compile_opt idl2

  print
  print, 'Testing suite for convert_to_string()'
end

; Path – path to test directory
pro unit_test_runner, path
  compile_opt idl2

  if ~file_test(path, /directory) then begin
    message, 'Input must be a path.'
  endif

  test_files = file_search(path, 'test*.pro')
  resolve_routine, file_basename(test_files,'.pro'), /compile_full_file
  tests = routine_info()

  print
  print,'--------------------------------------------------------------------------------'

  error_count = 0
  for i=0, tests.length-1 do begin
    catch, errorStatus
    if (errorStatus ne 0) then begin
      catch, /cancel
      print, 'ERROR: ', !ERROR_STATE.msg
      i++
      error_count++
      continue
    endif

    if (tests[i]).startswith('TEST_') then begin
      call_procedure, tests[i]
    endif
  endfor

  print
  print,'--------------------------------------------------------------------------------'
  print

  if error_count gt 0 then begin
    print, 'Unit test failures on: ' + path
  endif else begin
    print, 'Unit tests pass.'
  endelse

end