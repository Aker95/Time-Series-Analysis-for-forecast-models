% Function to perform OLS with time series, where "y" is the time series
% variable, and p the order of the AR process.

function [beta_hat,stderr_ols]=OLS(y,p)

y=y;  %this is the variable from 0 to T
N=length(y);
p=p;
reg=zeros(N,p);
%this for organize the number of columns accordion to the AR process that
%is required.
for i=1:p
    reg(:,i)=lagmatrix(y,i);
end
%just define the matrix that you will use in the OLS process
y(1:p,:)=[];
reg(1:p,:)=[];    
N=length(y);
    X=[ones(N,1) reg];
% estimate the OLS estimators

    beta_hat=(X'*X)\X'*y; 
    
    % Standard errors:
    
    K=size(X,2);
    u=y-X*beta_hat;
    sigma2=(u'*u)/(N-K);
    stderr_ols=diag(sqrt(sigma2.*inv(X'*X)));   
  

end