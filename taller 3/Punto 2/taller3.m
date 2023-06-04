%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Taller 3, Punto 2
% Integrantes:
% Nicolas Akerman -
% Andrés Chaparro - 201813157
% Edward Gómez - 202020028
% Jesús Cepeda - 201910058
% Sebastián Cifuentes - 201817089
% Sergio Pinila - 201814755
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Punto 2
% Preparar el ambiente
clc;
clear all;

ds = readtable('BRENT.csv','VariableNamingRule','preserve');
ds = table(transpose(1990+5/12:1/12:2022+3/12),ds.("Último"),'VariableNames',{'Fecha','Brent'});

%% Antes de empezar: se estima el mejor modelo

% Calculando el retorno del BRENT

ds.lbrent=log(ds.Brent)
ds.rbrent(2:383) = (log(ds.Brent(2:end))-log(ds.Brent(1:end-1)))*100;
ds.rbrent(1)=NaN;



%%
% Se prefiere el ARIMA (0,0,1)

MdlBIC= arima(0,0,1);
CondVarMdl = garch(0,1);
MdlBIC.Variance = CondVarMdl;

opts=optimset('fmincon')
opts.Algorithm='interior-point'

%% Punto 2A - Modelos y Pronósticos
%% Punto 2A.2 - Estimación 1 paso adelante del retorno mensual del precio del petróleo, desde enero de 2010 hasta marzo de 2022

%%Pronóstico los siguientes meses - Pronostico punto para el siguiente mes


ds.err_rbrent_pronpunto(1:383,1)=NaN;
ds.err_rbrent_pronpunto_2(1:383,1)=NaN;
ds.rbrent_pronpunto(1:383,1)=NaN;

for i=0:146
    %estimo modelo
    [Mdl1,~,~] = estimate(MdlBIC,ds.rbrent(1:236+i),'options',opts); 
    [rbrent_pronpuntoo,~] = forecast(Mdl1,1,'Y0',ds.rbrent(1:236+i));
    ds.rbrent_pronpunto(237+i)=rbrent_pronpuntoo;
    ds.err_rbrent_pronpunto(237+i)=ds.rbrent(237+i)-rbrent_pronpuntoo;
    ds.err_rbrent_pronpunto_2(237+i)=ds.err_rbrent_pronpunto(237+i).^2;
end






x = ds.Fecha(237:383);
y0(1:147)=ds.rbrent(237:383);
plot(x,y0)
title('Pronosticos entre enero 2010 y marzo 2022');

hold on
y1 = ds.rbrent_pronpunto(237:383);
plot(x,y1)

hold on

y2 = IC95(1:147,1);
plot(x,y2)

y3 = IC95(1:147,2);
plot(x,y3) 

hold off

%% 2A.4 - Pronóstico con modelo caminata aleatoria

ds.rbrent_1=[NaN(236,1); ds.rbrent(236:end-1)];
ds.eRW_2=(ds.rbrent_1-ds.rbrent).^2;
ds.eRW=(ds.rbrent_1-ds.rbrent);

std_error_caminata=nanstd(ds.eRW(237:383))



IC95_caminata(:,1)=(ds.rbrent_1-1.96*std_error_caminata);
IC95_caminata(:,2)=(ds.rbrent_1+1.96*std_error_caminata);

subplot(1,1,1)

x = ds.Fecha(237:383);
y0(1:147)=ds.rbrent(237:383);
plot(x,y0)
title('Pronosticos entre enero 2010 y marzo 2022');

hold on
y1 = ds.rbrent_1(237:383);
plot(x,y1)

hold on

y2 = IC95_caminata(237:383,1);
plot(x,y2)

y3 = IC95_caminata(237:383,2);
plot(x,y3) 

hold off

%% Evaluación de Pronósticos Puntuales    
%% 2B.1 - ESTÁNDARES ABSOLUTOS:
%%        Errores media Cero, ruido blanco y ecuación Mincer-Zarnowitz

%A. Errores Media CERO

Media_errores_pronpunto=nanmean(ds.err_rbrent_pronpunto(237:383,1));

Desvest_errores_pronpunto=nanstd(ds.err_rbrent_pronpunto(237:383,1));

IntConfianza_errores=[Media_errores_pronpunto-1.96*Desvest_errores_pronpunto,Media_errores_pronpunto+1.96*Desvest_errores_pronpunto];
    %%La idea es que el error no sea distinto de 0 a un 95% de confianza.

%B. Errores se comportan como RUIDO BLANCO:
%Revisamos la autocorrelacion:

figure (1)
subplot(1,2,1)
autocorr(ds.err_rbrent_pronpunto(237:383,1))
ylabel('ACF')
xlabel('Rezago')
title('ACF - ARMA (0,1)')

subplot(1,2,2)
parcorr(ds.err_rbrent_pronpunto(237:383,1))
ylabel('ACF')
xlabel('Rezago')
title('PACF - ARMA (0,1)')

%Q-TEST para revisar autocorr serial
[q2,P_Value2,Estadistico2,Valor_Critico2] = lbqtest(ds.err_rbrent_pronpunto(237:383),'lags',[5,10,15,20]);
P_Value2=[P_Value2]';
Estadistico2=[Estadistico2]';
Valor_Critico2=[Valor_Critico2]';

R2 = {'5 Rezagos','10 Rezagos','15 Rezagos','20 Rezagos'};
EstadisticoQ_2=table(P_Value2,Estadistico2,Valor_Critico2,'RowNames',R2);
display(EstadisticoQ_2) 

% Errores se comportan como ruido blanco. No se rechaza la H0 (no autocorr
% serial) para los rezagos.


%%
%C. ECUACION MINCER

