function create_netcdf_mag(fout,NX,NY,nt)

ncid = netcdf.create(fout,'CLOBBER');
%Define the dimensions
x_dimID = netcdf.defDim(ncid,'latitude',NX);
y_dimID = netcdf.defDim(ncid,'longitude',NY);
dimidt = netcdf.defDim(ncid,'ocean_time',nt);

Data =  netcdf.defVar(ncid,'time', 'float', [dimidt]);
netcdf.putAtt(ncid,Data,'units','matlab time');
netcdf.putAtt(ncid,Data,'short_name','time');

Data =  netcdf.defVar(ncid,'biomass', 'float', [x_dimID y_dimID dimidt]);
netcdf.putAtt(ncid,Data,'units','kg-dry m-2');
netcdf.putAtt(ncid,Data,'short_name','ammonium profiles');

Data =  netcdf.defVar(ncid,'harvest Nf', 'float', [x_dimID y_dimID dimidt]);
netcdf.putAtt(ncid,Data,'units','mg-N m-2');
netcdf.putAtt(ncid,Data,'short_name','harvested fixed nitrogen');

Data =  netcdf.defVar(ncid,'harvest Ns', 'float', [x_dimID y_dimID dimidt]);
netcdf.putAtt(ncid,Data,'units','mg-N m-2');
netcdf.putAtt(ncid,Data,'short_name','harvested stored nitrogen');

Data =  netcdf.defVar(ncid,'harvest B', 'float', [x_dimID y_dimID dimidt]);
netcdf.putAtt(ncid,Data,'units','kg-N m-2');
netcdf.putAtt(ncid,Data,'short_name','harvest biomass');

Data =  netcdf.defVar(ncid,'harvest n', 'float', [x_dimID y_dimID dimidt]);
netcdf.putAtt(ncid,Data,'units','count');
netcdf.putAtt(ncid,Data,'short_name','harvest counter');

% insert global attribute
NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(ncid,NC_GLOBAL,'title',['ROMS xyt file'])
%netcdf.putAtt(ncid,NC_GLOBAL,'long_title',psrc_title)
netcdf.putAtt(ncid,NC_GLOBAL,'institution','christinaf/SCCWRP')
netcdf.putAtt(ncid,NC_GLOBAL,'source','mag output')

% Leave define mode
netcdf.endDef(ncid);
netcdf.close(ncid)

