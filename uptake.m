function [UptakeN, UptakeFactor] = uptake(kelp,envt,farm,envt_counter)
% Determination of uptake rate for nitrate, ammonium, and urea.
%
%   Input: (ENVT,Q,Type,farm)
%           NO3 = nitrate concentration in seawater [umol NO3/m3]
%           NH4 = ammonium concentration in seawater [umol NH4/m3]
%           DON = dissolved organic nitrogen concentration [mmol/m3]
%           mag_u = seawater velocity [m/h]; magnitude velocity of x,y,z
%           Tw = wave period [h]
%           Type = 'subsurface/canopy' for conversion from surface area to
%           g(dry)
%           FARM_DIM = dimensions of farm needed for allometric
%           equations
%
%    Output:
%           Uptake, [mg N/g(dry)/h]; converted from [umol NO3+NH4+N/m2/h]
%           UptakeFactor.UptakeFactor_NO3/NH4/DON, dimensionless; 0-1 
%           UptakeFactor.Uptake_NOS/NH4/DON_mass, [umol NO3;NH4;N /g(dry)/h]
%
%    Note -> Uptake is only calculated for Canopy and Subsurface fronds. If
%    fronds are senscing, uptake not determined (NaN).


global param


%% ENVT INPUT

%NO3 = envt.NO3(1:farm.z_cult,envt_counter);
%NH4 = envt.NH4(1:farm.z_cult,envt_counter);
%DON = envt.DON(1:farm.z_cult,envt_counter);
%magu = envt.magu(1:farm.z_cult,envt_counter);

%DPD edit
NO3 = envt.NO3(1:farm.nz,envt_counter);
NH4 = envt.NH4(1:farm.nz,envt_counter);
DON = envt.DON(1:farm.nz,envt_counter);
magu = envt.magu(1:farm.nz,envt_counter);
Tw = envt.Tw(1,envt_counter);


%% Q                                        
% Quota-limited uptake: maximum uptake when Q is minimum and
% approaches zero as Q increases towards maximum; Possible that Q
% is greater than Qmax. Set any negative values to zero.

        UptakeFactor.vQ = (param.Qmax-kelp.Q)./(param.Qmax-param.Qmin);
        
        % Ensure that uptake doesn't take a negative value
        UptakeFactor.vQ(UptakeFactor.vQ < 0) = 0;
        UptakeFactor.vQ(UptakeFactor.vQ > 1) = 1;
        %disp('Vq'),UptakeFactor.vQ

        % Michaelis-Menten: Kinetically limited uptake only, for
        % exploratory, information purposes only. Not used to determine
        % Uptake rates
                
                 %vMichaelis_NO3 = NO3./(param.KsNO3+NO3); 
                 %vMichaelis_NH4 = NH4./(param.KsNH4+NH4);
                 %vMichaelis_DON = DON./(param.KsDON+DON);

