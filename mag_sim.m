%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  20200630, Christina Frieder
% 
%  mag1d - model of macroalgal growth in 1-D
%
%  State Variables:
%    NO3, Concentration of nitrate in seawater, [umol NO3/m3]
%    NH4, Concentration of ammonium in seawater, [umol NH4/m3]
%    Ns, macroalgal stored nitrogen, [mg N/m frond]
%    Nf, macroalgal fixed nitrogen, [mg N/m frond]
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
dir_ROMS   = 'D:\Data\SBC_Farm\SBCfarm_';
dir_WAVE   = 'D:\Data\SBC_Farm\';

% Biological parameters used by MAG
global param % made global and used by most functions; nothing within code changes param values
param = param_macrocystis; % should have a file per species

% Simulation Input
time = simtime([2001 1 1; 2001 12 31]); % start time and stop time of simulation
farm = farmdesign;  % loads 1-d farm
envt = envt_sb(farm,time,dir_ROMS,dir_WAVE); % Santa Barbara 
clear dir_ROMS dir_WAVE

% Simulation Output; preallocate space
kelp_ar = NaN(1,length(time.timevec_Gr)); % integrated biomass per growth time step

% Seed the Farm (Initialize Biomass)
% [frond ID, depth]
kelp = seedfarm(farm,time);

% MAG growth -> set up as dt_Gr loop for duration of simulation
for growth_step = time.dt_Gr:time.dt_Gr:time.duration % [hours]

    Gr_step = growth_step / time.dt_Gr;% growth counter
    ROMS_step = ceil(Gr_step*time.dt_Gr/time.dt_ROMS); % ROMS counter

    %% DERIVED BIOLOGICAL CHARACTERISTICS
    kelp = kelpchar(kelp,farm);
    kelp_ar(1,Gr_step) = nansum(nansum(kelp.Nf)); % mg N/m2

    %% DERIVED ENVT
    envt.PARz  = canopyshading(kelp,envt,farm,ROMS_step);
    %% GROWTH MODEL
    % updates Nf, Ns with uptake, growth, mortality, senescence
    % calculates DON and PON
    [kelp, ~, ~] = mag(kelp,envt,farm,time,ROMS_step,growth_step);
        
end
clear Gr_step growth_step ROMS_step 