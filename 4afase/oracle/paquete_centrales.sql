select * from centrales;
create or replace package PCentrales1 as

    procedure ExisteAerogenerador (p_codigo_aero aerogeneradores.codigo%TYPE);

    function ConvertirFecha (p_fecha varchar2)
        return varchar2;

    procedure AerogeneradorEnProduccion (p_codigo_aero aerogeneradores.codigo%TYPE,
                                         p_fecha varchar2);

    procedure AerogeneradorDesconectado (p_codigo_aero aerogeneradores.codigo%TYPE,
                                         p_fecha varchar2);

    /* Función principal */
    function ProduccionEnergia (p_codigo_aero aerogeneradores.codigo%TYPE,
                                p_fecha varchar2)
        return number;

end PCentrales1;
/

create or replace package body PCentrales1 as

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

    /* TODO: Comprobar también si la fecha es inferior a la de comienzo de producción */
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
            to_char(p.fechahora,'YYYYMMDD') >= p_fecha
            or
            to_char(d.fechahora_inicio, 'YYYYMMDD') >= p_fecha
            )
        and p.cod_aerogenerador = p_codigo_aero;

        if v_num_cons_desc = 0 then
            raise_application_error(-20003, 'Fecha superior a la última en producción');
        end if;

    end AerogeneradorEnProduccion;

    procedure AerogeneradorDesconectado (p_codigo_aero aerogeneradores.codigo%TYPE,
                                         p_fecha varchar2)
    is
        v_desc          number;
        v_fecha_desc    number;
    begin
        v_fecha_desc := to_number(p_fecha || '0000');

        select nvl(count(cod_aerogenerador), 0) into v_desc
        from desconexiones
        where cod_aerogenerador = p_codigo_aero
        and to_number(to_char(fechahora_inicio,'YYYYMMDDHH24MI')) <= v_fecha_desc
        and to_number(to_char(fechahora_fin,'YYYYMMDD')) > to_number(p_fecha);

        if v_desc > 0 then
            raise_application_error(-20004, 'Aerogenerador desconectado ese día');
        end if;

    end AerogeneradorDesconectado;

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

        AerogeneradorDesconectado(p_codigo_aero, v_fecha);

        select nvl(sum(p.produccion / 100 * m.prod_max_horaria),0)
        into v_produccion_dia
        from aerogeneradores a, producciones_aerogeneradores p, modelos_aerogeneradores m
        where a.codigo = p_codigo_aero
        and a.nombre_modelo = m.nombre
        and to_char(p.fechahora, 'YYYYMMDD') = v_fecha;

        return v_produccion_dia;

    end ProduccionEnergia;
end PCentrales1;
/

    /* selects de pruebas  Ejercicio 1 */

select PCentrales1.ProduccionEnergia('T6380001','1-1-2015') from dual;

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

    /* Fin selects de pruebas */


create or replace package PCentrales2 as

    TYPE TipoAerogenerador IS RECORD
    (
        codigo aerogeneradores.codigo%TYPE,
        marca modelos_aerogeneradores.marca%TYPE,
        modelo modelos_aerogeneradores.nombre%TYPE,
        produccion_max modelos_aerogeneradores.prod_max_horaria%TYPE
    );

    registroAerogenerador TipoAerogenerador;

    procedure InformeProduccionAero(
                                        p_codigo aerogeneradores.codigo%type,
                                        p_fecha varchar2
                                   );

    procedure InformeProduccionCentral(
                                        p_nombrecentral centrales.nombre%type,
                                        p_fecha varchar2
                                      );

    procedure InformeProduccionEmpresa(
                                        p_nombre_empresa empresas.nombre%type,
                                        p_fecha varchar2
                                      );

    /* Función principal */
    procedure GenerarInforme(
                                p_tipo_informe number,
                                p_fecha varchar2,
                                p_parametro varchar2
                            );
end PCentrales2;
/

create or replace package body PCentrales2 as

    procedure InformeProduccionAero(p_codigo aerogeneradores.codigo%type, p_fecha varchar2)
    is
        v_fecha number;
    begin
        PCentrales1.ExisteAerogenerador(p_codigo);
        PCentrales1.AerogeneradorEnProduccion(p_codigo, p_fecha);
        select a.codigo, m.marca, m.nombre, m.prod_max_horaria
        into registroAerogenerador
        from aerogeneradores a, modelos_aerogeneradores m
        where a.nombre_modelo = m.nombre
        and a.codigo = p_codigo;

    end InformeProduccionAero;

    procedure InformeProduccionCentral (p_nombrecentral centrales.nombre%type, p_fecha varchar2)
    is
    begin
        NULL;
    end InformeProduccionCentral;

    procedure InformeProduccionEmpresa (p_nombre_empresa empresas.nombre%type, p_fecha varchar2)
    is
    begin
        NULL;
    end InformeProduccionEmpresa;

    procedure GenerarInforme (  p_tipo_informe number,
                                p_fecha varchar2,
                                p_parametro varchar2
                             )
    is
        v_fecha varchar2(8);
    begin

        v_fecha := PCentrales1.ConvertirFecha(p_fecha);

        case
            when p_tipo_informe = 1 then
                InformeProduccionAero(p_parametro, v_fecha);
            when p_tipo_informe = 2 then
                InformeProduccionCentral(p_parametro, v_fecha);
            when p_tipo_informe = 3 then
                InformeProduccionEmpresa (p_parametro, v_fecha);
            else
                raise_application_error(-20005, 'Tipo de informe: ' || to_char(p_tipo_informe) || ' incorrecto');
        end case;

    end GenerarInforme;

end PCentrales2;
/

exec PCentrales2.GenerarInforme(5,'wee','weee');

select cod_aerogenerador from desconexiones d
where cod_aerogenerador = 'T6380001'
and to_number(to_char(d.fechahora_inicio,'YYYYMMDDHH24MI'), '9') <= '201501010000'
and to_number(to_char(d.fechahora_salida,'YYYYMMDD'), '9') > '20150101'