%Variable endogena Tasa deDesempleo Observad
Y=ds.rbrent(237:383);
%Variables Exogenas, pronosticos a un periodo:
X1=ds.rbrent_pronpunto(237:383);
% Mincer
Min1 = fitlm(X1,Y)
%wald test:
B1 = Min1.Coefficients.Estimate; 
Var1 = Min1.CoefficientCovariance;
%R*B=r
% R and r matrices
R1=[B1(1,1) 0;0 B1(2,1)] ; 
r1=[0 1]'; 
[hW1,pW1,sW1,cVW1] = waldtest(r1,R1,Var1)

%Interpretar la prueba: 
    %hw1: es 1 si rechaza el modelo restrictivo, probando que existe una 
    % relación entre "et" y "yt".
    %pw1 indica el p-valor con el que se acepta el modelo restrictivo (H0)
    %o se rechaza.

   
%% 2B.2 - Estándares Relativos: MSE,RMSE, MAE, R2, U-Theil

%Comparamos dos modelos: el ARMA(4,4), GARCH(1,1) vs Modelo de Caminata.


%I)MSE:
MSE_MdlAIC=nanmean(ds.err_rbrent_pronpunto_2(237:383))
MSE_Caminata=nanmean(ds.eRW_2(237:383));

%II)RMSE:
RMSE_MdlAIC=sqrt(MSE_MdlAIC); 
RMSE_Caminata=sqrt(MSE_Caminata);

%III)MAE:
ds.vabs_err_rbrent_pronpunto=abs(ds.err_rbrent_pronpunto); 
ds.vabs_eRW=abs(ds.eRW); 

MAE_MdlAIL=nanmean(ds.vabs_err_rbrent_pronpunto); MAE_Caminata=nanmean(ds.vabs_eRW);

% IV)R Cuadrado Predictivo
Mu_rbrent=mean(ds.rbrent(237:383)) 
ETD_2=(ds.rbrent(237:383)-Mu_rbrent).^2

Denominador1=sum(ETD_2)
R_2_MdlAIC=1-(nansum(ds.err_rbrent_pronpunto_2)/Denominador1)
R_2_Caminata=1-(nansum(ds.eRW_2)/Denominador1)

% U-THEIL
% creemos la variable Y_t+1 del desempleo
U_MdlAIK=1-(nansum(ds.err_rbrent_pronpunto_2(237:343))/nansum(ds.eRW_2(237:343)))

    %Si U->1 …… preferimos un martingala (el modelo de caminata aleatoria)

%% 2C.1 - Análisis Cuantílico - Gráfico de Confiabilidad    

f1=[];
S1=[];

f1=ds.rbrent_pronpunto(237:383,1); 
S1=(rbrent_Sim);

% Estimación Cuantiles:
QS1 = quantile(S1,[0.05:0.05:0.95],2);
% veamos que tan buenos fueron Visualmente los pronosticos:
ds.f1=[NaN(236,1); f1];
% Juntemos Todos Los Quantiles a la Tabla % Creemos una tabla con los Quantiles:


    ds.mes(1:383)=NaN
    for i=1:383
        ds.mes(i)=mod(i+4,12)
    end
    
    ds.ao=round(ds.Fecha)

FECHA=datetime(ds.ao,ds.mes,1);
Qs1=[NaN(236,19); QS1]; %19 es el # de cuantiles
Quantil = [table(FECHA,'VariableName',{'Fecha'}),array2table(Qs1)]; 
Quantil =table2timetable(Quantil);

ds.FECHA=datetime(ds.ao,ds.mes,1);
ds =table2timetable(ds);
%Juntemos las dos tablas:
ds=synchronize(ds,Quantil);
 
% Creando el fan chart
% Datos Historicos:
historicalDates = ds.Fecha(237:383);
historicalData = [ds.rbrent(237:383)];
historical = table(historicalDates,historicalData,'VariableNames',{'Dates','Data'});
%Datos de pronóstico:
forecastDates = ds.Fecha(237:383);
forecastData =[ds.f1(237:383) ds.Qs11(237:383) ds.Qs119(237:383)];
forecast =[table(forecastDates,'VariableName',{'Dates'}),array2table(forecastData)];

fanplot(historical,forecast,'FanFaceColor',[1 1 1;1 0 0],'HistoricalMarker','none','HistoricalLineColor','b'); ylabel('TD');
xlabel('Fecha')
%title('Pronóstico 1 paso Adelante Tasa de Desempleo%)




%%Gráfico de confiabilidad

%Utilicemos indexación lógica para encontrar los "hits" cuantilicos:
%Cuantil 5%
E5 = zeros (50, 1); E5(ds.rbrent(237:end)<ds.Qs11(237:end)) = 1; a5=mean(E5);
%%
a=[]
for i=1:19
    j=5*i

    fname=['a',num2str(j)];
    w=table2array(ds(:,19+i))

    E.(fname)=zeros (50, 1)
    E.(fname)(ds.rbrent(237:end)<w(237:end)) = 1
    a.(fname)=mean(E.(fname))
end
%%
a=struct2cell(a)
a=cell2mat(a)
% Vector de Cuantiles Empiricos Estimados:
Empirico=[a];

% Vector de Cuantiles Teoricos:
Teorico=[0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95]';
Confiabilidad=[Teorico, Empirico];
% Hagamos el diagrama de confiabilidad:
figure(3) 
plot(Confiabilidad(:,1),Confiabilidad(:,1),'b',Confiabilidad(:,1),Confiabilidad(:, 2),'r')
ylabel('Probabilidad Empírica')
xlabel('Probabilidad Teórica')
legend('Ideal', 'Observada','location','northwest');
title('Gráfico de Confiabilidad de la Predicción')



