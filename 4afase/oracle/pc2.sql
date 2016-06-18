create or replace package PCentrales2 as

    TYPE TipoParametrosPC2 IS RECORD
    (
        aerocodigo  aerogeneradores.codigo%TYPE,
        central     centrales.nombre%TYPE,
        empresa     empresas.nombre%TYPE,
        municipio   municipios.nombre%TYPE,
        provincia   provincias.nombre%TYPE,
        fecha       varchar2(8)
    );
    PC2 TipoParametrosPC2;

    TYPE TipoAerogenerador IS RECORD
    (
        codigo aerogeneradores.codigo%TYPE,
        marca modelos_aerogeneradores.marca%TYPE,
        modelo modelos_aerogeneradores.nombre%TYPE,
        produccion_max modelos_aerogeneradores.prod_max_horaria%TYPE
    );
    registroAerogenerador TipoAerogenerador;

    TYPE TipoRegDesconexiones IS RECORD
    (
        inicio     varchar2(16),
        fin        varchar2(16)
    );
    TYPE TipoTablaRegDesconexiones IS TABLE OF TipoRegDesconexiones
        INDEX BY BINARY_INTEGER;
    TablaListaDesconexiones TipoTablaRegDesconexiones;

    TYPE TipoRegProducciones IS RECORD
    (
        hora    varchar2(6),
        pprod   number,
        aprod   number
    );
    TYPE TipoTablaProducciones IS TABLE OF TipoRegProducciones
        INDEX by BINARY_INTEGER;
    TablaListaProducciones TipoTablaProducciones;

    TYPE TipoRegCentral IS RECORD
    (
        nombre      centrales.nombre%TYPE,
        municipio   municipios.nombre%TYPE,
        provincia   provincias.nombre%TYPE,
        velocidad   predicciones_viento.velocidad%TYPE,
        energia     number
    );
    TYPE TipoTablaRegCentrales is table of TipoRegCentral
        index by varchar2(10);
    TablaListaCentral TipoTablaRegCentrales;

    TYPE TipoRegEnergiaAero IS RECORD
    (
        codigo      aerogeneradores.codigo%type,
        produce     number,
        energia     number
    );
    Type TipoTablaCentralAeros is table of TipoRegEnergiaAero
        index by BINARY_INTEGER;

    TYPE TipoRegEnergiaCentral IS RECORD
    (
        central     centrales.nombre%type,
        aeros       TipoTablaCentralAeros,
        generadodia number
    );
    Type TipoTablaEnergiaAeros is table of TipoRegEnergiaCentral
        index by BINARY_INTEGER;

    TablaEnergiaCentral TipoTablaEnergiaAeros;

    procedure GenerarInforme(
                                p_tipo_informe varchar2,
                                p_fecha varchar2,
                                p_parametro varchar2
                            );
end PCentrales2;
/

