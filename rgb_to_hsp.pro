function image_join_channels, R, G, B
  dimensions = size(R, /DIMENSIONS)
  x_size = dimensions[0]
  y_size = dimensions[1]
  rgb = make_array(3, x_size, y_size)

  rgb[0, *, *] = reform(R, 1, x_size, y_size)
  rgb[1, *, *] = reform(G, 1, x_size, y_size)
  rgb[2, *, *] = reform(B, 1, x_size, y_size)

  return, rgb
end

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

function RGB_to_HSP, rgb

  R = reform(rgb[0, *, *])
  G = reform(rgb[1, *, *])
  B = reform(rgb[2, *, *])

  ; Calculate the Perceived brightness:
  P = SQRT(0.299 * (R^2.2) + 0.587 * (G^2.2) + 0.114  * (B^2.2))
  ; R*R is in place multiplication, element by element
  
  ; HUE
  ; If the min and max value are the same, it means that there is no hue.
  ; 
  ; If Red is max, then Hue = (G-B)/(max-min)
  ; If Green is max, then Hue = 2.0 + (B-R)/(max-min)
  ; If Blue is max, then Hue = 4.0 + (R-G)/(max-min)
  ;
  ; The Hue value you get needs to be multiplied by 60 to convert it to degrees on the color circle
  ; If Hue becomes negative you need to add 360 to, because a circle has 360 degrees.
  
  ; SATURATION
  ; If the min and max value are the same, it means that there is no saturation.
  ; 
  ; If Luminance is smaller then 0.5, then Saturation = (max-min)/(max+min)
  ; If Luminance is bigger then 0.5. then Saturation = ( max-min)/(2.0-max-min)
  
  ; Calculate the Hue and Saturation
  if  (R eq G) and (R eq B) then begin
    H=R*0.0
    S=R*0.0
    return, image_join_channels(H,S,P)
  endif
  
  if  (R ge G) and (R ge B) then begin  ;  R is largest
      if  (B ge G) then begin
          H=6./6.-1./6.*(B-G)/(R-G); 
          S=1.-G/R; 
      endif else begin
          H=0./6.+1./6.*(G-B)/(R-B); 
          S=1.-B/R; 
      endelse      
      
  endif else begin  
    if (G ge R) and (G ge B) then begin ;  G is largest
        if (R ge B) then begin
            H=2./6.-1./6.*(R-B)/(G-B); 
            S=1.-B/G; 
        endif else begin
          H=2./6.+1./6.*(B-R)/(G-R); 
          S=1.-R/G; 
        endelse
        
    endif else begin  ;  B is largest
        if (G ge R) then begin
            H=4./6.-1./6.*(G-R)/(B-R); 
            S=1.-R/B; 
        endif else begin
            H=4./6.+1./6.*(R-G)/(B-G); 
            S=1.-G/B; 
        endelse
    endelse  
  endelse

  return, image_join_channels(H,S,P)
  
end

function HSP_to_RGB, hsp
    return, hsp
end

; Function returns a list of those indices where values at
; A are GE than B and values at B are GE than C
function indices_descending_layer_values, A, B, C
    ; return, WHERE((A ge B) and (B ge C))
    return, WHERE(((A gt B) and (B ge C)) or ((A ge B) and (B gt C)))
end

function RGB_to_HSP_Rex, rgb

  R = reform(rgb[0, *, *])
  G = reform(rgb[1, *, *])
  B = reform(rgb[2, *, *])

  ; Calculate the Perceived brightness:
  P = SQRT(R*R*0.299 + G*G*0.587 + B*B*0.114)
  ; R*R is in place multiplication, element by element
  H = R*0.0
  S = R*0.0
  
  r_b_g = indices_descending_layer_values(R, B, G)
  H[r_b_g] = 6.0/6.0-1.0/6.0*(B[r_b_g]-G[r_b_g])/(R[r_b_g]-G[r_b_g])
  S[r_b_g] = 1.0-G[r_b_g]/R[r_b_g]
  
  r_g_b = indices_descending_layer_values(R, G, B)
  H[r_g_b] = 0.0/6.0 + 1.0/6.0*(G[r_g_b]-B[r_g_b])/(R[r_g_b]-B[r_g_b])
  S[r_g_b] = 1.0-B[r_g_b]/R[r_g_b];
  
  g_r_b = indices_descending_layer_values(G, R, B)
  H[g_r_b] = 2.0/6.0-1.0/6.0*(R[g_r_b]-B[g_r_b])/(G[g_r_b]-B[g_r_b])
  S[g_r_b] = 1.0-B[g_r_b]/G[g_r_b];
  
  g_b_r = indices_descending_layer_values(G, B, R)
  H[g_b_r] = 2.0/6.0+1.0/6.0*(B[g_b_r]-R[g_b_r])/(G[g_b_r]-R[g_b_r])
  S[g_b_r] = 1.0-R[g_b_r]/G[g_b_r];
  
  b_g_r = indices_descending_layer_values(B, G, R)
  H[b_g_r] = 4.0/6.0-1./6.*(G[b_g_r]-R[b_g_r])/(B[b_g_r]-R[b_g_r])
  S[b_g_r] = 1.0-R[b_g_r]/B[b_g_r]
  
  b_r_g = indices_descending_layer_values(B, R, G)
  H[b_r_g] = 4.0/6.0+1.0/6.0*(R[b_r_g]-G[b_r_g])/(B[b_r_g]-G[b_r_g])
  S[b_r_g] = 1.0 -G[b_r_g]/B[b_r_g]
    
  gray_scale = WHERE((R eq G) and (G eq B))
  H[gray_scale] = R[gray_scale]*0.0
  S[gray_scale] = R[gray_scale]*0.0

