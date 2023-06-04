%% Limpiar espacio global
clc; clear all;
%asignar directorio:
cd 'C:\Users\Nick\Documents\MAESTRIA\2022-1\Series de tiempo\taller\Taller 1 est\Punto 2'

ds = dataset('xlsfile', 'ISE.xlsx') ;
%%Arreglar base de datos
df= ds(:,1:2);

df= rmmissing(df);

 %% Obtener la diferencia del logaritmo
df.LISE = log(df.ISE);

df.CI = diff(df.LISE)*100;

summary(df);

Mode.CI= mode(df.CI);

Var.CI= var(df.CI);

Mean.CI = mean(df.CI);

SE.CI = sqrt(Var.CI);

CI = df.CI;

swtest(CI);

% 
%% Graficas de datos ca

figure (1)

subplot(2,1,1)
plot(df.CI)
title('Crecimiento ISE')
xlabel('Fecha') 
ylabel('%') 
xlim([0 203])

subplot(2,2,3)
boxplot(df.CI ) 
ylabel('Crecimiento ISE')
title('Box-Plot')

subplot(2,2,4)
histogram(df.CI, 20)
xlabel('Crecimiento ISE') 
ylabel('conteo')
title('Distribución')

% Al hacer la estadistica descriptiva del diferencial del logaritmo del ISE
% y su histograma se encontro que, aunque tiene una distribución semejante a la normal, 
% cuando se realiza un test de Shapiro- Wilk este rechaza la hipotesis nula de que este distrubuye normal. 
% esto se puede entender al tener una districión con una inclinación hacia
% la derecha y con lo que parecería un pico bastante alto, lo cual indica
% que sus valores se concentran en una mayor medida en cero. Haciendo que
% su media sea un poco mayor a cero con un valor de 0.2991. Dicho lo
% anterior al observar su varianza y desviacion estandard de 3.4243 y
% 1.8505, respectiva; es facil inclinarse a que esta media no sea
% estadisticamente significativa de 0, que sería lo que se intuira al ver el grafico de su valores en la parte superior de la figura 1. 
% Lo cual nos ayuda a intuir que esta seríe no tiene un crecimiento
% deterministico. Por el otro lado, al ver sus minimo, maximo y diferentes
% percentil al igual que el Box-Plot, se puede ver que hay unos datos
% valores atipicos, que al comparar con los datos historicos, se puede
% concluir que son correspondientes al periodo del choque por las
% restricciones del COVID-19.
%mode 
%% Funcion de correlación y correlación parcial
%Sabemos que para un AR(1) con la forma Yt = Bo + B1*Yt-1 + Et la
%autocorrelación_n = B1^n

%autocorrelación
%{
B= cell2mat(MAR1.AR)

%B= 0.0655

ACAR=NaN(21,2);


for i=1:21
    ACAR(i,1)=i-1;
    ACAR(i,2)=B.^(i-1);
end

%Autocorrelacion parcial
AR20 = arima(20,0,0);
%%[EstMdl,EstParamCov,logL] = estimate(Mdl,df.CI)
MAR20 = estimate(AR20,df.CI);

B20=cell2mat(MAR20.AR);
%}


AC.CI = autocorr(df.CI);

PAR.CI = parcorr(df.CI);

figure (2)

subplot(1,2,1)
autocorr(df.CI)
ylabel('ACF')
xlabel('Rezago')
title('ACF varianción ISE')

subplot(1,2,2)
parcorr(df.CI)
ylabel('PACF')
xlabel('Rezago')
title('PACF varianción ISE')
%%

r= normrnd(1, 0.3, 10000, 1);
y= zeros(10000,1);
for i=13:10000
    y(i)=0.2*y(i-12) + r(i);
end
%%
figure (4)

subplot(1,2,1)
autocorr(y)
ylabel('ACF')
xlabel('Rezago')
title('ACF varianción Simulación')

subplot(1,2,2)
parcorr(y)
ylabel('PACF')
xlabel('Rezago')
title('PACF varianción. Simulación')

