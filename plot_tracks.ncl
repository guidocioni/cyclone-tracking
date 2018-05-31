load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

;------------------------------------------------------------
;-- set global constants
;------------------------------------------------------------
pi       =  4.0*atan(1.)
deg2rad  =  pi/180.
rad2deg  =  45./atan(1.)
fillval  = -99999.9

begin

; case=(/"10km","5km","2p5km","control","nested","control_latheat"/)
;case=(/"10km","5km","2p5km","control","nested"/)

 ; case=(/"nested","nested_windsixt","nested_windfourth","nested_windsqrt","nested_fixwind"/)
case=(/"2p5km","control","nested"/)

nrow=38
ncol=5
time_start=9 ;tracked before but only plotted from now on
time_stop=35

lat=new((/dimsizes(case),nrow/), double)
lon=new((/dimsizes(case),nrow/), double)
mslp_min=new((/dimsizes(case),nrow/), double)
gust_max=new((/dimsizes(case),nrow/), double)

do i=0, dimsizes(case)-1
  data = asciiread (case(i)+"_track.txt" , (/nrow,ncol/), "double")
  lat(i,:)    = data (:,2)    ; pressure     [mb / hPa]
  lon(i,:)    = data (:,1)    ; temperature  [C]
  mslp_min(i,:)=data (:,3)
  gust_max(i,:)=data (:,4)
end do

time = data(:,0)

 data_obs = asciiread ("traiettoria_obs.txt" , (/30,4/), "double")
 lon_obs = data_obs(:,2)
 lat_obs = data_obs(:,3)
 time_obs= data_obs(:,1)
 time_obs@longname= "Time"
 time_obs@units = "hours"

; create plot

ResC = True
ResC@gsnDraw=False
ResC@gsnFrame = False
ResC@mpLimitMode = "LatLon"
ResC@mpFillOn = False 
ResC@mpOutlineOn = False 
ResC@mpMaxLonF    = 16.5                      ; specify the plot domain
ResC@mpMinLonF    = 11.5                      ;                         
ResC@mpMinLatF    = 35.5                     ;
ResC@mpMaxLatF    = 38.5                    ;
;;;;;;;;;
ResC@gsnMajorLatSpacing = 1.
ResC@gsnMajorLonSpacing = 1.
ResC@tmXBLabelFontHeightF = 0.01
;ResC@gsnAddCyclic = False
;ResC@vpWidthF       = 0.9
; ResC@gsnMaximize   = True         ; Maximize plot in frame. 
ResC@mpGridAndLimbOn = True 
ResC@mpGridLatSpacingF = 1.
ResC@mpGridLonSpacingF = 1.
ResC@mpGridLineDashPattern = 1.
; ResC@mpGridLineThicknessF
ResC@mpGridMaskMode = "MaskNotOcean"

ResCzoom= ResC 
ResCzoom@mpMaxLonF    = 16.                      ; specify the plot domain
ResCzoom@mpMinLonF    = 15.0                      ;                         
ResCzoom@mpMinLatF    = 36.                     ;
ResCzoom@mpMaxLatF    = 37.7  
ResCzoom@tmYLOn = False
ResCzoom@tmYROn = True 
ResCzoom@tmXBOn = False 
ResCzoom@tmXTOn = True 
ResCzoom@mpGridAndLimbOn = False 
; ResCzoom@gsnMajorLatSpacing = .5
; ResCzoom@gsnMajorLonSpacing = .5
ResCzoom@mpGridLatSpacingF = .5
ResCzoom@mpGridLonSpacingF = .5

ResC@tmXTOn = False 
ResC@tmYROn = False 


wks = gsn_open_wks("pdf","tracks_complete_new_1") 
cmap = read_colormap_file("GMT_haxby")
;cmap = read_colormap_file("gsdtol")
res_lb                    = True
res_lb@vpWidthF           = 0.60
res_lb@vpHeightF          = 0.10
res_lb@lbPerimOn          = False            ; Turn off perimeter.
res_lb@lbOrientation      = "Horizontal"     ; Default is vertical.
;res_lb@lbLabelStride      = 10    
res_lb@lbLabelAlignment   = "InteriorEdges"  ; Default is "BoxCenters".
res_lb@lbFillColors       = cmap(2:,:)      ; Colors for boxes.
res_lb@lbMonoFillPattern  = True             ; Fill them all solid.
res_lb@lbLabelFontHeightF = 0.015 

lres= True
lres@gsLineThicknessF = 5
mres=True
; MarkerIndex=ispan(15, 0, 1)
MarkerIndex=(/2, 12, 5, 6, 7, 9, 4/)
mres@gsMarkerSizeF = 0.013

 mres2=True
 mres2@gsMarkerIndex = 16
 mres2@gsMarkerSizeF = 0.01

pres=True
 pres@gsLineColor="black"
 pres@gsLineThicknessF = 2.0

txres=True
txres@txFontHeightF = 0.01

shapefile_res=True 
shapefile_res@gsLineThicknessF = 1.0
shapefile_res@gsFillOpacityF = 0.2
shapefile_res@gsFillColor = "grey"

cnLevels=fspan(976,1003,25)


