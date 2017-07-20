;=================================================================
; Modified version of convert_mam3_BC_OC_emissions.pro,
; which was originally committed to marc_input repository by
; darothen on 8-April-2017 (commit id 895619c).
; This version has been modified by B.S.Grandey in order to produce
; the BC/OC/VOC emissions file for *p17c_marc_1850*.
; The intention is for the emissions to be consistent with those
; for p17c_mam3_1850, which uses the default MAM3 emissions files.
;=================================================================

;=================================================================
; Creates MAM3 BC, OC and SOA emissions files for use with MITaer.
; MAM3 BC/OC emissions are separated in 2 files: one of them 
; contains 2D surface emissions and the other - 3D forcing term. 
; For use in MITaer the forcing terms are recalculated as surface
; emissions and added to the 2D fields.
;
; Mam3 SOA emissions are already converted to OC using mass yield 
; factors and are in molecules C/cm2/s. To use them in MITaer they
; are converted to kg C/m2/s, then monoterpene and isoprene are 
; divided by the mass yield factors used in MITaer (see voc2soa 
; subroutine in MITaer_emis.F90). Toluene, alkanes, and alkenes 
; are dumped into OVOCS divided by the respective mass yield 
; factor.
;=================================================================
 
;where MAM3 files live
fdir = '/glade/p/cesmdata/cseg/inputdata/atm/cam/chem/trop_mozart_aero/emis/'
mam3sfcBCfname  = 'ar5_mam3_bc_surf_1850_c090726.nc'
mam3sfcOCfname  = 'ar5_mam3_oc_surf_1850_c090726.nc'
mam3sfcSOAfname = 'ar5_mam3_soag_1.5_surf_1850_c100217.nc'
mam3verBCfname  = 'ar5_mam3_bc_elev_1850_c090726.nc' 
mam3verOCfname  = 'ar5_mam3_oc_elev_1850_c090726.nc' 

;output file
MITaer_fname =  'emis_p17c_marc_1850.nc' 

;----------------  read surface data  ----------------
fname = fdir + mam3sfcBCfname
print, 'Reading ' + fname
icdf = ncdf_open( fname )

;dimensions
dimid = ncdf_dimid( icdf, 'time' )
ncdf_diminq, icdf, dimid, dummy, ntime
dimid = ncdf_dimid( icdf, 'lat' )
ncdf_diminq, icdf, dimid, dummy, nlat
dimid = ncdf_dimid( icdf, 'lon' )
ncdf_diminq, icdf, dimid, dummy, nlon

;lat/lon/date
ncdf_varget, icdf, 'lat',  lat
ncdf_varget, icdf, 'lon',  lon
ncdf_varget, icdf, 'date', date

;BC data
ncdf_varget, icdf, 'emiss_awb', tr1  ;agricultural waste burning
ncdf_varget, icdf, 'emiss_dom', tr2  ;domestic
ncdf_varget, icdf, 'emiss_ene', tr3  ;energy
ncdf_varget, icdf, 'emiss_ind', tr4  ;industry
ncdf_varget, icdf, 'emiss_tra', tr5  ;transport
ncdf_varget, icdf, 'emiss_wst', tr6  ;waste treatment
ncdf_varget, icdf, 'emiss_shp', tr7  ;ship emissions

;done reading surface BC
ncdf_close, icdf

;total surface BC emissions from all sectors
mam3BCsfc = DOUBLE( tr1 + tr2 + tr3 + tr4 + tr5 + tr6 + tr7 )

;--------------------------------------------------------------
;now read surface OC emissions
fname = fdir + mam3sfcOCfname
print, 'Reading ' + fname
icdf = ncdf_open( fname )

;lat/lon/date/level thickness
ncdf_varget, icdf, 'lat',  xlat
ncdf_varget, icdf, 'lon',  xlon
ncdf_varget, icdf, 'date', xdate

