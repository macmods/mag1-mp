%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  20200630, Christina Frieder
% 
%  mag1 - model of macroalgal growth in 1-D
%  volume-averaged; total biomass per volume
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
for year = 1999:2005 
    
    time = simtime([year 1 1; year 12 31]); % start time and stop time of simulation
    farm = farmdesign;  % loads 1-d farm
    
    % Load ENVT input for the year
    %envt = envt_testcase(farm,time); % mean 1999 conditions
    envt = envt_sb(farm,time,dir_ROMS,dir_WAVE); % Santa Barbara 
        
    % Seed the Farm (Initialize Biomass)
    % initial conditions (B,Q) set in farmdesign
    % [frond ID, depth]
    [kelp, harvest] = seedfarm(farm,time);
    
    % load a frond structure equivalent to test case intiial B (3 kg)
    %kelp.fronds = load('fronds_3kg.mat'); kelp.fronds = kelp.fronds.fronds;
    
    % Simulation Output; preallocate space
    kelp_b = NaN(1,length(time.timevec_Gr)); % integrated biomass per growth time step
    %Nf_nt = NaN(farm.nz,length(time.timevec_Gr));
    %Ns_nt = NaN(farm.nz,length(time.timevec_Gr));
    %Bm_nt = NaN(farm.nz,length(time.timevec_Gr));

    
% MAG growth -> set up as dt_Gr loop for duration of simulation
bt = 0; % placeholder for harvest threshold
for sim_hour = time.dt_Gr:time.dt_Gr:time.duration % [hours]

    gr_counter = sim_hour / time.dt_Gr;% growth counter
    envt_counter = ceil(gr_counter*time.dt_Gr/time.dt_ROMS); % ROMS counter

    %% DERIVED BIOLOGICAL CHARACTERISTICS
    kelp = kelpchar(kelp,farm);
    
       
    %% DERIVED ENVT
    envt.PARz  = canopyshading(kelp,envt,farm,envt_counter);
    
    %% GROWTH MODEL
    % updates Nf, Ns with uptake, growth, mortality, senescence
    % calculates DON and PON
    kelp = mag(kelp,envt,farm,time,envt_counter);
    
    %% FROND INITIATION
    kelp = frondinitiation(kelp,envt,farm,time,gr_counter);
    kelp = frondsenescence(kelp,time,sim_hour,gr_counter,harvest);  
    
    %% HARVEST
    % harvest is conditional
    
        temp_Nf = find_nan(kelp.Nf); 
        sumNf = trapz(farm.z_arr,temp_Nf);
        
        % find delta biomass (last time step = bt)
        db = sumNf ./ param.Qmin ./ 1e3 - bt; % change in biomass between last step and this step
        bt = sumNf ./ param.Qmin ./ 1e3; % for next time step
        
        
        if sumNf > farm.harvestNf_threshold % CRITERIA #1 is there enough harvestable canopy
        if db < param.h_threshold.*time.dt_Gr % CRITERIA #2 is the change in biomass decreasing
        
           % which harvest number is it
           if isnan(max(harvest.counter))
               harvest.counter(1,gr_counter) = 1;
           else
               harvest.counter(1,gr_counter) = max(harvest.counter) + 1;
           end
           
           % chop off the canopy and store it in harvest structure
           [harvest, kelp] = harvest_crit(harvest,kelp,farm,gr_counter);
           
        end
        end
         
    % Output
    kelp_b(1,gr_counter) = trapz(farm.z_arr,temp_Nf)./param.Qmin./1e3; % kg-dry/m
    clear temp_Nf 
 
    
end
clear db bt envt_counter gr_counter sim_hour

figure
plot(kelp_b)
hold on
plot(harvest.canopyB./1e3,'.r')
title(year)

%simid = sprintf('Y%d',year)
%mag1.(simid).kelp_b = kelp_b;

end


%% Figure of Output
%figure

 %   c=1;
 %   for year = 1999:2004
 %   simid = sprintf('Y%d',year)

 %   subplot(6,1,c)
 %   hold on
 %   plot(mag1.(simid).kelp_b,'r')
 %   title(year)
 %   ylabel('B (kg-dry/m2)')
 %   xlim([0 365])
 %   ylim([0 12])
 %   box on
 %   c=c+1;
%   end
    



