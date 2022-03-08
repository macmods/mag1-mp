function ncid = getncid(romsfilename,year)

VAR = {'NO3' 'NH4' 'DON' 'temp' 'magu' 'chla' 'PAR'}
for vv = 1:length(VAR)
    file = strcat(romsfilename,'z2mag_l2scb_',char(VAR(vv)),sprintf('_%d',year),'.nc');
    ncid.(char(VAR(vv))) = netcdf.open(file);
end