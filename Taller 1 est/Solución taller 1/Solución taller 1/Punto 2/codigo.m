%% Codigo para realizar la parte de proceso ARMA del taller

%%Resumen
% Este codigo se elaboró para hacer las estimaciones del punto relacionado con procesos ARMA

%%Datos
%%
%%

%El análisis se basará en una sola variable. El ISE de Colombia.

clc; clear;
%% Importando los datos

% Importando los datos como un conjunto de datos:

ds = readtable("ISE.xlsx", "UseExcel", false);
ds=table2timetable(ds);

% generando la variación mensual del ISE:

ds.LISE=log(ds.ISE);
DISE=diff(ds.LISE)*100;
ds.DISE=[NaN;DISE];
clear DISE
%% 1.a, 1.b y 1.c. Dibuje las series, estime y grafique ACF y PACF
summary (ds)

figure (1)
subplot(2,1,1)
plot(ds.Fecha, ds.DISE)
title('Crecimiento mensual del ISE')
xlabel('Fecha') 
ylabel('%') 


subplot(2,2,3)
autocorr(ds.DISE)
ylabel('ACF')
xlabel('Rezago')
title('ACF')

subplot(2,2,4)
parcorr(ds.DISE)
ylabel('PACF')
xlabel('Rezago')
title('PACF')

%% elimine los outliers y observe de nuevo el autocorrelograma

[ds.DISEO,ds.TF,lower,upper,center] = filloutliers(ds.DISE,'clip','median')

% 1.a, 1.b y 1.c. Dibuje las series, estime y grafique ACF y PACF
%%
figure (3)
subplot(2,1,1)
plot(ds.Fecha, ds.DISEO)
title('Crecimiento Mensual del ISE sin Outliers')
xlabel('Fecha') 
ylabel('%') 


subplot(2,2,3)
autocorr(ds.DISEO)
ylabel('ACF')
xlabel('Rezago')
title('ACF')

subplot(2,2,4)
parcorr(ds.DISEO)
ylabel('PACF')
xlabel('Rezago')
title('PACF')



%% 1.c. Estime los parametros AR(1) por MCO

% Variable Original:


% llamamos una función de MCO construida:

[AR1O,stAR1O]=OLS(ds.DISE(2:end-13),1)


% obtenemos que la constante es 0.2785 y el parametro AR(1) es 0.0707, sin
% ser este estadisticamente significativo..


% Variable ajustada por outliers:
% llamamos una función de MCO construida:

[AR1,stAR1]=OLS(ds.DISEO(2:end-13),1)


% obtenemos que la constante es 0.4632 y el parametro AR(1) es -0.2289, los
% dos estádisticamente significativos.



%% 1.c¿d. Estime los parametros AR(2) por MCO

% variable original

% llamamos una función de MCO construida:

[AR2O,stAR2O]=OLS(ds.DISE(2:end-13),2)


% obtenemos que los parametros son: constante 0.34, AR(1) 0.0812 y 
% AR(2) -0.2401. 

% Variable ajustada por Outliers:

% llamamos una función de MCO construida:

[AR2,stAR2]=OLS(ds.DISEO(2:end-13),2)


% obtenemos que los parametros son: constante 0.5183, AR(1) -0.2589 y 
% AR(2) -0.1259. 


