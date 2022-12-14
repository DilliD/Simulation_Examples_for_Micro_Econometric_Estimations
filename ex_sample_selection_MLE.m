clear;clc; close all;
% You should download m_est, BHHH, NR, grd_desc, gradp, and hessp functions
n=500; %sample size
x1=ones(n,1);
x2=trnd(5,n,1);
x3=-2+4*rand(n,1);
x4=randn(n,1)>0;
x5=-2+0.8*randn(n,1);
x6=chi2rnd(1,n,1);

x=[x1, x2, x6]; w=[x1, x2, x3, x4, x5];
beta0=[1;2;3];
gamma0=[4;1;2;-1];
rho0=0.3;
sigu=2;
kw=size(w,2);
kx=size(x,2);

R=[[1, rho0];[rho0, sigu^2]];
uv=mvnrnd(zeros(1,2), R, n);

ds=w(:,2:end)*gamma0+uv(:,1); d=ds>mean(ds);
ys=x*beta0+uv(:,2); y=ys.*d;

truePara=[-mean(ds);gamma0;beta0;rho0;sigu];

c0=truePara
logistcdf=@(t)( 1./(1+exp(-t)) );
rho=@(z)( 2*normcdf(z)-1 );
p1=@(a,b,t,s)( normcdf(-w*a) );
p2=@(a,b,t,s)( (1/s)*normpdf( (y-x*b)/s ) );
p3=@(a,b,t,s)( normcdf( ( w*a + (rho(t)/s)*(y-x*b) )/sqrt(1-rho(t)^2) ) );
qi0=@(a,b,t,s)(  (1-d).*log( p1(a,b,t,s) ) + d.*( log( p2(a,b,t,s) ) + log( p3(a,b,t,s) ) ) );
qi=@(c)(  100*qi0( c(1:kw,:),c(kw+1:kw+kx,:), c(end-1,:), c(end,:) ) );

[mle, stat]=m_est(qi, c0, 0.2, "print", 500)

%%
est=@(a)[ a(1:end-2,:); rho(a(end-1,:)); a(end,:) ];
gr=gradp(mle, est);
vcov=gr'*stat.vcov*gr;

result=[truePara, est(mle), est(mle)./sqrt(diag(vcov))];
disp(result(:,1:2))
disp(result)