;check coordinates
if( ~ARRAY_EQUAL(xlat ,lat) OR $ 
    ~ARRAY_EQUAL(xlon ,lon) OR $ 
    ~ARRAY_EQUAL(xdate,date)     )then begin
  print, 'lat/lon/date coordinates in '+fname+' are different. STOP!'
endif

;OC data
ncdf_varget, icdf, 'emiss_awb', tr1  ;agricultural waste burning
ncdf_varget, icdf, 'emiss_dom', tr2  ;domestic
ncdf_varget, icdf, 'emiss_ene', tr3  ;energy
ncdf_varget, icdf, 'emiss_ind', tr4  ;industry
ncdf_varget, icdf, 'emiss_tra', tr5  ;transport
ncdf_varget, icdf, 'emiss_wst', tr6  ;waste treatment
ncdf_varget, icdf, 'emiss_shp', tr7  ;ship emissions

;done reading surface OC
ncdf_close, icdf

;total surface OC emissions from all sectors
mam3OCsfc = DOUBLE( tr1 + tr2 + tr3 + tr4 + tr5 + tr6 + tr7 )

;---------------  surface SOAg emissions  ------------------
fname = fdir + mam3sfcSOAfname
print, 'Reading ' + fname
icdf = ncdf_open( fname )

;lat/lon/date/level thickness
ncdf_varget, icdf, 'lat',  xlat
ncdf_varget, icdf, 'lon',  xlon
ncdf_varget, icdf, 'date', xdate

;check coordinates
if( ~ARRAY_EQUAL(xlat ,lat) OR $ 
    ~ARRAY_EQUAL(xlon ,lon) OR $ 
    ~ARRAY_EQUAL(xdate,date)     )then begin
  print, 'lat/lon/date coordinates in '+fname+' are different. STOP!'
endif

;SOAg data
ncdf_varget, icdf, 'SOAG_BIGALK',   tr1  ;alkanes
ncdf_varget, icdf, 'SOAG_BIGENE',   tr2  ;alkenes
ncdf_varget, icdf, 'SOAG_TOLUENE',  tr3
ncdf_varget, icdf, 'SOAG_ISOPRENE', mam3ISOPR
ncdf_varget, icdf, 'SOAG_TERPENE',  mam3TERP

;done reading surface SOAg
ncdf_close, icdf

;dump alkanes, alkenes and toluene into OVOCS (other VOCs)
mam3OVOCS = DOUBLE( tr1 + tr2 + tr3 )

;----------------  read vertical data  ----------------
fname = fdir + mam3verBCfname
print, 'Reading ' + fname
icdf = ncdf_open( fname )

;vertical dimension
dimid = ncdf_dimid( icdf, 'altitude' )
ncdf_diminq, icdf, dimid, dummy, nlev

;lat/lon/date/level interface heights
ncdf_varget, icdf, 'lat',  xlat
ncdf_varget, icdf, 'lon',  xlon
ncdf_varget, icdf, 'date', xdate
ncdf_varget, icdf, 'altitude_int', zint

if( ~ARRAY_EQUAL(xlat ,lat) OR $ 
    ~ARRAY_EQUAL(xlon ,lon) OR $ 
    ~ARRAY_EQUAL(xdate,date)     )then begin
  print, 'lat/lon/date coordinates in '+fname+' are different. STOP!'
endif

;BC level data
ncdf_varget, icdf, 'forestfire', tr1 
ncdf_varget, icdf, 'grassfire',  tr2

;done reading BC level data
ncdf_close, icdf

;total BC level emissions from all sectors
mam3BCver = DOUBLE( tr1 + tr2 )

;---------------- OC level data -------------------
fname = fdir + mam3verOCfname
print, 'Reading ' + fname
icdf = ncdf_open( fname )

;lat/lon/date/level thickness
ncdf_varget, icdf, 'lat',  xlat
ncdf_varget, icdf, 'lon',  xlon
ncdf_varget, icdf, 'date', xdate
ncdf_varget, icdf, 'altitude_int', xzint

