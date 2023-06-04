function [LLM,AICM,BICM] = Garch_Elec(info,mdl)
ARC=3;
GA=3;
aicmin=Inf;
bicmin=Inf;
LLmin=-2000;
l=length(info);


for A=1:ARC
    for G=0:GA
        CondVarMdl = garch(G,A);
        mdl.Variance = CondVarMdl;
        [EstMdl,~,Logl] = estimate(mdl,info);
        [aic,bic] = aicbic(Logl,(G+A),l);
        if aic<aicmin
            aicmin=aic;
            AICM=[G,A];
        end
        if bic<bicmin
            bicmin=aic;
            BICM=[G,A];
        end
        if Logl>LLmin
            LLmin=Logl;
            LLM=[G,A];
        end
    end
end