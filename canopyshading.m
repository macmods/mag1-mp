function PARz = canopyshading(kelp,envt,farm,envt_counter)
% Bio-optical model, calculates the attenuation of light due to water,
% chl-a (from ROMS) and nitrogen-specific shading. Incoming PAR from ROMS.
% 
% Input: Nf (per m3; not per frond) * already smoothed at canopy
%        envt, farm, step (ENVT data)
% 
% Output: PAR as a function of depth across the entire farm regardless of
% whether there is kelp present in a given area or not.
%

global param

%% Canopy Shading; Nf

    % canopy shading is in fixed nitrogen units
    Nf = kelp.Nf;

    % redistribute amount of Nf at surface 
    canopyHeight = kelp.height-farm.z_cult; canopyHeight(canopyHeight<1) = 1;
    Nf(:,1) = Nf(:,1) ./ canopyHeight; % divide Nf by length of frond

    % replacement of NaN with zero for mathematical reasons   
    Nf(isnan(Nf)) = 0; 

    
%% Attenuation of PAR with depth

    % PAR, incoming
    PARo = envt.PAR(1,envt_counter);

    % preallocate space
    PARz=NaN(farm.z_cult/farm.dz,1);

% Calculate attenuation coefficents and resulting PAR from surface to
% cultivation depth
    
    for z = 1:farm.z_cult
        
        if z==1 
            
        PARz(z) = PARo; % no attenuation at surface
           
        else
            
        % attenuate with sum of three contributions
        K = param.PAR_Ksw .* farm.dz...
                + param.PAR_Kchla .* envt.chla(z,envt_counter)...
                + param.PAR_KNf   .* sum(Nf(z-1));
            
        PARz(z) = PARz(z-1) .* (exp(-K)); % output variable
        
        end
            
    end
       

end