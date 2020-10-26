function [kelp, DON, PON] = mag(kelp,envt,farm,time,envt_counter,growth_step)
% Calculate uptake and growth to derive delta_Ns and delta_Nt
% function dependencies: uptake, growth
%
% Input: kelp_fr, envt, farm, time, envt_step, growth_step
% Output: kelp_fr at t+1


global param
                
            
%% KELP - Known Variables
% create temporary variables

    Ns = kelp.Ns;
    Nf = kelp.Nf;
                
                
%% UPTAKE
% [mg N/g(dry)/h]: NO3+NH4+Urea

    Uptake = uptake(kelp,envt,farm,envt_counter);   

    
%% GROWTH
% Growth limited by internal nutrients, temperature, PAR, and height (stops
% growing once reaches max height); [h-1]

    Growth = growth(kelp,envt,farm,envt_counter);       
           
%% MORTALTIY                
% d_wave = frond loss due to waves; dependent on Hs, significant
% wave height [m]; Rodrigues et al. 2018 demonstrates linear relationship
% between Hs and frond loss rate [h-1] (continuous)

    M_wave  = param.d_wave_m .* envt.Hs(1,envt_counter);

% d_blade = blade erosion [h-1] (continuous); Multiplied by the
% frBlade -> fraction of total as blade
    
    M_blade = param.d_blade .* kelp.frBlade;  
    M_tot = M_wave + M_blade + param.d_frond;
    
    
%% Nf at t+1
            
% Nf(t+1) = Nf(t) + Growth - Mortality

     % change in Nf
     dNf1 = Growth .* Ns .* time.dt_Gr ...
          - M_tot .* Nf .* time.dt_Gr;

     Nf_new = Nf + dNf1; % add dNf to Nf

     
%% APICAL GROWTH
% Nf redistributed upwards if Nf > Nf_capacity. 

    % get total height for Nf_new
    B_new = nansum(Nf_new) ./ param.Qmin; % g-dry
    h_new = (param.Hmax .* B_new./1e3) ./ (param.Kh + B_new./1e3);
    
    z_up = 1;
    for z = farm.z_cult:-1:farm.z_cult-floor(h_new)
    
        B_z = (H1 .* param.Kh) ./ (param.Hmax - H1); % g-dry
    
        % delNf is the amount of biomass greater than
        % Nf_capacity. Nf_capacity was previously derived and
        % is dependent on height as kelp transitions from
        % subsurface to canopy.
        delNf = NaN(size(Nf_new(:,z)));       
        delNf(Nf_new(:,z) > Nf_capacity) = Nf_new(Nf_new(:,z) > Nf_capacity,z) - Nf_capacity(Nf_new(:,z) > Nf_capacity); % then calculate the amount of Nf beyond capacity...
        delNf(Nf_new(:,z) <= Nf_capacity) = 0;

        % redistribute Nf based upon a carrying capacity
        Nf_new(delNf>0,z-1) = nansum([delNf(delNf>0) Nf_new(delNf>0,z-1)],2);
        Nf_new(delNf>0,z) = Nf_capacity_new(delNf>0);

    end
    clear z delNf
                
                
%% Ns at t+1
% Because Ns is redistributed based on distribution of Nf -> we calculated
% Nf(t+1) first and now follow-up with Ns

% Ns(t+1) = Ns(t) + Uptake - Growth - Mortality 
% For uptake, only biomass in blades (frBlade) contributes 

    dNs1 = Uptake .* kelp.B .* kelp.frBlade .* time.dt_Gr ... % uptake contribution from blades only
         - Growth .* Ns .* time.dt_Gr ... % stored nitrogen lost due to growth
         - param.d_dissolved .* Ns .* time.dt_Gr ... % exudation term
         - M_blade .* Ns .* time.dt_Gr ... % blade erosion term
         - M_wave .* Ns .* time.dt_Gr; % wave-based mortality

    dNs1_sum = sum(cat(3,Ns,dNs1),3);  % add dNs to Ns

% redustribute (translocation) as a function of fractional Nf

    fNf = Nf_new ./ nansum(Nf_new,2);
    Ns_new = nansum(dNs1_sum,2) .* fNf; % Ns at t+1


