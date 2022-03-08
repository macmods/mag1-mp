function [envt] = loadwaveenvt(sshfilename,wepfilename,romsgrid)
% Load Wave Data        
% From NREL wave energy, converted from JSON to mat file

%% NREL wave energy; mat file
    % Column 1: Loacation ID
    % Column 2: Longitude
    % Column 3: Latitude
    % Column 4-15: Month Jan ... Dec
    ssh = load(sshfilename); ssh = ssh.ssh;
    wep = load(wepfilename); wep = wep.wep;
    
    
    % extract ROMS domain
    lonmin = min(min(romsgrid.lon_psi));
    lonmax = max(max(romsgrid.lon_psi));
    latmin = min(min(romsgrid.lat_psi));
    latmax = max(max(romsgrid.lat_psi));
    roms_domain_ssh = ssh(:,2) > lonmin & ssh(:,2) < lonmax & ssh(:,3) > latmin & ssh(:,3) < latmax;
    roms_domain_wep = wep(:,2) > lonmin & wep(:,2) < lonmax & wep(:,3) > latmin & wep(:,3) < latmax;
    clear lonmin lonmax latmin latmax
        
    ssh = ssh(roms_domain_ssh,:);
    wep = wep(roms_domain_wep,:);

    % ssh: find nearest WERP to ROMS location
    idx = dsearchn([ssh(:,2) ssh(:,3)],[reshape(romsgrid.lon_rho,1,numel(romsgrid.lon_rho))' reshape(romsgrid.lat_rho,1,numel(romsgrid.lat_rho))']);
    
    ssh_roms = NaN(numel(romsgrid.lon_rho),12);
    for mm = 1:12 % by month
    for dd = 1:length(idx) % by index
    ssh_roms(dd,mm) = ssh(idx(dd),3+mm); % extract nearest ssh value; 3+ to adjust for january in column 4 ... etc
    end
    end
    clear idx
    
    % wep: find nearest WERP to ROMS location
    idx = dsearchn([wep(:,2) wep(:,3)],[reshape(romsgrid.lon_rho,1,numel(romsgrid.lon_rho))' reshape(romsgrid.lat_rho,1,numel(romsgrid.lat_rho))']);
    
    wep_roms = NaN(numel(romsgrid.lon_rho),12);
    for mm = 1:12 % by month
    for dd = 1:length(idx) % by index
    wep_roms(dd,mm) = wep(idx(dd),3+mm); % extract nearest ssh value; 3+ to adjust for january in column 4 ... etc
    end
    end
    
    % reshape to match roms
    for mm = 1:12 
    ssh_tt = reshape(ssh_roms(:,mm),size(romsgrid.lon_rho));
    wep_tt = reshape(wep_roms(:,mm),size(romsgrid.lon_rho));
    ssh_tt(romsgrid.mask_rho == 0) = NaN;
    wep_tt(romsgrid.mask_rho == 0) = NaN;
    ssh_t(:,:,mm) = smooth2a(ssh_tt,10,10); % smooth product
    wep_t(:,:,mm) = smooth2a(wep_tt,10,10); % smooth product
    clear ssh_tt wep_tt
    end
    
    envt.ssh_roms = ssh_t; % meters
    envt.wep_roms = wep_t./60./60; % seconds to hours
    clear ssh_roms wep_roms ssh_t wep_t idx mm dd ssh wep
    
end
