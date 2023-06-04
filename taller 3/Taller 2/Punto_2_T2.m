%% Punto 2
% Preparar el ambiente
clc;
clear all;

ds = readtable('BRENT.csv','VariableNamingRule','preserve');
ds = table(transpose(1990+5/12:1/12:2022+3/12),ds.("Último"),'VariableNames',{'Fecha','Brent'});

%% Punto 2.1
% Grafica historica del Brent

figure
plot(ds.Fecha,ds.Brent)
title('Precio Mensual BRENT (USD)')
xlabel('Fecha')
ylabel('Precio USD')

%% Punto 2.2
% Calculando el retorno del BRENT

rBrent = (log(ds.Brent(2:end))-log(ds.Brent(1:end-1)))*100;
r_barra = mean(rBrent);
display(r_barra)

%% Punto 2.3
% Varianza del rendimiento y graficos del rendimiento

rBrent2 = (rBrent(1:end)-r_barra).^2;

figure

subplot(2,1,1)
plot(ds.Fecha(2:end),rBrent)
title('Rendimiento Mensual BRENT (pp)')
xlabel('Fecha')
ylabel('Rendimiento')

subplot(2,1,2)
plot(ds.Fecha(2:end),rBrent2)
title('Var. Rendimiento Mensual BRENT (pp^2)')
xlabel('Fecha')
ylabel('Var. Rendimiento')

%% Punto 2.4
% Construyendo el modelo

%% Punto 2.4.a
% Escoger el modelo

% Revisando ACF y PACF

figure

subplot(1,2,1)
autocorr(rBrent)
ylabel('ACF')
xlabel('Rezago')
title('ACF rBrent') % Sinusoidal, clara significancia del primer rezago, 
% el cuarto rezago es significativo a pesar de que ni el segundo ni tercero
% lo son, de ahi ya no sale de las bandas de contingencia

subplot(1,2,2)
parcorr(rBrent)
ylabel('PACF')
xlabel('Rezago')
title('PACF rBrent') % Sinusoidal, clara significancia del primer rezago, 
% el cuarto rezago es significativo a pesar de que ni el segundo ni tercero
% lo son, de ahi ya no sale de las bandas de contingencia

% No hay necesidad visible de diferenciar, I(0)

% Seleccionando P y Q para el ARMA

AR=4;
MA=4;
LL=NaN(AR+2,MA+2);
NBetas=NaN(AR+2,MA+2);

for i=0:AR
LL(i+2,1)=i;
NBetas(i+2,1)=i;
    for j=0:MA   
LL(1,j+2)=j
NBetas(1,j+2)=j
Mdl = arima(i,0,j);
[EstMdl,~,rB] = estimate(Mdl,rBrent);
param=i+j+1;
NBetas(i+2,j+2)=param;
LL(i+2,j+2)=rB;
    end
end

NBetas(2,2)=1;
C=size(NBetas,2);
T=length(rBrent((~isnan(rBrent))))
AIK=[];
SIC=[];
for i=2:C
   [aic,BIC] = aicbic(LL(2:end,i),NBetas(2:end,i),T) 
   AIK(:,i-1)=aic
   SIC(:,i-1)=BIC
end

% AIC: ARIMA (4,0,4)
% SIC: ARIMA (0,0,1)

% Se prefiere el ARIMA (4,0,4)

MdlAIK = arima(4,0,4);
[EstMdl,~,rB] = estimate(MdlAIK,rBrent);

%MdlAIK = arima(0,0,1);
%[EstMdl0,~,rB] = estimate(MdlAIK,rBrent);

%MdlAIK = arima(1,0,1);
%[EstMdl1,~,rB] = estimate(MdlAIK,rBrent);

%% Punto 2.4.b
% Residuales

AR=8;
MA=8;
LL=NaN(AR+2,MA+2);
NBetas=NaN(AR+2,MA+2);


for i=0:AR
LL(i+2,1)=i;
NBetas(i+2,1)=i;
    for j=0:MA   
LL(1,j+2)=j
NBetas(1,j+2)=j
Mdl = arima(i,1,j);
[EstMdl,~,Logl] = estimate(Mdl,rBrent);
param=i+j+1;
NBetas(i+2,j+2)=param;
LL(i+2,j+2)=Logl;
    end
end

NBetas(2,2)=1;
C=size(NBetas,2);
T=length(rBrent((~isnan(rBrent))))
AIK=[];
SIC=[];
for i=2:C
   [aic,BIC] = aicbic(LL(2:end,i),NBetas(2:end,i),T) 
   AIK(:,i-1)=aic
   SIC(:,i-1)=BIC
