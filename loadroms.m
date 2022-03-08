function roms = loadroms(romsfilename,year,subgrid)
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
% The ROMS simulations have been pre-processed and saved as mat files for
% use by MAG.
% Data is 1-m bins from surface to bottom depth.
% Interpolate to the farm z-array.

    

%% File Directory

VAR = {'NO3' 'NH4' 'DON' 'temp' 'magu' 'chla' 'PAR'};
for vv = 1:length(VAR)
    file = char(strcat(romsfilename,'z2mag_l2scb_',char(VAR(vv)),'_',num2str(year),'-',num2str(subgrid),'.nc'));
    roms.(char(VAR(vv))) = ncread(file,'Data');
    roms.(char(VAR(vv))) = permute(roms.(char(VAR(vv))),[2 1 3 4]);
end


end