;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;; Description: Take an array of data, sort it, remove duplicates, and 
;return 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
undef ( "remove_duplicates" ) 
function remove_duplicates( \ 
  i_data : numeric \ 
) 
begin 
  data = ndtooned( i_data ) 
  qsort(data) 
  duplicate = new( dimsizes(data), logical ) 
  duplicate(0) = False 
  do i = 1, dimsizes(data)-1 
    duplicate(i) = ( data(i).eq.data(i-1) ) 
  end do 
  uniqueInd = ind(.not.duplicate) 
  retVal = data(uniqueInd) 
  return(retVal) 
end ; remove_duplicates 

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
PVU=1E-6

begin

export_text           = False
plot_map              = True 
plot_centroid         = True
plot_timeseries       = False
plot_cross            = False
plot_vertical_section = False
diri="5km"

if diri.eq."control" then
 File = addfile( "./"+diri+"/complete.nc","r")
 File_pres=  addfile( "./"+diri+"/complete_pressure.nc","r")
 Filetopo = addfile( "../data_sicilia/extpar_guido_met_1226m.nc","r")
else if diri.eq."5km" then
 File = addfile( "./"+diri+"/complete.nc","r")  
 File_pres=  addfile( "./"+diri+"/complete_pressure.nc","r")
 Filetopo = addfile( "../data_sicilia/extpar_guido_met_4903m.nc","r")
else if diri.eq."2p5km" then
   File = addfile( "./"+diri+"/complete.nc","r")  
   Filetopo = addfile( "../data_sicilia/extpar_guido_met_2451m.nc","r")
else if diri.eq."10km" then
    File = addfile( "./"+diri+"/complete.nc","r")  
    File_pres=  addfile( "./"+diri+"/complete_pressure.nc","r")
    Filetopo = addfile( "../data_sicilia/extpar_guido_met_0010km.nc","r")
else if diri.eq."les" then
    File = addfile( "./"+diri+"/complete.nc","r")  
    Filetopo = addfile( "../data_sicilia/extpar_guido_met_1226m.nc","r")
else if diri.eq."5km_tiedtke" then
    File = addfile( "./"+diri+"/complete.nc","r")  
    Filetopo = addfile( "../data_sicilia/extpar_guido_met_4903m.nc","r")
else if diri.eq."flat_oro" then
    File = addfile( "./"+diri+"/complete.nc","r")  
    Filetopo = addfile( "../data_sicilia/extpar_guido_met_1226m.nc","r")
else if diri.eq."control_dual" then
    File = addfile( "./"+diri+"/complete.nc","r")  
    Filetopo = addfile( "../data_sicilia/extpar_guido_met_1226m.nc","r")
else if diri.eq."les_hires" then
    File = addfile( "./"+diri+"/complete.nc","r")  
    Filetopo = addfile( "../data_sicilia/extpar_guido_met_0613m.nc","r")
else if diri.eq."nested" then
    File = addfile( "./"+diri+"/DOM03.nc","r")  
    Filetopo = addfile( "../data_sicilia/extpar_nested_met306m.nc","r")
else if diri.eq."nested_fixwind" then
    File = addfile( "./"+diri+"/complete.nc","r")  
    Filetopo = addfile( "../data_sicilia/extpar_nested_met306m.nc","r")
else if diri.eq."control_latheat" then
    File = addfile( "./"+diri+"/complete.nc","r")  
    Filetopo = addfile( "../data_sicilia/extpar_guido_met_1226m.nc","r")
    File_pres=  addfile( "./"+diri+"/complete_pressure.nc","r")
else if diri.eq."nested_windsqrt" then
    File = addfile( "./"+diri+"/DOM03.nc","r")  
    Filetopo = addfile( "../data_sicilia/extpar_nested_met306m.nc","r")
else if diri.eq."nested_windfourth" then
    File = addfile( "./"+diri+"/DOM03.nc","r")  
    Filetopo = addfile( "../data_sicilia/extpar_nested_met306m.nc","r")
