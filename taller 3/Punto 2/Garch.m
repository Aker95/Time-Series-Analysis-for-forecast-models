clc;
clear all;

ds = readtable('BRENT.csv','VariableNamingRule','preserve');
ds = table(transpose(1990+5/12:1/12:2022+3/12),ds.("Último"),'VariableNames',{'Fecha','Brent'});

%% i Modelo utilizado: ARIMA (5,0,4) - GARCH (1,2)
rBrent = (log(ds.Brent(2:end))-log(ds.Brent(1:end-1)))*100;
[rBrent1,lower,upper,center] = filloutliers(rBrent,'clip','median');

X =find(ds{:,1}==2010);

info=rBrent(1:X);

Mdl = arima('ARLags',[1:1],'D',0,'MALags',[1:2],'SMALags',[1:3]*3,'SARLags', [1:3]*3); %AIC

[L_AIC,A_AIC,B_AIC]=Garch_Elec(info,Mdl);

Mdl = arima('D',0,'MALags',[1:1],'SARLags',[1:3]*3,'SMALags',[1:2]*3); %BIC
[L_BIC,A_BIC,B_BIC]=Garch_Elec(info,Mdl);
%%
Mdl = arima('ARLags',[1:1],'D',0,'MALags',[1:2],'SARLags',[1:3]*3,'SMALags',[1:3]*3); %LL

[L_LL,A_LL,B_LL]=Garch_Elec(info,Mdl);