if( ~ARRAY_EQUAL(xlat ,lat) OR $ 
    ~ARRAY_EQUAL(xlon ,lon) OR $ 
    ~ARRAY_EQUAL(xzint,zint ) OR $ 
    ~ARRAY_EQUAL(xdate,date)     )then begin
  print, 'lat/lon/date coordinates in '+fname+' are different. STOP!'
endif

;OC level data
ncdf_varget, icdf, 'forestfire', tr1 
ncdf_varget, icdf, 'grassfire',  tr2

;done reading OC level data
ncdf_close, icdf

;total OC level emissions from all sectors
mam3OCver = DOUBLE( tr1 + tr2 )

;-------------------- conversions -----------------------
;convert 3D level emissions to 2D surface emission equiv.
;and add them to the surface emissions
zint *= 1.d5 ;level thickness from km to cm
for iz=1,nlev-1 do begin
  dz = zint(iz+1)-zint(iz)
  mam3BCsfc += mam3BCver(*,*,iz,*)*dz 
  mam3OCsfc += mam3OCver(*,*,iz,*)*dz 
endfor

;convert surface emissions from molecules/cm2/s to kg/m2/s
Na   = 6.02214129d+23 ;Avogadro's number [#/mol]
mwgt = 12.d           ;C molecular weight [g/mol]
conv = 10.*mwgt/Na
mam3BCsfc *= conv
mam3OCsfc *= conv
mam3ISOPR *= conv
mam3TERP  *= conv
mam3OVOCS *= conv

;divide VOCs by the mass yield factor used in MITaer
mam3ISOPR /= 0.04
mam3OVOCS /= 0.05
mam3TERP  /= 0.35 * 0.0510 + $  ; alpha-piene
             0.23 * 0.0860 + $  ; beta-piene
             0.23 * 0.1445 + $  ; limonene
             0.05 * 0.1015 + $  ; myrcene
             0.05 * 0.0765 + $  ; sabinene
             0.04 * 0.0660 + $  ; delta3-carene
             0.02 * 0.0420 + $  ; ocimene
             0.02 * 0.0335 + $  ; terpinolene
             0.01 * 0.0805      ; alpha- &amp; gamma-terpene

;done with all conversions, now make the NetCDF

;create another time variable holding the 
;number of months since beginning
year  = FIX( date/10000. )
month = FIX( (date - year*10000)/100. )
time = lonarr(ntime)
for i=0,ntime-1 do  begin
  time(i) = (year(i)-year(0) )*12 + month(i)
endfor

;-------------------  write output  -------------------
;create new NetCDF file
fname = MITaer_fname
print, 'Writing ' + fname
icdf  = ncdf_create( fname, /clobber )

;fix the truncation error in lat/lon coordinates
dlat = 180./FLOAT(nlat-1)
dlon = 360./FLOAT(nlon)
for i=0,nlat-1 do lat(i) = -90. + i*dlat
for i=0,nlon-1 do lon(i) = i*dlon

;fill it with byte zeros
ncdf_control, icdf, /fill

;define dimensions
londim     = ncdf_dimdef( icdf, 'lon', nlon )
latdim     = ncdf_dimdef( icdf, 'lat', nlat )
tdim       = ncdf_dimdef( icdf, 'time', /unlimited )

;define variables
lonvar  = ncdf_vardef( icdf, 'lon',  [londim] )
ncdf_attput, icdf, lonvar, 'name', 'longitude'
ncdf_attput, icdf, lonvar, 'long_name', 'longitude'
ncdf_attput, icdf, lonvar, 'units', 'degrees_east'
ncdf_attput, icdf, lonvar, 'modulo', 360.
ncdf_attput, icdf, lonvar, 'axis', 'X'
ncdf_attput, icdf, lonvar, 'topology', 'circular'

latvar  = ncdf_vardef( icdf, 'lat',  [latdim] )
ncdf_attput, icdf, latvar, 'name', 'latitude'
ncdf_attput, icdf, latvar, 'long_name', 'latitude'
ncdf_attput, icdf, latvar, 'units', 'degrees_north'
ncdf_attput, icdf, latvar, 'axis', 'Y'