else if diri.eq."nested_windsixt" then
    File = addfile( "./"+diri+"/DOM03.nc","r")  
    Filetopo = addfile( "../data_sicilia/extpar_nested_met306m.nc","r")
else if diri.eq."nested_wind1p25" then
    File = addfile( "./"+diri+"/DOM03.nc","r")  
    Filetopo = addfile( "../data_sicilia/extpar_nested_met306m.nc","r")
end if 
end if 
end if 
end if 
end if 
end if 
end if
end if
end if
end if 
end if
end if 
end if
end if
end if
end if

print("DATA READ in "+get_cpu_time()+"s")

time= File->time
utc_date=cd_calendar(time, 0)
date=cd_calendar(time, -3)
gust=File->sp_10m
mslp=(File->pres_msl)/100.
topo=Filetopo->topography_c
height=(/20.000, 65.677, 131.880, 216.516, 318.336, 436.493, 570.373,\
        719.514, 883.557, 1062.224, 1255.291, 1462.584, 1683.966, 1919.330, \
        2168.596, 2431.707, 2708.624, 2999.329, 3303.815, 3622.092, 3954.183,\
        4300.121, 4659.952, 5033.731, 5421.524, 5821.524, 6221.524, 6621.524,\
        7021.524, 7421.524, 7821.524, 8221.524, 8621.524, 9021.524, 9421.524,\ 
        9821.524, 10221.524, 10621.524, 11021.524, 11421.524, 11821.524, 12221.524,\
        12621.524, 13021.524, 13421.524, 13821.524, 14234.210, 14660.386, 15113.594,\
        15595.549, 16108.074, 16653.108, 17232.713, 17849.081, 18504.545, 19201.585,\
        19942.837, 20731.107, 21569.375, 22460.814, 23408.796, 24416.908, 25488.963,\
        26617.350, 27803.623, 29038.622, 30322.249, 31655.249, 33038.397, 34472.507,\
        35958.428, 37497.048, 39089.298, 40736.151, 42438.627, 44197.795, 46014.776,\
        47890.748, 49826.951, 51824.685, 53877.930, 55976.216, 58132.167, 60335.466,\
        62606.299, 64946.444, 67357.797, 69842.381, 72363.546, 75000.000/) 
height=height(::-1)

temp=File->temp
temp=temp-273.15
 ; u=File->u
 ; v=File->v
 ;lhfl_s=File->lhfl_s

; if isfilevar(File, "pv_2") then
; pv=File->pv_2
; pv=pv/PVU
; pv&height=height
; else if isfilevar(File, "pv") then
;    pv=File->pv
;    pv=pv/PVU
; pv&height=height
; end if
; end if

  pv=File_pres->pv 
  pv=pv/PVU
  pv@units="PVU"

  levels=File_pres->lev

 ; temp&height=height

lon = File->clon * rad2deg ; cell center, lon (ncells)
lat = File->clat * rad2deg ; cell center, lat (ncells)

print("VARIABLES ASSIGNED in "+get_cpu_time()+"s")

;print("min(lon) = "+min(lon)) 
;print("min(lat) = "+min(lat)) 
;print("max(lon) = "+max(lon)) 
;print("max(lat) = "+max(lat)) 

mslp=mask(mslp, topo.ge.50 , False) 
temp=mask(temp, topo.ge.5, False)
;lhfl_s=mask(lhfl_s, topo.ge.5, False)

print("MASKING DONE in "+get_cpu_time()+"s")

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
;ResC@gsnAddCyclic = False

;ResC@vpWidthF       = 0.9
;ResC@vpHeightF      = 0.5
ResC@gsnMaximize   = True         ; Maximize plot in frame. 

cmap = read_colormap_file("amwg_blueyellowred")
res_lb                    = True
res_lb@vpWidthF           = 0.50
res_lb@vpHeightF          = 0.10
res_lb@lbPerimOn          = False            ; Turn off perimeter.
res_lb@lbOrientation      = "Horizontal"     ; Default is vertical.
;res_lb@lbLabelStride      = 10    
res_lb@lbLabelAlignment   = "InteriorEdges"  ; Default is "BoxCenters".
res_lb@lbFillColors       = cmap(2:,:)      ; Colors for boxes.
res_lb@lbMonoFillPattern  = True             ; Fill them all solid.
res_lb@lbLabelFontHeightF = 0.015 

