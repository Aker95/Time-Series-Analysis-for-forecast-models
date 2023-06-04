%% Codigo para hacer la sección de pronóstico de sección cruzada taller 1.
%% Resumen
% Este codigo contiene todos los MFILE necesarios para desarrollar el punto de pronostico
% de sección cruzada.

%% Datos 
% Los datos corresponden a las caracteristicas que definen el rating de un total 3.751 películas. SE tiene el rating Imdb y 25 variables explicativas. Estos datos provienen del DANE y tienen
% diferentes variables cualitativas. Los datos provienen del GITHUB de XXXX
%
%% 
clc; clear;

%% Importando los datos como un conjunto de datos:

% es muy facil en excel filtrar los datos de las peliculas en los que se
% reporta el rating IMDB y los que no. De igual forma tambien se estimaron
% las ganancias y el presupuesto como porcentaje del PIB previamente. Por
% eso se crean dos tablas en matlab y se evitan tareas innecesarias.

%Datos con ratings reportados

Cr = readtable("RATINGF.xlsx", "UseExcel", false,"sheet",'BaseSNA');


%Datos sin ratings reportados:

Sr = readtable("RATINGF.xlsx", "UseExcel", false,"sheet",'BaseNA');


%% 1.1.2 Estimando las ganancias y el presupuesto como porcentaje del PIB:

% Esta ya fue estimada previamente en Excel.


%% 1.1.3. Convirtiendo los datos en categoricos:

% Para la tabla con rating

Cr.color = categorical(Cr.color);
Cr.language = categorical(Cr.language);
Cr.country = categorical(Cr.country);
Cr.content_rating=categorical(Cr.content_rating);
Cr.director_name=categorical(Cr.director_name);
Cr.actor_1_name=categorical(Cr.actor_1_name);
Cr.actor_2_name=categorical(Cr.actor_2_name);
Cr.actor_3_name=categorical(Cr.actor_3_name);
Cr.movie_title=categorical(Cr.movie_title);
Cr.genres=categorical(Cr.genres);


% Para la tabla sin rating

Sr.color = categorical(Sr.color);
Sr.language = categorical(Sr.language);
Sr.country = categorical(Sr.country);
Sr.color = categorical(Sr.color);
Sr.content_rating=categorical(Sr.content_rating);
Sr.director_name=categorical(Sr.director_name);
Sr.actor_1_name=categorical(Sr.actor_1_name);
Sr.actor_2_name=categorical(Sr.actor_2_name);
Sr.actor_3_name=categorical(Sr.actor_3_name);
Sr.movie_title=categorical(Sr.movie_title);
Sr.genres=categorical(Sr.genres);



%% 1.1.4. Diagramas de disperción - correlograma:
Cr1=removevars(Cr,{'color', 'language', 'country', 'content_rating',...
    'director_name', 'actor_1_name', 'actor_2_name', 'actor_3_name',...
    'movie_title', 'genres', 'GDP', 'gross', 'budget', 'title_year'});

%1.1.4 a
% LAs variables 

%1.1.4 b Las variables que tienen una correlación superior a 0,15 en valor
%absoluta con el Imdb son: número de criticas, duración, likes del director
%en Facebook, númeor de votos de los usuarios, número de usuarios que
%hicieron reviews, facebook likes de la pelicula, ganancias como % del PIB

Cr2=removevars(Cr1,{'actor_3_facebook_likes', 'actor_1_facebook_likes'...
    'cast_total_facebook_likes','facenumber_in_poster', 'actor_2_facebook_likes'...
    ,'aspect_ratio', 'budget2', 'grossOverBudget'});

% el correlograma sería el siguiente:

figure(1)
corrplot(Cr2)

%% 1.1.5 Grafiquemos los diagramas de dispersión