;  ; Calculate the Hue and Saturation
;  if  array_equal(R, G) and array_equal(R, B) then begin  ; R = G = B
;      H=R*0.0
;      S=R*0.0
;      return, image_join_channels(H,S,P)
;  endif
  
;  if  (R ge G) and (R ge B) then begin  ;  R is largest
;      if  (B ge G) then begin
;          H=6.0/6.0-1.0/6.0*(B-G)/(R-G); 
;          S=1.0-G/R; 
;      endif else begin
;          H=0.0/6.0+1.0/6.0*(G-B)/(R-B); 
;          S=1.0-B/R; 
;      endelse      
      
;  endif else begin  
;    if (G ge R) and (G ge B) then begin ;  G is largest
;        if (R ge B) then begin
;            H=2.0/6.0-1.0/6.0*(R-B)/(G-B); 
;            S=1.0-B/G; 
;        endif else begin
;          H=2.0/6.0+1.0/6.0*(B-R)/(G-R); 
;          S=1.0-R/G; 
;        endelse
;        
;    endif else begin   ;  B is largest
;        if (G ge R) then begin
;            H=4.0/6.0-1./6.*(G-R)/(B-R); 
;            S=1.0-R/B; 
;        endif else begin
;            H=4.0/6.0+1.0/6.0*(R-G)/(B-G); 
;            S=1.0-G/B;
;        endelse
;    endelse  
;  endelse

   hsp = image_join_channels(H,S,P)
   return, hsp
end

