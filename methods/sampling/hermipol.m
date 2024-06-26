% Copyright Notice
%
% Copyright (C) 2024 CentraleSupelec
%
%    Authors: Julien Bect <julien.bect@centralesupelec.fr>


function p = hermipol(n)
% create hermite polynomial

p(1,1)=1;
p(2,1:2)=[2 0];
for k=2:n
    p(k+1,1:k+1)=2*[p(k,1:k) 0]-2*(k-1)*[0 0 p(k-1,1:k-1)];
end

end
