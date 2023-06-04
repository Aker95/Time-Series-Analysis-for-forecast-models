clc; clear all;
%asignar directorio:
%cd 'C:\Users\Nick\Documents\MAESTRIA\2022-1\Series de tiempo\taller\Taller 1 est\Punto 1'

%%
BASE = readtable('RATING.xlsx','Sheet','BASE','ReadVariableNames',true);
UGDP = readtable('RATING.xlsx','Sheet','USA GDP','ReadVariableNames',true);

%%

UGDP.Properties.VariableNames{1} = 'year';
BASE.Properties.VariableNames{17} = 'year';
df = data2set(join(BASE ,UGDP );
%%


df.grosspib = (df.gross./df.GDPUS_USD_)*100;
df.budgetpib = (df.budget./df.GDPUS_USD_)*100;
  
%%
