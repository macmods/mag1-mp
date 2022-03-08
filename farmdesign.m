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
    farm.z_arr = linspace(-farm.z,0,20);
    farm.dz = farm.z_arr(2) - farm.z_arr(1);
    farm.nz = length(farm.z_arr);
    
    % initial B/Q conditions
    farm.seedingB = 0.1*1e3; % seeding biomass [100 g-dry m-1]; 
    farm.seedingQ = 15; % seeding Q
    
    % minimum harvestable biomass
    % function of height
    
    % first step: using the B to height equation; calculate the amount of
    % biomass that is equivalent to where the biomass will be cut (=
    % canopy)
    b_below_canopy = ((farm.z_cult - abs(param.z_canopy)) .* param.Kh) ./ (param.Hmax - (farm.z_cult - abs(param.z_canopy)));
    
    % now add to this the threshold biomass for harvesting
    % [kg-dry] to Nf [mg N]
    harvest_threshold = b_below_canopy + param.b_threshold; % this is what needs to be there
    farm.harvestNf_threshold = harvest_threshold .* 1e3 .* param.Qmin;
    clear b_below_canopy
    
    
end
