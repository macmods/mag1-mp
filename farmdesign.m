function farm = farmdesign
% structure with farm properties
%
% Output: farm.()
%   z_cult; depth of cultivation, [m]
%   x,y,z; dimension of farm [m]
%   dx,dy,dz; bin size [m] 
%   seeding; initial seeding biomass
%   harvesting: h_threshold when B(t) - B(t-1) in canopy decreases by X kg
%   harvesting: b_threshold when at least XX amount of biomass in canopy
    
global param
%% farm dimensions and grid

    farm.z_cult = 20; %[m below surface]
    farm.z      = farm.z_cult; % [m]
    %farm.z_arr   = linspace(-farm.z,0,farm.z_cult);
    farm.z_arr = linspace(-farm.z,0,100);
    farm.dz = farm.z_arr(2) - farm.z_arr(1);
    farm.nz = length(farm.z_arr);
    
    % initial B/Q conditions
    farm.seedingB = 0.1*1e3; % seeding biomass [100 g-dry m-1]; 
    farm.seedingQ = 15; % seeding Q
    
    % 'canopy' starts at what depth
    farm.canopy = 1; % what depth is canopy defined at...
    
    % Harvesting thresholds
    farm.h_no = 1; % placeholder for harvest counter
    farm.h_threshold = -0.02; % 
    farm.b_threshold = 2.1875 .* 1e3 .* param.Qmin; % kg-dry to mg N in the canopy
    
    
end