lres= True
lres@gsLineThicknessF = 3.0

mres=True
mres@gsMarkerIndex = 16
mres@gsMarkerSizeF = 0.005

txres=True
txres@txFontHeightF = 0.01

;ResC@gsnCenterString= "track"

start=0
limit=36

lat_min=new(limit-start+1, double)
lon_min=new(limit-start+1, double)
mslp_min=new(limit-start+1, double)
mslp_min@long_name="Mean Sea-Level Pressure minimum [hPa]"
gust_max=new(limit-start+1, double)
gust_max@long_name="Maximum wind gust [m/s]"
lhfl_radius=new(limit-start+1, double)
lhfl_radius@long_name="Surface Latent Heat Flux [W/m**2]"
hour=new(limit-start+1, string)
hour_acc=new(limit-start+1, integer)
hour_acc=ispan(start, limit, 1)
hour_acc@long_name="Simulation lead time [hour]"
hour_acc@units = "hours since 2014-11-07 00:00:00"

;first box to search the minimum
min_lon=11.
max_lon=13.
min_lat=35.
max_lat=37.
box_ini=ind(lon.ge.min_lon .and. lon.le.max_lon .and. lat.ge.min_lat .and. lat.le.max_lat)

radius= 0.5 
box_dim=0.25 ; units latitude/longitude

print("Quest for the minimum is startinnngggg")
;minimum search
do i=start,limit
   k=i-start
   ; first 2 instants just perform a minimum search over the initial box
   if(i.eq.start .or. i.eq.(start+1) ) then 
       ;minimum must lies in the box defined by the boundaries
       cell_min=ind(lon.ge.min_lon .and. lon.le.max_lon .and. lat.ge.min_lat .and. lat.le.max_lat \
                    .and. mslp(i,:).eq. min(mslp(i,box_ini)) )
       ; cell_min should be 1-dimensional, otherwise shit happens
       if(dimsizes(cell_min) .ne. 1) then 
           lat_min(k) = lat(min(cell_min))  
           lon_min(k) = lon(min(cell_min))
           mslp_min(k)= mslp(i,min(cell_min))
       else
           lat_min(k) = lat(cell_min)  
           lon_min(k) = lon(cell_min)
           mslp_min(k)= mslp(i,cell_min)
       end if
       circle=ind(lon^2+lat^2-2*lon*lon_min(k)-2*lat*lat_min(k) .le. radius^2-lon_min(k)^2-lat_min(k)^2)
       gust_max(k)=avg(gust(i,0,circle))
       ;lhfl_radius(k)=avg(lhfl_s(i,circle))
       ; just to be sure that shit does NOT happen
       delete([/cell_min, circle/])
   else
       ;find new center based on linear-extrapolation from the two previous positions
       lat_new=2*lat_min(k-1)-lat_min(k-2)
       lon_new=2*lon_min(k-1)-lon_min(k-2)
       box_new=ind(lon.ge.(lon_new-box_dim)  .and. lon.le.(lon_new+box_dim)\
                   .and. lat.ge.(lat_new-box_dim) .and. lat.le.(lat_new+box_dim))
       cell_min=ind(lon.ge.(lon_new-box_dim) .and. lon.le.(lon_new+box_dim)\
                    .and. lat.ge.(lat_new-box_dim).and. lat.le.(lat_new+box_dim)\
                    .and. mslp(i,:) .eq. min(mslp(i,box_new)) )
       if(dimsizes(cell_min) .ne. 1) then 
           lat_min(k) = lat(min(cell_min))  
           lon_min(k) = lon(min(cell_min))
           mslp_min(k)= mslp(i,min(cell_min))
       else
           lat_min(k) = lat(cell_min)  
           lon_min(k) = lon(cell_min)
           mslp_min(k)= mslp(i,cell_min)
       end if
       circle=ind(lon^2+lat^2-2*lon*lon_min(k)-2*lat*lat_min(k) .le. radius^2-lon_min(k)^2-lat_min(k)^2)
       gust_max(k)=avg(gust(i,0,circle))
       ;lhfl_radius(k)=avg(lhfl_s(i,circle))
       ; just to be sure that shit does NOT happen
       delete([/box_new, lat_new, lon_new, circle, cell_min/])
   end if
   ; print("iteration n."+(k+0.0))
   ; print(lat_min(i)+" | "+lon_min(i)+" | "+mslp_min(i))
   hour(k)=utc_date(i,3)
