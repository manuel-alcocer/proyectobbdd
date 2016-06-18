create or replace package PC8 as

    /* ESTADO PREVIO A LA TRANSACCIÓN EN AEROGENERADORES */
    TYPE TipoRegEstadoAnterior is record
    (
        central     centrales.nombre%TYPE,
        modelo      modelos_aerogeneradores.nombre%TYPE
    );
    TYPE TipoTablaEstadoAnterior is table of TipoRegEstadoAnterior
        index by aerogeneradores.codigo%TYPE;

    TablaEstadoAnterior TipoTablaEstadoAnterior;
    DUPTablaEstadoAnterior TipoTablaEstadoAnterior;
            /* FIN ESTADO PREVIO */

/* ------------------------------------------------------------------ */

        /* ÚLTIMA TRANSACCIÓN EN AEREOGENERADORES */
    TYPE TipoRegCantModelos is record
    (
        cantidad    number
    );
    TYPE TipoTablaCantModelos is table of TipoRegCantModelos
        index by modelos_aerogeneradores.nombre%TYPE;

    TYPE TipoRegAeros is record
    (
        modelo      modelos_aerogeneradores.nombre%TYPE
    );
    TYPE TipoTablaAeros is table of TipoRegAeros
        index by aerogeneradores.codigo%TYPE;

        /* ESTA TABLA CONTIENE A LAS OTRAS DOS */
    TYPE TipoRegModelosCentrales is record
    (
        aeros           TipoTablaAeros,
        cantmodelos     TipoTablaCantModelos
    );
    TYPE TipoTablaModelosCentrales is table of TipoRegModelosCentrales
        index by centrales.nombre%TYPE;

    TablaNuevaTransaccion TipoTablaModelosCentrales;
    DUPTablaNuevaTransaccion TipoTablaModelosCentrales;
            /* FIN ÚLTIMA TRANSACCIÓN */

/* --------------------------------------------------------------------- */

    procedure LimpiarTablaEstadoAnterior;

    procedure GuardarEstadoAnterior (p_codigo aerogeneradores.codigo%TYPE,
                                     p_central centrales.nombre%TYPE,
                                     p_modelo modelos_aerogeneradores.nombre%TYPE);

    procedure GuardarNuevaTransaccion (p_codigo aerogeneradores.codigo%TYPE,
                                       p_central centrales.nombre%TYPE,
                                       p_modelo modelos_aerogeneradores.nombre%TYPE);

    procedure RestaurarCentral(p_central centrales.nombre%TYPE);

    procedure ContarModelosCentral;

    procedure DuplicarTablas;
end PC8;
/

