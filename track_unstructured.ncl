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

; Open model level output file

diri="2p5km"

if diri.eq."control" then
 File = addfile( "./"+diri+"/complete.nc","r")  
 Filetopo = addfile( "../data_sicilia/extpar_guido_met_1226m.nc","r")
else if diri.eq."5km" then
 File = addfile( "./"+diri+"/complete.nc","r")  
 Filetopo = addfile( "../data_sicilia/extpar_guido_met_4903m.nc","r")
else if diri.eq."2p5km" then
   File = addfile( "./"+diri+"/complete.nc","r")  
   Filetopo = addfile( "../data_sicilia/extpar_guido_met_2451m.nc","r")
else if diri.eq."10km" then
    File = addfile( "./"+diri+"/complete.nc","r")  
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
gust=File->sp_10m
mslp=(File->pres_msl)/100.
topo=Filetopo->topography_c

 temp=File->temp
 ; u=File->u
 ; v=File->v

 if diri.ne."les_hires" then
   pv=File->pv_2
   pv=pv/PVU
 end if 

lon = File->clon * rad2deg ; cell center, lon (ncells)
lat = File->clat * rad2deg ; cell center, lat (ncells)

print("VARIABLES ASSIGNED in "+get_cpu_time()+"s")

;print("min(lon) = "+min(lon)) 
;print("min(lat) = "+min(lat)) 
;print("max(lon) = "+max(lon)) 
;print("max(lat) = "+max(lat)) 

mslp=mask(mslp, topo.ge.5 , False) 
temp=mask(temp, topo.ge.5, False)

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

wks = gsn_open_wks("pdf","track") 
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
limit=48

lat_min=new(limit-start+1, double)
lon_min=new(limit-start+1, double)
mslp_min=new(limit-start+1, double)
gust_max=new(limit-start+1, double)
hour=new(limit-start+1, string)
hour_acc=new(limit-start+1, integer)
hour_acc=ispan(start, limit, 1)

;first box to search the minimum
min_lon=11.
max_lon=13.
min_lat=35.
max_lat=37.
box_ini=ind(lon.ge.min_lon .and. lon.le.max_lon .and. lat.ge.min_lat .and. lat.le.max_lat)

radius= 1.0 
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
       gust_max(k)=max(gust(i,0,circle))
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
       gust_max(k)=max(gust(i,0,circle))
       ; just to be sure that shit does NOT happen
       delete([/box_new, lat_new, lon_new, circle, cell_min/])
   end if
   print("iteration n."+(k+0.0))
   ;print(lat_min(i)+" | "+lon_min(i)+" | "+mslp_min(i))
   hour(k)=utc_date(i,3)
end do 

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

; write coordinates and mslp in a text file
alist=[/hour_acc,lon_min,lat_min,mslp_min,gust_max/]
write_table(diri+"_track.txt","w",alist,"%2i%10.8f%10.8f%8.4f%4.2f")

exit
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

radius=1.0
level=85
do i=start,limit
   centroid=ind(lon^2+lat^2-2*lon*lon_min(i)-2*lat*lat_min(i) .le. radius^2-lon_min(i)^2-lat_min(i)^2)
   mslp_c=mslp(i,centroid)
   temp_c=temp(i,level,centroid)
   ;pv_c=pv(i,{35000},centroid)

   ; u_c=u(i,89,centroid)
   ; v_c=v(i,89,centroid)
   ; lat_c=tofloat(lat(centroid))
   ; lon_c=tofloat(lon(centroid))

   resc@gsnCenterString = hour(i)
   resc@sfXArray = lon(centroid) 
   resc@sfYArray = lat(centroid) 
   resc2@sfXArray = lon(centroid) 
   resc2@sfYArray = lat(centroid)
   resc3@sfXArray = lon(centroid) 
   resc3@sfYArray = lat(centroid)

   wks2= gsn_open_wks("png","centroid"+i)
   plot=gsn_csm_contour(wks2, temp_c-avg(temp_c), resc)
   over=gsn_csm_contour(wks2, mslp_c, resc2)
   ;over2=gsn_csm_contour(wks2, pv_c, resc3)

   overlay(plot,over)
   ;overlay(plot,over2)
   draw(plot)
   ; wmsetp("vcw", 0.5)
   ; wmsetp("vch", 0.01)
   ; wmsetp("vrs", 25.)
   ; wmsetp("vrn", 0.005)

   ;wmvectmap(wks2, lat_c, lon_c, u_c, v_c)
   frame(wks2)
   delete([/centroid, mslp_c, temp_c, resc@sfXArray, resc@sfYArray, resc2@sfXArray, resc2@sfYArray, resc3@sfXArray, resc3@sfYArray/])
   ; delete([/u_c, v_c, lat_c, lon_c, pv_c/])
end do

wks3 = gsn_open_wks("pdf","mslp_wind") 
resxy=True
resxy@vpWidthF       = 0.9
resxy@vpHeightF      = 0.5
resxy@gsnDraw = False
resxy@trXMinF = start
resxy@trXMaxF = limit
resxy@xyLineColors="black"
resxy@gsnMaximize   = True
resxy2=resxy
resxy2@xyLineColors="red"

timeseries=gsn_csm_xy2(wks3, hour_acc, mslp_min, gust_max,resxy,resxy2)

draw(timeseries)
frame(wks3)

end