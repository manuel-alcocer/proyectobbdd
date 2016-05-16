/*
        5. Muestra los nombres de las centrales donde hay aerogeneradores que han sufrido
        una desconexión tanto el 1 como el 11 de enero de 2015 usando operadores de
        conjuntos.
*/

select distinct nombre_central from AEROGENERADORES
where codigo in (
     select cod_aerogenerador from DESCONEXIONES
     where date_format(fechahora_inicio, '%d%m%Y') = '03012015'
     and cod_aerogenerador in (
     select cod_aerogenerador from DESCONEXIONES
     where date_format(fechahora_inicio, '%d%m%Y') = '03022015'));
