function [mu, sig] = multiply_marginal(mu1,sig1,mu2,sig2)

mu = (mu1 * sig2^2 + mu2 * sig1^2)/(mu1^2 + mu2^2);
sig = (sig1^2 * sig2^2)/(sig1^2 + sig2^2);

end