end do 

if plot_map then
wks = gsn_open_wks("x11","track") 
print("Plotting map")
map=gsn_csm_map(wks,ResC)

cnLevels=fspan(min(mslp_min),max(mslp_min),10)
do j=0,dimsizes(mslp_min)-2
   lres@gsLineColor=GetFillColor(cnLevels,cmap,avg( (/mslp_min(j),mslp_min(j+1)/)))
   gsn_polyline(wks,map,(/lon_min(j),lon_min(j+1)/),(/lat_min(j),lat_min(j+1)/),lres) 
end do
marker1 = gsn_add_polymarker(wks,map,lon_min,lat_min,mres)
text1 = gsn_add_text(wks, map,hour,lon_min-0.01, lat_min+0.1,txres)
gsn_labelbar_ndc(wks,dimsizes(cnLevels)+1,floor(cnLevels),0.30,0.30,res_lb)

draw(map)
frame(wks)
end if

if export_text then 
; write coordinates and mslp in a text file
alist=[/hour_acc,lon_min,lat_min,mslp_min,gust_max/]
write_table(diri+"_track.txt","w",alist,"%2i%10.8f%10.8f%8.4f%4.2f")
end if

; plot centroid
; with temp. perturbation, and mslp

; define variables in a circle around the minimum
resc = True
resc@cnFillOn = True 
resc@cnLinesOn=False
resc@gsnDraw = False
resc@gsnFrame = False
resc2=resc
resc2@cnFillOn = False 
resc2@cnLinesOn= True
resc3=resc2
resc3@cnLevelSelectionMode = "ManualLevels"
resc3@cnMinLevelValF= 5.0
resc3@cnMaxLevelValF= 8.0
resc3@cnLevelSpacingF = 3.0
resc3@cnLineColor = "purple"
resc3@cnLineThicknessF = 2.0

resc@cnLevelSelectionMode= "ManualLevels"
resc@cnMinLevelValF = -3
resc@cnMaxLevelValF = 3 
resc@cnFillPalette="GHRSST_anomaly"
; resc@lbOrientation ="Vertical"

resc2@cnLineLabelDensityF  = 1.1
resc2@cnLineLabelFontHeightF = 0.01 

radius=1.
; level=85000
do i=start,limit
   centroid:=ind(lon^2+lat^2-2*lon*lon_min(i)-2*lat*lat_min(i) .le. radius^2-lon_min(i)^2-lat_min(i)^2)
   mslp_c:=mslp(i,centroid)
   temp_c:=dim_avg_n_Wrap(temp(i,79:85,centroid),0)
   ;pv_c=pv(i,{35000},centroid)

   ; u_c=u(i,89,centroid)
   ; v_c=v(i,89,centroid)
   ; lat_c=tofloat(lat(centroid))
   ; lon_c=tofloat(lon(centroid))

   resc@gsnCenterString = date(i)+"| Temperature anomaly and MSLP"
   resc@sfXArray:= lon(centroid) 
   resc@sfYArray:= lat(centroid)
   resc2@sfXArray:= lon(centroid) 
   resc2@sfYArray:= lat(centroid)

   if plot_centroid then
   wks2= gsn_open_wks("pdf","centroid_"+diri+"_"+i)
   plot=gsn_csm_contour(wks2, temp_c-avg(temp_c), resc)
   over=gsn_csm_contour(wks2, mslp_c, resc2)
   ;over2=gsn_csm_contour(wks2, pv_c, resc3)

   overlay(plot,over)
   ;overlay(plot,over2)
   draw(plot)
   frame(wks2)
   end if
