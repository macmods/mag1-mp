%% era5 WAVES
% an interpolated product from era5
addpath(genpath('/data/project3/kesf/tools_matlab/matlab_paths/'))
addpath(genpath('/data/project3/friederc/tools_macmods/tools/mag1-mp/'))

global param % made global and used by most functions; nothing within code changes param values
param = param_macrocystis; % should have a file per species

romsgrdfile = '/data/project5/kesf/ROMS/L2_SCB/grid/roms_grd.nc';
wavefilename = '/data/project3/friederc/tools_macmods/data/era5/era5_l2scb.nc';
romsgrid = loadromsgrid;
farm = farmdesign;  % loads 1-d farm
romsgrid = loadkelpmask(romsgrid,farm.z_cult);

year = 1999
time = simtime([year 1 1; year 12 31]); % start time and stop time of simulation

% Load Wave Data        
% From NREL wave energy, converted from JSON to mat file

%% era5 extracted nc files
    % longitude, latitude, time, swh, mwp
    % degrees north, degrees east, hours since 1900-01-01, meters, seconds
    ssh = ncread(wavefilename,'swh'); 
    wep = ncread(wavefilename,'mwp'); 
    
    % There's an extra dimension as part of some era5 experimental
    % version... only use first dimension of 'expver'
    ssh = squeeze(ssh(:,:,1,:));
    wep = squeeze(wep(:,:,1,:));
    
    % era5 has its own grid
    lon_ssh = ncread(wavefilename,'longitude'); 
    lat_ssh = ncread(wavefilename,'latitude'); 
    [lon_nd, lat_nd] = meshgrid(lon_ssh,lat_ssh);
    lon_nd = double(lon_nd');
    lat_nd = double(lat_nd');
    lon_ll = reshape(lon_nd,numel(lon_nd),1);
    lat_ll = reshape(lat_nd,numel(lat_nd),1);
    
    % Convert to datetime vector and then to matlab time
    time_ssh = ncread(wavefilename,'time'); 
    time_ssh = datenum(datetime(1900,1,1) + hours(time_ssh));
    lia = find(ismember(time_ssh,time.timevec_ROMS));
    
    % interp to romsgrid
    ssh_t = ssh(:,:,lia);
    wep_t = wep(:,:,lia);
    
    for tt=1:length(lia)
        disp(tt)
        ssh_tt = naninterp(lon_nd,lat_nd,ssh_t(:,:,tt),romsgrid.lon_rho,romsgrid.lat_rho);
        ssh_tt(~romsgrid.kelp_mask) = NaN;
        wep_tt = naninterp(lon_nd,lat_nd,wep_t(:,:,tt),romsgrid.lon_rho,romsgrid.lat_rho);
        wep_tt(~romsgrid.kelp_mask) = NaN;
        
        fixme = find((isnan(ssh_tt) & romsgrid.kelp_mask));
      
        % remove nans
        ssh_l = reshape(ssh_t(:,:,tt),size(ssh,1)*size(ssh,2),1);
        wep_l = reshape(wep_t(:,:,tt),size(wep,1)*size(wep,2),1);
        idx = ~isnan(ssh_l(:,1));
        ssh_ll = ssh_l(idx);
        wep_ll = wep_l(idx);
        
        % only look at points with NaN that are in kelp mask to find
        % nearest
        for ff = 1:length(fixme)
        [~,nearest] = min(pdist2([lon_ll(idx) lat_ll(idx)],[romsgrid.lon_rho(fixme(ff)) romsgrid.lat_rho(fixme(ff))]));
        ssh_tt(fixme(ff)) = ssh_ll(nearest);
        wep_tt(fixme(ff)) = wep_ll(nearest);
        end
    
        wep_tt = wep_tt ./60 ./60; % seconds to hours
 
        waves.ssh(:,:,tt) = ssh_tt;
        waves.wep(:,:,tt) = wep_tt;
        
    end
    
    
    % save fiels
    grd = '/data/project5/kesf/ROMS/L2_SCB/grid/roms_grd.nc';
    %grd = 'C:\Users\Christinaf\OneDrive - SCCWRP\matlab_tools\data_inputs\roms_grd.nc';
    fout_wave = sprintf('/data/project6/friederc/macmods_input/era5/ssh_%d.nc',year);
    create_netcdf_wave(fout_wave,'ssh','ssh','sig. wave height','m',grd)
    ncwrite(fout_wave,'ssh',waves.ssh)
    fout_wave = sprintf('/data/project6/friederc/macmods_input/era5/wep_%d.nc',year);
    create_netcdf_wave(fout_wave,'wep','wep','wave period','h',grd)
    ncwrite(fout_wave,'wep',waves.wep)
        
    
    
end
