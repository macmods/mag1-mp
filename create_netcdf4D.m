function create_netcdf4D(fout,ncvar,NX,NY,NZ)

ncid = netcdf.create(fout,'CLOBBER');
%Define the dimensions
x_dimID = netcdf.defDim(ncid,'latitude',NX);
y_dimID = netcdf.defDim(ncid,'longitude',NY);
z_dimID = netcdf.defDim(ncid,'depth',NZ);
dimidt = netcdf.defDim(ncid,'ocean_time',netcdf.getConstant('NC_UNLIMITED'));
Data =  netcdf.defVar(ncid,ncvar, 'float', [x_dimID y_dimID z_dimID dimidt]);

% insert global attribute
NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(ncid,NC_GLOBAL,'title',['ROMS xyt file: ',ncvar])
%netcdf.putAtt(ncid,NC_GLOBAL,'long_title',psrc_title)
netcdf.putAtt(ncid,NC_GLOBAL,'institution','UCLA/SCCWRP')
netcdf.putAtt(ncid,NC_GLOBAL,'source','ROMS-BEC v2018')

% Leave define mode
netcdf.endDef(ncid);
netcdf.close(ncid)

