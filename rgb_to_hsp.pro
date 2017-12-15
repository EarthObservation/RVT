;function make_hsp, H, S, P
;  dimensions = size(H, /DIMENSIONS)
;  x_size = dim[0]
;  y_size = dim[1]
;  hsp = make_array(3, x_size, y_size)
;
;  hsp[0, *, *] = reform(H, 1, x_size, y_size)
;  hsp[1, *, *] = reform(S, 1, x_size, y_size)
;  hsp[2, *, *] = reform(P, 1, x_size, y_size)
;  
;  return, hsp
;end

;function image_join_channels, R, G, B
;  dimensions = size(R, /DIMENSIONS)
;  x_size = dim[0]
;  y_size = dim[1]
;  rgb = make_array(3, x_size, y_size)
;
;  rgb[0, *, *] = reform(R, 1, x_size, y_size)
;  rgb[1, *, *] = reform(G, 1, x_size, y_size)
;  rgb[2, *, *] = reform(B, 1, x_size, y_size)
;
;  return, rgb
;end

;; Gama correction, decoding
;function sRGB_to_RGB, sRGB
;
;  R = reform(sRGB[0, *, *])
;  G = reform(sRGB[1, *, *])
;  B = reform(sRGB[2, *, *])
;
;  R = R^2.2
;  G = G^2.2
;  B = B^2.2
;  
;  return, image_join_channels(R, G, B)
;
;end
;
;; Gamma correction, encoding
;function RGB_to_sRGB, linRGB
;
;  R = reform(linRGB[0, *, *])
;  G = reform(linRGB[1, *, *])
;  B = reform(linRGB[2, *, *])
;
;  R = R^(1.0/2.2)
;  G = G^(1.0/2.2)
;  B = B^(1.0/2.2)
;  
;  return, image_join_channels(R, G, B)
;
;end

;function RGB_to_HSP, rgb
;
;  R = reform(rgb[0, *, *])
;  G = reform(rgb[1, *, *])
;  B = reform(rgb[2, *, *])
;
;  ; Calculate the Perceived brightness:
;  P = SQRT(0.299 * (R^2.2) + 0.587 * (G^2.2) + 0.114  * (B^2.2))
;  ; R*R is in place multiplication, element by element
;  
;  ; HUE
;  ; If the min and max value are the same, it means that there is no hue.
;  ; 
;  ; If Red is max, then Hue = (G-B)/(max-min)
;  ; If Green is max, then Hue = 2.0 + (B-R)/(max-min)
;  ; If Blue is max, then Hue = 4.0 + (R-G)/(max-min)
;  ;
;  ; The Hue value you get needs to be multiplied by 60 to convert it to degrees on the color circle
;  ; If Hue becomes negative you need to add 360 to, because a circle has 360 degrees.
;  
;  ; SATURATION
;  ; If the min and max value are the same, it means that there is no saturation.
;  ; 
;  ; If Luminance is smaller then 0.5, then Saturation = (max-min)/(max+min)
;  ; If Luminance is bigger then 0.5. then Saturation = ( max-min)/(2.0-max-min)
;  
;  ; Calculate the Hue and Saturation
;  if  (R eq G) and (R eq B) then
;    H=R*0.0
;    S=R*0.0
;    return, image_join_channels(H,S,P)
;  endif
;  
;  if  (R ge G) and (R ge B) then   ;  R is largest
;      if  (B ge G) then
;          H=6./6.-1./6.*(B-G)/(R-G); 
;          S=1.-G/R; 
;      endif else then
;          H=0./6.+1./6.*(G-B)/(R-B); 
;          S=1.-B/R; 
;      endelse      
;      
;  endif else then  
;    if (G ge R) and (G ge B) then  ;  G is largest
;        if (R ge B) then
;            H=2./6.-1./6.*(R-B)/(G-B); 
;            S=1.-B/G; 
;        endif else then
;          H=2./6.+1./6.*(B-R)/(G-R); 
;          S=1.-R/G; 
;        endelse
;        
;    endif else then   ;  B is largest
;        if (G ge R) then
;            H=4./6.-1./6.*(G-R)/(B-R); 
;            S=1.-R/B; 
;        endif else then
;            H=4./6.+1./6.*(R-G)/(B-G); 
;            S=1.-G/B; 
;        endelse
;    endelse  
;  endelse
;
;  return, image_join_channels(H,S,P)
;  
;end
;
;function HSP_to_RGB, hsp
;    return, hsp
;end
;
;function RGB_to_HSP_Rex, rgb
;
;  R = reform(rgb[0, *, *])
;  G = reform(rgb[1, *, *])
;  B = reform(rgb[2, *, *])
;
;  ; Calculate the Perceived brightness:
;  P = SQRT(R*R*0.299 + G*G*0.587 + B*B*0.114)
;  ; R*R is in place multiplication, element by element
;
;  ; Calculate the Hue and Saturation
;  if  (R eq G) and (R eq B) then
;      H=R*0.
;      S=R*0. 
;      return, image_join_channels(H,S,P)
;  endif
;  
;  if  (R ge G) and (R ge B) then   ;  R is largest
;      if  (B ge G) then
;          H=6./6.-1./6.*(B-G)/(R-G); 
;          S=1.-G/R; 
;      endif else then
;          H=0./6.+1./6.*(G-B)/(R-B); 
;          S=1.-B/R; 
;      endelse      
;      
;  endif else then  
;    if (G ge R) and (G ge B) then  ;  G is largest
;        if (R ge B) then
;            H=2./6.-1./6.*(R-B)/(G-B); 
;            S=1.-B/G; 
;        endif else then
;          H=2./6.+1./6.*(B-R)/(G-R); 
;          S=1.-R/G; 
;        endelse
;        
;    endif else then   ;  B is largest
;        if (G ge R) then
;            H=4./6.-1./6.*(G-R)/(B-R); 
;            S=1.-R/B; 
;        endif else then
;            H=4./6.+1./6.*(R-G)/(B-G); 
;            S=1.-G/B; 
;        endelse
;    endelse  
;  endelse
;
;  return, image_join_channels(H,S,P)
;  
;end
;
;function HSP_to_RGB_Rex, hsp
;
;
;
;
;  return, hsp
;end

