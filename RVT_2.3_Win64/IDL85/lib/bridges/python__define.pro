; $Id: //depot/Release/ENVI53_IDL85/idl/idldir/lib/bridges/python__define.pro#2 $
;
; Copyright (c) 2014-2015, Exelis Visual Information Solutions, Inc. All
;       rights reserved. Unauthorized reproduction is prohibited.
;----------------------------------------------------------------------------
; http://www.rafekettler.com/magicmethods.html
;

;---------------------------------------------------------------------------
function Python::Init, pyObjectID, pData

  compile_opt idl2, hidden
  ON_ERROR, 2

  Python.Load

  self.pyID = -1
  if (ISA(pyObjectID)) then begin
    self.pyID = pyObjectID
    ; We are caching a reference - so bump up the refcount.
    PYTHON_INCREF, self.pyID
  endif

  if (ISA(pData)) then begin
    self.pData = pData
  endif

  HEAP_NOSAVE, self
  return, 1
end


;---------------------------------------------------------------------------
pro Python::Cleanup

  compile_opt idl2, hidden
  ON_ERROR, 2
  if (self.pyID gt 0) then begin
    PYTHON_DECREF, self.pyID
  endif
  ; Let garbage collection decrease the ref count.
  self.pData = PTR_NEW()
end


;---------------------------------------------------------------------------
; Internal method to find a case-insensitive match of an attribute/method.
;
function Python::_FindAttr, pyID, attr, METHOD=method

  compile_opt idl2, hidden, static
  ON_ERROR, 2

  if (ISA(self)) then begin
    MESSAGE, 'Internal error: Must be called as a static method.'
  endif

  ; Try whatever case came in (usually lowercase).
  if (PYTHON_HASATTR(pyID, attr)) then begin
    if (~KEYWORD_SET(method)) then begin
      return, attr
    endif
    pyObj = PYTHON_GETATTR(pyID, attr)
    if (PYTHON_HASATTR(pyObj.pyID, '__call__')) then begin
      return, attr
    endif
  endif

  ; If that fails, try matching the dictionary of attributes & methods.
  if (PYTHON_HASATTR(pyID, '__dict__')) then begin
    ; Note that __dict__ can either return an IDL hash or a Python mappingproxy.
    ; Luckily, both objects have a keys() method. The IDL hash.keys() returns
    ; an IDL list, while the mappingproxy.keys() returns a Python.dict_keys.
    ; Again, luckily we can use foreach to iterate over either one.
    dict = PYTHON_GETATTR(pyID, '__dict__')
    if (ISA(dict)) then begin
      keys = dict.keys()
    endif
  endif else begin
    ; If we don't have a dictionary, use dir() to retrieve an IDL list.
    keys = Python.Dir(Python(pyID))
  endelse

  if (ISA(keys)) then begin
    foreach key, keys do begin
      if (key.ToLower() eq attr) then begin
        if (~KEYWORD_SET(method)) then begin
          return, key
        endif
        pyObj = PYTHON_GETATTR(pyID, key)
        if (PYTHON_HASATTR(pyObj.pyID, '__call__')) then begin
          return, key
        endif
      endif
    endforeach
  endif

  return, !null
end


