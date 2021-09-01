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
dir_ROMS   = 'D:\github\mag1-mp-m3\envtl_data\SBCfarm_';
dir_WAVE   = 'D:\github\mag1-mp-m3\envtl_data\';

% Biological parameters used by MAG
global param % made global and used by most functions; nothing within code changes param values
param = param_macrocystis; % should have a file per species

% Simulation Input
for year = 1999:2004
    time = simtime([year 1 1; year 12 31]); % start time and stop time of simulation
    farm = farmdesign;  % loads 1-d farm
    envt = envt_sb(farm,time,dir_ROMS,dir_WAVE); % Santa Barbara 
    
    % Simulation Output; preallocate space
    kelp_b = NaN(1,length(time.timevec_Gr)); % integrated biomass per growth time step

    % Seed the Farm (Initialize Biomass)
    % [frond ID, depth]
    kelp = seedfarm(farm);

% MAG growth -> set up as dt_Gr loop for duration of simulation
for sim_hour = time.dt_Gr:time.dt_Gr:time.duration % [hours]

    gr_counter = sim_hour / time.dt_Gr;% growth counter
    envt_counter = ceil(gr_counter*time.dt_Gr/time.dt_ROMS); % ROMS counter

    %% DERIVED BIOLOGICAL CHARACTERISTICS
    kelp = kelpchar(kelp,farm);
    kelp_b(1,gr_counter) = nansum(kelp.Nf)./param.Qmin./1e3; % kg-dry/m
    kelp_h(1,gr_counter) = kelp.height;
    
    %% DERIVED ENVT
    envt.PARz  = canopyshading(kelp,envt,farm,envt_counter);
    
    %% GROWTH MODEL
    % updates Nf, Ns with uptake, growth, mortality, senescence
    % calculates DON and PON
    kelp = mag(kelp,envt,farm,time,envt_counter);
    
    %% FROND INITIATION
    kelp = frondinitiation(kelp,envt,farm,time,gr_counter);
    kelp = frondsenescence(kelp,time,sim_hour);   
    
    
end
clear growth_step gr_counter envt_counter 

simid = sprintf('Y%d',year)
mag1.(simid).kelp_b = kelp_b;

end


%% Figure of Output
figure

    for year = 1999:2004
    simid = sprintf('Y%d',year)

    plot(mag1.(simid).kelp_b,'k')
    hold on
    end
    
    xlabel('Day of Year')
    ylabel('Biomass (kg-dry/m2)')
    xlim([0 365])
    
    