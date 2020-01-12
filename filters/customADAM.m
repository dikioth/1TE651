function h =  customADAM(xT, varargin)
% customADAM: ADAM optimizer.
% h = customADAM(xT, x1, N, x2*, M*, ...)
% Input:
%       - xT: The target signal.
%       - x1: Reference signal.
%       - N : Filter tap for x1.
%       - x2*: Optional additional reference signal.
%       - M *: Optional additional filter tap to x2.
%
%  OBS: Additional reference signals and filter length must come in pairs.
% Output:
%       - h: The optimal coefficients.
%

% Handle arguments
if mod(length(varargin), 2) == 0
    % if varargin comes in pairs, e.g x1 and N.
    numpairs = length(varargin)/2;
    
    for np = numpairs
        sumTaps = sum([varargin{2:2:end}]);
        startIter = max([varargin{2:2:end}]);
    end
else
    error('customADAM: Incorrect usage of function');
end


% Default values. Suggested by ref [1]
alpha = 0.001;
beta1 = 0.9;
beta2 = 0.999;
epsilon = 1e-8;

% Initializing
h = ones(sumTaps,1);
m = zeros(sumTaps,1);
v = zeros(sumTaps,1);


for n = startIter:length(xT)
    
    y = [];
    for np = 1:numpairs
        xref = varargin{2*np-1};
        NN = varargin{2*np};
        x = xref(n:-1:n-NN+1);
        y = vertcat(y, x);
    end
    
    d = xT(n);  % desired signal.
    g = -y' * (d - h'*y);   % gradient.
    m = beta1.* m + (1 - beta1).* g(:);
    v = beta2.* v + (1 - beta2).* g(:).^2;
    mhat = m./ (1 - beta1^n);
    vhat = v./ (1 - beta2^n);
    h = h - alpha.*mhat./(sqrt(vhat) + epsilon);
end
end

% References:
% [1] D. P. Kingma and J. Ba, Adam: A method for stochastic optimization,?
% Latest version available online: https://arxiv.org/abs/1412.6980.