create or replace package body PCentrales2 as

    procedure MostrarDia
    is
    begin
        dbms_output.put_line('Día: ' || to_char(to_date(PC2.fecha,'YYYYMMDD'),'DD/MM/YYYY'));
    end MostrarDia;

    procedure CrearCabeceraAerogenerador
    is
    begin
        select a.codigo, m.marca, m.nombre, m.prod_max_horaria
        into registroAerogenerador
        from aerogeneradores a, modelos_aerogeneradores m
        where a.nombre_modelo = m.nombre
        and a.codigo = PC2.aerocodigo;
    end CrearCabeceraAerogenerador;

    procedure MostrarCabeceraAerogenerador
    is
    begin
        PC1.ExisteAerogenerador(PC2.aerocodigo);
        CrearCabeceraAerogenerador();
        dbms_output.put_line(
                                'Aerogenerador ' || registroAerogenerador.codigo || ' '
                                || registroAerogenerador.marca || ' '
                                || registroAerogenerador.modelo
                            );
        dbms_output.put_line('===================================================================');
        dbms_output.put_line(' ');

    end MostrarCabeceraAerogenerador;

    procedure RellenarTablaDesconexiones
    is
        cursor c_desconexiones is
            select  fechahora_inicio as inicio,
                    fechahora_fin as fin
            from desconexiones
            where to_char(fechahora_inicio, 'YYYYMMDD') = PC2.fecha
            AND to_char(fechahora_fin, 'YYYYMMDD') = PC2.fecha
            AND cod_aerogenerador = PC2.aerocodigo
            order by fechahora_inicio asc;

        indice BINARY_INTEGER := 0;
        formato_fecha varchar2(20) := 'DD-MM-YYYY HH24:MI';

    begin
        TablaListaDesconexiones.delete;
        for v_desconexiones in c_desconexiones loop
            TablaListaDesconexiones(indice).inicio := to_char(v_desconexiones.inicio, formato_fecha);
            TablaListaDesconexiones(indice).fin := to_char(v_desconexiones.fin, formato_fecha);
            indice := indice + 1;
        end loop;
    end RellenarTablaDesconexiones;

    procedure MostrarTablaDesconexiones
    is
        indice BINARY_INTEGER := TablaListaDesconexiones.first;
    begin
        dbms_output.put_line(chr(10) || 'Lista de Desconexiones');
        dbms_output.put_line('======================');
        while indice is not null loop
            dbms_output.put_line(
                                    to_char(indice) || ': ' ||
                                    TablaListaDesconexiones(indice).inicio || ' - ' ||
                                    TablaListaDesconexiones(indice).fin
                                );
            indice := TablaListaDesconexiones.next(indice);
        end loop;
    end MostrarTablaDesconexiones;

    procedure MostrarDesconexiones
    is
    begin
        RellenarTablaDesconexiones();
        if TablaListaDesconexiones.count > 0 then
            MostrarTablaDesconexiones();
        else
            dbms_output.put_line('No hubo desconexiones ese día');
        end if;
    end MostrarDesconexiones;

    procedure RellenarTablaProducciones
    is
        cursor c_producciones is
            select a.codigo as codigo,
            m.prod_max_horaria,
            to_char(p.fechahora, 'HH24:MI') as hora,
            p.produccion
            from aerogeneradores a, modelos_aerogeneradores m, producciones_aerogeneradores p
            where a.nombre_modelo = m.nombre
            and a.codigo = p.cod_aerogenerador
            and to_char(p.fechahora, 'YYYYMMDD') = PC2.fecha
            and p.cod_aerogenerador = PC2.aerocodigo
            order by p.fechahora asc;

        indice BINARY_INTEGER := 0;
    begin
        TablaListaProducciones.delete;
        for v_producciones in c_producciones LOOP
            TablaListaProducciones(indice).hora := v_producciones.hora;
            TablaListaProducciones(indice).pprod := v_producciones.produccion;
            TablaListaProducciones(indice).aprod := v_producciones.produccion / 100 * v_producciones.prod_max_horaria;
            indice := indice + 1;
        end LOOP;
    end RellenarTablaProducciones;

    procedure MostrarTablaProducciones
    is
        indice BINARY_INTEGER := TablaListaProducciones.FIRST;
        v_suma number := 0;
    begin
        dbms_output.put_line(chr(10) || 'Lista de producciones');
        dbms_output.put_line('=====================');
        while indice is not null loop
            dbms_output.put_line(
                                    TablaListaProducciones(indice).hora || ': ' ||
                                    to_char(TablaListaProducciones(indice).aprod)
                                );
            v_suma := v_suma + TablaListaProducciones(indice).aprod;
            indice := TablaListaProducciones.next(indice);
        end loop;
        dbms_output.put_line(chr(10) || 'Energía total: ' || v_suma);
    end MostrarTablaProducciones;


    procedure ComprobarCentral
    is
    begin
        PC2.empresa := null;
        PC2.municipio := null;
        PC2.provincia := null;

        select e.nombre, m.nombre, p.nombre
            into PC2.empresa, PC2.municipio, PC2.provincia
            from empresas e, centrales c, municipios m, provincias p
            where c.nombre = PC2.central
            and c.cif_empresa = e.cif
            and c.cod_municipio = m.codigo
            and m.cod_provincia = p.codigo;

        if PC2.empresa is null then
            raise_application_error(-20006, 'Central inexistente');
        end if;
    end ComprobarCentral;

    procedure RellenarTablaCentral
    is
        cursor c_energiacentral is
            select c.nombre as cnombre,
                    m.nombre as mnombre,
                    prov.nombre as pnombre,
                    to_char(p.fechahora, 'HH24:MI') as hora,
                    pred.velocidad as velocidad,
                    mo.prod_max_horaria / 100 * p.produccion as energia,
                    mo.nombre as modelo,
                    a.codigo as codigo
            from    centrales c, municipios m, provincias prov, aerogeneradores a,
                    predicciones_viento pred, modelos_aerogeneradores mo,
                    producciones_aerogeneradores p
            where c.nombre = PC2.central
            and c.cod_municipio = m.codigo
            and m.cod_provincia = prov.codigo
            and c.nombre = a.nombre_central
            and to_char(pred.fechahora, 'YYYYMMDD') = PC2.fecha
            and to_char(p.fechahora, 'YYYYMMDD') = PC2.fecha
            and p.fechahora = pred.fechahora
            and pred.nombre_central = a.nombre_central
            and a.nombre_modelo = mo.nombre
            and a.codigo = p.cod_aerogenerador
            order by p.fechahora asc;
    begin
        TablaListaCentral.delete;
        for v_energiacentral in c_energiacentral loop
            TablaListaCentral(v_energiacentral.hora).nombre    := v_energiacentral.cnombre;
            TablaListaCentral(v_energiacentral.hora).municipio := v_energiacentral.mnombre;
            TablaListaCentral(v_energiacentral.hora).provincia := v_energiacentral.pnombre;
            TablaListaCentral(v_energiacentral.hora).velocidad := v_energiacentral.velocidad;
            TablaListaCentral(v_energiacentral.hora).energia   := nvl(TablaListaCentral(v_energiacentral.hora).energia,0) + v_energiacentral.energia;
        end loop;
    end RellenarTablaCentral;

    procedure CalcularEnergiaTotalDia(p_energia IN OUT number)
    is
        indice varchar2(10) := TablaListaCentral.first;
    begin
        while indice is not null loop
            p_energia := p_energia + TablaListaCentral(indice).energia;
            indice := TablaListaCentral.next(indice);
        end loop;
    end CalcularEnergiaTotalDia;

    Procedure MostrarCabeceraCentral
    is
        v_energia_total_dia number := 0;
    begin
        dbms_output.put_line(chr(10) || 'Central: ' || PC2.central);
        dbms_output.put_line(PC2.municipio || ' (' || PC2.provincia || ')');
        MostrarDia();
        CalcularEnergiaTotalDia(v_energia_total_dia);
        dbms_output.put_line('Energía total día: ' || v_energia_total_dia);
    end MostrarCabeceraCentral;

    procedure MostrarTablaCentral
    is
        indice varchar2(10) := TablaListaCentral.first;
    begin
        if TablaListaCentral.count > 0 then
            dbms_output.put_line(chr(10) || 'Detalle de producciones');
            dbms_output.put_line('========================');
            while indice is not null loop
                dbms_output.put_line(
                                        indice || ': ' ||
                                        TablaListaCentral(indice).velocidad || 'km/h - ' ||
                                        TablaListaCentral(indice).energia
                                    );
                indice := TablaListaCentral.next(indice);
            end loop;
        else
            dbms_output.put_line('No hubo producciones este día.');
        end if;
    end MostrarTablaCentral;

    procedure ComprobarEmpresa
    is
        v_cant number := 0;
    begin
        select nvl(count(*),0) into v_cant
        from empresas
        where nombre = PC2.empresa;

        if v_cant = 0 then
            raise_application_error(-20007, 'No existe la empresa ' || PC2.empresa);
        end if;

    end ComprobarEmpresa;

    procedure RellenarTablaEnergiaCentral
    is
        cursor c_empresas is
            select e.nombre as empresa,
            c.nombre as central
            from empresas e, centrales c
            where e.cif = c.cif_empresa
            and e.nombre = PC2.empresa;

        cursor c_aeros is
            select a.codigo as codigo,
                nvl(sum(p.produccion / 100 * mo.prod_max_horaria),0) as energiadia
                from aerogeneradores a, producciones_aerogeneradores p, modelos_aerogeneradores mo
                where a.codigo = p.cod_aerogenerador
                and a.nombre_modelo = mo.nombre
                and a.nombre_central = PC2.central
                and to_char(p.fechahora,'YYYYMMDD') = PC2.fecha
                group by a.codigo
                order by a.codigo;

        i BINARY_INTEGER := 0;
        j BINARY_INTEGER := 0;
    begin
        TablaEnergiaCentral.delete;
        for v_central in c_empresas loop
            PC2.central := v_central.central;
            TablaEnergiaCentral(i).central := PC2.central;
            TablaEnergiaCentral(i).generadodia := 0;
            j := 0;
            for v_aeros in c_aeros loop
                TablaEnergiaCentral(i).aeros(j).codigo := v_aeros.codigo;
                TablaEnergiaCentral(i).aeros(j).energia := v_aeros.energiadia;
                TablaEnergiaCentral(i).generadodia := TablaEnergiaCentral(i).generadodia + v_aeros.energiadia;
                j := j + 1;
            end loop;
            i := i + 1;
        end loop;
    end RellenarTablaEnergiaCentral;

    procedure MostrarTablaEnergiaCentral
    is
        i BINARY_INTEGER := TablaEnergiaCentral.first;
        j BINARY_INTEGER := TablaEnergiaCentral(i).aeros.first;
    begin
        while i is not null loop
            dbms_output.put_line(
                                    chr(10) ||
                                    '>>> Central: ' ||
                                    TablaEnergiaCentral(i).central
                                );
            dbms_output.put_line('=======================================');
            if TablaEnergiaCentral(i).aeros.count > 0 then
                j := TablaEnergiaCentral(i).aeros.first;
                while j is not null loop
                    dbms_output.put_line(
                                            TablaEnergiaCentral(i).aeros(j).codigo || ' - ' ||
                                            TablaEnergiaCentral(i).aeros(j).energia
                                        );
                    j := TablaEnergiaCentral(i).aeros.next(j);
                end loop;
                dbms_output.put_line(
                                        chr(10) ||
                                        '**** Total generado ' ||
                                        TablaEnergiaCentral(i).central || ': ' ||
                                        TablaEnergiaCentral(i).generadodia
                                    );
            else
                dbms_output.put_line('No hay producciones para ese día.');
            end if;
            i := TablaEnergiaCentral.next(i);
        end loop;
    end MostrarTablaEnergiaCentral;

    procedure InformeProduccionAero
    is
        v_desc number;
    begin
        MostrarCabeceraAerogenerador();
        MostrarDia();
        v_desc := PC1.AerogeneradorDesconectado(PC2.aerocodigo, PC2.fecha);
        if v_desc > 0 then
                dbms_output.put_line(chr(10) || 'Aerogenerador desconectado todo el día.');
                dbms_output.put_line(chr(10) || 'Energía producida: 0');
        else
            MostrarDesconexiones();
            RellenarTablaProducciones();
            MostrarTablaProducciones();
        end if;
    end InformeProduccionAero;

    procedure InformeProduccionCentral
    is
    begin
        ComprobarCentral();
        RellenarTablaCentral();
        MostrarCabeceraCentral();
        MostrarTablaCentral();
    end InformeProduccionCentral;

    procedure InformeProduccionEmpresa
    is
    begin
        ComprobarEmpresa();
        dbms_output.put_line(chr(10) || 'Empresa: ' ||  PC2.empresa);
        MostrarDia();
        RellenarTablaEnergiaCentral();
        MostrarTablaEnergiaCentral();
    end InformeProduccionEmpresa;

    procedure GenerarInforme(
                                p_tipo_informe varchar2,
                                p_fecha varchar2,
                                p_parametro varchar2
                            )
    is
    begin
        PC2.fecha := PC1.ConvertirFecha(p_fecha);
        case
            when p_tipo_informe = '1' then
                PC2.aerocodigo := p_parametro;
                InformeProduccionAero();
            when p_tipo_informe = '2' then
                PC2.central := p_parametro;
                InformeProduccionCentral();
            when p_tipo_informe = '3' then
                PC2.empresa := p_parametro;
                InformeProduccionEmpresa();
            else
                raise_application_error(-20005, 'Tipo de informe: ' || to_char(p_tipo_informe) || ' incorrecto');
        end case;
    end GenerarInforme;

end PCentrales2;
/
