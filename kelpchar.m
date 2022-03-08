function kelp = kelpchar(kelp,farm)
% Calculate biological characteristics from Nf, Ns (known)
%
% OUTPUT:  
%   Q
%   Biomass
%   depth resolved surface_area-to-biomass
%   height (total height in m)
%   frBlade, fractional biomass that is blade
%
% NOTES:
% Q is integrated across depth, Rassweiler et al. (2018) found that %N does
% not vary with depth. This can be interpreted as translocation occuring on
% the scale of hours (Parker 1965, 1966, Schmitz and Lobban 1976). Side
% note: Ns is redistributed after uptake as a function of fractional Nf.
% This is how the model "translocates" along a gradient of high-to-low
% uptake. Mathematically, this keeps Q constant with depth. -> There may be
% more recent work coming out of SBC LTER that indicates %N varies along
% the frond, particularly in the canopy in a predictable age-like matter
% (e.g., what tissues are doing most of the photosynthesis) (T. Bell pers.
% comm.)
%
% Biomass calculation from Hadley et al. (2015), Table 4 [g(dry)/dz]
%                
% Surface area to biomass
%
% Blade-to-stipe ratio derived from Nyman et al. 1993 Table 2
  

global param
%% Calculate DERIVED variables on a per frond basis

    % KNOWN STATE VARIABLES
    % Ns, Nf 
    
    % DERIVED VARIABLES
        
        % no nan
        temp_Ns = find_nan(kelp.Ns);
        temp_Nf = find_nan(kelp.Nf);
        
        kelp.Q = param.Qmin .* (1 + trapz(farm.z_arr,temp_Ns) ./ trapz(farm.z_arr,temp_Nf));
        kelp.B = kelp.Nf ./ param.Qmin; % grams-dry
        
        %surface-area to biomass conversion (depth resolved)
        % canopy forming (has more surface area in canopy
        kelp.sa2b = NaN(farm.nz,1);
        if any(kelp.Nf(farm.z_arr > param.z_canopy) > 0)
        kelp.sa2b(farm.z_arr >= param.z_canopy) = param.Biomass_surfacearea_canopy;
        kelp.sa2b(farm.z_arr < param.z_canopy) = param.Biomass_surfacearea_watercolumn;
        else
        kelp.sa2b(1:farm.nz) = param.Biomass_surfacearea_subsurface;
        end
        
        %DPD edit
        temp_B = find_nan(kelp.B);
        kelp.height = (param.Hmax .* trapz(farm.z_arr,temp_B)./1e3 )./ (param.Kh + trapz(farm.z_arr,temp_B)./1e3);
        
        % Blade to Stipe for blade-specific parameters
           
            % generate a fractional height
            fh = diff(farm.z_arr)';
            fh(end+1) = fh(end);
            fh = cumsum(fh);
            
            fhn = fh .* squeeze((kelp.B > 0));
            %fh = fh .* ~isnan(kelp.B);
            %disp('fh pre'), fh
            fhN = fhn./ kelp.height; 
            fhN(fhN==0) = NaN;
            fhN(fhN>1) = 1;
            
            
	        BtoS = param.Blade_stipe(1) - param.Blade_stipe(2) .* fhN + param.Blade_stipe(3) .* fhN .^ 2;
	    
            kelp.frBlade = BtoS ./ (BtoS + 1);
            clear fh fhn fhN BtoS
            
        % biomass per m (for growth)
        kelp.b_per_m = make_Bm(kelp.height,farm);
        


end
