create or replace package PC1 as

    procedure ExisteAerogenerador(p_codigo_aero aerogeneradores.codigo%TYPE);

    function ConvertirFecha(p_fecha varchar2)
        return varchar2;

    function AerogeneradorDesconectado(
                                        p_codigo_aero aerogeneradores.codigo%TYPE,
                                        p_fecha varchar2
                                      )
        return number;

    /* Función principal */
    function ProduccionEnergia(
                                p_codigo_aero aerogeneradores.codigo%TYPE,
                                p_fecha varchar2 default null
                              )
        return number;

end PC1;
/

create or replace package body PC1 as

    procedure ExisteAerogenerador(p_codigo_aero aerogeneradores.codigo%TYPE)
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

    function ConvertirFecha(p_fecha varchar2)
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

    function AerogeneradorDesconectado(
                                        p_codigo_aero aerogeneradores.codigo%TYPE,
                                        p_fecha varchar2
                                      )
        return number
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

        return v_desc;

    end AerogeneradorDesconectado;

    function CalcularProduccion(
                                p_codigo_aero aerogeneradores.codigo%TYPE,
                                p_fecha varchar2
                               )
        return number
    is
        v_produccion_dia number;
    begin
        select nvl(sum(p.produccion / 100 * m.prod_max_horaria),0)
        into v_produccion_dia
        from aerogeneradores a, producciones_aerogeneradores p, modelos_aerogeneradores m
        where a.codigo = p_codigo_aero
        and a.nombre_modelo = m.nombre
        and to_char(p.fechahora, 'YYYYMMDD') = p_fecha;

        return v_produccion_dia;
    end CalcularProduccion;

    function ProduccionEnergia(
                                p_codigo_aero aerogeneradores.codigo%TYPE,
                                p_fecha varchar2
                              )
        return number
    is
        v_produccion_dia    number;
        v_desconectado      number;
        v_fecha             varchar2(8);
    begin
        if p_fecha is null then
            raise_application_error(-20002, 'Debes introducir el parámetro fecha');
        end if;
        /* Comprueba que existe ese código, si no, detiene la ejecución */
        ExisteAerogenerador(p_codigo_aero);

        /* Comprueba la fecha y en caso positivo, convierte la fecha a YYYYMMDD */
        v_fecha := ConvertirFecha(p_fecha);

        /* Comprueba que el aerogenerador ese día no estaba desconectado */
        v_desconectado := AerogeneradorDesconectado(p_codigo_aero, v_fecha);
        /* Si lo estaba, detiene la ejecución */
        if v_desconectado > 0 then
            raise_application_error(-20003, 'Aerogenerador desconectado ese día');
        end if;

        /* Calcula la producción */
        v_produccion_dia := CalcularProduccion(p_codigo_aero, v_fecha);
        /* Devuelve la producción */
        return v_produccion_dia;

    end ProduccionEnergia;

end PC1;
/