datevar = ncdf_vardef( icdf, 'date', [tdim], /LONG )
ncdf_attput, icdf, datevar, 'name', 'date'
ncdf_attput, icdf, datevar, 'axis', 'T'

timevar = ncdf_vardef( icdf, 'time', [tdim], /LONG )
ncdf_attput, icdf, timevar, 'name', 'time'
ncdf_attput, icdf, timevar, 'units', 'months starting at ' + $
                                      string(year(0), FORMAT='(i4)') + $
                                     '-01-01'

BCvar   = ncdf_vardef( icdf, 'mBC', [londim,latdim,tdim], /DOUBLE )
ncdf_attput, icdf, BCvar, 'name', 'mBC'
ncdf_attput, icdf, BCvar, 'long_name', 'black carbon emission'
ncdf_attput, icdf, BCvar, 'units', 'kg/m2/s'
ncdf_attput, icdf, BCvar, 'missing_value', 1.e+20

OCvar   = ncdf_vardef( icdf, 'mOC', [londim,latdim,tdim], /DOUBLE )
ncdf_attput, icdf, OCvar, 'name', 'mOC'
ncdf_attput, icdf, OCvar, 'long_name', 'organic carbon emission'
ncdf_attput, icdf, OCvar, 'units', 'kg/m2/s'
ncdf_attput, icdf, OCvar, 'missing_value', 1.e+20

OVOCSvar= ncdf_vardef( icdf, 'ovoc', [londim,latdim,tdim], /DOUBLE )
ncdf_attput, icdf, OVOCSvar, 'name', 'ovoc'
ncdf_attput, icdf, OVOCSvar, 'long_name', 'other VOCs emission'
ncdf_attput, icdf, OVOCSvar, 'units', 'kg/m2/s'
ncdf_attput, icdf, OVOCSvar, 'missing_value', 1.e+20

ISOPRvar= ncdf_vardef( icdf, 'isoprene', [londim,latdim,tdim], /DOUBLE )
ncdf_attput, icdf, ISOPRvar, 'name', 'isoprene'
ncdf_attput, icdf, ISOPRvar, 'long_name', 'isoprene emission'
ncdf_attput, icdf, ISOPRvar, 'units', 'kg/m2/s'
ncdf_attput, icdf, ISOPRvar, 'missing_value', 1.e+20

TERPTvar= ncdf_vardef( icdf, 'terpene', [londim,latdim,tdim], /DOUBLE )
ncdf_attput, icdf, TERPTvar, 'name', 'terpene'
ncdf_attput, icdf, TERPTvar, 'long_name', 'monoterpene emission'
ncdf_attput, icdf, TERPTvar, 'units', 'kg/m2/s'
ncdf_attput, icdf, TERPTvar, 'missing_value', 1.e+20

AVOCSvar= ncdf_vardef( icdf, 'avoc', [londim,latdim], /DOUBLE )
ncdf_attput, icdf, AVOCSvar, 'name', 'avoc'
ncdf_attput, icdf, AVOCSvar, 'long_name', 'anthropogenic VOCs emission'
ncdf_attput, icdf, AVOCSvar, 'units', 'kg/m2/s'
ncdf_attput, icdf, AVOCSvar, 'missing_value', 1.e+20

;date stamp
datestring = systime()
ncdf_attput, icdf, /GLOBAL, 'history', $
             'Created ' + datestring + ' by lz4ax'

;put file into data mode
ncdf_control, icdf, /endef

;fill coordinate variables
ncdf_varput, icdf, lonvar,         lon
ncdf_varput, icdf, latvar,         lat
ncdf_varput, icdf, datevar,        date
ncdf_varput, icdf, timevar,        time