%% WHOLE-FROND SENESCENCE
            
% If Type is senescing (Type == 3), Nf and Ns decrease at a rate of
% moartlity_frond;

    Ns_new(kelp.type==3,:) = Ns(kelp.type==3,:) - Ns(kelp.type==3,:) .* param.d_frond .* time.dt_Gr;
    Nf_new(kelp.type==3,:) = Nf(kelp.type==3,:) - Nf(kelp.type==3,:) .* param.d_frond .* time.dt_Gr;


% If type == senescing && Nf and Ns below threshold set Nf and Ns to NaN
% Threshold set to be 10% of Nf_capacity

    Nf_new(kelp.type==3  & Nf(:,farm.z_cult) < 0.1 * param.Nf_capacity_subsurface,:) = NaN;
    Ns_new(kelp.type==3  & Nf(:,farm.z_cult) < 0.1 * param.Nf_capacity_subsurface,:) = NaN;
    Age_new(kelp.type==3 & Nf(:,farm.z_cult) < 0.1 * param.Nf_capacity_subsurface,:) = NaN; % stop existing


%% DON, PON

% DON, the amount of kelp contribution to DON; [mg N] -> [mmol N/m3]
%   There are four sources of DON contribution from the Ns pool
%   1. dissolved loss
%   2. blade erosion
%   3. wave-based mortality
%   2. senescence

    DON = ...
       (  nansum(param.d_dissolved .* Ns) .* time.dt_Gr ...
       +  nansum(M_blade .* Ns) .* time.dt_Gr ...
       +  nansum(M_wave .* Ns) .* time.dt_Gr ...
       +  nansum(param.d_frond .* Ns(kelp.type==3,:)).* time.dt_Gr ) ...
       ./ param.MW_N;
  
   
% PON, the amount of kelp contribution to PON; [mg N/m3]
%   There are three sources of PON contribution from the Nf pool
%   1. blade erosion
%   2. wave-based mortality
%   3. senescence

    PON = ...
       (  nansum(param.d_blade .* Nf) .* time.dt_Gr ...
       +  nansum(M_wave .* Nf) .* time.dt_Gr ...
       +  nansum(param.d_frond .* Nf(kelp.type==3,:)) .* time.dt_Gr);

                          
%% NEW FROND
% A new frond is initiated at a rate of Frond_init, and happens as a
% discrete event every 1/Frond_init (hours), dependent on Q

% A new frond = Nf equivalent of 1 m (Nf_capacity) initiated at cultivation
% depth

    initiate = 1 / (param.Frond_init(1) * nanmean(kelp.Q) + param.Frond_init(2)); % from per hour to hours
    
        % Just in case Q is > 40; but it shouldn't be ...
        if nanmean(kelp.Q) > 40
            initiate = 1/ (param.Frond_init(1) * 40 + param.Frond_init(2));
        end

% Evaluate whether or not it is time to start a new frond
% if Current hours is greater than initiation of the "lastFrond" -> YES

    % light conditions at cultivation depth must be greater than
    % compensating light irradiance (PARc) and smallest frond must be at
    % least 1.1 meters (the model is fairly sensitive to this latter term
    % of 1.1 ... if it's smaller -> get more fronds and thus biomass
    if envt.PARz(farm.z_cult) > param.PARc && min(kelp.Height_tot) > 1.1
        if growth_step * time.dt_Gr >= kelp.lastFrond + initiate %lastFrond is the hour of simulation last frond was intitiated
        [Nf_new, Ns_new, Nf_capacity_new, Age_new, kelp.ID] = frondinitiation(kelp.Q,kelp.ID,Nf_new,Ns_new,Nf_capacity_new,Age_new,farm);
        kelp.lastFrond = growth_step; % replace with current hour of simulation
        end
    end
    clear initiate         

    
%% UPDATE STATE VARIABLES
% Note, these replace existing matrices (don't append)

kelp.Nf = Nf_new;
kelp.Ns = Ns_new;
kelp.Nf_capacity = Nf_capacity_new;
kelp.Age = Age_new;

end