create or replace package body PC8 as

    procedure LimpiarTablaEstadoAnterior
    is
    begin

        TablaEstadoAnterior.delete;
        TablaNuevaTransaccion.delete;
        dbms_output.put_line('ehehe');
    end LimpiarTablaEstadoAnterior;

    procedure GuardarEstadoAnterior (p_codigo aerogeneradores.codigo%TYPE,
                                     p_central centrales.nombre%TYPE,
                                     p_modelo modelos_aerogeneradores.nombre%TYPE)
    is
    begin
        PC8.TablaEstadoAnterior(p_codigo).central := p_central;
        PC8.TablaEstadoAnterior(p_codigo).modelo := p_modelo;
    end GuardarEstadoAnterior;

    procedure GuardarNuevaTransaccion (p_codigo aerogeneradores.codigo%TYPE,
                                       p_central centrales.nombre%TYPE,
                                       p_modelo modelos_aerogeneradores.nombre%TYPE)
    is
    begin
        PC8.TablaNuevaTransaccion(p_central).aeros(p_codigo).modelo := p_modelo;
        if PC8.TablaNuevaTransaccion(p_central).cantmodelos.exists(p_modelo) = False then
            PC8.TablaNuevaTransaccion(p_central).cantmodelos(p_modelo).cantidad := 1;
        else
            PC8.TablaNuevaTransaccion(p_central).cantmodelos(p_modelo).cantidad := PC8.TablaNuevaTransaccion(p_central).cantmodelos(p_modelo).cantidad + 1;
        end if;
    end GuardarNuevaTransaccion;

    procedure RestaurarCentral(p_central centrales.nombre%TYPE)
    is

        v_codigo    aerogeneradores.codigo%TYPE;

        old_central   centrales.nombre%TYPE;
        old_modelo    modelos_aerogeneradores.nombre%TYPE;

        new_central centrales.nombre%TYPE;

    begin
        /* Borra los aerogeneradores de la ultima transaccion */
        v_codigo := DUPTablaNuevaTransaccion(p_central).aeros.first;
        while v_codigo is not null loop
            if DUPTablaEstadoAnterior.exists(v_codigo) then
                old_central := DUPTablaEstadoAnterior(v_codigo).central;
                old_modelo := DUPTablaEstadoAnterior(v_codigo).modelo;
                new_central := p_central;
                dbms_output.put_line('Deshaciendo cambios en: ' || v_codigo);
                update aerogeneradores
                    set nombre_central = old_central, nombre_modelo = old_modelo
                    where codigo = v_codigo;
            else
                dbms_output.put_line('Se borra el aerogenerador: ' || v_codigo);
                delete from aerogeneradores
                    where codigo = v_codigo;
            end if;
            v_codigo := DUPTablaNuevaTransaccion(p_central).aeros.next(v_codigo);
        end loop;

    end RestaurarCentral;

    procedure ContarModelosCentral
    is
        v_cant_centrales    number;
        v_cant_modelos      number;
        v_umbral_modelos    number := 3;
        /* esta central es el nuevo nombre de central para ese codigo de aerogeneradores */
        v_central           centrales.nombre%TYPE;
    begin
        v_cant_centrales := DUPTablaNuevaTransaccion.count;
        if v_cant_centrales > 0 then
            v_central := DUPTablaNuevaTransaccion.first;
            while v_central is not null loop
                select count(count(nombre_modelo)) into v_cant_modelos
                    from aerogeneradores
                    where nombre_central = v_central
                    group by nombre_modelo;
                if v_cant_modelos > v_umbral_modelos then
                    dbms_output.put_line('Se excedió el número máximo ( ' || v_umbral_modelos ||
                                         ' ) de modelos de aerogeneradores... Se desharán los nuevos cambios');
                    RestaurarCentral(v_central);
                end if;
                v_central := DUPTablaNuevaTransaccion.next(v_central);
            end loop;
        end if;
    end ContarModelosCentral;

    procedure DuplicarTablas
    is
    begin
        DUPTablaEstadoAnterior := TablaEstadoAnterior;
        DUPTablaNuevaTransaccion := TablaNuevaTransaccion;
    end DuplicarTablas;

end PC8;
/

create or replace trigger PrepararControlModelos
before insert or update on aerogeneradores
begin
    PC8.LimpiarTablaEstadoAnterior;
end PrepararControlModelos;
/

create or replace trigger ControlModelosCentral
before insert or update on aerogeneradores
for each row
begin
    case
        when inserting then
            PC8.GuardarNuevaTransaccion(:new.codigo,:new.nombre_central,:new.nombre_modelo);
        when updating then
            PC8.GuardarEstadoAnterior(:old.codigo,:old.nombre_central,:old.nombre_modelo);
            PC8.GuardarNuevaTransaccion(:new.codigo,:new.nombre_central,:new.nombre_modelo);
    end case;
end ControlModelosCentral;
/



create or replace trigger ComprobarTablaModelos
after insert or update on aerogeneradores
begin
    PC8.DuplicarTablas;
    PC8.ContarModelosCentral;

end ComprobarTablaModelos;
/


update aerogeneradores
    set nombre_modelo = 'S88'
    where codigo LIKE 'T41300%';


select codigo, nombre_modelo from aerogeneradores
where nombre_central = 'JEREZ';


update aerogeneradores
    set nombre_modelo = 'P-10'
    where codigo like 'T413000%';

update aerogeneradores
    set nombre_modelo = 'N100'
where codigo like 'T413001%';

update aerogeneradores
    set nombre_modelo = 'N90'
    where codigo = 'T4130018';

update aerogeneradores
    set nombre_central = 'JEREZ'
    where nombre_central = 'LA DEHESICA';

select count(count(nombre_modelo))
    from aerogeneradores
    where nombre_central = 'JEREZ'
    group by nombre_modelo;

update aerogeneradores
    set nombre_modelo = 'S88'
    where codigo LIKE 'T41300%';

insert into aerogeneradores values ('T4130040', 'JEREZ', 'N90');

insert into aerogeneradores
select replace(codigo, 'T4', 'T8'), 'JEREZ', nombre_modelo
from aerogeneradores
where nombre_central = 'LA DEHESICA';
*/
