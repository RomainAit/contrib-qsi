%Demonstration using the modified branin-hoo function

%Plots show:
%- Density of the stochastic/uncertain inputs.
%- Initial design (black dots), sampled points (red dots), contour and estimated contour of the
%  points belonging to the critical region (black and red curves).
% - True and estimated quantile sets.

% Copyright Notice
%
% Copyright (C) 2024 CentraleSupelec
%
%    Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr> 

DEMO = 1;
ID = -1;

funct_struct = @branin_mod_struct;
funct_config = @branin_mod_config;

warning 'off'
here = fileparts(mfilename('fullpath')); %local path
prm = funct_struct(); %call to function parameters to check for error in dimension for demo
config = funct_config();

if (prm.dim_x ~= 1) || (prm.dim_s ~= 1)
    error("Invalid problem dimension")
end

generate_doe_init(funct_struct, funct_config, ID);
QSI_SUR(funct_struct, funct_config, ID, DEMO);

%Deleting saved datas
filename = sprintf('doe_init_%s_init_%d.csv', prm.name, ID); %delete grid
delete(fullfile(here, 'data/doe_init', filename))
filename = sprintf('doe_QSI_%s_%s_%d.csv', config.critName, prm.name, ID); %delete DoE
delete(fullfile(here, 'data/results/design', filename))
filename = sprintf('cov_QSI_%s_1_%s_%d.csv', config.critName, prm.name, ID); %delete cov model
delete(fullfile(here, 'data/results/param', filename))
filename = sprintf('param_QSI_%s_1_%s_%d.csv', config.critName, prm.name, ID); %delete cov param
delete(fullfile(here, 'data/results/param', filename))
