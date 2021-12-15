function [harvest, kelp] = harvest_crit(harvest,kelp,farm,gr_counter)
% Calculate harvest per frond and sum across area
% Output: harvest structure
%   Nf harvest per area (x, y)


global param

    % How much to remove

    % Need this much leftover
    Nf_below_canopy = ((farm.z_cult - abs(param.z_canopy)) .* param.Kh) ./ (param.Hmax - (farm.z_cult - abs(param.z_canopy))) .* 1e3 .* param.Qmin;
    
        % Nf
        temp_Nf = find_nan(kelp.Nf);
        sumNf = trapz(farm.z_arr,temp_Nf); 
        harvest.canopyNf(1,gr_counter) = sumNf - Nf_below_canopy;
        fracNf = harvest.canopyNf(1,gr_counter)/sumNf;

        % Remove Ns as the same fraction as the amount of Nf removed
        temp_Ns = find_nan(kelp.Ns);
        sumNs = trapz(farm.z_arr,temp_Ns); 
        harvest.canopyNs(1,gr_counter) = sumNs .* fracNf;

        temp_B = find_nan(kelp.B);
        sumB = trapz(farm.z_arr,temp_B); 
        harvest.canopyB(1,gr_counter) = sumB .* fracNf;
       

    % convert X percent of fronds to senescence
    
        cut_i = find(kelp.fronds.status == 1);
        cut_s = ceil(length(cut_i) .* param.harvest_frond);
        kelp.fronds.status(min(cut_i):min(cut_i)+cut_s-1) = 2;
        
        % replace those designated as senescing with a NaN end age so that natural senescence no longer over-rides
        kelp.fronds.end_age(min(cut_i):min(cut_i)+cut_s-1) = 9e9;
        clear cut_i cut_s

        
    % Take away what was harvested
    
        Nf_new = sumNf - harvest.canopyNf(1,gr_counter);
        Ns_new = sumNs - harvest.canopyNs(1,gr_counter);
        
        kelp.height = (param.Hmax .* Nf_new./param.Qmin./1e3 )./ (param.Kh + Nf_new./param.Qmin./1e3);
        kelp.b_per_m = make_Bm(kelp.height,farm);
    
        kelp.Nf = Nf_new .* kelp.b_per_m;
        kelp.Ns = Ns_new .* kelp.b_per_m;



end