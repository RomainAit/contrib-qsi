%Usage: Ranjan(@funct_struct, @config, list_id)
%Compute sequential DoE using Ranjan sampling criterion
%DoE and models parameters are save in /results

function Ranjan(funct_struct, config, id)

[prm, f, s_trnsf] = funct_struct();
config = config();
here = fileparts(mfilename('fullpath'));

dim_tot = prm.dim_x+prm.dim_s;
kappa = 1.96;

if prm.const(1,1) > -inf || dim_tot ~= 2
    error('error')
end

for it = id
    %Initial design
    file_grid = sprintf ('grid_%s_%d_init.csv', prm.name, it);
    di = readmatrix(fullfile(here, 'grid', file_grid));
    zi = f(di);

    Model = [];

    % Create dataframes
    dn = stk_dataframe(di);
    zn = stk_dataframe(zi);

    %Prepare tab to save param
    save_param = zeros(config.T+1,dim_tot+1,prm.M);
    save_cov = zeros(config.T+1, 1, prm.M);

    time = [];
    pts_tot = config.pts_x*config.pts_s;

    %loop on steps
    for t = 1:config.T
        tic

        % Sample points in X x S
        dt = stk_sampling_randunif(pts_tot,dim_tot,prm.BOX);

        % Estimate parameters
        Model = [];
        for m = 1:prm.M
            [Model(m), ind_cov] = estim_matern ...
                (dn, zn(:,m), prm.list_cov, config.lognugget);
            save_cov(t,:,m) = ind_cov;
            save_param(t,:,m) = Model(m).param;
        end

        % Compute Ranjan criterion
        var = stk_predict(Model, dn, zn, dt).var;
        proba = proba_xi(Model, dn, zn, dt, prm)';

        tau = norminv(1-proba);
        tau_plus = tau + kappa;
        tau_minus = tau - kappa;

        phi_plus = normpdf(tau_plus);
        phi_minus = normpdf(tau_minus);
        cdf_plus = normcdf(tau_plus);
        cdf_minus = normcdf(tau_minus);

        crit_tab = var.*(kappa^2 - 1 - tau.^2).*(cdf_plus - cdf_minus) - ...
            2*tau.*(phi_plus - phi_minus) + ...
            tau_plus.*phi_plus - tau_minus.*phi_minus;

        % Update design
        [~, indmax] = max(crit_tab);
        newpt = dt(indmax,:);

        time = [time, toc];

        dn = stk_dataframe([dn;newpt]);
        zn = stk_dataframe([zn;f(newpt)]);

    end

    %Save design and param
    for m = 1:prm.M
        [Model(m), ind_cov] = estim_matern ...
            (dn, zn(:,m), prm.list_cov, config.lognugget);
        save_cov(config.T+1,:,m) = ind_cov;
        save_param(config.T+1,:,m) = Model(m).param;
    end

    filename = sprintf ('doe_ranjan_%s_%d.csv', prm.name, it);
    writematrix (double (dn), fullfile (here, 'results/design', filename));

    for m = 1:prm.M
        filename = sprintf ('param_ranjan_%d_%s_%d.csv', m, prm.name, it);
        writematrix(save_param(:,:,m), fullfile (here, 'results/param', filename));

        filename = sprintf ('cov_ranjan_%d_%s_%d.csv', m, prm.name, it);
        writematrix (save_cov(:,:,m), fullfile (here, 'results/param', filename));
    end

    filename = sprintf ('time_ranjan_%s_%d.csv', prm.name, it);
    writematrix(time, fullfile (here, 'results/time', filename));

end

end
