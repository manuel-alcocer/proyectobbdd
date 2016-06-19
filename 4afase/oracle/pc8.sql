create or replace package PC8 as

    TYPE TipoRegCantModelos is record
    (
        cantidad    number
    );
    TYPE TipoTablaCantModelos is table of TipoRegCantModelos
        index by modelos_aerogeneradores.nombre%TYPE;

    TYPE TipoRegModelosCentrales is record
    (
        modelos     TipoTablaCantModelos
    );
    TYPE TipoTablaModelosCentrales is table of TipoRegModelosCentrales
        index by centrales.nombre%TYPE;

    TablaCantModelos TipoTablaModelosCentrales;

    procedure RellenarTablaCantModelos;

    function ComprobarTransaccion (p_codigo aerogeneradores.codigo%TYPE,
                                    p_central centrales.nombre%TYPE,
                                    p_modelo modelos_aerogeneradores.nombre%TYPE)
        return boolean;

end PC8;
/

create or replace package body PC8 as

    procedure RellenarTablaCantModelos
    is
        cursor c_centrales is
            select nombre from centrales;

        v_nombre_central    centrales.nombre%TYPE;

        cursor c_modelos is
            select nombre_modelo as nombre, nvl(count(*),0) as cantidad
                from aerogeneradores
                where nombre_central = v_nombre_central
                group by nombre_modelo;

        j modelos_aerogeneradores.nombre%TYPE;

    begin
        TablaCantModelos.delete;
        for v_central in c_centrales loop
            v_nombre_central := v_central.nombre;
            for v_modelo in c_modelos loop
                TablaCantModelos(v_central.nombre).modelos(v_modelo.nombre).cantidad := v_modelo.cantidad;
            end loop;
        end loop;
    end RellenarTablaCantModelos;

    function ComprobarTransaccion (p_codigo aerogeneradores.codigo%TYPE,
                                    p_central centrales.nombre%TYPE,
                                    p_modelo modelos_aerogeneradores.nombre%TYPE)
        return boolean
    is
        v_umbral_modelos number := 3;
        existe_ese_modelo  boolean := False;
        v_cantidad_modelos number := 0;
    begin
        existe_ese_modelo := TablaCantModelos(p_central).modelos.exists(p_modelo);
        if not existe_ese_modelo then
            v_cantidad_modelos := TablaCantModelos(p_central).modelos.count;
            if v_cantidad_modelos >= v_umbral_modelos then
                return False;
            end if;
        else
            TablaCantModelos(p_central).modelos(p_modelo).cantidad := NVL(TablaCantModelos(p_central).modelos(p_modelo).cantidad, 0) + 1;
            return True;
        end if;
    end ComprobarTransaccion;
end PC8;
/

create or replace trigger PrepararControlModelos
before insert or update on aerogeneradores
begin
    PC8.RellenarTablaCantModelos;
end PrepararControlModelos;
/

create or replace trigger ControlModelosCentral
after insert or update on aerogeneradores
for each row
declare
    v_exito boolean;
    e_limite_sobrepasado_insercion exception;
    e_limite_sobrepasado_actualiza exception;
begin
    case
        when inserting then
            v_exito := PC8.ComprobarTransaccion(:new.codigo,:new.nombre_central,:new.nombre_modelo);
            if not v_exito then
                raise e_limite_sobrepasado_insercion;
            end if;
    end case;
exception
    when e_limite_sobrepasado_insercion then
        dbms_output.put_line('Se ha sobrepasado el límite de modelos por central (3) ');
        delete from aerogeneradores
            where codigo = :new.codigo;
        /* dbms_output('No se hará la transacción para el aerogenerador: ' || p_codigo);*/
end ControlModelosCentral;
/
