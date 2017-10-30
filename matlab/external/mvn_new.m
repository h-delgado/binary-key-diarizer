function [g] = mvn_new(cov, m)
%MVN_NEW  Initialize a mvn struct
%
%   [d] = MVN_NEW(cov, m) initializes a MVN struct using the given covariance
%   matrix COV and mean vector M.
%
%   (c) 2010-2011, Dominik Schnitzer, <dominik.schnitzer@ofai.at>
%   http://www.ofai.at/~dominik.schnitzer/mvn

%   This file is part of the MVN Octave/Matlab Toolbox
%   MVN is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   MVN is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with MVN.  If not, see <http://www.gnu.org/licenses/>.

    g.m = m(:);
    g.cov = cov;
    
    if (rcond(cov) < 1e-15)
        throw(MException('mvn:cov', 'Covariance is badly scaled!'));
    end
    
    % speedup for
    %
    %  g.logdet = log(det(g.cov));
    %  g.icov = inv(g.cov);
    %
    % using Cholesky:
    
     g_chol = chol(cov);
     g.logdet = 2*sum(log(diag(g_chol)));
     g_ui = g_chol\eye(length(g.m));
     g.icov = g_ui*g_ui';
end
