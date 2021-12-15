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
    canopyHeight = kelp.height-(farm.z_cult+param.z_canopy); canopyHeight(canopyHeight<1) = 1;
    
    % below I am redistributing "canopy"; ...
    Nf(farm.z_arr > param.z_canopy) = Nf(farm.z_arr > param.z_canopy) ./ canopyHeight; 
    
    % replacement of NaN with zero for mathematical reasons; although
    % shouldnt be any NaN
    Nf(isnan(Nf)) = 0; 

    
%% Attenuation of PAR with depth

    % PAR, incoming
    PARo = envt.PAR(1,envt_counter);

    % preallocate space
    PARz=NaN(farm.nz,1);

% Calculate attenuation coefficents and resulting PAR from surface to
% cultivation depth
    
    for zz = length(farm.z_arr):-1:1
        z = farm.z_arr(zz);
        
        if z == 0 
            
        PARz(zz) = PARo; % no attenuation at surface
           
        else
            
        % attenuate with sum of three contributions
        K = param.PAR_Ksw * farm.dz...
	   + param.PAR_Kchla * envt.chla(zz,envt_counter)*farm.dz...
	   + param.PAR_KNf * Nf(zz+1) * farm.dz;

        PARz(zz) = PARz(zz+1) .* (exp(-K)); % output variable
               
        end
            
    end
       
end
