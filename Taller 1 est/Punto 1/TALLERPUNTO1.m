%PUNTO 2
clc; clear all;
ds = readtable("RATING.xlsx", "UseExcel", false);
%unimos las dos tablas
ds1 = readtable('RATING.xlsx','Sheet','USA GDP');
ds1.Properties.VariableNames{1} = 'year';
ds.Properties.VariableNames{17} = 'year';
T = join( ds , ds1);
%%
%calculamos el gross como porcentaje del dgp 
p= (T.gross./T.GDPUS_USD_)*100;
%calculamos el  budget como porcentaje del dgp 
x=(T.budget./T.GDPUS_USD_)*100;
%PUNTO 3
T.color = categorical(T.color);
T.language = categorical(T.language);
T.country = categorical(T.country);
T.language = categorical(T.language);
T.content_rating = categorical(T.content_rating);
T.director_name = categorical(T.director_name);
T.actor_1_name = categorical(T.actor_1_name);
T.actor_2_name = categorical(T.actor_2_name);
T.actor_3_name = categorical(T.actor_3_name);
T.genres = categorical(T.genres);
%PUNTO 4 
T1 = removevars(T,[2 7 8 13 14 15 16 17 21 25 26 22 23 24]);
TW=T1(:,1);

figure
subplot(1,2,1)
autocorr(ds.imdb_score)
ylabel('ACF')
xlabel('Rezago')
title('ACF varianción ISE')

subplot(1,2,2)
parcorr(ds.imdb_score)
ylabel('PACF')
xlabel('Rezago')
title('PACF varianción ISE')
