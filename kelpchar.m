function kelp = kelpchar(kelp,farm)
% Calculate biological characteristics from Nf, Ns, and Age (known)
% function dependency: type_vX.m, height_vX.m
%
% OUTPUT:  
%   Q
%   Biomass
%   Type
%   Height and Height_tot
%   frBlade, fractional biomass that is blade
%   kelp_ar.Nf, assemble data from per frond to per area and smooth in
%   canopy
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
% Biomass calculation from Hadley et al. (2015), Table 4 [g(dry)/frond/dz]
%                
% Type of frond: following SBC LTER designation 
%   1 = subsurface
%   2 = canopy
%   3 = senescing
%            
% Blade-to-stipe ratio derived from Nyman et al. 1993 Table 2
  

global param
%% Calculate DERIVED variables on a per frond basis

    % KNOWN STATE VARIABLES
    % Ns, Nf, Age known 
    % Create temporary variables
    
        Ns = kelp.Ns;
        Nf = kelp.Nf;
        Age= kelp.Age;


    % DERIVED VARIABLES
    
        kelp.Q = param.Qmin .* (1 + nansum(Ns,2) ./ nansum(Nf,2));
        kelp.B = Nf ./ param.Qmin;
        kelp.type = frondtype(Nf,Age,farm);
        kelp.Height = frondheight(Nf,farm);
        kelp.Height_tot = nansum(kelp.Height,2);
            kelp.Height_tot(kelp.Height_tot == 0) = NaN;

        % Blade to Stipe for blade-specific parameters
        fHeight = cumsum(kelp.Height./kelp.Height_tot,2,'reverse'); % fractional frond height (0 at base; 1 at tip)
        BtoS = param.Blade_stipe(1) - param.Blade_stipe(2) .* fHeight + param.Blade_stipe(3) .* fHeight .^ 2;
        kelp.frBlade = BtoS ./ (BtoS + 1);

        % preallocate space to uptakeN to be calculated during Uptake
        % function
        kelp.UptakeN = NaN(size(Nf,1),size(Nf,2));
        
        
clear Ns Nf Age fHeight BtoS 
end