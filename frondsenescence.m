function kelp = frondsenescence(kelp,time,sim_hour,gr_counter,harvest)
% Identify those fronds that are senescing. This is defined as 2 weeks past
% maximum age. Nf and Ns is lost at a rate of 10% for 10 days for the
% fraction of total fronds that are senescing

global param

    % assess frond status relative to age
    if sim_hour < kelp.fronds(:,3)
    kelp.fronds(:,4) = 1; % alive
    elseif sim_hour > kelp.fronds(:,3)
    kelp.fronds(:,4) = 2; % senesce
    elseif sim_hour > kelp.fronds(:,3)+24*10
    kelp.fronds(:,4) = 3; % dead
    end
    
    % when was the last harvest
    lastharvest = find(~isnan(harvest.counter),1,'last');
    if ~isempty(lastharvest)
        % has it been more than two weeks since last cut
        if time.timevec_Gr(gr_counter) > time.timevec_Gr(lastharvest)+10
            if kelp.fronds(:,3) == 9e9
            kelp.fronds(:,4) = 3;
            kelp.fronds(:,3) = NaN;
            end
        end
    end
            
    % fraction of senescing fronds
    s = sum(kelp.fronds(:,4)==2);
    a = sum(kelp.fronds(:,4)==1);
    f_s = s/(s+a);
    %disp('Time'), sim_hour / 24
    %disp('s'), s
    %disp('a'), a
    %disp('f_s'), f_s
    
    % remove Nf and Ns at a rate of d_frond for fraction that are senescing
    Nf_senesce = param.d_frond .* kelp.Nf .* f_s .* time.dt_Gr;
    Ns_senesce = param.d_frond .* kelp.Ns .* f_s .* time.dt_Gr;
    
    % update state variables
    kelp.Nf = kelp.Nf - Nf_senesce;
    kelp.Ns = kelp.Ns - Ns_senesce;
    
end
