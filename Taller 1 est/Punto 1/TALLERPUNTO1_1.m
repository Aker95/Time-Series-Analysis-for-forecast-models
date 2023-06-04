%PUNTO 2
clc; clear all;
ds = readtable("RATING.xlsx", "UseExcel", false);
%unimos las dos tablas
ds1 = readtable('RATING.xlsx','Sheet','USA GDP');
ds1.Properties.VariableNames{1} = 'year';
ds.Properties.VariableNames{17} = 'year';
T = join( ds , ds1);
%calculamos el gross como porcentaje del dgp 
p= (T.gross./T.GDPUS_USD_)*100;
%calculamos el  budget como porcentaje del dgp 
x=(T.budget./T.GDPUS_USD_)*100;
%% 

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
%% 

%PUNTO 4 
T1 = removevars(T,[2 7 8 13 14 15 16 17 21 25 26 22 23 24]);

a=corrcoef(T1.Variables,Rows="complete");
CorIMDB = a(:,1);
IMDB=T1(:,1);
P = removevars(T1,{'actor_3_facebook_likes','cast_total_facebook_likes','facenumber_in_poster','actor_2_facebook_likes','aspect_ratio'});
%a. las variables con correlación mayor a 0.15 son número de críticas con
%review,duración,likes de facebook del director,número de usuarios que
%votaron por la película,numero de usuarios que hicieron un review y likes
%de facebook de la película  
%b.
corrplot(P)

%% 
%PUNTO 5

scatter(P.num_critic_for_reviews,P.imdb_score)
xlabel('numero criticas con review')
ylabel('imdb_score')
%se observa una relación no lineal, se asemeja a una logarítmica
%% 
scatter(P.duration,P.imdb_score)
xlabel('duración')
ylabel('imdb_score')
%se observa una relación no lineal parece logarítmica
%% 
scatter(P.director_facebook_likes,P.imdb_score)
xlabel('likes de facebook del director')
ylabel('imdb_score')
%% 
scatter(P.num_voted_users,P.imdb_score)
xlabel('numero usuarios que votaron por la pelicula')
ylabel('imdb_score')
%se observa una relación no lineal parece logarítmica

%% 
scatter(P.num_user_for_reviews,P.imdb_score)
xlabel('numero de usuarios que hicieron review')
ylabel('imdb_score')
%se observa una relación no lineal parece logarítmica

%% 
scatter(P.movie_facebook_likes,P.imdb_score)
xlabel('facebook likes de la pelicula')
ylabel('imdb_score')
%se observa una relación no lineal parece logarítmica



%% 
%PUNTO 6

cualitative = removevars(T,{'num_critic_for_reviews','cast_total_facebook_likes','facenumber_in_poster','actor_2_facebook_likes','aspect_ratio','duration','actor_1_facebook_likes','actor_3_facebook_likes','gross','num_voted_users','budget','num_user_for_reviews','year','movie_facebook_likes','GDPUS_USD_','director_facebook_likes'});
clean=rmmissing(cualitative)
%% 
boxplot(clean.imdb_score,clean.color)
xlabel('Color (Blanco o Negro)') 
ylabel('IMDB')
%esta puede resultar una varible cualitativa útil, ya que, el gráfico
%muestra que hay diferentes valores de IMDB en la media cuando la película
%es a blanco y negro que cuando es a color, por lo que, esto puede se puede
%un modelo que incluya esto en su estimación  
%% 
boxplot(clean.imdb_score,clean.language)
xlabel('idioma') 
ylabel('IMDB')
%esta puede resultar una varible cualitativa útil, ya que, el gráfico
%muestra que hay diferentes valores de IMDB en la media dependiendo del 
%idioma de  la película, sin embargo, se podría realizar entre menos
%idiomas como una dummy de si es en inglés o no(otro idioma) la película y
%ver como es la relación con el IDMB