; Create first map 
map=gsn_csm_map(wks,ResC)
id=gsn_add_shapefile_polylines(wks,map,"/work/mh0731/m300382/shapefiles/ITA_adm_shp/ITA_adm2.shp",shapefile_res)
id2=gsn_add_shapefile_polygons(wks,map,"/work/mh0731/m300382/shapefiles/ITA_adm_shp/ITA_adm2.shp",shapefile_res)
id3=gsn_add_shapefile_polylines(wks,map,"/work/mh0731/m300382/shapefiles/MLT_adm_shp/MLT_adm0.shp",shapefile_res)
id4=gsn_add_shapefile_polygons(wks,map,"/work/mh0731/m300382/shapefiles/MLT_adm_shp/MLT_adm0.shp",shapefile_res)

marker=new(dimsizes(case), graphic)
line=new((/dimsizes(case),time_stop-time_start+1/), graphic)

text=new(dimsizes(case), graphic)
text_hour=new(dimsizes(case), graphic)

; print(dimsizes(time(time_start:time_stop:3)))
; print(dimsizes(lon(1,time_start:time_stop:3)))
; print(dimsizes(lat(1,time_start:time_stop:3)))

do i=0,dimsizes(case)-1
  do j=time_start,time_stop
   lres@gsLineColor=get_color_rgba(cmap,cnLevels,avg((/mslp_min(i,j),mslp_min(i,j+1)/)))
   line(i,j-time_start)=gsn_add_polyline(wks,map,(/lon(i,j),lon(i,j+1)/),(/lat(i,j),lat(i,j+1)/),lres)
 delete(lres@gsLineColor) 
end do
mres@gsMarkerIndex = MarkerIndex(i)
marker(i) = gsn_add_polymarker(wks,map,lon(i,time_start:time_stop),lat(i,time_start:time_stop),mres)
text(i)   = gsn_add_text(wks, map,case(i),lon(i,time_stop)-0.01, lat(i,time_stop-1)+0.01,txres)
text_test= gsn_add_text(wks,map,time(time_start:time_stop:3),lon(i,time_start:time_stop:3)-0.01,lat(i,time_start:time_stop:3)+0.01,txres)
end do
marker_obs = gsn_add_polymarker(wks,map,lon_obs,lat_obs,mres2)
line_obs   = gsn_add_polyline(wks,map,lon_obs,lat_obs,pres)
tx_obs     = gsn_add_text(wks,map,time_obs(0:dimsizes(lon_obs)-1:3),lon_obs(0:dimsizes(lon_obs)-1:3),lat_obs(0:dimsizes(lon_obs)-1:3)-0.1,txres)

; text_test= gsn_add_text(wks,map,time(time_start:time_stop:3),lon(1,time_start:time_stop:3)-0.01,lat(1,time_start:time_stop:3)+0.01,txres)


; Create second map 
map2=gsn_csm_map(wks,ResCzoom)
id5=gsn_add_shapefile_polylines(wks,map2,"/work/mh0731/m300382/shapefiles/ITA_adm_shp/ITA_adm2.shp",shapefile_res)
id6=gsn_add_shapefile_polygons(wks,map2,"/work/mh0731/m300382/shapefiles/ITA_adm_shp/ITA_adm2.shp",shapefile_res)
txres@txFontHeightF = (txres@txFontHeightF)*2. 

marker2=new(dimsizes(case), graphic)
line2=new((/dimsizes(case),time_stop-time_start+1/), graphic)

do i=0,dimsizes(case)-1
  do j=time_start,time_stop
   lres@gsLineColor=get_color_rgba(cmap,cnLevels,avg((/mslp_min(i,j),mslp_min(i,j+1)/)))
   line2(i,j-time_start)=gsn_add_polyline(wks,map2,(/lon(i,j),lon(i,j+1)/),(/lat(i,j),lat(i,j+1)/),lres)
 delete(lres@gsLineColor) 
end do
mres@gsMarkerIndex = MarkerIndex(i)
marker2(i) = gsn_add_polymarker(wks,map2,lon(i,time_start:time_stop),lat(i,time_start:time_stop),mres)
text_test= gsn_add_text(wks,map2,time(time_start:time_stop:3),lon(i,time_start:time_stop:3)-0.01,lat(i,time_start:time_stop:3)+0.01,txres)
end do
marker_obs_2 = gsn_add_polymarker(wks,map2,lon_obs,lat_obs,mres2)
line_obs_2   = gsn_add_polyline(wks,map2,lon_obs,lat_obs,pres)
tx_obs_2     = gsn_add_text(wks,map2,time_obs(0:dimsizes(lon_obs)-1:3),lon_obs(0:dimsizes(lon_obs)-1:3),lat_obs(0:dimsizes(lon_obs)-1:3)+0.15,txres)


  res1                     = True
  res2                     = True
  res1@gsnMaximize         = True
  res2@gsnAttachPlotsYAxis = True

  amid = gsn_attach_plots(map,map2,res1,res2)
  draw(map)
  frame(wks)

;gsn_labelbar_ndc(wks,dimsizes(cnLevels)+1,floor(cnLevels),0.3,0.3,res_lb)

end
