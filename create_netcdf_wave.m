function create_netcdf_wave(fout,ncvar,shortname,longname,unit,grd)

lon = ncread(grd, 'lon_rho')' ;
lat = ncread(grd, 'lat_rho')' ;

[NX,NY] = size(lon) ;

ncid = netcdf.create(fout,'CLOBBER');
%Define the dimensions
x_dimID = netcdf.defDim(ncid,'latitude',NX);
y_dimID = netcdf.defDim(ncid,'longitude',NY);
dimidt = netcdf.defDim(ncid,'ocean_time',netcdf.getConstant('NC_UNLIMITED'));
Data =  netcdf.defVar(ncid,ncvar, 'float', [x_dimID y_dimID dimidt]);

netcdf.putAtt(ncid,Data,'units',unit);
netcdf.putAtt(ncid,Data,'short_name',shortname);

% insert global attribute
NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(ncid,NC_GLOBAL,'title',['ROMS xyt file: ',ncvar])
%netcdf.putAtt(ncid,NC_GLOBAL,'long_title',psrc_title)
netcdf.putAtt(ncid,NC_GLOBAL,'institution','christinaf/SCCWRP')
netcdf.putAtt(ncid,NC_GLOBAL,'source','era5 interpolated')

% Leave define mode
netcdf.endDef(ncid);
netcdf.close(ncid)

