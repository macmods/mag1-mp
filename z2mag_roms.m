% Environmental Input Data
% INPUT: farm, time, directories for ROMS data
% OUTPUT: envt.()
%   NO3; daily ROMS Nitrate in seawater; [umol/m3]
%   NH4; daily ROMS Ammonium in seawater; [umol/m3]
%   DON; daily ROMS DON, dissolved organic nitrogen; [mmol N/m3]
%   T; daily ROMS Temperature; [Celcius]
%   magu; magnitude velocity from daily ROMS Uo,Vo,Wo Seawater velocity, [m/h]
%   PAR; daily ROMS PAR, photosynthetically active radiation; incoming PAR; [W/m2]
%   chla; adily ROMS chl-a: sum of DIAZ+DIAT+SP (small phytoplankton); [mg-chla/m3]
%
% The ROMS simulations have been z-sliced
% Data is ~1-m bins from surface to bottom depth.

    
addpath(genpath('/data/project3/kesf/tools_matlab/matlab_paths/'))
%% One year at a time

    year = 2000;
    time = simtime([year 1 1; year 12 31]); % start time and stop time of simulation
    %time = simtime([year-1 12 1; year 11 31]); % start time and stop time of simulation
    
    
%% Create 4d ncfiles

    grd = '/data/project6/friederc/macmods_input/l2interp/roms_grd.nc';
     fout_no3 = sprintf('/data/project6/friederc/macmods_input/l2interp/z2mag_l2scb_NO3_%d.nc',year);
    create_netcdf4D(fout_no3,'NO3','nitrate','nitrate','umol m-3',grd,20)
    
     fout_nh4 = sprintf('/data/project6/friederc/macmods_input/l2interp/z2mag_l2scb_NH4_%d.nc',year);    
    create_netcdf4D(fout_nh4,'NH4','ammonium','ammonium','umol m-3',grd,20)
    
     fout_don = sprintf('/data/project6/friederc/macmods_input/l2interp/z2mag_l2scb_DON_%d.nc',year);
    create_netcdf4D(fout_don,'DON','DON','dissolved organic nitrogen','mmol m-3',grd,20)
    
     fout_temp = sprintf('/data/project6/friederc/macmods_input/l2interp/z2mag_l2scb_temp_%d.nc',year);
    create_netcdf4D(fout_temp,'temp','temp','temperature','Celcius',grd,20)
    
     fout_chla = sprintf('/data/project6/friederc/macmods_input/l2interp/z2mag_l2scb_chla_%d.nc',year);
    create_netcdf4D(fout_chla,'chla','chla','chlorophyll-a combined','',grd,20)
    
     fout_magu = sprintf('/data/project6/friederc/macmods_input/l2interp/z2mag_l2scb_magu_%d.nc',year);
    create_netcdf4D(fout_magu,'magu','magu','magnitude velocity','m h-1',grd,20)
    
     fout_par = sprintf('/data/project6/friederc/macmods_input/l2interp/z2mag_l2scb_PAR_%d.nc',year);
    create_netcdf4D(fout_par,'PAR','PAR','incoming PAR','W m-2',grd,1)
  
    
%% Creat a file per variable with time component
cpt=0;
for tt = 1:length(time.timevec_ROMS)
    
    date_tt = datevec(time.timevec_ROMS(tt));
    year_tt = date_tt(1);
    month_tt = date_tt(2);
    day_tt = date_tt(3);
    
    rep_mod = '/data/project6/friederc/macmods_input/l2interp/';
        
        % Which file based on day of year
        file = strcat(rep_mod,'z_l2_scb_avg.Y',num2str(year_tt),'M',num2str(month_tt,'%02d'),'D',num2str(day_tt,'%02d'),'.nc')

        NO3 = ncread(file,'NO3') .* 1e3; % from mmol/m3 to umol/m3
        NO3(NO3 < 0.01e3) = 0.01e3;
        ncwrite(fout_no3, 'NO3', NO3, [1 1 1 tt+cpt]);
        
        NH4 = ncread(file,'NH4') .* 1e3; % from mmol/m3 to umol/m3
        ncwrite(fout_nh4, 'NH4', NH4, [1 1 1 tt+cpt]);
        
        DON = ncread(file,'DON'); % mmol/m3 
        ncwrite(fout_don, 'DON', DON, [1 1 1 tt+cpt]);
        
        temp = ncread(file,'temp'); % mmol/m3 
        ncwrite(fout_temp, 'temp', temp, [1 1 1 tt+cpt]);
        
        chla = ncread(file,'SPCHL')+ncread(file,'DIATCHL')+ncread(file,'DIAZCHL');
        chla(chla < 0) = 0; % replace negatives
        ncwrite(fout_chla, 'chla', chla, [1 1 1 tt+cpt]);
        
        u = ncread([file],'u') .* (60*60); %[m/h]
        v = ncread([file],'v') .* (60*60); %[m/h]
        u = permute(u,[2 1 3]);
        v = permute(v,[2 1 3]);
        % get u and v onto correct grid
        for zz = 1:size(u,3)
            u_rho(:,:,zz) = u2rho_2d(u(:,:,zz));
            v_rho(:,:,zz) = v2rho_2d(v(:,:,zz));
        end
        u_rho = permute(u_rho,[2 1 3]);
        v_rho = permute(v_rho,[2 1 3]);
        
        w = ncread([file],'w') .* (60*60); %[m/h]
        
        magu = sqrt(u_rho.^2 + v_rho.^2 + w.^2);
        clear u v w u_rho v_rho
        ncwrite(fout_magu, 'magu', magu, [1 1 1 tt+cpt]);
        
        fileP = strcat(rep_mod,'l2_scb_avg.Y',num2str(year_tt),'M',num2str(month_tt,'%02d'),'D',num2str(day_tt,'%02d'),'.nc')
        PAR = ncread(fileP,'PARinc'); % W/m2
        ncwrite(fout_par, 'PAR', PAR, [1 1 1 tt+cpt]);
        
end
