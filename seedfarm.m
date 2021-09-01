function kelp = seedfarm(farm)
% Kelp, pre-allocation of MAG variables; Initialize farm biomass
% Input: farm (z_cult, dz)
% Output: 
%   kelp with structured variables
%       Nf (fixed nitrogen) mg N/m3
%       Ns (stored nitrogen) mg N/m3   
%       lastfrond: simulation hour at which last frond initiated

%% Initialize kelp state variables and characteristics
global param
    %kelp.Ns = NaN(farm.z_cult/farm.dz,1);
    %kelp.Nf = NaN(farm.z_cult/farm.dz,1);
    %DPD edit
    kelp.Ns = NaN(farm.nz,1);
    kelp.Nf = NaN(farm.nz,1);
    %temp_Ns = kelp.Ns(~isnan(kelp.Ns))
    %z_Ns   = farm.z_arr(~isnan(kelp.Ns))

    
%% Seed the farm
% Nf, Ns (initial biomass set by farm.seeding)

    height_seed = ceil((param.Hmax .* farm.seeding./1e3 )./ (param.Kh + farm.seeding./1e3));
    %DPD edit
    %Calculate b_per_m
    b_per_m = make_Bm(height_seed,farm); 
    kelp.Nf = farm.seeding .* param.Qmin .* b_per_m; % equivalent to a single 1 m frond; [mg N]
    %kelp.Nf = farm.seeding .* param.Qmin .* param.b_per_m(:,height_seed); % equivalent to a single 1 m frond; [mg N]
    %kelp.Ns = ((20-param.Qmin)*(farm.seeding .* param.Qmin .* param.b_per_m(:,height_seed)))/param.Qmin; % corresponds to a Q of 20
    kelp.Ns = ((20-param.Qmin)*(farm.seeding .* param.Qmin .* b_per_m))/param.Qmin; % corresponds to a Q of 20


%% Other characteristics: Fronds
% lastfrond: simulation hour at which last frond was initiated

    frondcount = 100; % preallocation for 1 year of sim
    id = NaN(frondcount,1); id(1,1) = 1;
    start_age = NaN(frondcount,1); start_age(1,1) = 0;
    end_age = NaN(frondcount,1); end_age(1,1) = param.age_max;
    status = NaN(frondcount,1); status(1,1) = 1; 
    
    kelp.fronds = table(id,start_age,end_age,status);
    
end
