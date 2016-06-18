create or replace trigger desconexion10max
before insert or update on desconexiones
for each row
    declare
        v_diez_min  float := 10/1440;
    begin
        if round((:new.fechahora_fin - :new.fechahora_inicio),5) > v_diez_min then
            raise_application_error(-20010, 'El periodo de desconexion no puede ser mayor que 10 minutos');
        end if;
end desconexion10max;
/