%% v(Tw,Hs,[N])                 
% Kinetic+Mass-Transfer Limited Uptake: derivation from Stevens and
% Hurd 1997, Eq. 11

        % CONSTANTS

            % visc = kinematic viscosity; [m2/h] 

            % Dm = molecular diffusion coefficient; [m2/h] *** Dm = T *
            % 3.65e-11 + 0.72e-10; determined for 18C (Li and Gregory
            % 1974);

            % n_length = number of iterations of wave-driven currents;
            % selected based on number of iterations attaining 95% of
            % maximum value for n_length = 1000

                visc     = 10^-6*60*60; 
                Dm       = (18*3.65e-11 + 9.72e-10)*60*60; 
                n_length = 25; 

            % Diffusive Boundary Layer [m] Stevens and Hurd (1997) argued
            % that the high coefficient of u_star (0.33*u) was required to
            % match whole-frond drag estimates at low velocities

                DBL = 10 .* (visc ./ (0.33 .* abs(magu)));
                %disp('DBL'), DBL
        % There are two components of flow being considered. Calculate
        % contribution of each to uptake.

            % 1. Oscillatory Flow
                %dpd edit
                val = NaN(farm.nz,n_length);
                for n = 1:n_length
                    val(:,n) = (1-exp((-Dm.*n^2*pi^2.*Tw)./(2.*DBL.^2)))/(n^2*pi^2);
                end

                Oscillatory = ((4.*DBL)./Tw) .* sum(val,2);
                %disp ('Oscillatory'), Oscillatory
            % 2. Uni-directional Flow

                Flow = Dm ./ DBL;
		%disp('Flow'), Flow

        % Mass-Transfer Limitation is the sum of these two types of flows

                Beta   = Flow + Oscillatory; 

        % Kinetic+Mass-Transfer Limited Uptake, bring different components
        % to calcualte the Uptake Factor from Eq. 11 from Stevens and Hurd
        % 1997

                lambdaNO3 = 1 +  (param.VmaxNO3 ./ (Beta.*param.KsNO3)) - (NO3 ./ param.KsNO3);
                lambdaNH4 = 1 +  (param.VmaxNH4 ./ (Beta.*param.KsNH4)) - (NH4 ./ param.KsNH4);
                lambdaDON = 1 +  (param.VmaxDON ./ (Beta.*param.KsDON)) - (DON.*0.2.*1e3 ./ param.KsDON); % DON*0.2 = [urea]
                %disp('lambdaNO3'), lambdaNO3(1)
                %disp('lambdaNH4'), lambdaNH4(1)
                %disp('lambdaDON'), lambdaDON(1)



                % Below is what we call "Uptake Factor." It varies betwen 0
                % and 1 and includes kinetically limited uptake and
                % mass-transfer-limited uptake (oscillatory +
                % uni-directional flow)

                UptakeFactor.UptakeFactor_NO3 = NO3 ./ (param.KsNO3 .* ((NO3./param.KsNO3)  + 1/2 .* (lambdaNO3+sqrt(lambdaNO3.^2 + 4 .* (NO3 ./ param.KsNO3)))));
                UptakeFactor.UptakeFactor_NH4 = NH4 ./ (param.KsNH4 .* ((NH4./param.KsNH4)  + 1/2 .* (lambdaNH4+sqrt(lambdaNH4.^2 + 4 .* (NH4 ./ param.KsNH4)))));
                UptakeFactor.UptakeFactor_DON = DON.*0.2.*1e3 ./ (param.KsDON .* ((DON.*0.2.*1e3./param.KsDON)  + 1/2 .* (lambdaDON+sqrt(lambdaDON.^2 + 4 .* (DON.*0.2.*1e3 ./ param.KsDON)))));
                %disp('UptFNO3'), UptakeFactor.UptakeFactor_NO3(1)
                %disp('UptFNH4'), UptakeFactor.UptakeFactor_NH4(1)
                %disp('UptFDON'), UptakeFactor.UptakeFactor_DON(1)


        % Uptake Rate CALCULATION, for each N source

                % Nutrient Uptake Rate = Max Uptake * UptakeFactor
                % [umol N/m2/h]

                    Uptake_NO3 = param.VmaxNO3 .* UptakeFactor.UptakeFactor_NO3; 
                    Uptake_NH4 = param.VmaxNH4 .* UptakeFactor.UptakeFactor_NH4; 
                    Uptake_DON = param.VmaxDON .* UptakeFactor.UptakeFactor_DON; 

                % Convert from surface area to g(dry). Based on
                % allometric conversions from param that
                % are dependent on kelp type (subsurface, canopy,
                % watercolumn)
                % [umol N/g(dry)/h]

                % and multiply by Q limitation (vQ)
                %disp('kelp type'), kelp.type
                if kelp.type == 1
                    
                    UptakeFactor.Uptake_NO3_mass = Uptake_NO3 .* param.Biomass_surfacearea_subsurface*2 ./ param.dry_wet .* UptakeFactor.vQ;
                    UptakeFactor.Uptake_NH4_mass = Uptake_NH4 .* param.Biomass_surfacearea_subsurface*2 ./ param.dry_wet .* UptakeFactor.vQ;
                    UptakeFactor.Uptake_DON_mass = Uptake_DON .* param.Biomass_surfacearea_subsurface*2 ./ param.dry_wet .* UptakeFactor.vQ;
                    
                elseif kelp.type == 2
                    
                    UptakeFactor.Uptake_NO3_mass(1,1) = Uptake_NO3(1) .* param.Biomass_surfacearea_canopy*2 ./ param.dry_wet .* UptakeFactor.vQ;
                    UptakeFactor.Uptake_NO3_mass(2:farm.z_cult,1) = Uptake_NO3(2:farm.z_cult) .* param.Biomass_surfacearea_watercolumn*2 ./ param.dry_wet .* UptakeFactor.vQ;

                    UptakeFactor.Uptake_NH4_mass(1,1) = Uptake_NH4(1) .* param.Biomass_surfacearea_canopy*2 ./ param.dry_wet .* UptakeFactor.vQ;
                    UptakeFactor.Uptake_NH4_mass(2:farm.z_cult,1) = Uptake_NH4(2:farm.z_cult) .* param.Biomass_surfacearea_watercolumn*2 ./ param.dry_wet .* UptakeFactor.vQ;

                    UptakeFactor.Uptake_DON_mass(1,1) = Uptake_DON(1) .* param.Biomass_surfacearea_canopy*2 ./ param.dry_wet .* UptakeFactor.vQ;
                    UptakeFactor.Uptake_DON_mass(2:farm.z_cult,1) = Uptake_DON(2:farm.z_cult) .* param.Biomass_surfacearea_watercolumn*2 ./ param.dry_wet .* UptakeFactor.vQ;

                end
                
                % Convert from umol -> mg N
                % [mg N/g(dry)/h]

                    Uptake_NO3_massN = UptakeFactor.Uptake_NO3_mass .* param.MW_N ./ 1e3; 
                    Uptake_NH4_massN = UptakeFactor.Uptake_NH4_mass .* param.MW_N ./ 1e3;
                    Uptake_DON_massN = UptakeFactor.Uptake_DON_mass .* param.MW_N ./ 1e3;


%% TOTAL Uptake = Uptake NO3 + Uptake NH4 + Uptake DON
% [mg N/g(dry)/h]

    UptakeN = Uptake_NO3_massN + Uptake_NH4_massN + Uptake_DON_massN;
    UptakeN(isnan(kelp.Nf)) = NaN; % only retain values where kelp is present

end