;fill data variables
ncdf_varput, icdf, BCvar,    mam3BCsfc
ncdf_varput, icdf, OCvar,    mam3OCsfc
ncdf_varput, icdf, OVOCSvar, mam3OVOCS
ncdf_varput, icdf, AVOCSvar, mam3OVOCS(*,*,0)*0.0
ncdf_varput, icdf, ISOPRvar, mam3ISOPR
ncdf_varput, icdf, TERPTvar, mam3TERP

;close NetCDF file
ncdf_close, icdf

;check the new file
print, 'Checking new file ... '
icdf = ncdf_open( fname )

;dimensions
dimid = ncdf_dimid( icdf, 'time' )
ncdf_diminq, icdf, dimid, dummy, ntime
dimid = ncdf_dimid( icdf, 'lat' )
ncdf_diminq, icdf, dimid, dummy, nlat
dimid = ncdf_dimid( icdf, 'lon' )
ncdf_diminq, icdf, dimid, dummy, nlon

;lat/lon
ncdf_varget, icdf, 'lat', lat
ncdf_varget, icdf, 'lon', lon

;data
ncdf_varget, icdf, 'mBC',      BC
ncdf_varget, icdf, 'mOC',      OC
ncdf_varget, icdf, 'ovoc',     OVOC
ncdf_varget, icdf, 'isoprene', ISOPR
ncdf_varget, icdf, 'terpene',  TERPT
ncdf_varget, icdf, 'avoc',     AVOC

;done reading
ncdf_close, icdf

;check BC
iwhere = where( FINITE(BC, /NAN), nwhere  )
iwhere = where( BC LT 0. OR BC GT 1e5, nwhere2 )
if( nwhere GT 0 )then begin
   print, 'BC field contains NaNs! STOP'
   RETALL
endif
if( nwhere2 GT 0 )then begin
   print, 'BC field &lt;0 1e5 &gt;! STOP'
   RETALL
endif
print, 'BC checks OK'

iwhere = where( FINITE(OC, /NAN), nwhere  )
iwhere = where( OC LT 0. OR OC GT 1e5, nwhere2 )
if( nwhere GT 0 )then begin
   print, 'OC field contains NaNs! STOP'
   RETALL
endif
if( nwhere2 GT 0 )then begin
   print, 'OC field &lt;0 1e5 &gt;! STOP'
   RETALL
endif
print, 'OC checks OK'

iwhere = where( FINITE(OVOC, /NAN), nwhere  )
iwhere = where( OVOC LT 0. OR OVOC GT 1e5, nwhere2 )
if( nwhere GT 0 )then begin
   print, 'OVOC field contains NaNs! STOP'
   RETALL
endif
if( nwhere2 GT 0 )then begin
   print, 'OVOC field &lt;0 1e5 &gt;! STOP'
   RETALL
endif
print, 'OVOCs checks OK'

iwhere = where( FINITE(ISOPR, /NAN), nwhere  )
iwhere = where( ISOPR LT 0. OR ISOPR GT 1e5, nwhere2 )
if( nwhere GT 0 )then begin
   print, 'ISOPR field contains NaNs! STOP'
   RETALL
endif
if( nwhere2 GT 0 )then begin
   print, 'ISOPR field &lt;0 1e5 &gt;! STOP'
   RETALL
endif
print, 'isoprene checks OK'

iwhere = where( TERPT LT 0. OR TERPT GT 1e5, nwhere2 )
if( nwhere GT 0 )then begin
   print, 'TERPT field contains NaNs! STOP'
   RETALL
endif
if( nwhere2 GT 0 )then begin
   print, 'TERPT field &lt;0 1e5 &gt;! STOP'
   RETALL
endif
print, 'terpene checks OK'

iwhere = where( FINITE(AVOC, /NAN), nwhere  )
iwhere = where( AVOC LT 0. OR AVOC GT 1e5, nwhere2 )
if( nwhere GT 0 )then begin
   print, 'AVOC field contains NaNs! STOP'
   RETALL
endif
if( nwhere2 GT 0 )then begin
   print, 'AVOC field &lt;0 1e5 &gt;! STOP'
   RETALL
endif
print, 'Anthr. VOCs checks OK'

end

