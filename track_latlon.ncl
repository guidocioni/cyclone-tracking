load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

begin

; Open model level output file

; File = addfile( "./control/complete_remap.nc","r")
; Filetopo = addfile( "./topo_default.nc","r")
 File = addfile( "./complete_remap.nc","r")
 Filetopo = addfile( "../data_sicilia/extpar_guido_met_4880m.nc","r")
 
 time= File->time
 gust=File->gust10
 mslp=File->pres_sfc
 mslp=mslp/100
 topo=Filetopo->topography_c
 u=File->u
 v=File->v

; mask over land points 

 mslp=mask(mslp, topo.ge.1 , False)

; create plot

 ResC = True
; ResC@mpFillOn     = False
ResC@gsnDraw=False
ResC@gsnFrame = False
 ResC@mpLimitMode = "LatLon"
 ResC@mpMaxLonF    = 17                      ; specify the plot domain
 ResC@mpMinLonF    = 11                      ;                         
 ResC@mpMinLatF    = 34                     ;
 ResC@mpMaxLatF    = 39                     ;
 ResC@mpDataBaseVersion  = "HighRes" 
 ResC@gsnAddCyclic = False

 ResC@gsnMaximize   = True         ; Maximize plot in frame. 
 
 lres= True
 lres@gsLineColor="blue"
 lres@gsLineThicknessF = 2.0

 mres=True
 mres@gsMarkerIndex = 16
 mres@gsMarkerSizeF = 0.005

 ;ResC@gsnCenterString= "track"
  
 ilat=new(dimsizes(time), integer) 
 ilon=new(dimsizes(time), integer) 
 lat_min=new(dimsizes(time), double)
 lon_min=new(dimsizes(time), double)
 mslp_min=new(dimsizes(time), double)
 gust_max=new(dimsizes(time), double)
 copy_VarAtts(gust,gust_max)

start=0

;radius of lon-lat to search max. gust
;depends only on the resolution
lon_radius=0.05
lat_radius=0.05

;minimum search
smooth_1=0.5
smooth_2=0.25


i=start
; mask mslp_masked over land to avoid low points
 
; mslp(i,:,:)=smth9_Wrap(mslp(i,:,:), smooth_1, smooth_2, False) 
 
 dims = dimsizes(mslp(i,:,:))
 x1d = ndtooned(mslp(i,:,:))      ; convert 2D array to 1D for use in minind
 inds = ind_resolve(minind (x1d), dims)    ; convert 1D array back to 2D 
 ilat(i) = inds(0,0)        ; select the latitude index where the X array is at its' minimum  
 ilon(i) = inds(0,1)        ; select the longitude index where the X array is at its' minimum  
 lat_min(i) = mslp&lat(ilat(i))   ; insert the latitude index into the lat coordinate variable
 lon_min(i) = mslp&lon(ilon(i))   ; insert the longitude index into the lon coordinate variable
 mslp_min(i)= mslp(i,ilat(i),ilon(i))
 gust_max(i)=max(gust(i,0,{lat_min(i):lat_min(i)+lat_radius},{lon_min(i):lon_min(i)+lon_radius}))
 delete(dims)
 delete(x1d)
 delete(inds)

i=start+1
; mslp(i,:,:)=smth9_Wrap(mslp(i,:,:), smooth_1, smooth_2, False) 
 
 dims = dimsizes(mslp(i,:,:))
 x1d = ndtooned(mslp(i,:,:))      ; convert 2D array to 1D for use in minind
 inds = ind_resolve(minind (x1d), dims)    ; convert 1D array back to 2D 
 ilat(i) = inds(0,0)        ; select the latitude index where the X array is at its' minimum  
 ilon(i) = inds(0,1)        ; select the longitude index where the X array is at its' minimum  
 lat_min(i) = mslp&lat(ilat(i))   ; insert the latitude index into the lat coordinate variable
 lon_min(i) = mslp&lon(ilon(i))   ; insert the longitude index into the lon coordinate variable
 mslp_min(i)= mslp(i,ilat(i),ilon(i))
 gust_max(i)=max(gust(i,0,{lat_min(i):lat_min(i)+lat_radius},{lon_min(i):lon_min(i)+lon_radius}))
 delete(dims)
 delete(x1d)
 delete(inds)

; box for the minimum search around the first guess
 box=5
;

do i=start+2,dimsizes(time)-1
; mslp(i,:,:)=smth9_Wrap(mslp(i,:,:), smooth_1, smooth_2, False) 


 ilat_c=2*ilat(i-1)-ilat(i-2)
 ilon_c=2*ilon(i-1)-ilon(i-2)
 
 dims = dimsizes(mslp(i, ilat_c-box:ilat_c+box , ilon_c-box:ilon_c+box ))
 x1d = ndtooned(mslp(i,  ilat_c-box:ilat_c+box , ilon_c-box:ilon_c+box  ))      ; convert 2D array to 1D for use in minind
 inds = ind_resolve(minind (x1d), dims)    ; convert 1D array back to 2D 
 ilat(i) =  inds(0,0)-box+ilat_c       ; select the latitude index where the X array is at its' minimum  
 ilon(i) =  inds(0,1)-box+ilon_c        ; select the longitude index where the X array is at its' minimum
 lat_min(i) = mslp&lat(ilat(i))   ; insert the latitude index into the lat coordinate variable
 lon_min(i) = mslp&lon(ilon(i))   ; insert the longitude index into the lon coordinate variable
 mslp_min(i)= mslp(i,ilat(i),ilon(i))
 gust_max(i)=max(gust(i,0,{lat_min(i):lat_min(i)+lat_radius},{lon_min(i):lon_min(i)+lon_radius}))
 delete(dims)
 delete(x1d)
 delete(inds)
 delete(ilat_c)
 delete(ilon_c)
end do 

 wks = gsn_open_wks("x11","track")

 map=gsn_csm_map(wks,ResC)
 line1= gsn_add_polyline(wks,map,lon_min,lat_min,lres) 
 marker1 = gsn_add_polymarker(wks,map,lon_min,lat_min,mres)
 
 draw(map)
 frame(wks)


 wks2 = gsn_open_wks("x11","mslp_wind") 
 resxy=True
  resxy@vpWidthF       = 0.9
  resxy@vpHeightF      = 0.5
 resxy@xyLineColors="black"
  resxy@gsnMaximize   = True
 resxy2=resxy
 resxy@xyLineColors="red"
 
 restick = True
 restick@ttmFormat = "%h"
 time_axis_labels(time,resxy,restick) ; call the formatting procedure
 plot=gsn_csm_xy2(wks2, time, mslp_min, gust_max,resxy,resxy2)

frame(wks2)
draw(plot)
 

end
