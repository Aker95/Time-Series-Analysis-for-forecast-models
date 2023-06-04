clc; clear all;
%asignar directorio:
%cd 'C:\Users\Nick\Documents\MAESTRIA\2022-1\Series de tiempo\taller\Taller 1 est\Punto 1'

%%
BASE = readtable('RATING.xlsx','Sheet','BASE','ReadVariableNames',true);
UGDP = readtable('RATING.xlsx','Sheet','USA GDP','ReadVariableNames',true);

%%

UGDP.Properties.VariableNames{1} = 'year';
BASE.Properties.VariableNames{17} = 'year';
df = join(BASE ,UGDP );
%%

df.grosspib = (df.gross./df.GDPUS_USD_)*100;
df.budgetpib = (df.budget./df.GDPUS_USD_)*100;
  
%%
%determine which variables are numeric and which are not
 NumVar= varfun(@isnumeric,df, 'output', 'uniform');

 for i=1:width(df)
     if NumVar(i) == 0
       df.(i) = categorical(df.(i));
     end
 end

%%

% corr(df.(1),df.(3),'rows','complete') obtain the correlation of two
% variables ignoring nan values

names = df(:,NumVar).Properties.VariableNames;
vartype = repmat({'double'}, 1,sum(NumVar));
Corr = table('Size',[1 19],'VariableTypes', vartype,'VariableNames',names);
%%
j=0;
for i=1:width(df)
    if NumVar(i)==1
        j=j+1;
        Corr{1,j} = corr(df.(1),df.(i),'rows','complete');
    end
end

%%
j=0;

Corrlist = NumVar;

for i=1:width(df)
    if Corrlist(i)==1
        j=j+1;
        if abs(Corr{1,j})<0.15
            Corrlist(i)=0;
        end
    end
end

%%

figure (1)

corrplot(df(:,Corrlist))
%%
%{
figure (2)
scatter(df.(1), df.(3))
xlabel(names(1))
ylabel(names(3))
%}
%%
j=1;

figure (2)

for i=1:width(Corrlist)
    if Corrlist(i)==1
        subplot(3,3,j)
        scatter(df.(1), df.(i))
        xlabel(names(1))
        ylabel(names(j))
        j = j + 1;
    end
end
%%
