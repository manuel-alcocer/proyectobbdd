/*
        5. Muestra los nombres de las centrales donde hay aerogeneradores que han sufrido
        una desconexión tanto el 1 como el 11 de enero de 2015 usando operadores de
        conjuntos.
*/

select distinct nombre_central from aerogeneradores
where codigo in (
     select cod_aerogenerador from desconexiones
     where to_char(fechahora_inicio, 'DDMMYYYY') = '01012015'
     INTERSECT
     select cod_aerogenerador from desconexiones
     where to_char(fechahora_inicio, 'DDMMYYYY') = '11012015');
