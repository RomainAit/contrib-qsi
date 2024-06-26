%Compute lebesgue measure of the symmetric difference between two quantiles
%sets.

% Copyright Notice
%
% Copyright (C) 2024 CentraleSupelec
%
%    Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr> 

function dev = lebesgue_deviation(set1,set2)

part1 = set1-set2;
part2 = set2-set1;

dev = (1/size(set1,2))*(sum(part1>0)+sum(part2>0));

end