%% 
boxplot(clean.imdb_score,clean.country)
xlabel('País') 
ylabel('IMDB')
%esta puede resultar una varible cualitativa útil, ya que, el gráfico
%muestra que hay diferentes valores de IMDB en la media dependiendo del 
%país de  la película, sin embargo, se podría realizar evaluando si la
%película es en estados unidos o no (otro país) porque se ve que este país
%tiene un comportamiento especial en comparación con los otros  
%% 
boxplot(clean.imdb_score,clean.content_rating)
xlabel('rating contenido') 
ylabel('IMDB')
%Hay variaciones de la mediana y son más leves por lo que pueda que el  
%rating de la película no cause mayores diferencias en la IMDB, sin
%embargo, puede ser interesante observarlo en la estimación
%% 
boxplot(clean.imdb_score,clean.director_name)
xlabel('nombre director') 
ylabel('IMDB')
%no resulta una variable interesante para usar en la estimación del modelo
% ya que los datos no muestran ningún comportamiento que parezca tener 
%relación con el IMDB
%% 
boxplot(clean.imdb_score,clean.actor_1_name)
xlabel('nombre actor principal') 
ylabel('IMDB')
%no resulta una variable interesante para usar en la estimación del modelo
% ya que los datos no muestran ningún comportamiento que parezca tener 
%relación con el IMDB
%% 
boxplot(clean.imdb_score,clean.actor_2_name)
xlabel('nombre actor secundario') 
ylabel('IMDB')
%no resulta una variable interesante para usar en la estimación del modelo
% ya que los datos no muestran ningún comportamiento que parezca tener 
%relación con el IMDB
%% 
boxplot(clean.imdb_score,clean.actor_3_name)
xlabel('nombre actor terciario') 
ylabel('IMDB')
%no resulta una variable interesante para usar en la estimación del modelo
% ya que los datos no muestran ningún comportamiento que parezca tener 
%relación con el IMDB
%% 
boxplot(clean.imdb_score,clean.genres)
xlabel('generos') 
ylabel('IMDB')

%hay variaciones de la mediana puede ser interesante observarlo en la estimación
%% 
%PUNTO 7 
P1=rmmissing(P)

Modelo1=fitlm(P1,'imdb_score~num_critic_for_reviews+duration+director_facebook_likes+num_voted_users+num_user_for_reviews+movie_facebook_likes')
%% 

mod2 = removevars(T,[7 8 13 14 15 16 17 21 25 26 22 23 24]);
tablamod2 = removevars(mod2,{'actor_3_facebook_likes','cast_total_facebook_likes','facenumber_in_poster','actor_2_facebook_likes','aspect_ratio'});
tablamod21= rmmissing(tablamod2)
Modelo1=fitlm(tablamod21,'imdb_score~num_critic_for_reviews+duration+director_facebook_likes+num_voted_users+num_user_for_reviews+movie_facebook_likes+color')

%modelo 1: R-squared: 0.302,  Adjusted R-Squared: 0.301
%modelo 2: R-squared: 0.312,  Adjusted R-Squared: 0.31
%para pronósticos preferimos valores más altos del R cuadrado y el ajustado
%por lo cual se puede preferir el el modelo 2, sin embargo, ambos r
%cuadrados no tienen un valor muy alto, lo cual, indica que estos modelos
%podrían no dar los mejores pronósticos, asimismo, el criterio de la
%correlación parece no ser suficiente para asegurar unos buenos pronósticos

%% 
%PUNTO 8
Modelo1=fitlm(P1,'imdb_score~num_critic_for_reviews+duration+director_facebook_likes+num_voted_users+num_user_for_reviews+movie_facebook_likes')


% Generemos los pronósticos dentro de muestra y grafiquemos:

% Modelo 1 - pronóstico dentro de muestra:

betas1=Modelo1.Coefficients.Estimate;
%% 
%Estimación de los NaN 
NAN = readtable("nanvalues.xlsx", "UseExcel", false);
NAN.imdb_score=betas1(1,1)+betas1(2,1)*NAN.num_critic_for_review+betas1(3,1).*NAN.duration+betas1(4,1).*NAN.director_facebook_likes+betas1(5,1).*NAN.num_voted_users+betas1(6,1).*NAN.num_user_for_reviews+betas1(7,1).*NAN.movie_facebook_likes;
%% 
%gráfico de dispersión
scatter(NAN.duration,NAN.imdb_score)
xlabel('duración de la película')
ylabel('imdb_score')
%análisis del gráfico: el resultado parece consistente, ya que, se espera
%que las películad tengan mayor rating en una duración "media", que es
%donde evidentemente en el gráfico se concentran la mayor cantidad de
%películas y donde hay niveles altos de rating. Para películas con una 
% duración muy corta, que usualmente son para un público infantil o no 
% grandes producciones, tiene sentido tener un menor rating; asimismo, 
% hay películas con una duración mayor pero con un gran rating,lo cual,
% refleja el caso de películas galardonadas y best sellers a lo largo 
% del tiempo, por lo cual, podemos tener un pronóstico acertado. 
