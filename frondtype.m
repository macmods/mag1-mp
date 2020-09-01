function type = frondtype(Nf,age,farm)
% Categorizes the frond into one of four categories: (1) SUBSURFACE = frond
% has not reachd the surface, criteria is that Nf at cultivation depth > 0
% (2) CANOPY = frond has reached the surface, criteria is that Nf at
% surface is > 0 (3) SENESCING = frond that is older than Mortality_age (4)
% DEAD = there is no Nf at cultivation depth, criteria is that Age is >
% Mortality_age and senescence is complete (Nf == NaN)
%
% Output:
%   type(subsurface,canopy,senescing)
%   1 = subsurface
%   2 = canopy
%   3 = senescing
           
global param

% preallocate space
type = NaN(size(Nf,1),1);
               
%% SUBSURFACE                    
% if Nf at cultivation depth is > 0 = subsurface frond

   type(Nf(:,farm.z_cult) > 0) = 1;

%% CANOPY
% if Nf at surface is > 0 = canopy frond; this will replace
% replaces subsurface category with canopy

   type(Nf(:,1) > 0) = 2;


%% SENESCING
% 1. AGE-BASED SENESCENCE
   % if Age is > 1/Mortality_age and Nf still around; type is
   % senescing

   type(age >= param.Age_max & Nf(:,farm.z_cult) > 0) = 3;

% 2. HARVESTED-BASED SENESCENCE
   % indicator for harvested frond is Age == 9999

   type(age == 9999) = 3;
                          
                      
end    