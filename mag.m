function [kelp, DON, PON] = mag(kelp,envt,farm,time,envt_counter)
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
    M_tot = M_wave + M_blade;
    

%% Ns at t+1
% Because Ns is redistributed based on distribution of Nf -> we calculated
% Nf(t+1) first and now follow-up with Ns

% Ns(t+1) = Ns(t) + Uptake - Growth - Mortality 
% For uptake, only biomass in blades (frBlade) contributes 

    dNs1 = Uptake .* kelp.B .* kelp.frBlade .* time.dt_Gr ... % uptake contribution from blades only
         - Growth .* Ns .* time.dt_Gr ... % stored nitrogen lost due to growth
         - param.d_dissolved .* Ns .* time.dt_Gr ... % exudation term
         - M_tot .* Ns .* time.dt_Gr; % wave-based mortality

    Ns_new = Ns + dNs1;  % add dNs to Ns

    
%% Nf at t+1
            
% Nf(t+1) = Nf(t) + Growth - Mortality

     % change in Nf
     dNf1 = Growth .* Ns .* time.dt_Gr ...
          - M_tot .* Nf .* time.dt_Gr;

     Nf_new = Nf + dNf1; % add dNf to Nf

     
%% APICAL GROWTH
% Nf redistributed upwards if Nf > km3. Evaluate each depth bin
% separately from the bottom towards the surface. The surface is left alone
% so that the canopy accumulates. The surface bin is z=1.

        
    for z = farm.z_cult:-1:2 

        % delNf is the amount of biomass greater than
        % km3. km3 is an input parameter, constant with depth. To improve
        % upon need better distribution data of biomass with depth.
        delNf = NaN(size(Nf_new(:,z)));       
        delNf(Nf_new(:,z) > param.km3) = Nf_new(Nf_new(:,z) > param.km3,z) - param.km3; % then calculate the amount of Nf beyond capacity...
        delNf(Nf_new(:,z) <= param.km3) = 0;

        % redistribute Nf based upon a carrying capacity
        Nf_new(delNf>0,z-1) = nansum([delNf(delNf>0) Nf_new(delNf>0,z-1)],2);
        Nf_new(delNf>0,z) = param.km3;

    end
    clear z delNf
                    
                
%% TRANSLOCATION
% redustribute (translocation) as a function of fractional Nf

    fNf = Nf_new ./ nansum(Nf_new,2);
    Ns_new = nansum(Ns_new,2) .* fNf; % Ns at t+1


%% DON, PON

% DON, the amount of kelp contribution to DON; [mg N] -> [mmol N/m3]
%   There are three sources of DON contribution from the Ns pool
%   1. dissolved loss
%   2. blade erosion
%   3. wave-based mortality

    DON = (nansum(param.d_dissolved .* Ns) .* time.dt_Gr) ...
        +  nansum(M_tot .* Ns) .* time.dt_Gr ...
        ./ param.MW_N;
  
   
% PON, the amount of kelp contribution to PON; [mg N/m3]
%   There are three sources of PON contribution from the Nf pool
%   1. blade erosion
%   2. wave-based mortality

    PON = nansum(M_tot .* Nf) .* time.dt_Gr;

                          

%% UPDATE STATE VARIABLES
% Note, these replace existing matrices (don't append)

kelp.Nf = Nf_new;
kelp.Ns = Ns_new;


end