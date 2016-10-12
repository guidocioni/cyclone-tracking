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

; Open model level output file

case=(/"control","2p5km","5km","10km","les"/)
nrow=40
ncol=5
time_start=8

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
; create plot

ResC = True
ResC@gsnDraw=False
ResC@gsnFrame = False
ResC@mpLimitMode = "LatLon"
ResC@mpMaxLonF    = 17                      ; specify the plot domain
ResC@mpMinLonF    = 11.5                      ;                         
ResC@mpMinLatF    = 35                     ;
ResC@mpMaxLatF    = 39                     ;
ResC@mpDataBaseVersion  = "HighRes"
ResC@mpOutlineOn = True
;ResC@gsnAddCyclic = False

;ResC@vpWidthF       = 0.9
;ResC@vpHeightF      = 0.5
ResC@gsnMaximize   = True         ; Maximize plot in frame. 

wks = gsn_open_wks("x11","tracks") 
cmap = read_colormap_file("MPL_gist_gray")
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
MarkerIndex=ispan(15, 0, 1)
mres@gsMarkerSizeF = 0.005

txres=True
txres@txFontHeightF = 0.01

map=gsn_csm_map(wks,ResC)
cnLevels=fspan(min(mslp_min),max(mslp_min),10)

marker=new(dimsizes(case), graphic)
text=new(dimsizes(case), graphic)

do i=0,dimsizes(case)-1
  do j=time_start,dimsizes(mslp_min(i,:))-2
   lres@gsLineColor=get_color_rgba(cmap,cnLevels,avg( (/mslp_min(i,j),mslp_min(i,j+1)/)))
   gsn_polyline(wks,map,(/lon(i,j),lon(i,j+1)/),(/lat(i,j),lat(i,j+1)/),lres)
   mres@gsMarkerIndex = MarkerIndex(i)
   marker(i) = gsn_add_polymarker(wks,map,lon(i,time_start:),lat(i,time_start:),mres)
   text(i)   = gsn_add_text(wks, map,case(i),lon(i,dimsizes(mslp_min(i,:))-1)-0.01, lat(i,dimsizes(mslp_min(i,:))-1)+0.01,txres)
 delete(lres@gsLineColor) 
end do
 gsn_labelbar_ndc(wks,dimsizes(cnLevels)+1,floor(cnLevels),0.30,0.30,res_lb)
end do

draw(map)
frame(wks)

end
