function kelp = kelpchar(kelp,farm)
% Calculate biological characteristics from Nf, Ns (known)
% function dependency: type_vX.m, height_vX.m
%
% OUTPUT:  
%   Q
%   Biomass
%   type
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
% Type of frond: following SBC LTER designation 
%   1 = subsurface
%   2 = canopy
%            
% Blade-to-stipe ratio derived from Nyman et al. 1993 Table 2
  

global param
%% Calculate DERIVED variables on a per frond basis

    % KNOWN STATE VARIABLES
    % Ns, Nf 
    
    % DERIVED VARIABLES
    
        kelp.Q = param.Qmin .* (1 + nansum(kelp.Ns,2) ./ nansum(kelp.Nf,2));
        kelp.B = kelp.Nf ./ param.Qmin; % grams-dry
        kelp.type = frondtype(kelp.Nf,farm);
        kelp.height = (param.Hmax .* nansum(kelp.B,2)./1e3 )./ (param.Kh + nansum(kelp.B,2)./1e3);
        
        % Blade to Stipe for blade-specific parameters
           
            % generate a fractional height
            fh = flip([1:farm.z_cult]);
            fh = fh .* ~isnan(kelp.B);
            fh = fh ./ kelp.height; fh(fh==0) = NaN;
            
            BtoS = param.Blade_stipe(1) - param.Blade_stipe(2) .* fh + param.Blade_stipe(3) .* fh .^ 2;
            kelp.frBlade = BtoS ./ (BtoS + 1);
            clear fh BtoS
        
clear Ns Nf 
end