;---------------------------------------------------------------------------
; Note: Do not add *any* keywords here. Everything needs to be handled
; through REF_EXTRA. See the note below.
;
pro Python::GetProperty, _REF_EXTRA=extra

  compile_opt idl2, hidden, static
  ON_ERROR, 2

  Python.Load

  ; Am I being called as a static method?
  ; The "-1" indicates the builtins module
  pyID = ISA(self) ? self.pyID : -1

  ; We need to handle our own keywords as special cases of ref_extra.
  ; Otherwise, because of IDL keyword matching, if you tried to retrieve
  ; a variable named "c", then Python.C would just match the CLASSNAME keyword.
  foreach ex, extra do begin
    case ex of

    'CLASSNAME': begin
      class = PYTHON_GETATTR(pyID, '__class__')
      (SCOPE_VARFETCH('CLASSNAME', /REF_EXTRA)) = $
        PYTHON_GETATTR(class.pyID, '__name__')
      end

    'DIM': (SCOPE_VARFETCH('DIM', /REF_EXTRA)) = self._overloadSize()

    'LENGTH': begin
      dim = self._overloadSize()
      (SCOPE_VARFETCH('LENGTH', /REF_EXTRA)) = PRODUCT(dim, /INTEGER)
      end

    'NDIM': begin
      dim = self._overloadSize()
      ndim = ISA(dim, /ARRAY) ? N_ELEMENTS(dim) : 0
      (SCOPE_VARFETCH('NDIM', /REF_EXTRA)) = ndim
      end

    'PYID': (SCOPE_VARFETCH('PYID', /REF_EXTRA)) = pyID

    'REFCOUNT': begin
      sys = PYTHON_IMPORT('sys')
      refcount = PYTHON_CALLMETHOD(sys.pyID, 'getrefcount', self)
      ; Subtract 1 since getrefcount temporarily bumps up the ref count.
      refcount--
      (SCOPE_VARFETCH('REFCOUNT', /REF_EXTRA)) = refcount
    end

    'TNAME': (SCOPE_VARFETCH('TNAME', /REF_EXTRA)) = 'OBJREF'

    'TYPECODE': (SCOPE_VARFETCH('TYPECODE', /REF_EXTRA)) = 11

    'TYPENAME': (SCOPE_VARFETCH('TYPENAME', /REF_EXTRA)) = OBJ_CLASS(self)

    else: begin
      exname = Python._FindAttr(pyID, STRLOWCASE(ex))
      if (~ISA(exname)) then begin
        MESSAGE, /NONAME, 'Python: Unknown attribute: "' + STRLOWCASE(ex) + '"'
      endif
      result = PYTHON_GETATTR(pyID, exname)
      (SCOPE_VARFETCH(ex, /REF_EXTRA)) = TEMPORARY(result)
      end

    endcase
  endforeach
end


;---------------------------------------------------------------------------
; Note: Do not add *any* keywords here. Everything needs to be handled
; through REF_EXTRA. See the note above in GetProperty.
;
pro Python::SetProperty, $
  _REF_EXTRA=extra

  compile_opt idl2, hidden, static
  ON_ERROR, 2

  Python.Load

  ; Am I being called as a static method?
  ; The "-1" indicates the builtins module
  pyID = ISA(self) ? self.pyID : -1

  foreach ex, extra do begin
    exname = Python._FindAttr(pyID, STRLOWCASE(ex))
    ; If we didn't find an existing attribute (of any case),
    ; create a new lowercase one.
    if (~ISA(exname)) then begin
      exname = STRLOWCASE(ex)
    endif
    PYTHON_SETATTR, pyID, exname, SCOPE_VARFETCH(ex, /REF_EXTRA)
  endforeach
end


;---------------------------------------------------------------------------
function Python::Import, module

  compile_opt idl2, hidden, static
  ON_ERROR, 2

  if (ISA(self)) then begin
    MESSAGE, /NONAME, 'Python::Import must be called as a static method.'
  endif

  Python.Load

  result = PYTHON_IMPORT(module)
  return, result
end


;---------------------------------------------------------------------------
pro Python::Import, module

  compile_opt idl2, hidden, static
  ON_ERROR, 2

  if (ISA(self)) then begin
    MESSAGE, /NONAME, 'Python::Import must be called as a static method.'
  endif

  Python.Load

  void = PYTHON_RUN('from ' + module + ' import *')
end


;---------------------------------------------------------------------------
pro Python::Load, version

  compile_opt idl2, hidden, static
  ON_ERROR, 2

  HELP, /MESSAGES, OUTPUT=output
  foreach str, output do begin
    if (str.Contains('PYTHON')) then return
  endforeach

  if (ISA(version)) then begin
    DLM_LOAD, version
    return
  endif

  ; Determine which Python version to load.
  SPAWN, ['python', '--version'], stdout, stderr, /noshell
  if (stderr[0].Contains('Python 2.7')) then begin
    DLM_LOAD, 'Python27'
  endif else if (stderr[0].Contains('Python 3.4')) then begin
    DLM_LOAD, 'Python34'
  endif else begin
    MESSAGE, 'Unable to find a valid Python installation.'
  endelse
end


