function [kelp, harvest] = seedfarm(farm,time)
% Kelp, pre-allocation of MAG variables; Initialize farm biomass
% Input: farm (z_cult, dz)
% Output: 
%   kelp with structured variables
%       Nf (fixed nitrogen) mg N/m3
%       Ns (stored nitrogen) mg N/m3   
%       lastfrond: simulation hour at which last frond initiated

%% Initialize kelp state variables and characteristics
global param

    %DPD edit
    kelp.Ns = NaN(farm.nz,1);
    kelp.Nf = NaN(farm.nz,1);
   
    
%% Seed the farm
% Nf, Ns (initial biomass set by farm.seeding)

    height_seed = ceil((param.Hmax .* farm.seedingB./1e3 )./ (param.Kh + farm.seedingB./1e3));
    %DPD edit
    %Calculate b_per_m
    b_per_m = make_Bm(height_seed,farm); 
    kelp.Nf = farm.seedingB .* param.Qmin .* b_per_m; % equivalent to a single 1 m frond; [mg N]
    kelp.Ns = ((farm.seedingQ-param.Qmin)*(farm.seedingB .* param.Qmin .* b_per_m))/param.Qmin; % corresponds to a Q of 20


%% Other characteristics: Fronds
% lastfrond: simulation hour at which last frond was initiated

    frondcount = 100; % preallocation for 1 year of sim
    id = NaN(frondcount,1); id(1,1) = 1;
    start_age = NaN(frondcount,1); start_age(1,1) = 0;
    end_age = NaN(frondcount,1); end_age(1,1) = param.age_max;
    status = NaN(frondcount,1); status(1,1) = 1; 
    
    kelp.fronds = table(id,start_age,end_age,status);
    
%% Harvest array
% preallocate space

    harvest.canopyNf = NaN(1,length(time.timevec_Gr));
    harvest.canopyNs = NaN(1,length(time.timevec_Gr));
    harvest.canopyB = NaN(1,length(time.timevec_Gr));
    harvest.counter = NaN(1,length(time.timevec_Gr));
   
end
