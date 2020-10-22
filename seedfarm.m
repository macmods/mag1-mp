function kelp = seedfarm(farm)
% Kelp, pre-allocation of MAG variables; Initialize farm biomass
% Input: farm (z_cult, dz)
% Output: 
%   kelp with two structure variables
%       Nf (fixed nitrogen) mg N/m3
%       Ns (stored nitrogen) mg N/m3          

%% Initialize kelp state variables and characteristics
global param

    kelp.Ns = NaN(1,farm.z_cult/farm.dz);
    kelp.Nf = NaN(1,farm.z_cult/farm.dz);
        
    
%% Seed the farm
% Nf, Ns (initial biomass set by farm.seeding)

    kelp.Nf(1,farm.z_cult/farm.dz) = farm.seeding .* param.Qmin; % equivalent to a single 1 m frond; [mg N]
    kelp.Ns(1,farm.z_cult/farm.dz) = ((20-param.Qmin)*(farm.seeding .* param.Qmin))/param.Qmin; % corresponds to a Q of 20
    
end