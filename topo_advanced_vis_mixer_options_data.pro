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
  norm_droplist[0] = 'Value'
  norm_droplist[1] = 'Perc'

  return, norm_droplist
end

function gen_vis_norm_default
  ; Preferred normalizations for each visualization
  vis_norm = hash()
  vis_norm += hash('Analytical hillshading','Value')
  vis_norm += hash('Hillshading from multiple directions','Value')
  vis_norm += hash('PCA of hillshading','Perc')
  vis_norm += hash('Slope gradient','Value')
  vis_norm += hash('Simple local relief model','Perc')
  vis_norm += hash('Sky-View Factor','Value')
  vis_norm += hash('Anisotropic Sky-View Factor','Perc')
  vis_norm += hash('Openness - Positive','Value')
  vis_norm += hash('Openness - Negative','Value')
  vis_norm += hash('Sky illumination','Perc')
  vis_norm += hash('Local dominance','Value')
  return, vis_norm
end

function noise_removal_levels
  svf_rn_droplist = strarr(3)
  svf_rn_droplist[0] = 'low'
  svf_rn_droplist[1] = 'medium'
  svf_rn_droplist[2] = 'high'
  return, svf_rn_droplist
end 

function gen_terrain_types
  terrains = ['general', 'flat', 'steep']
  return, terrains
end

function flat_terrain_settings
  flat_ts = hash()
  flat_ts += hash('hs_sun_elevation',15)
  flat_ts += hash('mhs_sun_elevation',15)
  flat_ts += hash('slrm_radius',10)
  flat_ts += hash('svf_noise','high')
  flat_ts += hash('svf_radius',20)
  flat_ts += hash('ld_radius_min',10)
  flat_ts += hash('ld_radius_max',20)
  flat_ts += hash('slope_min',0.0)
  flat_ts += hash('slope_max',15.0)
  flat_ts += hash('svf_min',0.9)
  flat_ts += hash('svf_max',1.0)
  flat_ts += hash('pos_open_min',85.0)
  flat_ts += hash('pos_open_max',93.0)
  flat_ts += hash('neg_open_min',75.0)
  flat_ts += hash('neg_open_max',95.0)
  flat_ts += hash('ld_min',0.5)
  flat_ts += hash('ld_max',3.0)
;  steep_ts += hash('pca_min',1.0)
;  steep_ts += hash('pca_max',1.0)
  return, flat_ts
end

function general_terrain_settings
  general_ts = hash()
  general_ts += hash('hs_sun_elevation',35)
  general_ts += hash('mhs_sun_elevation',35)
  general_ts += hash('slrm_radius',20)
  general_ts += hash('svf_noise','none')
  general_ts += hash('svf_radius',10)
  general_ts += hash('ld_radius_min',10)
  general_ts += hash('ld_radius_max',20)
  general_ts += hash('slope_min',0.0)
  general_ts += hash('slope_max',50.0)
  general_ts += hash('svf_min',0.7)
  general_ts += hash('svf_max',1.0)
  general_ts += hash('pos_open_min',68.0)
  general_ts += hash('pos_open_max',93.0)
  general_ts += hash('neg_open_min',60.0)
  general_ts += hash('neg_open_max',95.0)
  general_ts += hash('ld_min',0.5)
  general_ts += hash('ld_max',1.8)
;  steep_ts += hash('pca_min',1.0)
;  steep_ts += hash('pca_max',1.0)
  return, general_ts
end

function steep_terrain_settings
  steep_ts = hash()
  steep_ts += hash('hs_sun_elevation',55)
  steep_ts += hash('mhs_sun_elevation',45)
  steep_ts += hash('slrm_radius',50)
  steep_ts += hash('svf_noise','none')
  steep_ts += hash('svf_radius',10)
  steep_ts += hash('ld_radius_min',10)
  steep_ts += hash('ld_radius_max',10)  
  steep_ts += hash('slope_min',0.0)
  steep_ts += hash('slope_max',60.0)
  steep_ts += hash('svf_min',0.55)
  steep_ts += hash('svf_max',1.0)
  steep_ts += hash('pos_open_min',55.0)
  steep_ts += hash('pos_open_max',95.0)
  steep_ts += hash('neg_open_min',45.0)
  steep_ts += hash('neg_open_max',95.0)
  steep_ts += hash('ld_min',0.55)
  steep_ts += hash('ld_max',0.95)
;  steep_ts += hash('pca_min',1.0)
;  steep_ts += hash('pca_max',1.0)
  return, steep_ts
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

pro topo_advanced_vis_mixer_options_data
  ;topo_advanced_vis_mixer_options_data
end