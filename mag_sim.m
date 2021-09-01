%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  20200630, Christina Frieder
% 
%  mag1 - model of macroalgal growth in 1-D
%  volume-averaged; not tracking fronds
%
%  State Variables:
%    NO3, Concentration of nitrate in seawater, [umol NO3/m3]
%    NH4, Concentration of ammonium in seawater, [umol NH4/m3]
%    Ns, macroalgal stored nitrogen, [mg N/m3]
%    Nf, macroalgal fixed nitrogen, [mg N/m3]
%    DON, dissolved organic nitrogen, [mmol N/m3]
%    PON, particulate organic nitrogen, [mg N/m3]
%  Farm Design: 1 dimensional(depth, z) [meters]
%    1:dz:z_cult
%  Environmental input:
%    nitrate, ammonium, dissolved organic nitrogen: for uptake term
%    seawater velociity and wave period: for uptake term
%    temperature: for growth term
%    wave height: for mortality term
%    PAR and chla: for light attenuation
%  Data Source:
%    ROMS, 1-km grid solution for SCB 
%    NBDC for waves
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
% Directories containing input environmental data
dir_ROMS   = 'C:\Users\Christinaf\OneDrive - SCCWRP\macmods\github\mag1-mp-m3\envtl_data\SBCfarm_';
dir_WAVE   = 'C:\Users\Christinaf\OneDrive - SCCWRP\macmods\github\mag1-mp-m3\envtl_data\';

% Biological parameters used by MAG
global param % made global and used by most functions; nothing within code changes param values
param = param_macrocystis; % should have a file per species

% Simulation Input

    % run for X days
    time = simtime([1999 1 1; 1999 12 31]); % start time and stop time of simulation
    farm = farmdesign;  % loads 1-d farm
    
    %envt = envt_testcase(farm,time); % mean 1999 conditions
    envt = envt_sb(farm,time,dir_ROMS,dir_WAVE); % Santa Barbara 
    
    % Simulation Output; preallocate space
    kelp_b = NaN(1,length(time.timevec_Gr)); % integrated biomass per growth time step

    % Seed the Farm (Initialize Biomass)
    % [frond ID, depth]
    kelp = seedfarm(farm);
    %load('max_initial_kelp.mat')

% MAG growth -> set up as dt_Gr loop for duration of simulation
%Create arrays for storage
Nf_nt = NaN(farm.nz,time.duration);
Ns_nt = NaN(farm.nz,time.duration);


for sim_hour = time.dt_Gr:time.dt_Gr:time.duration % [hours]
%for sim_hour = time.dt_Gr:2
    gr_counter = sim_hour / time.dt_Gr;% growth counter
    envt_counter = ceil(gr_counter*time.dt_Gr/time.dt_ROMS); % ROMS counter

    %% DERIVED BIOLOGICAL CHARACTERISTICS
    kelp = kelpchar(kelp,farm);
    Nf_nt(:,sim_hour) = kelp.Nf;
    Ns_nt(:,sim_hour) = kelp.Ns;


    %kelp_b(1,gr_counter) = nansum(kelp.Nf)./param.Qmin./1e3; % kg-dry/m
    %DPD edit
    temp_Ns = find_nan(kelp.Ns);  
    kelp_b(1,gr_counter) = trapz(farm.z_arr,temp_Ns)./param.Qmin./1e3; % kg-dry/m
    %disp('HEIGHT'), kelp.height
    b_per_m2 = make_Bm(kelp.height,farm);
    
    %% DERIVED ENVT
    envt.PARz  = canopyshading(kelp,envt,farm,envt_counter);
    
    %% GROWTH MODEL
    % updates Nf, Ns with uptake, growth, mortality, senescence
    % calculates DON and PON
    kelp = mag(kelp,envt,farm,time,envt_counter);
    %Nf_nt(:,sim_hour) = kelp.Nf;
    %Ns_nt(:,sim_hour) = kelp.Ns;  
    %% FROND INITIATION
    kelp = frondinitiation(kelp,envt,farm,time,gr_counter);
    kelp = frondsenescence(kelp,time,sim_hour);   
    
    
end
zs = farm.z_arr;
save('Ns_Nf', 'Ns_nt', 'Nf_nt', 'zs');
clear growth_step gr_counter envt_counter 