figure(2)
subplot(3,3,1)
scatter(Cr2.num_critic_for_reviews,Cr2.imdb_score,40,'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1)
xlabel('Número de criticas') 
ylabel('Imdb Score')

subplot(3,3,2)
scatter(Cr2.duration,Cr2.imdb_score,40,'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1)
xlabel('Duración') 
ylabel('Imdb Score')

subplot(3,3,3)
scatter(Cr2.director_facebook_likes,Cr2.imdb_score,40,'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1)
xlabel('Likes del director') 
ylabel('Imdb Score')

subplot(3,3,4)
scatter(Cr2.num_voted_users,Cr2.imdb_score,40,'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1)
xlabel('Número de usuarios que votaron') 
ylabel('Imdb Score')

subplot(3,3,5)
scatter(Cr2.num_user_for_reviews,Cr2.imdb_score,40,'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1)
xlabel('Número de reviews') 
ylabel('Imdb Score')

subplot(3,3,6)
scatter(Cr2.movie_facebook_likes,Cr2.imdb_score,40,'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1)
xlabel('Número de likes pelicula') 
ylabel('Imdb Score')

subplot(3,3,7)
scatter(Cr2.gross2,Cr2.imdb_score,40,'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1)
xlabel('Ganancias % del PIB') 
ylabel('Imdb Score')


% En general todas podrían tener una relación concava con el idb score. Sin
% embargo, la duración muestra una clara relación concava con el idb score
% que se debería tener en cuenta. Despues de los 250 minutos de duración se
% ve una clara disminucion en la calificación del apelicula. Esto no es
% claro para el resto de variables, al menos a primera vista.

%% 1.1.6. Elaboración boxplots variables categoricas:

figure (3)

gscatter(Cr.duration, Cr.imdb_score, Cr.genres)
xlabel('Educacion') 
ylabel('Log Salario')


figure (4)

boxplot(Cr.imdb_score, Cr.color)

figure (5)

boxplot(Cr.imdb_score, Cr.language)

figure (6)

boxplot(Cr.imdb_score, Cr.country)

figure (7)

boxplot(Cr.imdb_score, Cr.content_rating)

figure (8)

boxplot(Cr.imdb_score, Cr.director_name)

figure (9)

boxplot(Cr.imdb_score, Cr.actor_1_name)

figure (10)

boxplot(Cr.imdb_score, Cr.actor_2_name)

figure (11)

boxplot(Cr.imdb_score, Cr.actor_3_name)

figure (12)

boxplot(Cr.imdb_score, Cr.genres)


%% 1.1.7. Estimación modelos de regresión y R2:

Cr.d2=Cr.duration.^2;
Modelo1=fitlm(Cr,'imdb_score~num_critic_for_reviews+duration+director_facebook_likes+num_voted_users+num_user_for_reviews+movie_facebook_likes+gross2')

Modelo2=fitlm(Cr,'imdb_score~num_critic_for_reviews+duration+director_facebook_likes+num_voted_users+num_user_for_reviews+movie_facebook_likes+gross2+genres')




% el modelo con la variable DUMMY y con el intercepto tendría un mejor
% desempeño, su R2 muestra que es capaz de explicar el 38% de la
% variabilidad del rating, mientras que el modelo sin DUMMY cambia por
% alcanzaría a explicar tan solo el 30%.

%% 1.1.8. Estimación ratings no presentados:

betahat=Modelo1.Coefficients.Estimate;


% dgenres=dummyvar(Sr.genres);
% 
% Sr.imdb_score=betahat(1,1)+Sr.num_critic_for_reviews.*betahat(2,1)+Sr.duration.*betahat(3,1)+Sr.director_facebook_likes.*betahat(4,1)...
%     +Sr.num_voted_users.*betahat(5,1)+Sr.num_user_for_reviews.*betahat(6,1)+Sr.movie_facebook_likes.*betahat(7,1)+dgenres(:,2).*betahat(8,1)...
%     +dgenres(:,3).*betahat(9,1)+dgenres(:,4).*betahat(10,1)+dgenres(:,5).*betahat(11,1)+dgenres(:,6).*betahat(12,1)+dgenres(:,7).*betahat(13,1)...
%     +dgenres(:,8).*betahat(14,1)+dgenres(:,9).*betahat(15,1)+dgenres(:,10).*betahat(16,1)+dgenres(:,11).*betahat(17,1)+0.*betahat(18,1)...
%     +dgenres(:,12).*betahat(19,1)+0.*betahat(20,1)+dgenres(:,13).*betahat(21,1)+0.*betahat(22,1)+0.*betahat(23,1)+Sr.gross.*betahat(24,1);


Sr.imdb_score=betahat(1,1)+Sr.num_critic_for_reviews.*betahat(2,1)+Sr.duration.*betahat(3,1)+Sr.director_facebook_likes.*betahat(4,1)...
   +Sr.num_voted_users.*betahat(5,1)+Sr.num_user_for_reviews.*betahat(6,1)+Sr.movie_facebook_likes.*betahat(7,1)+Sr.gross2.*betahat(8,1);

figure(13)
scatter(Sr.duration,Sr.imdb_score,40,'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1)
xlabel('Duración') 
ylabel('Imdb')


%% 1.2.1. Intervalo de confianza sin simulaciones. 

%estimemos la desviación y media de los errores de pronóstico:

S=std(Modelo2.Residuals.Raw);
mu=mean(Modelo2.Residuals.Raw);

% Mediana de las variables exogenas

MNCR=median(Cr.num_critic_for_reviews);
Mduration=median(Cr.duration);
MDFL=median(Cr.director_facebook_likes);
MNVU=median(Cr.num_voted_users);
MNUFR=median(Cr.num_user_for_reviews);
MMFL=median(Cr.movie_facebook_likes);
MG2=median(Cr.gross2);

% Estimación del rating medio de la ecuacion [2] del taller y carácteristicas establecidas:

betahat=Modelo2.Coefficients.Estimate;

MuR=betahat(1,1)+MNCR*betahat(2,1)+Mduration*betahat(3,1)+MDFL*betahat(4,1)...
    +MNVU*betahat(5,1)+MNUFR*betahat(6,1)+MMFL*betahat(7,1)+betahat(9,1)+MG2*betahat(24,1);


%intervalo 95%:

MuRU=MuR+norminv(0.975)*S;
MuRD=MuR-norminv(0.975)*S;



% reportando los datos en una tabla:
format long g
MODELOS = {'Pronóstico Rating Promedio'};


Pronostico=MuR;
Intervalo_Superior=MuRU;
Intervalo_Inferior=MuRD;
Intervalo = table(Pronostico,Intervalo_Inferior,Intervalo_Superior,'RowNames',MODELOS)




%% 1.2.2 y 1.2.3 simulaciones asumiendo normalidad:

% R=50:

RNormal50=normrnd(0,S,[1,50]);
MuR50_Normal=(RNormal50'+MuR);

% calculamos los intervalos de predicción a 95% de confianza:
format long g
pw50normal = prctile(MuR50_Normal, [2.5 97.5]);

% R=500:

RNormal500=normrnd(0,S,[1,500]);
MuR500_Normal=(RNormal500'+MuR);

% calculamos los intervalos de predicción a 95% de confianza:
format long g
pw500normal = prctile(MuR500_Normal, [2.5 97.5]);

% R=10000:

RNormal10000=normrnd(0,S,[1,10000]);
MuR10000_Normal=(RNormal10000'+MuR);

% calculamos los intervalos de predicción a 95% de confianza:
format long g
pw10000normal = prctile(MuR10000_Normal, [2.5 97.5])

format long g
figure (14)

subplot(3,1,1)
ksdensity(MuR50_Normal)
grid on
line([pw50normal(1,1) pw50normal(1,1)], ylim*2,'Color','r','LineStyle',':','LineWidth',2)
line([pw50normal(1,2) pw50normal(1,2)], ylim,'Color','r','LineStyle',':','LineWidth',2)
line([MuR MuR],ylim*2,'Color','b','LineStyle',':','LineWidth',5)
ylim([0 0.6])
xlim([3 10])
ylabel('Densidad')
title('Gráfico de Densidad 50 simulaciones')

subplot(3,1,2)
ksdensity(MuR500_Normal)
grid on
line([pw500normal(1,1) pw500normal(1,1)], ylim*2,'Color','r','LineStyle',':','LineWidth',2)
line([pw500normal(1,2) pw500normal(1,2)], ylim,'Color','r','LineStyle',':','LineWidth',2)
line([MuR MuR],ylim*2,'Color','b','LineStyle',':','LineWidth',5)
ylim([0 0.6])
xlim([3 10]) 
ylabel('Densidad')
title('Gráfico de Densidad 500 simulaciones')


subplot(3,1,3)
ksdensity(MuR10000_Normal)
grid on
line([pw10000normal(1,1) pw10000normal(1,1)], ylim*2,'Color','r','LineStyle',':','LineWidth',2)
line([pw10000normal(1,2) pw10000normal(1,2)], ylim,'Color','r','LineStyle',':','LineWidth',2)
line([MuR MuR],ylim*2,'Color','b','LineStyle',':','LineWidth',5)
ylim([0 0.6])
xlim([3 10])
xlabel('Pronóstico Rating IMDB - (Mediana + Animación)') 
ylabel('Densidad')
title('Gráfico de Densidad 10.000 simulaciones')


    
%% 1.2.4 y 1.2.5 simulaciones no parámetrica:

% a. generamos 10.000 numeros aleatorios que se obtienen directamente de los errores estimados:

RNoP = datasample(Modelo2.Residuals.Raw,10000);

%b. De la estimación del punto con distribución normal tomamos la estimación y generamos 10000 pronosticos con los
%errores no parametricos:


MuR_NoP=(RNoP'+MuR);


% c. calculamos los intervalos de predicción a 95% de confianza:


pw1NoP = prctile(MuR_NoP, [2.5 97.5])


% e. se hace la funcion de densidad y se gráfica

figure (15)

ksdensity(MuR_NoP)
grid on
line([pw1NoP(1,1) pw1NoP(1,1)], ylim*2,'Color','r','LineStyle',':','LineWidth',2)
line([pw1NoP(1,2) pw1NoP(1,2)], ylim,'Color','r','LineStyle',':','LineWidth',2)
line([MuR MuR],ylim*2,'Color','b','LineStyle',':','LineWidth',5)
ylim([0 0.6])
xlim([3 10])
xlabel('Pronóstico Rating IMDB - (Mediana + Animación)') 
ylabel('Densidad')
title('Gráfico Simulación No Paramétrica')


%% 1.2.6 y 1.2.7 simulaciones no paramétrica en errores y asumiendo normalidad:
% en los parametros.


% Generando los parametros;

betasigma=Modelo2.CoefficientCovariance;

RBetas = mvnrnd(betahat,betasigma,10000);


% simulaciones:

Salario_Betas=[];

for i=1:10000
MuR_Betas(i)=RBetas(i,1)+MNCR*RBetas(i,2)+Mduration*RBetas(i,3)+MDFL*RBetas(i,4)...
    +MNVU*RBetas(i,5)+MNUFR*RBetas(i,6)+MMFL*RBetas(i,7)+RBetas(i,9)+MG2*RBetas(i,24)+RNoP(i,1);
end

% d. calculamos los intervalos de predicción a 95% de confianza:

pw1betas = prctile(MuR_Betas, [2.5 97.5])



figure (16)

ksdensity(MuR_Betas)
grid on
line([pw1betas(1,1) pw1betas(1,1)], ylim*2,'Color','r','LineStyle',':','LineWidth',2)
line([pw1betas(1,2) pw1betas(1,2)], ylim,'Color','r','LineStyle',':','LineWidth',2)
line([MuR MuR],ylim*2,'Color','b','LineStyle',':','LineWidth',5)
ylim([0 0.6])
xlim([3 10])
xlabel('Pronóstico Rating IMDB - (Mediana + Animación)') 
ylabel('Densidad')
title('Gráfico Simulación No Paramétrica')




%% 1.2.8 y 1.2.9 simulaciones asumiendo heteroscedasticidad normalidad
% en los parametros.


% ya tenemos la estimación por MCO.  hagamos la estimacion del cuadrado de
% los errores de estimacion.

Cr.Residuales2=Modelo2.Residuals.Raw.^2;

% estimando la regresion contra los errores al cuadrado;

Modelo3=fitlm(Cr,'Residuales2~num_critic_for_reviews+duration+director_facebook_likes+num_voted_users+num_user_for_reviews+movie_facebook_likes+gross2+genres', 'RobustOpts','on')

% organizando las matrices para la estimación por minimos cuadrados
% generalizados:


Sigma2=diag(Modelo3.Fitted);
SIGMA=inv(Sigma2);
Y=Cr.imdb_score;
unos=ones(length(Y),1);

% para genero es mejor crear una variable categorica en un vector:

GenresD=dummyvar(Cr.genres);
GenresD=GenresD(:,2:17);


X=[unos Cr.num_critic_for_reviews Cr.duration Cr.director_facebook_likes Cr.num_voted_users...
    Cr.num_user_for_reviews Cr.movie_facebook_likes GenresD Cr.gross2];
HBetas=inv((X'*SIGMA*X))*X'*SIGMA*Y;


% %10000 simulaciones de los erores
 Y_HAT=HBetas'*X';
 Error=Y-Y_HAT';
 Ss=std(Error);
 Ms=mean(Error);
 RNormalH=normrnd(0,Ss,[1,10000]);

MuR_H=(RNormalH'+MuR);
 

% d. calculamos los intervalos de predicción a 95% de confianza:

pw1betasH = prctile(MuR_H, [2.5 97.5])


figure (17)

ksdensity(MuR_H)
grid on
line([pw1betasH(1,1) pw1betasH(1,1)], ylim*2,'Color','r','LineStyle',':','LineWidth',2)
line([pw1betasH(1,2) pw1betasH(1,2)], ylim,'Color','r','LineStyle',':','LineWidth',2)
line([MuR MuR],ylim*2,'Color','b','LineStyle',':','LineWidth',5)
ylim([0 0.6])
xlim([3 10])
xlabel('Pronóstico Salario medio') 
ylabel('Densidad')
title('Gráfico Simulación Errores Heteroscedasticos y Normalidad en los Parámetros')