;---------------------------------------------------------------------------
function Python::Run, command

  compile_opt idl2, hidden, static
  ON_ERROR, 2

  if (ISA(self)) then begin
    MESSAGE, /NONAME, 'Python::Run must be called as a static method.'
  endif

  Python.Load

  ; Redirect Python's stdout to our own Python class, so we can capture it.
  lf = STRING(10b)
  void = PYTHON_RUN( $
    "class idl_stdout:" + lf + $
    "    def __init__(self):" + lf + $
    "        self.data = ''" + lf + $
    "        self.enable = True" + lf + $
    "    def write(self, s):" + lf + $
    "        if (self.enable): self.data += s" + lf)
  void = PYTHON_RUN("import sys; sys.stdout = idl_stdout()")

  foreach com, command do begin
    com1 = com.Split('\\\\n')
    for i=0,com1.length-1 do begin
      com1[i] = (com1[i].Split('\\n')).Join(lf)
    endfor
    com = com1.Join('\\n')
    if (STRLEN(com.Trim()) eq 0) then continue

    ; For commands ending with a semicolon, suppress the output.
    if (com.EndsWith(';')) then begin
      void = PYTHON_RUN("sys.stdout.enable = False")
      disabledOutput = !True
    endif

    void = PYTHON_RUN(com)

    ; Reenable output?
    if (KEYWORD_SET(disabledOutput)) then begin
      void = PYTHON_RUN("sys.stdout.enable = True")
      disabledOutput = !False
    endif

  endforeach

  ; Retrieve the Python output.
  void = PYTHON_RUN("__idloutput__ = sys.stdout.data")
  result = PYTHON_GETATTR(-1, '__idloutput__')

  ; Using linefeeds (\n=10b), break the output into a string array.
  result = STRTOK(result, lf, /EXTRACT, /PRESERVE_NULL)
  if (result[-1] eq '' && result.LENGTH gt 1) then begin
    result = result[0:-2]
  endif
  if (result.LENGTH eq 1) then result = result[0]
  return, result
end


;---------------------------------------------------------------------------
pro Python::Run, command

  compile_opt idl2, hidden, static
  ON_ERROR, 2

  if (N_PARAMS() eq 1) then begin
    result = Python.Run(command)
    if (ISA(result, /ARRAY) || STRLEN(result) gt 0) then begin
      PRINT, result, /IMPLIED
    endif
    return
  endif

  cmd = ''

  catch, iErr
  if (iErr ne 0) then begin
    MESSAGE, !error_state.msg, /INFO
  endif

  while (1) do begin
    READ, cmd, PROMPT='>>> '
    if (cmd.Trim() eq '' || $
      cmd.StartsWith('quit(',/FOLD) || $
      cmd.ToLower() eq 'quit' || cmd eq '^C') then break
    if (STRLEN(cmd) eq 0) then begin
      continue
    endif
    result = Python.Run(cmd)
    if (N_ELEMENTS(result) gt 1 || STRLEN(result) gt 0) then begin
      PRINT, result, /IMPLIED
    endif
  endwhile
end


;---------------------------------------------------------------------------
function Python::Wrap, value

  compile_opt idl2, hidden, static
  ON_ERROR, 2

  if (ISA(self)) then begin
    MESSAGE, /NONAME, 'Python::Wrap must be called as a static method.'
  endif

  if (~ISA(value) && ~ISA(value, /NULL)) then begin
    MESSAGE, /NONAME, 'Python: Undefined variable: ' + SCOPE_VARNAME(value, LEVEL=-1)
  endif

  Python.Load

  return, PYTHON_WRAP(ARG_PRESENT(value) ? value : TEMPORARY(value))
end


;----------------------------------------------------------------------------
function Python::_overloadFunction, arg1, arg2, arg3, _REF_EXTRA=ex

  compile_opt idl2, hidden
  ON_ERROR, 2

  ; Am I being called as a static method?
  ; The "-1" indicates the builtins module
  pyID = ISA(self) ? self.pyID : -1
  method = "__call__"
  nparams = N_PARAMS()

  if (ISA(ex)) then begin
    case (nparams) of
      0: result = PYTHON_CALLMETHOD(pyID, method, _EXTRA=ex)
      1: result = PYTHON_CALLMETHOD(pyID, method, arg1, _EXTRA=ex)
      2: result = PYTHON_CALLMETHOD(pyID, method, arg1, arg2, _EXTRA=ex)
      3: result = PYTHON_CALLMETHOD(pyID, method, arg1, arg2, arg3, _EXTRA=ex)
      else:
    endcase
  endif else begin
    case (nparams) of
      0: result = PYTHON_CALLMETHOD(pyID, method)
      1: result = PYTHON_CALLMETHOD(pyID, method, arg1)
      2: result = PYTHON_CALLMETHOD(pyID, method, arg1, arg2)
      3: result = PYTHON_CALLMETHOD(pyID, method, arg1, arg2, arg3)
      else:
    endcase
  endelse
  return, result