% Al analizar las graficas de correlación y correlación parcial se ve que en
% ambas el 2do rezago es significativo, al igual que el rezago 13. Debido a que
% la serie claramente no tiene el comportamiento tradicional de un AR, donde la grafica
% de correlaciones cae paulatinamente, o de un MA donde las correlaciones parciales caen.
% Tambien se podría intuir un comportamiento estacional ya que el ISE tiene una
% periodicidad anual. Al correr una simulación de un proceso con
% periodicidad anual y una persistencia semejante a la presentada por el
% modelo, se puede ver un comportamiento muy similar (ver grafica 4) lo
% cual sustenta esta tesis que la seríe del diferencial del logaritmo del ISE tiene un comportamiento
% con una estacionalidad anual.
%% Eliminar outliers 
[df.CIA, TF, lower, upper, center] = filloutliers(df.CI, "clip", "median");
%% Funcion de correlación

%{
%Autocorrelación
ACARA=NaN(21,2);


for i=1:21
    ACARA(i,1)=i-1;
    ACARA(i,2)=BA.^(i-1);
end


%Autocorrelación parcial
AR20 = arima(20,0,0);
%%[EstMdl,EstParamCov,logL] = estimate(Mdl,df.CI)
MAR20 = estimate(AR20,df.CIA);
B20=cell2mat(MAR20.AR);

%}

figure (3)

subplot(1,2,1)
autocorr(df.CIA)
ylabel('ACF')
xlabel('Rezago')
title('ACF varianción ISE')

subplot(1,2,2)
parcorr(df.CIA)
ylabel('PACF')
xlabel('Rezago')
title('PACF varianción. CIRA ISE')

%%
figure (5)
plot(df.CIA)
title('Crecimiento ISE ajustado')
xlabel('Fecha') 
ylabel('%') 
xlim([0 203])

% Cuando se analisa las graficas de correlación y correlación parcial una
% vez se retiran los datos atipicos de la seríe, se puede ver que el
% comportamiento estacional descrito anteriormente es eliminado. Es más cuando
% se ven estas graficas a profundida y la grafica de la seríe de tiempo
% (figura 5) se puede ver como esta seríe tiene una muy alta volatilidad,
% por lo que vuelve a su media de forma rapida. De estas graficas uno
% podria untuir que una vez se elimina la tendencia, este modelo solo queda
% en función del termino del error. Por lo cual el pronostico más acertado
% sería su esperanza condicional, para su varianza, un
% modelo garch que modelo los cluster de volatilidad.
%% Calculo del AR1
AR1 = arima(1,0,0);
%%[EstMdl,EstParamCov,logL] = estimate(Mdl,df.CI)
MAR1 = estimate(AR1,df.CI);
B= MAR1.AR;
C = MAR1.Constant;
B = cell2mat(B);

Var.CI = MAR1.Variance;
ED.CI = sqrt(Var.CI);

MAR1A = estimate(AR1, df.CIA);
BA= MAR1A.AR;
CA = (MAR1A.Constant);
BA = cell2mat(BA);

Var.CIA = MAR1A.Variance;
ED.CIA = sqrt(Var.CIA);

% Aunque en ambos modelos las constantes se podría intuir que no son
% estadisticamentes diferente a 0 ya que ambas estan a menos de una
% desviación estandar de este, el coeficiente del termino autoregresivo
% tiene signo opuesto, lo cual nos indica que necesariamente los modelos
% son diferentes ya que el efecto del periodo pasado sobre el presente son
% opuestos. Por lo cual, los datos de la pandemia afectan la estimación.

%% 
AR2 = arima(2,0,0);


MAR2 = estimate(AR2,df.CI);
C2 = MAR2.Constant;
B2 =  cell2mat(MAR2.AR);

Var.C2I = MAR2.Variance;
ED.C2I = sqrt(Var.C2I);

MAR2A = estimate(AR2,df.CIA);
CA2 = MAR2A.Constant;
BA2 =  cell2mat(MAR2A.AR);

Var.C2IA = MAR2A.Variance;
ED.C2IA = sqrt(Var.C2IA);

% Se repite lo mencionado anteriormente.