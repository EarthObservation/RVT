function numeric_to_luminosity, numeric_value
  min_value = min(numeric)
  max_value = max(numeric)

  val = float(numeric_value - min_value)
  interval = float(max_value - min_value)
  scaled = val/interval

  ;scaled = float(numeric_value - min_value) / float(max_value - min_value)
  luminosity = fix(scaled * 100)
  return luminosity
end