end do

if plot_timeseries then
wks3 = gsn_open_wks("x11","mslp_lhflx") 
resxy=True
resxy@vpWidthF       = 0.9
resxy@vpHeightF      = 0.5
resxy@gsnDraw = False
resxy@gsnFrame = False
resxy@trXMinF = start
resxy@trXMaxF = limit
resxy@xyLineColors="black"
resxy@xyLineThicknessF = 4
resxy@tiYAxisFontHeightF = 0.02
resxy@gsnMaximize   = True
resxy2=resxy
resxy2@xyLineColors="red"

timeseries=gsn_csm_xy2(wks3, hour_acc, mslp_min, gust_max,resxy,resxy2)

draw(timeseries)
frame(wks3)
end if 

if plot_cross then
; plot cross section through cyclone

; define variables in a circle around the minimum
resc = True
resc@cnFillOn = True 
resc@cnLinesOn=False
resc@gsnDraw = False
resc@gsnFrame = False
resc2=resc
resc2@cnFillOn = False 
resc2@cnLinesOn= True

radius=0.5
do i=start,limit
   centroid:=ind(lon^2+lat^2-2*lon*lon_min(i)-2*lat*lat_min(i) .le. radius^2-lon_min(i)^2-lat_min(i)^2)
   lat_c:=tofloat(lat(centroid))
   lon_c:=tofloat(lon(centroid))
   temp_c:=temp(i,:,centroid)

  qsort(lon_c)
  qsort(lat_c)

   cross_temp:=new((/dimsizes(temp&height), dimsizes(lon_c)/), typeof(temp))
   do j=0,dimsizes(lon_c)-1
    inds_lat:=ind(lon_c.eq.lon_c(j))
    print(inds_lat)
    print(lat_c(inds_lat))
    print(lon_c(inds_lat))
    break
   end do 

   wks2= gsn_open_wks("x11","cross_"+diri+"_"+i)
   plot=gsn_csm_contour(wks2, cross_temp, resc)   

   draw(plot)
   frame(wks2)
   ; delete([/centroid, lat_c, lon_c, cross_temp, inds_lat/])
end do
end if

if plot_vertical_section then

; define variables in a circle around the minimum
 respres=True 
 respres@gsnMaximize = True 
   
  respres@vpHeightF = 0.7
  respres@vpWidthF = 1.0
  respres@cnFillOn             = True                  ; turn on color
  respres@cnFillPalette = "GMT_wysiwyg"
  ;respres@cnFillPalette = "MPL_gist_gray"
  respres@cnLinesOn            = False                 ; no contour lines
  
  respres@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  respres@cnMinLevelValF       = -10.                  ; set min contour level
  respres@cnMaxLevelValF       =  15.                  ; set max contour level
  respres@cnLevelSpacingF      = 1                  ; set contour spacing

radius=0.25
pv_c=new((/dimsizes(levels), limit-start+1/), typeof(pv))
k=0
do i=start,limit
  ; resxy@gsnCenterString = date(i)+" | PV | "+radius+"deg. centroid average"
   centroid:=ind(lon^2+lat^2-2*lon*lon_min(i)-2*lat*lat_min(i) .le. radius^2-lon_min(i)^2-lat_min(i)^2)
   lat_c:=lat(centroid)
   lon_c:=lon(centroid)
   ; temp_c:=dim_avg_n_Wrap(temp(i,lev_up:lev_down,centroid), 1)  ;only vertical dependency 
   pv_c(:,k)=dim_avg_n_Wrap(pv(i,:,centroid), 1)
   k=k+1
end do
   
  pv_c!0= "lev"
  pv_c!1= "time"
  pv_c&lev = levels 
  pv_c&time = hour_acc 

   wks2= gsn_open_wks("pdf","vertical_"+diri)
   ; plot=gsn_csm_xy(wks2, pv_c(::-1), levels(::-1), resxy)   
   plot=gsn_csm_pres_hgt(wks2, pv_c({100000:20000},:), respres)
   frame(wks2)

end if

end
