function farm = farmdesign
% structure with farm properties
%
% Output: farm.()
%   z_cult; depth of cultivation, [m]
%   x,y,z; dimension of farm [m]
%   dx,dy,dz; bin size [m] 
%   seeding; initial seeding biomass

%% farm dimensions and grid

    farm.z_cult = 20; %[m below surface]
    farm.z      = farm.z_cult; % [m]
    %farm.dz     = 1; % [m]
    %DPD edit
    % make depth array spaced evenly that extends to surface at z=0 m
    %farm.z_arr  = linspace(-farm.z_cult,0,farm.z_cult+1);
    %use above one when Nf,Ns .mat file is for 21 bins
    farm.z_arr   = linspace(-farm.z_cult,0,farm.z_cult);
    farm.dz = farm.z_arr(2) - farm.z_arr(1);
    farm.nz = length(farm.z_arr);
    farm.seeding= 100; % seeding biomass [g-dry m-1]; 
    
end
