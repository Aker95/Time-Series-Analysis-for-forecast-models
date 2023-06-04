function [AICM,BICM] = model_election(info,AR,MA,Sea,SMA,SAR)
aicmin=Inf;
bicmin=Inf;
l=length(info);
for R=0:AR
    for M=0:MA
        for SM=0:SMA
            for SR=0:SAR
                if  R~= 0 &  M~= 0 & SM~= 0 & SR~= 0 
                    MdL = arima('ARLags',[1:R],'D',0,'MALags',[1:M], 'SARLags',[1:SR]*Sea,'SMALags',[1:SM]*Sea);
                elseif R== 0 & M~= 0 & SM~= 0 & SR~= 0 
                    MdL = arima('D',0,'MALags',[1:M], 'SARLags',[1:SR]*Sea,'SMALags',[1:SM]*Sea);
                elseif R~= 0 &  M == 0 & SM ~= 0 & SR ~= 0 
                    MdL = arima('D',0,'ARLags',[1:M], 'SARLags',[1:SR]*Sea,'SMALags',[1:SM]*Sea);
                elseif SM== 0 & SR~= 0 
                    if R~= 0 & M == 0 
                        MdL = arima('D',0,'ARLags',[1:M], 'SARLags',[1:SR]*Sea);
                    elseif R ==  0 & M ~= 0 
                        MdL = arima('D',0,'MALags',[1:M], 'SARLags',[1:SR]*Sea);
                    end
                elseif SM~=0 & SR==0 
                    if R~= 0 & M == 0 
                        MdL = arima('D',0,'ARLags',[1:M], 'SMALags',[1:SM]*Sea);
                    elseif R ==  0 & M ~= 0 
                        MdL = arima('D',0,'MALags',[1:M], 'SMALags',[1:SM]*Sea);
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
                end
            end
        end
    end
end


