function h =  customADAM(xT, xref, N)

% Default vars. By ref [5]
alpha = 0.001;
beta1 = 0.9;
beta2 = 0.999;
epsilon = 1e-8;

% Initializing
h = 1*ones(N,1);
m = zeros(N,1);
v = zeros(N,1);

iter = length(xT);
Hvect = zeros(N, iter);

for n = N:iter
    
    % gradient
    y = xref(n:-1:n-N+1);
    d = xT(n);
    g = -y' * (d - h'*y);
    m = beta1.* m + (1 - beta1).* g(:);
    v = beta2.* v + (1 - beta2).* g(:).^2;
    mhat = m./ (1 - beta1^n);
    vhat = v./ (1 - beta2^n);
    h = h - alpha.*mhat./(sqrt(vhat) + epsilon);
end
out = Hvect;
end



% References:
% [5] D. P. Kingma and J. Ba, ?Adam: A method for stochastic optimization,?
% Latest version available online: https://arxiv.org/abs/1412.6980.