clc; clear all;

ds = readtable("Monedas.xlsx", "UseExcel", false);

Ret= diff(log(table2array(ds(:,2:end))));
names=string(ds(:,2:end).Properties.VariableNames);

%%
Ret_std=(Ret-mean(Ret))./std(Ret);
%I
Ret_t=horzcat(ds(2:end,1), array2table(Ret));
Ret_t= renamevars(Ret_t,string(Ret_t(:,2:end).Properties.VariableNames),names);
%II
Ret_std_t=horzcat(ds(2:end,1), array2table(Ret_std));
Ret_std_t= renamevars(Ret_std_t,string(Ret_std_t(:,2:end).Properties.VariableNames),names);
%%
Corr = corrcoef(Ret_std);
Corr= renamevars(array2table(Corr),array2table(Corr).Properties.VariableNames,names);
Corr=Corr(find(strcmpi(Corr.Properties.VariableNames,'Colombia')),:);%The strcmpi() function is a built-in function in C and is defined in the “string.h” header file. The strcmpi() function is same as that of the strcmp() function but the only difference is that strcmpi() function is not case sensitive and on the other hand strcmp() function is the case sensitive.
CorrF = table2array(Corr);
CorrF = array2table(CorrF.');
CorrF.Properties.RowNames = Corr.Properties.VariableNames;
CorrF=sortrows(CorrF,1,'descend');
CorrF=CorrF(1:31,:);
CorrG = table2array(CorrF);
CorrG = array2table(CorrG.');
CorrG.Properties.VariableNames = CorrF.Properties.RowNames;

%%
Nam_cat=categorical(CorrG(:,2:end).Properties.VariableNames);
Nam_cat= reordercats(Nam_cat,CorrG(:,2:end).Properties.VariableNames);
figure (1)
bar(Nam_cat,table2array(CorrG(:,2:end)));
%%
Y=table2array(Ret_std_t(:,'Colombia'));
X=table2array(removevars(Ret_std_t,{'Fecha','Colombia'}));
[BL StatsL] = lasso(X,Y, 'CV', 10,'intercept',false);

% Creemos una gráfica donde se muestre el error cuadrado medio y los 
% Lambda estimados.
figure (2)
lassoPlot(BL, StatsL, 'PlotType', 'CV')

%%
BLasso = BL(:,StatsL.Index1SE);

Co_la=array2table(BLasso);

Co_la.Properties.RowNames = removevars(Ret_std_t,{'Fecha','Colombia'}).Properties.VariableNames;


Ind=Co_la.BLasso==0;
Co_la(Ind,:)=[];
Co_la=sortrows(Co_la,1,'descend');

%%
[~,PCy1,EVy1,~,E] = pca(X);

Pc1=PCy1(:,1);

Corr_PC = corr(Y,Pc1);


%%
Ind =find(ds{:,1}=='01-Dec-2010');
figure (3)

subplot(1,2,1)
autocorr(Y(1:Ind))
ylabel('ACF')
xlabel('Rezago')
title('ACF')

subplot(1,2,2)
parcorr(Y(1:Ind))
ylabel('PACF')
xlabel('Rezago')
title('PACF')



%[AICM,BICM]=model_election(Y(1:Ind),5,5,0,0,0);

%%
Mdl=arima(0,0,1)


[EstMdl,~,~] = estimate(Mdl,Y(1:Ind));
[res_m, var_m] = infer(EstMdl,Y(1:Ind));
%%

figure (4)

subplot(1,2,1)
autocorr(res_m)
ylabel('ACF')
xlabel('Rezago')
title('ACF')

subplot(1,2,2)
parcorr(res_m)
ylabel('PACF')
xlabel('Rezago')
title('PACF')


R1 = {'5 Rezagos';'10 Rezagos'; '15 Rezagos'};


[QSIC,P_ValueSIC,EstadisticoSIC,Valor_CriticoSIC] = lbqtest(res_m,'lags',[5,10,15])


P_ValueSIC=[P_ValueSIC]';
EstadisticoSIC=[EstadisticoSIC]';
Valor_CriticoSIC=[Valor_CriticoSIC]';

Estadistico_Q1=table(P_ValueSIC,EstadisticoSIC,Valor_CriticoSIC,'RowNames',R1)

% se asume errores ruido blanco por lo cual no se realizan test de
% volatilidad condicional

%%
%Y_estP=Pc1*(1:Ind)*regress(Y(1:Ind),Pc1*(1:Ind));
mln = fitlm(Pc1(1:Ind),Y(1:Ind));
PC_res= mln.Residuals.Raw;


figure (5)

subplot(1,2,1)
autocorr(PC_res)
ylabel('ACF')
xlabel('Rezago')
title('ACF')

subplot(1,2,2)
parcorr(PC_res)
ylabel('PACF')
xlabel('Rezago')
title('PACF')


%[PAICM,PBICM]=model_election(PC_res,5,5,0,0,0);
%%
PEstMdl = estimate(Mdl,Y(1:Ind),'X', Pc1(1:Ind));

[res_mp, var_m] = infer(PEstMdl,Y(1:Ind));
%%

figure (7)

subplot(1,2,1)
autocorr(res_mp)
ylabel('ACF')
xlabel('Rezago')
title('ACF')

subplot(1,2,2)
parcorr(res_mp)
ylabel('PACF')
xlabel('Rezago')
title('PACF')


R1 = {'5 Rezagos';'10 Rezagos'; '15 Rezagos'};


[QSIC,P_ValueSIC,EstadisticoSIC,Valor_CriticoSIC] = lbqtest(res_mp,'lags',[5,10,15])


P_ValueSIC=[P_ValueSIC]';
EstadisticoSIC=[EstadisticoSIC]';
Valor_CriticoSIC=[Valor_CriticoSIC]';

Estadistico_Q1=table(P_ValueSIC,EstadisticoSIC,Valor_CriticoSIC,'RowNames',R1)

%%
Col=diff(log(table2array(ds(:,find(strcmpi(ds.Properties.VariableNames,'Colombia'))))));
MY=mean(Col);
EEY=std(Col);
f1=[];
f2=[];

for i=0:(height(Y)-Ind-1)   
%Estimación Modelo 1
[res, var] = infer(EstMdl,Y(1:Ind+i));
[TDf1,~,~] = forecast(EstMdl,1,'Y0',Y(1:Ind+i),'V0',var, 'E0', res);
f1(i+1,1)=(TDf1);
[res, var] = infer(PEstMdl,Y(1:Ind+i));
[TDf1,~,~] = forecast(PEstMdl,1,'Y0',Y(1:Ind+i),'V0',var, 'E0', res,'XF',Pc1(1:Ind+i));
f2(i+1,1)=(TDf1);
end

f1e=f1*EEY+MY;
f2e=f2*EEY+MY;
%%
fecha=table2timetable(ds).Fecha;

%%
figure (6)

plot(fecha(Ind-20:end),Col(Ind-21:end),'Color',[.7,.7,.7])
hold on
plot(fecha(Ind+2:end),f1e,'k-*','LineWidth',.7)
hold on
plot(fecha(Ind+2:end),f2e,'b--o','LineWidth',.7)
ylabel('%')
xlabel('Fecha')
hold off
legend('Retornos del COP', 'Arima', 'Arima + PC','location','southwest')
title('Retornos del COP')

%%
e1=Col(Ind+1:end)-f1e;
e2=Col(Ind+1:end)-f2e;

e1_2=e1.^2;
e2_2=e2.^2;

% errores medios al cuadrado:
MSE1=nanmean(e1_2);
MSE2=nanmean(e2_2);

% RMSE
RMSE1=sqrt(MSE1);
RMSE2=sqrt(MSE2);

%MAE
e1_A=abs(e1);
e2_A=abs(e2);

MAE1=nanmean(e1_A);
MAE2=nanmean(e2_A);

%R Cuadrado Predictivo
MuTD=mean(Col(Ind+1:end));
ETD_2=(Col(Ind+1:end)-MuTD).^2;
Denominador1=sum(ETD_2);

R_2P1=1-(nansum(e1_2)/Denominador1);
R_2P2=1-(nansum(e2_2)/Denominador1);



% Tabla resumen resultados:

MSE=[MSE1; MSE2];
RMSE=[RMSE1; RMSE2];
MAE=[MAE1; MAE2];
R2_P=[R_2P1; R_2P2];

R2 = {'ARMA(0,1)';'ARMA(0,1) + PrC1'};

Criterios=table(MSE,RMSE,MAE, R2_P,'RowNames',R2)






