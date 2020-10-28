function kelp = frondinitiation(kelp,envt,farm,time,gr_counter)
% A new frond is initiated at a rate of Frond_init, and happens as a
% discrete event every 1/Frond_init (hours), dependent on Q

% A new frond = Nf equivalent of 1 m (Nf_capacity) initiated at cultivation
% depth


global param


%% NEW FROND
% how many hours should it be between initiation?
initiate = 1 / (param.frond_init(1) * kelp.Q + param.frond_init(2)); % from per hour to hours
    
        % Just in case Q is > 40; but it shouldn't be ...
        if kelp.Q > 40
            initiate = 1/ (param.frond_init(1) * 40 + param.frond_init(2));
        end

%% Evaluate whether or not it is time to start a new frond
% if Current hours is greater than initiation of the "lastFrond" -> YES

    % light conditions at cultivation depth must be greater than
    % compensating light irradiance (PARc) 
    
    if envt.PARz(farm.z_cult) > param.PARc
        
        if gr_counter * time.dt_Gr >= max(kelp.fronds.start_age) + initiate
        
            % add Nf and Ns
            kelp.Nf(farm.z_cult) = kelp.Nf(farm.z_cult) + 109.98;
            kelp.Ns(farm.z_cult) = kelp.Ns(farm.z_cult) + (kelp.Q-param.Qmin)*109.98/param.Qmin;

            % Frond characteristics
            next = max(kelp.fronds.id)+1;
            kelp.fronds.id(next) = next; % add a frond
            kelp.fronds.start_age(next) = gr_counter * time.dt_Gr;
            kelp.fronds.end_age(next) = gr_counter * time.dt_Gr + param.age_max;
            kelp.fronds.status(next) = 1;
            
        end
        
    end

    
end    