function HSP_to_RGB_Rex, hsp

  Pr = 0.299
  Pg = 0.587
  Pb = 0.114
  
  H = reform(hsp[0, *, *])
  S = reform(hsp[1, *, *])
  P = reform(hsp[2, *, *])
  
  dimensions = size(H, /DIMENSIONS)
  x_size = dimensions[0]
  y_size = dimensions[1]

  minOverMax = make_array(x_size, y_size)
  part = make_array(x_size, y_size) 
  R = make_array(x_size, y_size)
  G = make_array(x_size, y_size)
  B = make_array(x_size, y_size)
  
  minOverMax = 1.0-S

  pos_idx = WHERE(minOverMax gt 0.0)
    
      idx = WHERE(H[pos_idx] lt 1.0/6.0)  ; R>G>B
      H[idx] = 6.0*(H[idx] - 0./6.)
      part[idx] = 1.0 + H[idx]*(1.0/minOverMax[idx]-1.0)
      B[idx] = P[idx]/sqrt(Pr/minOverMax[idx]/minOverMax[idx] + Pg * part[idx] * part[idx] + Pb)
      R[idx] = B[idx]/minOverMax[idx]
      G[idx] = B[idx] +H[idx]*(R[idx] - B[idx])
    
      idx = WHERE(H[pos_idx] ge 1.0/6.0 and H[pos_idx] gt 2.0/6.0) ;  G>R>B
      H[idx] = 6.*(-H[idx] + 2./6.)
      part[idx] = 1. + H[idx]*(1.0/minOverMax[idx] - 1.0)
      B[idx] = P[idx]/sqrt(Pg/minOverMax[idx]/minOverMax[idx] + Pr * part[idx] * part[idx] + Pb)
      G[idx] = B[idx]/minOverMax[idx] 
      R[idx] = B[idx] + H[idx]*(G[idx] - B[idx])
      
      idx = WHERE(H[pos_idx] ge 2.0/6.0 and H[pos_idx] lt 3.0/6.0) ;  G>B>R
      H[idx] = 6.0 *( H[idx] - 2.0/6.0)
      part[idx] = 1.0 + H[idx] * (1.0/minOverMax[idx]-1.0);
      R[idx] = P[idx]/sqrt(Pg/minOverMax[idx]/minOverMax[idx] + Pb * part[idx] * part[idx] + Pr)
      G[idx] = R[idx]/minOverMax[idx]
      B[idx] = R[idx] + H[idx]*(G[idx] - R[idx])
         
      idx = WHERE(H[pos_idx] ge 3.0/6.0 and H[pos_idx] lt 4.0/6.0)  ;  B>G>R
      H[idx] = 6.0*(-H[idx]+4.0/6.0)
      part[idx] = 1.0 + H[idx]*(1.0/minOverMax[idx]-1.0)
      R[idx] = P[idx]/sqrt(Pb/minOverMax[idx]/minOverMax[idx] + Pg * part[idx] * part[idx] + Pr)
      B[idx] = R[idx]/minOverMax[idx]
      G[idx] = R[idx] + H[idx]*(B[idx] - R[idx])
      
      idx = WHERE(H[pos_idx] ge 4.0/6.0 and H[pos_idx] lt 5.0/6.0) ;  B>R>G
      H[idx] = 6.0*( H[idx] -4.0/6.0) 
      part[idx] = 1.0+H*(1.0/minOverMax[idx]-1.0)
      G[idx] = P[idx]/sqrt(Pb/minOverMax[idx]/minOverMax[idx] + Pr * part[idx] * part[idx] + Pg)
      B[idx] = G[idx]/minOverMax[idx]
      R[idx] = G[idx] + H[idx]*(B[idx] - G[idx])
              
      idx = WHERE(H[pos_idx] ge 5.0/6.0) ;  R>B>G
      H[idx] = 6.0*(-H[idx] + 6.0/6.0)
      part[idx] = 1.0 + H[idx]*(1.0/minOverMax[idx] -1.0)
      G[idx] = P[idx]/sqrt(Pr/minOverMax[idx]/minOverMax[idx] + Pb * part[idx] * part[idx] + Pg)
      R[idx] = G[idx]/minOverMax[idx]
      B[idx] = G[idx] + H[idx]*(R[idx] - G[idx])
    
    
  neg_idx = WHERE(minOverMax gt 0.0)  

       idx = WHERE(H[neg_idx] lt 1.0/6.0) ;  R>G>B
       H[idx] = 6.0*(H[idx] - 0.0/6.0)
       R[idx] = sqrt(P[idx]*P[idx]/(Pr+Pg*H[idx]*H[idx]))
       G[idx] = R[idx]*H[idx]
       B[idx] = H[idx] * 0.0
  
       idx = WHERE(H[neg_idx] ge 1.0/6.0 and H[neg_idx] lt 2.0/6.0) ;  G>R>B        
       H[idx] = 6.0*(-H[idx] + 2.0/6.0)
       G[idx] = sqrt(P[idx]*P[idx]/(Pg+Pr*H[idx]*H[idx]))
       R[idx] = G[idx]*H[idx]
       B[idx] = H[idx] * 0.0

       idx = WHERE(H[neg_idx] ge 2.0/6.0 and H[neg_idx] lt 3.0/6.0) ;  G>B>R
       H[idx] = 6.0*(H[idx] - 2.0/6.0)
       G[idx] = sqrt(P[idx]*P[idx]/(Pg+Pb*H*H))
       B[idx] = G[idx]*H[idx]
       R[idx] = H[idx] * 0.0
        
       idx = WHERE(H[neg_idx] ge 3.0/6.0 and H[neg_idx] lt 4.0/6.0) ;  B>G>R
       H[idx] = 6.0*(-H[idx] + 4.0/6.0)
       B[idx] = sqrt(P[idx]*P[idx]/(Pb+Pg*H[idx]*H[idx]))
       G[idx] = B[idx]*H[idx]
       R[idx] = H[idx] * 0.0;
     
       idx = WHERE(H[neg_idx] gt 4.0/6.0 and H[neg_idx] lt 5.0/6.0) ;  B>R>G
       H[idx] = 6.*( H[idx] - 4.0/6.0)
       B[idx] = sqrt(P[idx]*P[idx]/(Pb+Pr*H[idx]*H[idx]))
       R[idx] = B[idx]*H[idx]
       G[idx] = H[idx] * 0.0
       
       idx = WHERE(H[neg_idx] gt 5.0/6.0) ;  R>B>G
       H[idx] = 6.0*(-H[idx] + 6.0/6.0)
       R[idx] = sqrt(P[idx]*P[idx]/(Pr+Pb*H[idx]*H[idx]))
       B[idx] = R[idx]*H[idx]
       G[idx] = H[idx]*0.0;
       
  
  
  rgb = image_join_channels(R,G,B)
  return, rgb
end

