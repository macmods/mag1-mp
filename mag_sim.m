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

    %romsgrdfile = 'C:\Users\Christinaf\OneDrive - SCCWRP\macmods\Data\ROMS_L2_SCB_AP\roms_grd.nc'
    %wavefilename = 'C:\Users\Christinaf\OneDrive - SCCWRP\macmods\Data\ERA5\era5_l2scb.nc';
    
    addpath(genpath('/data/project3/kesf/tools_matlab/matlab_paths/'))
    addpath(genpath('/data/project3/friederc/tools_macmods/tools/mag1-mp/'))
    
    romsgrdfile = '/data/project5/kesf/ROMS/L2_SCB/grid/roms_grd.nc';
    wavefilename = '/data/project6/friederc/macmods_input/era5/';
    romsfilename = '/data/project6/friederc/macmods_input/l2interp/';

%% GLOBAL Biological parameters used by MAG

    global param % made global and used by most functions; nothing within code changes param values
    param = param_macrocystis; % should have a file per species


%% Grid and farm properties
    % 1. ROMS grid - extract from grid file
    farm = farmdesign;  % loads 1-d farm
    romsgrid_full = loadromsgrid;
    romsgrid_full = loadkelpmask(romsgrid_full,farm.z_cult);

    % Simulation Input
    year = 1998
    time = simtime([year 1 1; year 12 31]); % start time and stop time of simulation
    %time = simtime([year-1 12 1; year 11 31]); % start time and stop time of simulation
    
    % work on a sub grid
    msplit = [1 352; 353 705; 706 1058; 1059 1412];
    for subgrid = 3:4
  
        % Modify grid
        romsgrid = loadsubgrid(romsgrid_full,subgrid,msplit);
        
        % These are huge files; having them loaded in memory only works on
        % poseidon
        roms = loadroms(romsfilename,year,subgrid);
        waves = loadwaves(wavefilename,year,subgrid,msplit);

        % Simulation Output
        fout_mag = sprintf('/data/project6/friederc/macmods_output/mag_l2scb_%d-%d.mat',[year subgrid]);
        %create_netcdf_mag(fout_mag,romsgrid.NY,romsgrid.NX,length(time.timevec_ROMS))
        foutd_mag.biomass = NaN(romsgrid.NY,romsgrid.NX,length(time.timevec_ROMS));
        foutd_mag.harvest_Nf = NaN(romsgrid.NY,romsgrid.NX,length(time.timevec_ROMS));
        foutd_mag.harvest_Ns = NaN(romsgrid.NY,romsgrid.NX,length(time.timevec_ROMS));
        foutd_mag.harvest_B = NaN(romsgrid.NY,romsgrid.NX,length(time.timevec_ROMS));
        foutd_mag.harvest_n = NaN(romsgrid.NY,romsgrid.NX,length(time.timevec_ROMS));

        
    %% Loop through grid cells
    for m = 1:romsgrid.NY
    disp(m)
    disp(datetime)
    for n = 1:romsgrid.NX
    
        % only loop if within kelp mask
        if romsgrid.kelp_mask(m,n)
        
        %% Seed the Farm (Initialize Biomass)
        % initial conditions (B,Q) set in farmdesign
        % [frond ID, depth]
        
        %%%%%% https://www.mathworks.com/help/matlab/import_export/load-parts-of-variables-from-mat-files.html
        [kelp, harvest] = seedfarm(romsgrid,farm,time);
        
        %% ROMS-BEC ENVT
        % load ROMS-BEC data for full time at one location
        envt = loadenvt(roms,waves,m,n);
                
        %% GROWTH MODEL
        % updates Nf, Ns with uptake, growth, mortality, senescence
        % calculates DON and PON%% MAG growth -> set up as dt_Gr loop for duration of simulation
        bt = 0; % placeholder for harvest threshold
        for sim_hour = time.dt_Gr:time.dt_Gr:time.duration % [hours]

            gr_counter = sim_hour / time.dt_Gr;% growth counter
            envt_counter = ceil(gr_counter*time.dt_Gr/time.dt_ROMS); % ROMS counter
    
        
                %% DERIVED BIOLOGICAL CHARACTERISTICS
                kelp = kelpchar(kelp,farm);
            
                %% DERIVED ENVT
                % an interpolated product to farm.z_arr
                envt.PARz  = canopyshading(kelp,envt,farm,envt_counter);
                
                %% MAG Model; uptake, growth, mortality
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
                   if isnan(max(harvest.counter(:)))
                       harvest.counter(gr_counter) = 1;
                   else
                       harvest.counter(gr_counter) = max(harvest.counter) + 1;
                   end

                   % chop off the canopy and store it in harvest structure
                   [harvest, kelp] = harvest_crit(harvest,kelp,farm,gr_counter);

                end
                end

                % Output
                kelp_b(gr_counter) = trapz(farm.z_arr,kelp.Nf)./param.Qmin./1e3; % kg-dry/m
                
        end % end of mag 
                
        foutd_mag.biomass(m,n,:) = kelp_b;
        foutd_mag.harvest_Nf(m,n,:) = harvest.canopyNf;
        foutd_mag.harvest_Ns(m,n,:) = harvest.canopyNs;
        foutd_mag.harvest_B(m,n,:) = harvest.canopyB;
        foutd_mag.harvest_n(m,n,:) = harvest.counter;

        end % kelp mask

    end % n loop
    end % m loop
    
    save(fout_mag,'foutd_mag','-v7.3')
%     ncwrite(fout_mag,'biomass',foutd_mag.biomass)
%     ncwrite(fout_mag,'harvest Nf',foutd_mag.harvest_Nf)
%     ncwrite(fout_mag,'harvest Ns',foutd_mag.harvest_Ns)
%     ncwrite(fout_mag,'harvest B',foutd_mag.harvest_B)
%     ncwrite(fout_mag,'harvest n',foutd_mag.harvest_n)
%     ncwrite(fout_mag,'time',time.timevec_ROMS)

    end % end subgrid    
% end year
    