



function [int_next, done] = multisensory_looming_deadline_staircase(int_list, resp_list, threshold, step_init, model_number, rever_stop)
    
% adaptive staircare -- accelerated stochastic approximation
%
% the accelerated stochastic approximation is a non-parametric adaptive
% method to find rapidly a threshold. it was described by Kesten (1958).
%
% input:
%   int_list = list of intensities, including current intensity being displayed
%   resp_list = list of responses, including response to current intensity (0 = miss, 1 = hit)
%   threshold = desired threshold
%   step_init = maximum initial step size (in units of intensity)
%
% optional argument:
%   model_number (default 0) = select a different staircase, 0=Kesten,
%   1=Pascal's ASA, 2=Anderson & Johnson (2006), 3=Modified A&J ASA for
%   constant size step at first 2 trials.
%   rever_stop (default Inf) = stops after a given number of staircase reversals 
%
% output:
%   int_next = next intensity to display
%   done = converged (1) or not yet (0)
%
% history:
% 2 nov 2007 -- pascal mamassian - wrote it
% 29 oct 2015 -- baptiste changed it
%

    
    if (nargin < 5)
        model_number = 0;
    end
    if (nargin < 6)
        rever_stop = inf;
    end
    

    nn = length(int_list);          % number of intensities displayed so far (including current)
    int_curr = int_list(end);       % intensity at last trial
    resp_curr = resp_list(end);     % response at last trial
    cc = step_init / max(threshold, 1-threshold);

    mm = 0;                         % number of reversals
    if (nn > 2)
        switch model_number
            case 0  % Kesten
                mm = sum(resp_list(3:end)~=resp_list(2:end-1));
            case 1  % Mamassian
                mm = sum(resp_list(2:end)~=resp_list(1:end-1));
            case 2  % Anderson & Johnson (2006)
                mm = sum(resp_list(3:end)~=resp_list(2:end-1));
            case 3  % Me
                mm = sum(resp_list(3:end)~=resp_list(2:end-1));
        end
    end
    
    if model_number~=3
        bb = min(nn,2);             % baseline step divider
    else
        bb = 1;
    end
    
    int_next = int_curr - (cc / (bb+mm)) * (resp_curr - threshold);

    done = (mm>rever_stop);

end

