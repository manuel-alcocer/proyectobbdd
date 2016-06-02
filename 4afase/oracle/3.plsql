create or replace trigger controlproduccion
before insert or update on producciones_aerogeneradores
for each row
    declare
        v_prod_maxima number;
    begin
        v_prod_maxima := CalcularMaximo(:new.cod_aerogenerador);

        if :new.produccion > v_prod_maxima then
            raise_application_error(-20004, 'La produccion supera el máximo del modelo del aerogenerador');
        end if;
    end controlproduccion;
