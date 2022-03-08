function kelp = frondinitiation(kelp,envt,farm,time,gr_counter)
% A new frond is initiated at a rate of Frond_init, and happens as a
% discrete event every 1/Frond_init (hours), dependent on Q

% A new frond = Nf equivalent of 1 m (Nf_capacity) initiated at cultivation
% depth


global param

Nf = kelp.Nf;
Ns = kelp.Ns;
Q = kelp.Q;
start_age = kelp.fronds(:,2);
id = kelp.fronds(:,1);

%% NEW FROND
% how many hours should it be between initiation?
initiate = 1 / (param.frond_init(1) * Q + param.frond_init(2)); % from per hour to hours
    
        % Just in case Q is > 40; but it shouldn't be ...
        if Q > 40
            initiate = 1/ (param.frond_init(1) * 40 + param.frond_init(2));
        end

%% Evaluate whether or not it is time to start a new frond
% if Current hours is greater than initiation of the "lastFrond" -> YES

    % light conditions at cultivation depth must be greater than
    % compensating light irradiance (PARc) 
    %disp('PARz Par C'), envt.PARz(abs(farm.z_arr) == farm.z_cult) 
    %disp('PAR bot'), envt.PARz(1)
    %disp('PARc'), param.PARc
    %if envt.PARz(abs(farm.z_arr) == farm.z_cult) > param.PARc
    if envt.PARz(1) > param.PARc % bottom grid cell is cultivation depth
        %disp('maxf'), max(kelp.fronds.start_age)
        %disp('initiate'), initiate	
        %disp('max start'), max(kelp.fronds.start_age) + initiate   
        
        if gr_counter * time.dt_Gr >= max(start_age) + initiate
        
            % add Nf and Ns
            %kelp.Nf(1) = kelp.Nf(1) + 109.98;
            %kelp.Ns(1) = kelp.Ns(1) + (kelp.Q-param.Qmin)*109.98/param.Qmin;
            kelp.Nf(farm.z_arr == -farm.z_cult) = Nf(farm.z_arr == -farm.z_cult) + 109.98;
            kelp.Ns(farm.z_arr == -farm.z_cult) = Ns(farm.z_arr == -farm.z_cult) + (Q-param.Qmin)*109.98/param.Qmin;
            %disp('frondinit'), gr_counter * time.dt_Gr
            % Frond characteristics
            next = max(id)+1;
            
            kelp.fronds(next,1) = next; % add a frond
            kelp.fronds(next,2) = gr_counter * time.dt_Gr;
            kelp.fronds(next,3) = gr_counter * time.dt_Gr + param.age_max;
            kelp.fronds(next,4) = 1;
            
        end
        
    end

    
end    