end


;----------------------------------------------------------------------------
function Python::_overloadMethod, methodIn, arg1, arg2, arg3, _REF_EXTRA=ex

  compile_opt idl2, hidden, static
  ON_ERROR, 2

  ; Do not include the method name
  nparams = N_PARAMS() - 1

  ; Am I being called as a static method?
  ; The "-1" indicates the builtins module
  pyID = ISA(self) ? self.pyID : -1

  if (pyID eq 0) then begin
    MESSAGE, /NONAME, 'Python: Python object is undefined.'
  endif

  method = STRLOWCASE(methodIn)

  ; Hack for the Python builtins help() function.  Normally this would
  ; return nothing. Instead, use pydoc to construct the help output
  ; and return that as the result.
  if (~ISA(self) && method eq 'help' && nparams eq 1) then begin
    pydoc = PYTHON_IMPORT('pydoc')
    pyID = pydoc.pyID
    method = 'render_doc'
  endif

  ; Hack for the Python builtins dir() function. With no arguments
  ; this was throwing an error about "frame does not exist".
  ; Instead, substitute __main__ for the frame to get a valid dir() result.
  if (~ISA(self) && method eq 'dir' && nparams eq 0) then begin
    arg1 = Python.Import('__main__')
    nparams++
  endif

  ; Find the matching method, ignoring case.
  method = Python._FindAttr(pyID, method, /METHOD)
  if (~ISA(method)) then begin
    MESSAGE, /NONAME, 'Python: Unknown method: "' + methodIn + '"'
  endif

  if (ISA(ex)) then begin
    case (nparams) of
      0: result = PYTHON_CALLMETHOD(pyID, method, _EXTRA=ex)
      1: result = PYTHON_CALLMETHOD(pyID, method, arg1, _EXTRA=ex)
      2: result = PYTHON_CALLMETHOD(pyID, method, arg1, arg2, _EXTRA=ex)
      3: result = PYTHON_CALLMETHOD(pyID, method, arg1, arg2, arg3, _EXTRA=ex)
      else:
    endcase
  endif else begin
    case (nparams) of
      0: result = PYTHON_CALLMETHOD(pyID, method)
      1: result = PYTHON_CALLMETHOD(pyID, method, arg1)
      2: result = PYTHON_CALLMETHOD(pyID, method, arg1, arg2)
      3: result = PYTHON_CALLMETHOD(pyID, method, arg1, arg2, arg3)
      else:
    endcase
  endelse

  ; Hack for the builtin help() function. See comment above.
  if (method eq 'render_doc' && ISA(result, /STRING, /SCALAR)) then begin
    ; Remove all of the fancy "backspace" bold formatting codes,
    ; and split the string up at the linefeeds.
    result = BYTE(result)
    backspace = result eq 8b
    if (~ARRAY_EQUAL(backspace, 0b)) then begin
      ; Delete the previous character.
      backspace += SHIFT(backspace,-1)
      result = STRING(result[WHERE(~backspace)])
    endif
    result = STRTOK(result, STRING(10b), /EXTRACT, /PRESERVE_NULL)
  endif

  return, result
end


