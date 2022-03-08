function roms = splitroms(romsfilename,year)


VAR = {'NO3' 'NH4' 'DON' 'temp' 'magu' 'chla' 'PAR'};

msplit = [1 352; 353 705; 706 1058; 1059 1412];
mNX = msplit(:,2) - msplit(:,1);

for vv = 1:length(VAR)
    file = char(strcat(romsfilename,'z2mag_l2scb_',char(VAR(vv)),'_',num2str(year),'.nc'));
    data = ncread(file,char(VAR(vv)));
    
    % split into 4 files
    for mm = 1:4
        
      fout = sprintf('_%d-%d.nc',[year mm]);
      fout = strcat('/data/project6/friederc/macmods_input/l2interp/z2mag_l2scb_',char(VAR(vv)),fout)
      create_netcdf4D(fout,'Data',602,mNX(mm)+1,20)
      ncwrite(fout, 'Data', data(:,msplit(mm,1):msplit(mm,2),:,:));
      
    end
    
    clear data 
    
end

VAR = {'PAR'};

for vv = 1:length(VAR)
    file = char(strcat(romsfilename,'z2mag_l2scb_',char(VAR(vv)),'_',num2str(year),'.nc'));
    data = ncread(file,char(VAR(vv)));
    
    % split into 4 files
    for mm = 1:4
        
      fout = sprintf('_%d-%d.nc',[year mm]);
      fout = strcat('/data/project6/friederc/macmods_input/l2interp/z2mag_l2scb_',char(VAR(vv)),fout)
      create_netcdf4D(fout,'Data',602,mNX(mm)+1,1)
      ncwrite(fout, 'Data', data(:,msplit(mm,1):msplit(mm,2),:,:));
      
    end
    
    clear data 
    
end
      