function [Growth, gQ_fr, gT_fr, gE_fr, gH_fr] = growth(kelp,envt,farm,ROMS_step)
% Growth, nitrogen movement from Ns to Nf = umax*gQ*gT*gE*gH; [per hour]
%
% Input: (Q,Type,Height,envt,farm,envt_step,kelploc)
%        Growth only calculated for subsurface and canopy fronds
%
% Output: 
%   Growth, [h-1]
%   gQ, quota-limited growth 
%       from Wheeler and North 1980 Fig. 2   
%   gT, temperature-limited growth
%       piecewise approach taken from Broch and Slagstad 2012 (for sugar
%       kelp) and optimized for Macrocystis pyrifera
%       calls on gT_vX
%   gE, light-limited growth
%       from Dean and Jacobsen 1984
%       calls on gE_vX
%   gH, Sigmoidal rate decrease starting at 5% below max height
%       essential a mathematical function to have smoothed, slowed growth
%       rather than abrupt growth changes at max_height


global param

%% Kelp Input
Q = kelp.Q;
type = kelp.type;
Height_tot = kelp.Height_tot;
        

%% gQ -> ranges from zero to 1

    % Fronds, either subsurface or canopy, don't calc for senescing
    % A trick so that senescing fronds do NOT grow (same approach applied
    % in uptake
    frond = type == 1 | type == 2;

    gQ_fr = NaN(length(Q),1); 
    gQ_fr(frond) = (Q(frond) - param.Qmin) ./ (param.Qmax - param.Qmin); 
    gQ_fr(gQ_fr > 1) = 1;
    gQ_fr(gQ_fr < 0) = 0;
    
    
%% gT -> ranges froms zero to 1

    % temp data
    temp = envt.T(1:farm.z_cult,ROMS_step);
    
    gT = NaN(size(temp)); % preallocate space
        
        gT(temp < param.Tmin) = 1/param.Tmin * temp(temp < param.Tmin);
        gT(temp >= param.Tmin & temp < param.Tmax) = 1;
        
            % Solve systems of equations where Tmax = 1; Tlim = 0;
            % Linear decrease from Tmax to Tlim with intercept b and slope m
            
            b = 1 / (-param.Tmax / param.Tlim + 1);
            m = 1 / (param.Tmax - param.Tlim);
            
        gT(temp >= param.Tmax & temp <= param.Tlim) = m .* temp(temp >= param.Tmax & temp <= param.Tlim) + b;
        gT(temp > param.Tlim) = 0;

    gT_fr = repmat(gT,1,length(Q))'; % repeat temperature effect across all fronds
    clear gT temp
    
    
%% gE -> ranges from zero to 1
% light varies across the farm, so extract correct light field with kelploc
% Bertalanffy Growth Equation (Dean and Jacobsen 1984)
% Input: PAR [W/m2]

    % k sets curvature of relationship. qualitatively fit to match Dean
    % and Jacobsen 1984; 50% growth at PAR ~2.5 and near 100% growth at
    % PAR ~7+
        
        gE = 1-exp(param.kPAR*(envt.PARz-param.PARc));
        
        % If values < 0 replace with zero. We are explicitely modeling
        % mortality and so growth shouldn't be negative.
        gE(gE < 0) = 0;
        
    gE_fr = repmat(gE,1,length(Q))'; % repear PAR effect across all fronds
    clear gE PAR
       
        
%% gH -> ranges from zero to 1           

    % as frond approaches Hmax ... growth approaches zero -> a mathematical
    % solution to incorporate height limit
    gH_fr = 0.5 + 0.5 .* tanh(-(Height_tot - (param.Hmax-0.05*param.Hmax)));
    

%% Growth
% per hour

    Growth = param.umax .* gQ_fr .* gT_fr .* gE_fr .* gH_fr;


end