end

[res_AIK,var_AIK,~] = infer(EstMdl,rBrent);

rAIK_barra = mean(res_AIK);
display(rAIK_barra) % Media cercana a cero

MeanRMdl = fitlm(ones(1,382),res_AIK,"constant");
display(MeanRMdl.Coefficients) % Media no distinta de cero


figure

subplot(2,1,1)
plot(ds.Fecha(2:end),res_AIK)
title('Residuales Modelo ARIMA (4,0,4)')
xlabel('Fecha')
ylabel('Residuales (pp)') % Aparenta ruido blanco

subplot(2,1,2)
histfit(res_AIK)
ylabel('PDF')
xlabel('pp')
title('Histograma') % Aparenta normalidad, toca revisar outliers

figure

subplot(1,2,1)
autocorr(res_AIK)
ylabel('ACF')
xlabel('Rezago')
title('ACF') % No hay correlacion serial entre los errores

subplot(1,2,2)
parcorr(res_AIK)
ylabel('PACF')
xlabel('Rezago')
title('PACF') % No hay correlacion serial entre los errores

[q1,P_Value1,Estadistico1,Valor_Critico1] = lbqtest(res_AIK,'lags',[4,5,10,15,20]);
P_Value1=[P_Value1]';
Estadistico1=[Estadistico1]';
Valor_Critico1=[Valor_Critico1]';

R1 = {'4 Rezagos','5 Rezagos','10 Rezagos','15 Rezagos','20 Rezagos'};
EstadisticoQ_1=table(P_Value1,Estadistico1,Valor_Critico1,'RowNames',R1);
display(EstadisticoQ_1) % Errores se comportan como ruido blanco

res_AIK2 = (abs(res_AIK)).^2;

sig_AIK = mean(res_AIK2);
display(sig_AIK) % Varianza no condicional

VarRMdl = fitlm(ds.Fecha(2:end),res_AIK2);
display(VarRMdl.Coefficients) % Varianza no condicional no dependiente del tiempo

% Prueba de normalidad??? [SW,SF] = swft(res_AIK,1);

%% 2.4.c
% Dinamicas de varianza

figure

subplot(1,2,1)
autocorr(res_AIK2)
ylabel('ACF')
xlabel('Rezago')
title('ACF residual^2') % Clara significancia del segundo rezago,
% de ahi ya no sale de las bandas de contingencia

subplot(1,2,2)
parcorr(res_AIK2)
ylabel('PACF')
xlabel('Rezago')
title('PACF residual^2') % Clara significancia del segundo rezago,
% de ahi ya no sale de las bandas de contingencia

% No hay necesidad visible de diferenciar, I(0)

[q2,P_Value2,Estadistico2,Valor_Critico2] = lbqtest(res_AIK2,'lags',[2,5,10,15,20]);
P_Value2=[P_Value2]';
Estadistico2=[Estadistico2]';
Valor_Critico2=[Valor_Critico2]';

R2 = {'2 Rezagos','5 Rezagos','10 Rezagos','15 Rezagos','20 Rezagos'};
EstadisticoQ_2=table(P_Value2,Estadistico2,Valor_Critico2,'RowNames',R2);
display(EstadisticoQ_2) % Significancia conjunta de los errores al cuadrado hasta el segundo rezago

% Seleccionando P y Q para el ARIMA(4,0,4)-GARCH
%%

SG2=2;
EP2=2;
LL=NaN(SG2+2,EP2+2);
NBetas=NaN(SG2+2,EP2+2);

for i=0:SG2
LL(i+2,1)=i;
NBetas(i+2,1)=i;
    for j=1:EP2   
LL(1,j+2)=j
NBetas(1,j+2)=j
Mdl = arima(4,0,4);
CondVarMdl = garch(i,j);
Mdl.Variance = CondVarMdl;
[EstMdlGARCH,~,rB] = estimate(Mdl,rBrent);
param=i+j+1;
NBetas(i+2,j+2)=param;
LL(i+2,j+2)=rB;
    end
end
%%

NBetas(2,2)=1;
C=size(NBetas,2);
T=length(rBrent((~isnan(rBrent))));
AIK=[];
SIC=[];

for i=3:C
   [aic,BIC] = aicbic(LL(2:end,i),NBetas(2:end,i),T) 
   AIK(:,i-1)=aic
   SIC(:,i-1)=BIC
