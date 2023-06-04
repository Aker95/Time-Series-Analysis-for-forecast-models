function [LLM,AICM,BICM] = model(info)
AR=5;
MA=5;
SMA=4;
SAR=4;
aicmin=Inf;
bicmin=Inf;
LLmin=-2000;
l=length(info);
for R=0:AR
    for M=0:MA
        for SM=0:SMA
            for SR=0:SAR
                if  R~= 0 &  M~= 0 & SM~= 0 & SR~= 0 
                    MdL = arima('ARLags',[1:R],'D',0,'MALags',[1:M], 'SARLags',[1:SR]*6,'SMALags',[1:SM]*6);
                elseif R== 0 & M~= 0 & SM~= 0 & SR~= 0 
                    MdL = arima('D',0,'MALags',[1:M], 'SARLags',[1:SR]*6,'SMALags',[1:SM]*6);
                elseif R~= 0 &  M == 0 & SM ~= 0 & SR ~= 0 
                    MdL = arima('D',0,'ARLags',[1:M], 'SARLags',[1:SR]*6,'SMALags',[1:SM]*6);
                elseif SM== 0 & SR~= 0 
                    if R~= 0 & M == 0 
                        MdL = arima('D',0,'ARLags',[1:M], 'SARLags',[1:SR]*6);
                    elseif R ==  0 & M ~= 0 
                        MdL = arima('D',0,'MALags',[1:M], 'SARLags',[1:SR]*6);
                    end
                elseif SM~=0 & SR==0 
                    if R~= 0 & M == 0 
                        MdL = arima('D',0,'ARLags',[1:M], 'SMALags',[1:SM]*6);
                    elseif R ==  0 & M ~= 0 
                        MdL = arima('D',0,'MALags',[1:M], 'SMALags',[1:SM]*6);
                    end
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
                if Logl<LLmin
                    LLmin=Logl;
                    LLM=[R,M,SR,SM];
                end
                end
            end
        end
    end
end