;---------------------------------------------------------------------------
pro Python::_overloadBracketsLeftSide, arg, value, isRange, $
  i0, i1, i2, i3, i4, i5, i6, i7

  compile_opt idl2, hidden
  ON_ERROR, 2

  ; Return quietly if any subscripts are !NULL.
  if (ISA(i0, /NULL) || ISA(i1, /NULL) || ISA(i2, /NULL) || $
    ISA(i3, /NULL) || ISA(i4, /NULL) || ISA(i5, /NULL) || $
    ISA(i6, /NULL) || ISA(i7, /NULL)) then return

  if (N_ELEMENTS(isRange) gt 1) then begin
    MESSAGE, /NONAME, 'Python: Multiple array subscripts are not allowed.'
  endif

  self.GetProperty, CLASSNAME=pythonClass

  if (pythonClass eq 'ndarray') then begin
    count = (self._overloadSize())[0]

    ; handle [i:j:k]
    if (isRange[0]) then begin
      ; Adjust negative indices (also handles "*" indices.
      if (i0[0] lt 0 && (ABS(i0[0]) le count)) then i0[0] += count
      if (i0[1] lt 0 && (ABS(i0[1]) le count)) then i0[1] += count
      nelem = (i0[1] - i0[0])/i0[2] + 1
      if (nelem le 0) then begin
        MESSAGE, /NONAME, 'Python: Illegal subscript range.'
      endif
      i0 = LINDGEN(nelem)*i0[2] + i0[0]
    endif

    nval = N_ELEMENTS(value)
    if (nval gt 1 && nval ne N_ELEMENTS(i0)) then begin
      MESSAGE, /NONAME, $
        'Python: Array subscript must have same size as source expression.'
    endif
    ; For ndarray's we can just pass in arrays of indices and values
    ; and Python will take care of filling in the correct values.
    ; If there are multiple subscripts and a single value, the value will
    ; be replicated, which matches IDL's behavior.
    void = self.__setitem__(i0, value)
    return
  endif

  if (pythonClass eq 'list' || pythonClass eq 'tuple') then begin

    count = (self._overloadSize())[0]

    ; handle [i:j:k]
    if (isRange[0]) then begin
      ; Adjust negative indices (also handles "*" indices.
      if (i0[0] lt 0 && (ABS(i0[0]) le count)) then i0[0] += count
      if (i0[1] lt 0 && (ABS(i0[1]) le count)) then i0[1] += count
      nelem = (i0[1] - i0[0])/i0[2] + 1
      if (nelem le 0) then begin
        MESSAGE, /NONAME, 'Python: Illegal subscript range.'
      endif
      i0 = LINDGEN(nelem)*i0[2] + i0[0]
    endif

    ; For an array of indices, set each value.
    if (ISA(i0, /ARRAY) || ISA(i0, 'IDL_OBJECT')) then begin
      nval = N_ELEMENTS(value)
      if (nval gt 1 && nval ne N_ELEMENTS(i0)) then begin
        MESSAGE, /NONAME, $
          'Python: Array subscript must have same size as source expression.'
      endif
      foreach i, i0, index do begin
        val1 = (nval gt 1) ? value[index] : value
        void = self.__setitem__(i, val1)
      endforeach
    endif else begin
      ; For a scalar index, just set the value.
      void = self.__setitem__(i0, value)
    endelse

    return
  endif


  ; Duck typing to see if we behave like a dictionary
  if (PYTHON_HASATTR(self.pyID, 'keys')) then begin

    ; a[*] or a[0:*] or a[0:-1]
    if (isRange[0]) then begin
      if (i0[0] ne 0 || i0[1] ne -1 || i0[2] ne 1) then $
        MESSAGE, /NONAME, 'Python: Subscript range is not allowed for dict.'
      ; Retrieve all key values pairs
      i0 = self.keys()
    endif

    ; For an array of keys, set all of the keys to the value.
    if (ISA(i0, /ARRAY) || ISA(i0, 'IDL_OBJECT')) then begin
      nval = N_ELEMENTS(value)
      if (nval gt 1 && nval ne N_ELEMENTS(i0)) then begin
        MESSAGE, /NONAME, $
          'Python: Key and Value must have the same number of elements.'
      endif
      index = 0LL
      foreach key, i0 do begin
        val1 = (nval gt 1) ? value[index] : value
        void = self.__setitem__(key, val1)
        index++
      endforeach
    endif else begin
      ; For a scalar key, just set the value.
      void = self.__setitem__(i0, value)
    endelse

    return
  endif

  MESSAGE, /NONAME, $
    'Python: Unable to index object of type: "' + pythonClass + '"'
end


;---------------------------------------------------------------------------
function Python::_overloadBracketsRightSide, isRange, $
  i0, i1, i2, i3, i4, i5, i6, i7

  compile_opt idl2, hidden
  ON_ERROR, 2

  ; If any subscripts are !NULL, return !NULL.
  if (ISA(i0, /NULL) || ISA(i1, /NULL) || ISA(i2, /NULL) || $
    ISA(i3, /NULL) || ISA(i4, /NULL) || ISA(i5, /NULL) || $
    ISA(i6, /NULL) || ISA(i7, /NULL)) then return, !null

  if (N_ELEMENTS(isRange) gt 1) then begin
    MESSAGE, /NONAME, 'Python: Multiple array subscripts are not allowed.'
  endif


  self.GetProperty, CLASSNAME=pythonClass

  if (pythonClass eq 'ndarray') then begin
    count = (self._overloadSize())[0]

    ; handle [i:j:k]
    if (isRange[0]) then begin
      ; Adjust negative indices (also handles "*" indices.
      if (i0[0] lt 0 && (ABS(i0[0]) le count)) then i0[0] += count
      if (i0[1] lt 0 && (ABS(i0[1]) le count)) then i0[1] += count
      nelem = (i0[1] - i0[0])/i0[2] + 1
      if (nelem le 0) then begin
        MESSAGE, /NONAME, 'Python: Illegal subscript range.'
      endif
      i0 = LINDGEN(nelem)*i0[2] + i0[0]
    endif

    result = self.__getitem__(i0)
    return, result
  endif

  if (pythonClass eq 'list' || pythonClass eq 'tuple') then begin

    count = (self._overloadSize())[0]

    ; handle [i:j:k]
    if (isRange[0]) then begin
      ; Adjust negative indices (also handles "*" indices.
      if (i0[0] lt 0 && (ABS(i0[0]) le count)) then i0[0] += count
      if (i0[1] lt 0 && (ABS(i0[1]) le count)) then i0[1] += count
      nelem = (i0[1] - i0[0])/i0[2] + 1
      if (nelem le 0) then begin
        MESSAGE, /NONAME, 'Python: Illegal subscript range.'
      endif
      i0 = LINDGEN(nelem)*i0[2] + i0[0]
    endif

    ; For an array of indices, return an IDL LIST.
    if (ISA(i0, /ARRAY) || ISA(i0, 'IDL_OBJECT')) then begin
      result = LIST()
      foreach i, i0 do begin
        value = self.__getitem__(i)
        result.Add, value, /NO_COPY
      endforeach
    endif else begin
      ; For a scalar index, just return the value.
      result = self.__getitem__(i0)
    endelse

    return, result
  endif

  ; Duck typing to see if we behave like a dictionary
  if (PYTHON_HASATTR(self.pyID, 'keys')) then begin

    ; a[*] or a[0:*] or a[0:-1]
    if (isRange[0]) then begin
      if (i0[0] ne 0 || i0[1] ne -1 || i0[2] ne 1) then $
        MESSAGE, /NONAME, 'Python: Subscript range is not allowed for dict.'
      ; Retrieve all key values pairs
      i0 = self.keys()
    endif

    ; For an array of keys, return an IDL HASH.
    if (ISA(i0, /ARRAY) || ISA(i0, 'IDL_OBJECT')) then begin
      result = HASH()
      foreach key, i0 do begin
        value = self.__getitem__(key)
        result[key] = value
      endforeach
    endif else begin
      ; For a scalar key, just return the value.
      result = self.__getitem__(i0)
    endelse

    return, result
  endif

  MESSAGE, /NONAME, $
    'Python: Unable to index object of type: "' + pythonClass + '"'
  return, 0
end


;---------------------------------------------------------------------------
function Python::_overloadForeach, value, index

  compile_opt idl2, hidden
  ON_ERROR, 2

  hasIndex = ISA(index)

  CATCH, ierr
  if (ierr ne 0) then begin
    CATCH, /CANCEL
    MESSAGE, /RESET
    index = -1
    return, 0b
  endif

  ; If we don't have an index yet, see if we are a type with an index,
  ; or are we "iterable".
  if (~hasIndex) then begin
    pyClass = PYTHON_GETATTR(self.pyID, '__class__')
    pythonClass = PYTHON_GETATTR(pyClass.pyID, '__name__')
    hasIndex = (pythonClass eq 'ndarray' || pythonClass eq 'list' || $
      pythonClass eq 'tuple')
    if (hasIndex) then begin
      index = -1LL
    endif else begin
      index = PYTHON_CALLMETHOD(self.pyID, '__iter__')
    endelse
  endif

  CATCH, ierr
  if (ierr ne 0) then begin
    CATCH, /CANCEL
    MESSAGE, /RESET
    index = -1
    return, 0b
  endif

  if (ISA(index, /NUMBER)) then begin
    ; Just catch the error if we walk off the end.
    ; It's faster than testing the length.
    index++
    value = PYTHON_CALLMETHOD(self.pyID, '__getitem__', index)
  endif else begin
    ; Call the builtin next() so we are compatible with Python 2.x and 3.x.
    value = PYTHON_CALLMETHOD(-1, 'next', index)
  endelse

  return, 1b
end


;---------------------------------------------------------------------------
function Python::_overloadHelp, varname

  compile_opt idl2, hidden
  ON_ERROR, 2

  ; Subtract 1 from the ref count because the user doesn't care that
  ; we are inside of the Help method call.
  refcount = HEAP_REFCOUNT(self) - 1

  myname = STRING(varname, FORMAT='(A-' + STRTRIM(STRLEN(varname) > 15,2) + ',TR1)')

  result = myname + OBJ_CLASS(self) + '  <ID=' + $
    STRTRIM(OBJ_VALID(self,/GET_HEAP_ID),2) + $
    '>'

  if (PYTHON_HASATTR(self.pyID, '__class__')) then begin
    class = PYTHON_GETATTR(self.pyID, '__class__')
    class = STRING(class, /PRINT)
    if (ISA(class, /STRING)) then begin
      result += '  ' + class
    endif
  endif

  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadImpliedPrint, varname

  compile_opt idl2, hidden
  ON_ERROR, 2

  ; The "-1" indicates the builtins module
  result = PYTHON_CALLMETHOD(-1, 'repr', self)
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadPrint

  compile_opt idl2, hidden
  ON_ERROR, 2

  ; The "-1" indicates the builtins module
  result = PYTHON_CALLMETHOD(-1, 'str', self)
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadSize

  compile_opt idl2, hidden
  ON_ERROR, 2
  
  self.GetProperty, CLASSNAME=pythonClass

  if (pythonClass eq 'ndarray') then begin
    self.GetProperty, SHAPE=shape
    result = REVERSE(shape.ToArray())
  endif else begin
    CATCH, iErr
    if (iErr ne 0) then begin
      CATCH, /CANCEL
      MESSAGE, /RESET
      result = 1
    endif else begin
      ; The "-1" indicates the builtins module
      result = PYTHON_CALLMETHOD(-1, 'len', self)
      if (result gt 1) then result = [result]
    endelse
  endelse
  return, result
end


;---------------------------------------------------------------------------
function Python::_callBinaryOperator, arg1, arg2, operator

  compile_opt idl2, hidden
  ON_ERROR, 2

  arg1a = ISA(arg1, 'PYTHON') ? arg1 : Python.Wrap(arg1)
  result = PYTHON_CALLMETHOD(arg1a.pyID, operator, arg2)
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadAsterisk, arg1, arg2

  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__mul__')
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadCaret, arg1, arg2

  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__pow__')
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadMinus, arg1, arg2

  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__sub__')
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadMinusUnary

  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self.__neg__()
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadMod, arg1, arg2

  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__mod__')
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadPlus, arg1, arg2

  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__add__')
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadSlash, arg1, arg2

  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__truediv__')
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadIsTrue

  compile_opt idl2, hidden
  ON_ERROR, 2

  result = Python.bool(self)
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadAND, arg1, arg2

  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__and__')
  return, result
end


;----------------------------------------------------------------------------
function Python::_overloadEQ, arg1, arg2
  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__eq__')
  return, result
end


;----------------------------------------------------------------------------
function Python::_overloadGE, arg1, arg2
  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__ge__')
  return, result
end


;----------------------------------------------------------------------------
function Python::_overloadGT, arg1, arg2
  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__gt__')
  return, result
end


;----------------------------------------------------------------------------
function Python::_overloadLE, arg1, arg2
  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__le__')
  return, result
end


;----------------------------------------------------------------------------
function Python::_overloadLT, arg1, arg2
  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__lt__')
  return, result
end


;----------------------------------------------------------------------------
function Python::_overloadNE, arg1, arg2
  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__ne__')
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadNOT

  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self.__invert__()
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadOR, arg1, arg2

  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__or__')
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadTilde

  compile_opt idl2, hidden
  ON_ERROR, 2

  result = ~self->_overloadIsTrue()
  return, result
end


;---------------------------------------------------------------------------
function Python::_overloadXOR, arg1, arg2

  compile_opt idl2, hidden
  ON_ERROR, 2

  result = self._callBinaryOperator(arg1, arg2, '__xor__')
  return, result
end


;---------------------------------------------------------------------------
pro Python__define

  compile_opt idl2, hidden

  void = { Python, $
    inherits IDL_Object, $
    pyID: 0LL, $
    pData: PTR_NEW() }

end