end

% AIC: GARCH (1,2)
% SIC: GARCH (1,1)

% Se prefiere el GARCH (1,1)?

MdlAIK = arima(4,0,4);
CondVarMdl = garch(1,1);
MdlAIK.Variance = CondVarMdl;
[EstMdl_GARCH,~,rB] = estimate(MdlAIK,rBrent);

% LogL?

%[h,pvalue,stat,cvalue]=archtest(res_AIK,"lags",[1,2]);??

%% Punto 2.4.d
% Nuevas dinamicas de varianza

[res_AIK_GARCH,var_AIK_GARCH,~] = infer(EstMdl_GARCH,rBrent);

res_GARCH = (res_AIK_GARCH)./sqrt(var_AIK_GARCH);
res_GARCH2 = (res_GARCH).^2;

rGARCH_barra = mean(res_GARCH);
display(rGARCH_barra) 

MeanRMdlGARCH = fitlm(ones(1,382),res_GARCH,"constant");
display(MeanRMdlGARCH.Coefficients) % Media no distinta de cero

figure 

subplot(2,1,1)
plot(ds.Fecha(2:end),res_GARCH)
ylabel('Residuales (pp)')
xlabel('Fecha')
title('Residuales Modelo ARIMA(4,0,4)-GARCH(1,1)')

subplot(2,1,2)
qqplot(res_GARCH)
ylabel('Q Res Norm')
xlabel('Q Res Mod')
title('QQ-PLOT Errores Estándarizados')

figure

subplot(2,2,1)
autocorr(res_GARCH)
ylabel('ACF')
xlabel('Rezago')
title('ACF Res') % No hay correlacion serial entre los errores

subplot(2,2,2)
parcorr(res_GARCH)
ylabel('PACF')
xlabel('Rezago')
title('PACF Res') % No hay correlacion serial entre los errores

subplot(2,2,3)
autocorr(res_GARCH2)
ylabel('ACF')
xlabel('Rezago')
title('ACF Res^2') % No hay correlacion serial entre los errores

subplot(2,2,4)
parcorr(res_GARCH2)
ylabel('PACF')
xlabel('Rezago')
title('PACF Res^2') % No hay correlacion serial entre los errores

[q3,P_Value3,Estadistico3,Valor_Critico3] = lbqtest(res_GARCH2,'lags',[2,5,10,15,20]);
P_Value3=[P_Value3]';
Estadistico3=[Estadistico3]';
Valor_Critico3=[Valor_Critico3]';

R3 = {'2 Rezagos','5 Rezagos','10 Rezagos','15 Rezagos','20 Rezagos'};
EstadisticoQ_3=table(P_Value3,Estadistico3,Valor_Critico3,'RowNames',R3);
display(EstadisticoQ_3) % No significancia conjunta de los errores al cuadrado 

% Normalidad en los residuales??

%% Punto 2.5
% Modelo utilizado: ARIMA (4,0,4) - GARCH (1,1)

MdlAIK = arima(4,0,4);
CondVarMdl = garch(1,1);
MdlAIK.Variance = CondVarMdl;
[EstMdl_GARCH,~,rB] = estimate(MdlAIK,rBrent);

%% Punto 2.5.a
% Pronostico punto para el siguiente mes

[rBrent_Apr22,Var_rBrent_Apr22] = forecast(EstMdl_GARCH,1,'Y0',rBrent);
display(rBrent_Apr22)
display(Var_rBrent_Apr22) 

%% Punto 25.b
% Pronostico intervalo y densidad para el siguiente mes
rng(1234)
DistSim1000 = normrnd(0,sqrt(Var_rBrent_Apr22),[1,1000]);
Dist_rBrent = rBrent_Apr22 + DistSim1000;

IC95 = rBrent_Apr22 + 1.96*[-sqrt(Var_rBrent_Apr22) sqrt(Var_rBrent_Apr22)];

figure 
histfit(Dist_rBrent)
hold on
plot([rBrent_Apr22 rBrent_Apr22],[0 100],'LineWidth',2,'Color',[0 0 0])
hold on
plot([IC95(1) IC95(1)],[0 100],'LineWidth',2,'Color',[0.5 0.5 0.6])
hold on 
plot([IC95(2) IC95(2)],[0 100],'LineWidth',2,'Color',[0.5 0.5 0.6])
ylabel('PDF')
xlabel('rBrent')
title('Histograma rBrent')

