/*
        4. Muestra aquellas centrales en las que exista alguna predicción de viento de dirección
        Norte y tengan más de 3 aerogeneradores.
*/

select distinct nombre_central from predicciones_viento
where substr(direccion,length(direccion),1) = 'N'
and nombre_central in (
    select nombre_central from aerogeneradores
    group by nombre_central
    having count(*) > 3);
