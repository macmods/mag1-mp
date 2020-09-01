function kelp = seedfarm(farm,time)
% Kelp, pre-allocation of MAG variables; Initialize farm biomass
% Input: farm, time
% Output: kelp_fr.()
%   xXX_yXX; data stored as a structure with single structure for each x
%   and y location on farm where kelp is outplanted
%     Ns; stored nitrogen (mg N/m frond)
%     Nf; fixed nitrogen (mg N/m frond)
%     Nf_capacity (mg N/m3)
%     Age [h]
%     ID; frond number, useful for tracking last frond
%     lastFrond; time that last frond was initiated, used by frond
%       initiation function
%     kelploc; [X,Y], used to translate from structure to farm grid
% Output: kelp_ar.()
%     variables tracked per area are the sum of all fronds within given
%     location
          

%% Initialize kelp state variables and characteristics
global param

    kelp.Ns = NaN(farm.frondcount,farm.z_cult/farm.dz);
    kelp.Nf = NaN(farm.frondcount,farm.z_cult/farm.dz);
    kelp.Nf_capacity = NaN(farm.frondcount,1);
    kelp.Age = NaN(farm.frondcount,1);
    kelp.ID = NaN(farm.frondcount,1);
        
    
%% Seed the farm
% Nf, Ns, AGE, NF_CAPACITY, ID

    kelp.Nf_capacity(1,1) = param.Nf_capacity_subsurface;
    kelp.Nf(1,farm.z_cult) = param.Nf_capacity_subsurface; % equivalent to a single 1 m frond; [mg N]
    kelp.Ns(1,farm.z_cult) = ((20-param.Qmin)*param.Nf_capacity_subsurface)/param.Qmin; % corresponds to a Q of 20
    kelp.Age(1) = time.dt_Gr;
    kelp.ID(1) = 1;
    kelp.lastFrond = time.dt_Gr;
    

end