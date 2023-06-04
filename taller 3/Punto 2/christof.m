



function [LR_uc,LR_i,LR_cc,LR_uc_p,LR_i_p,LR_cc_p]=christof(I,p)
%CHRISTOF Perform Christoffersen's (1998) tests of coverage.
%   [LR_UC,LR_I,LR_CC]=CHRISTOF(I,P) returns the likelihood ratio test values
%   for the unconditional coverage, independence and conditional coverage 
%   tests, respectively, for a binary time series I and a coverage
%   probability P. The series I(t) is defined as: 
%   I(t) = 1 if the actual value of the forecasted process belongs to the 
%   prediction interval for time t computed at time t-1 and 0 otherwise.
%   [LR_UC,LR_I,LR_CC,LR_UC_P,LR_I_P,LR_CC_P]=CHRISTOF(I,P) additionally 
%   returns the corresponding p-values.
%
%   Reference(s): 
%   [1] Christoffersen, P. (1998) Evaluating Interval Forecasts, 
%   International Economic Review 39, 841-862.
%   [2] R.Weron, A.Misiorek (2008) Forecasting spot electricity prices: 
%   A comparison of parametric and semiparametric time series models, 
%   International Journal of Forecasting 24, 744-763.

%   Written by Rafal Weron (2007.09.09)

lenI = length(I);

% Unconditional coverage
% condition on the first observation so that LR_uc + LR_i = LR_cc
n1 = sum(I(2:end)); 
n0 = lenI - 1 - n1;
pihat = n1 / (n0+n1);

LR_uc = -2*( n1*log(p) + n0*log(1-p) ) + ...
    2*( n1*log(pihat) + n0*log(1-pihat) );
% p-value
LR_uc_p = 1 - chi2cdf(LR_uc,1);

% Independence
n01 = sum(I(find(I(1:lenI-1) == 0) + 1));
n00 = length(find(I(1:lenI-1) == 0)) - n01;
n11 = sum(I(find(I(1:lenI-1) == 1) + 1));
n10 = length(find(I(1:lenI-1) == 1)) - n11;
pihat01 = n01 / (n00 + n01);
pihat11 = n11 / (n10 + n11);
pihat2 = (n01 + n11) / (n00 + n01 + n10 + n11);

LR_i = -2*( (n00+n10)*log(1-pihat2) + (n01+n11)*log(pihat2) ) + ...
    2*( n00*log(1-pihat01) + n01*log(pihat01) + n10*log(1-pihat11) + n11*log(pihat11) );
% p-value
LR_i_p = 1 - chi2cdf(LR_i,1);

% Conditional coverage
% LR_cc = -2*( n1*log(p) + n0*log(1-p) ) + ...
%     2*( n00*log(1-pihat01) + n01*log(pihat01) + n10*log(1-pihat11) + n11*log(pihat11) );
LR_cc = LR_uc + LR_i;
% p-value
LR_cc_p = 1 - chi2cdf(LR_cc,2);