pro test_luminosity
  file_names = ["C:\Users\MSomrak\Documents\_Writting papers\RVT paper\images\Chactun_manjse_vizualizacije_1_5_stop_grayscale.tif", "C:\Users\MSomrak\Documents\_Writting papers\RVT paper\images\Chactun_manjse_vizualizacije_2_HS_RGB.tif"]
  active = read_image_geotiff(file_names[0], 1)
  background = read_image_geotiff(file_names[1], 1)
    
  active = RGB_to_float(active)
  background = RGB_to_float(background)
  blended_image = blend_luminosity(active, background); blend_normal(active, background) ;blend_multi_dim_images('Overlay', active, background)  ;blend_luminosity(active, background)
  
  out_file = "C:\Users\MSomrak\Documents\_Writting papers\RVT paper\images\Chactun_manjse_vizualizacije_Luminosity_RVT.tif"  ; Luminosity_RVT.tif"
  Write_tiff, out_file, blended_image, compression=1, geotiff=geotiff, /float
end