clc;
clear all;

ds = readtable('BRENT.csv','VariableNamingRule','preserve');
ds = table(transpose(1990+5/12:1/12:2022+3/12),ds.("Último"),'VariableNames',{'Fecha','Brent'});

%% i Modelo utilizado: ARIMA (5,0,4) - GARCH (1,2)
X =find(ds{:,1}==2010);
rBrent = (log(ds.Brent(2:end))-log(ds.Brent(1:end-1)))*100;
%[info,lower,upper,center] = filloutliers(rBrent(1:X),'clip','median');


info=rBrent(1:X);
%%
AR=2;
MA=2;
SMA=6;
SAR=6;
aicmin=Inf;
bicmin=Inf;
LLmin=-2000;
l=length(info);
for R=0:AR
    for M=0:MA
        for SM=0:SMA
            for SR=0:SAR
                if  R~= 0 &  M~= 0 & SM~= 0 & SR~= 0 
                    MdL = arima('ARLags',[1:R],'D',0,'MALags',[1:M], 'SARLags',[1:SR]*3,'SMALags',[1:SM]*3);
                elseif R== 0 & M~= 0 & SM~= 0 & SR~= 0 
                    MdL = arima('D',0,'MALags',[1:M], 'SARLags',[1:SR]*3,'SMALags',[1:SM]*3);
                elseif R~= 0 &  M == 0 & SM ~= 0 & SR ~= 0 
                    MdL = arima('D',0,'ARLags',[1:R], 'SARLags',[1:SR]*3,'SMALags',[1:SM]*3);
                elseif R~= 0 & M == 0 & SM== 0 & SR~= 0
                    MdL = arima('ARLags',[1:R],'D',0, 'SARLags',[1:SR]*3);
                elseif R ==  0 & M ~= 0 & SM== 0 & SR~= 0
                    MdL = arima('MALags',[1:M], 'D',0, 'SARLags',[1:SR]*3)
                elseif R~= 0 & M == 0 & SM~=0 & SR==0 
                    MdL = arima('ARLags',[1:R],'D',0,'SMALags',[1:SM]*3);
                elseif R ==  0 & M ~= 0 & SM~=0 & SR==0 
                    MdL = arima('D',0,'MALags',[1:M], 'SMALags',[1:SM]*3);
                else
                    MdL = arima(R,0,M);
                end
                if  R~= 0 |  M~= 0 | SM~= 0 | SR~= 0 
                [EstMdl,~,Logl] = estimate(MdL,info);
                [aic,bic] = aicbic(Logl,(R+M+SM+SR),l);
                if aic<aicmin
                    aicmin=aic;
                    AICM=[R,M,SR,SM];
                end
                if bic<bicmin
                    bicmin=aic;
                    BICM=[R,M,SR,SM];
                end
                if Logl>LLmin
                    LLmin=Logl;
                    LLM=[R,M,SR,SM];
                end
                end
            end
        end
    end
end




%%
MdL = arima('MALags',[1:1], 'SARLags',11,'SMALags',11);
[EstMdl,~,Logl] = estimate(MdL,info);
[aic,bic1] = aicbic(Logl,1,l);