create or replace package PCentrales as

    /****** Funciones y procedimientos Ejercicio 1 ******/
    procedure ExisteAerogenerador (p_codigo_aero aerogeneradores.codigo%TYPE);

    function ConvertirFecha (p_fecha varchar2)
        return varchar2;

    procedure AerogeneradorEnProduccion (p_codigo_aero aerogeneradores.codigo%TYPE,
                                         p_fecha varchar2);

    function ProduccionEnergia (p_codigo_aero aerogeneradores.codigo%TYPE,
                                p_fecha varchar2)
        return number;
            /****** Fin Ejercicio 1 ******/

    /****** Funciones y procedimientos Ejercicio 3 ******/
/*
    function CalcularMaximo(p_cod_aerogenerador aerogeneradores.codigo%TYPE)
        return number;
*/
            /****** Fin Ejercicio 3 ******/
end PCentrales;
/

create or replace package body PCentrales as

    /****** Funciones y procedimientos Ejercicio 1 ******/
    procedure ExisteAerogenerador (p_codigo_aero aerogeneradores.codigo%TYPE)
    is
        v_cantidad number;
    begin
        select nvl(count(*),0) into v_cantidad
        from aerogeneradores
        where codigo = p_codigo_aero;

        if v_cantidad = 0 then
            raise_application_error(-20001, 'No existe aerogenerador con ese código');
        end if;

    end ExisteAerogenerador;

    function ConvertirFecha (p_fecha varchar2)
    return varchar2
    is
        v_fecha varchar2(8);
        v_formato varchar2(10);

    begin
        case
            when regexp_like (p_fecha, '\d{1,2}/\d{1,2}/\d{2}') then
                v_formato := 'DD/MM/YY';
            when regexp_like (p_fecha, '\d{1,2}/\d{1,2}/\d{4}') then
                v_formato := 'DD/MM/YYYY';
            when regexp_like (p_fecha, '\d{1,2}-\d{1,2}-\d{4}') then
                v_formato := 'DD-MM-YYYY';
            when regexp_like (p_fecha, '\d{1,2}-\d{1,2}-\d{2}') then
                v_formato := 'DD-MM-YY';
            else
                raise_application_error (-20002, 'Formato de fecha incorrecto');
        end case;

        v_fecha := to_char(to_date(p_fecha, v_formato), 'YYYYMMDD');

        return v_fecha;
    end;

    procedure AerogeneradorEnProduccion (p_codigo_aero aerogeneradores.codigo%TYPE,
                                         p_fecha varchar2)
    is
        v_num_cons_desc number;
    begin
        select count(p.cod_aerogenerador) into v_num_cons_desc
        from aerogeneradores a, producciones_aerogeneradores p, desconexiones d
        where a.codigo = p.cod_aerogenerador(+)
        and a.codigo = d.cod_aerogenerador(+)
        and (
            to_char(p.fechahora,'YYYYMMDD') > p_fecha
            or
            to_char(d.fechahora_inicio, 'YYYYMMDD') > p_fecha
            )
        and p.cod_aerogenerador = p_codigo_aero;

        if v_num_cons_desc = 0 then
            raise_application_error(-20003, 'Fecha superior a la última en producción');
        end if;

    end AerogeneradorEnProduccion;

    function ProduccionEnergia (p_codigo_aero aerogeneradores.codigo%TYPE,
                                p_fecha varchar2)
        return number
    is
        v_produccion_dia    number;
        v_num_prods         number;
        v_fecha             varchar2(8);
    begin
        ExisteAerogenerador(p_codigo_aero);

        v_fecha := ConvertirFecha(p_fecha);

        AerogeneradorEnProduccion(p_codigo_aero, v_fecha);

        select nvl(sum(p.produccion / 100 * m.prod_max_horaria),0), count(p.produccion)
        into v_produccion_dia, v_num_prods
        from aerogeneradores a, producciones_aerogeneradores p, modelos_aerogeneradores m
        where a.codigo = p_codigo_aero
        and a.nombre_modelo = m.nombre
        and to_char(p.fechahora, 'YYYYMMDD') = v_fecha;

        /* Si v_num_prods == 0 => aerogenerador desconectado ese dia */
        /* v_num_prods == 23 => todo el día conectado*/
        if v_num_prods = 0 then
            raise_application_error(-20004, 'Aerogenerador desconectado ese día');
        end if;

        return v_produccion_dia;

    end ProduccionEnergia;
            /****** Fin Ejercicio 1 ******/

        /****** Funciones y procedimientos Ejercicio 3 ******/
/*
    function CalcularMaximo(p_cod_aerogenerador aerogeneradores.codigo%TYPE)
        return number
    is
    begin
    end CalcularMaximo;
*/
            /****** Fin Ejercicio 3 ******/

end PCentrales;
/

/* mis selects de pruebas */

select PCentrales.ProduccionEnergia('T6380001','1-1-2015') from dual;

select count(p.cod_aerogenerador)
from aerogeneradores a, producciones_aerogeneradores p, desconexiones d
where a.codigo = p.cod_aerogenerador(+)
and a.codigo = d.cod_aerogenerador(+)
and (
    to_char(p.fechahora,'YYYYMMDD') > '20160101'
    or
    to_char(d.fechahora_inicio, 'YYYYMMDD') > '20160101'
)
and p.cod_aerogenerador = 'T6380001';
