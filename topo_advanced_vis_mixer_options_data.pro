pro topo_advanced_vis_mixer_options_data
;topo_advanced_vis_mixer_options_data
end

function gen_vis_droplist
  ; Visualization methods
  vis_droplist = strarr(12)
  vis_droplist[0] = 'Analytical hillshading'
  vis_droplist[1] = 'Hillshading from multiple directions'
  vis_droplist[2] = 'PCA of hillshading'
  vis_droplist[3] = 'Slope gradient'
  vis_droplist[4] = 'Simple local relief model'
  vis_droplist[5] = 'Sky-View Factor'
  vis_droplist[6] = 'Anisotropic Sky-View Factor'
  vis_droplist[7] = 'Openness - Positive'
  vis_droplist[8] = 'Openness - Negative'
  vis_droplist[9] = 'Sky illumination'
  vis_droplist[10] = 'Local dominance'
  vis_droplist[11] = '<none>'
  vis_droplist[12] = '<input custom file>'

  return, vis_droplist
end

function gen_blend_droplist
  ; Blending modes
  blend_droplist = strarr(5)
  blend_droplist[0] = 'Normal'
  blend_droplist[1] = 'Multiply'
  blend_droplist[2] = 'Overlay'
  blend_droplist[3] = 'Luminosity'
  blend_droplist[4] = 'Screen'

  return, blend_droplist
end

function gen_norm_droplist
  ; Normalization
  norm_droplist = strarr(2)
  norm_droplist[0] = 'Lin'
  norm_droplist[1] = 'Perc'

  return, norm_droplist
end

function gen_vis_norm_default
  ; Preferred normalizations for each visualization
  vis_norm = hash()
  vis_norm += hash('Analytical hillshading','Lin')
  vis_norm += hash('Hillshading from multiple directions','Lin')
  vis_norm += hash('PCA of hillshading','Perc')
  vis_norm += hash('Slope gradient','Lin')
  vis_norm += hash('Simple local relief model','Perc')
  vis_norm += hash('Sky-View Factor','Lin')
  vis_norm += hash('Anisotropic Sky-View Factor','Perc')
  vis_norm += hash('Openness - Positive','Lin')
  vis_norm += hash('Openness - Negative','Lin')
  vis_norm += hash('Sky illumination','Perc')
  vis_norm += hash('Local dominance','Lin')

  return, vis_norm
end

;-------------------------------------------------------
; Functions to retrieve defaults for eah visualization:
; - normalizatinon
; - min (using default normalization)
; - max (using default normalization)
;-------------------------------------------------------

function get_norm_default, visualization, p_wdgt_state
  return, (*p_wdgt_state).hash_vis_norm_default[visualization]
end

function get_min_default, visualization, p_wdgt_state
  find_min = (*p_wdgt_state).vis_min_default
  return, find_min[visualization]
end

function get_max_default, visualization, p_wdgt_state
  find_max = (*p_wdgt_state).vis_max_default
  return, find_max[visualization]
end


;-------------------------------------------------------
; Get hash of strings for indexed options &
; hash of indices for string values of options
;-------------------------------------------------------

function gen_hash_strings, droplist
  indexes = indgen(droplist.LENGTH)
  hash_map = hash(droplist, indexes)
  return, hash_map
end

function gen_hash_indexes, droplist
  indexes = indgen(droplist.LENGTH)
  hash_map = hash(indexes, droplist)
  return, hash_map
end

;-------------------------------------------------------
; Min and Max limit for normalization?
;-------------------------------------------------------

function set_vis_max_limit, vis_droplist, max_limit
  limit = replicate(float(max_limit),vis_droplist.LENGTH)
  find_max = hash(vis_droplist, limit)
  return, find_max
end

function set_vis_min_limit, vis_droplist, min_limit
  limit = replicate(float(min_limit),vis_droplist.LENGTH)
  find_min = hash(vis_droplist, limit)
  return, find_min
end

function get_min_limit, visualization, p_wdgt_state
  find_min = (*p_wdgt_state).vis_min_limit
  return, find_min[visualization]
end

function get_max_limit, visualization, p_wdgt_state
  find_max = (*p_wdgt_state).vis_max_limit
  return, find_max[visualization]
end