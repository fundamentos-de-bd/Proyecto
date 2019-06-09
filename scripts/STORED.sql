/*
Una función que permite obtener el historial de precios de una propiedad dada a
partir de una fecha dada.
Esta información se puede usar después para presentarse de manera gráfica.
*/

-- Tipo para las tuplas que se regresas.
CREATE OR REPLACE TYPE precio_hist IS OBJECT (
    fecha DATE,
    precio NUMBER(10)
);

-- Tipo para la tabla que se regresa
CREATE OR REPLACE TYPE table_hist_precio IS TABLE OF precio_hist;

-- Función
CREATE OR REPLACE FUNCTION hist_precios (id_propiedad NUMBER, fecha DATE) RETURN table_hist_precio IS
    r table_hist_precio;
BEGIN
    SELECT CAST (
        MULTISET (
            SELECT fecha, precio 
                FROM venta_historial
                WHERE venta_historial.id_propiedad = id_propiedad
                    AND venta_historial.fecha >= fecha
        ) AS table_hist_precio 
    ) INTO r
    FROM dual;
    RETURN r;
END hist_precios;

/*
Procedimiento que permite obtener un informe mensual de ventas de una inmobiliaria
dada
Esto es:
    * La cantidad de propiedades adquiridas
    * La cantidad de dinero invertido en ellas
    * La cantidad de propiedades vendidas
    * La cantidad de dinero ganado
    * La ganancia neta
*/
CREATE OR REPLACE PROCEDURE reporte_mensual(id_inmobiliaria NUMBER) IS
    CURSOR adquisiciones IS 
        SELECT * 
            FROM ser_duenio 
            WHERE ser_duenio.id_duenio IN 
                (SELECT id_duenio 
                    FROM inmobiliaria 
                    WHERE inmobiliaria.id_inmobiliaria = id_inmobiliaria)
                AND EXTRACT(YEAR FROM ser_duenio.fecha_inicio) = EXTRACT(YEAR FROM CURRENT_DATE)
                AND EXTRACT(MONTH FROM ser_duenio.fecha_inicio) = EXTRACT(MONTH FROM CURRENT_DATE);
    CURSOR ventas IS 
        SELECT * 
            FROM ser_duenio 
            WHERE ser_duenio.id_duenio IN 
                (SELECT id_duenio 
                    FROM inmobiliaria 
                    WHERE inmobiliaria.id_inmobiliaria = id_inmobiliaria)
                AND EXTRACT(YEAR FROM ser_duenio.fecha_fin) = EXTRACT(YEAR FROM CURRENT_DATE)
                AND EXTRACT(MONTH FROM ser_duenio.fecha_fin) = EXTRACT(MONTH FROM CURRENT_DATE);
    inversion NUMBER(10) := 0;
    ganancia NUMBER(10) := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE ('PROPIEDADES ADQUIRIDAS');
    FOR p IN adquisiciones LOOP
        DBMS_OUTPUT.PUT_LINE (TO_CHAR(p.id_propiedad) || ' | ' || TO_CHAR(p.fecha_inicio, 'yyyy/mm/dd') || ' | ' || TO_CHAR(p.monto_compra));
        inversion := inversion + p.monto_compra;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE ('TOTAL DE PROPIEDADES ADQUIRIDAS: ' || TO_CHAR(adquisiciones%ROWCOUNT));
    DBMS_OUTPUT.PUT_LINE ('DINERO INVERTIDO TOTAL: ' || TO_CHAR(inversion));
    
    DBMS_OUTPUT.PUT_LINE ('PROPIEDADES VENDIDAS');
    FOR p IN ventas LOOP
        DBMS_OUTPUT.PUT_LINE (TO_CHAR(p.id_propiedad) || ' | ' || TO_CHAR(p.fecha_inicio, 'yyyy/mm/dd') || ' | ' || TO_CHAR(p.monto_compra));
        ganancia := ganancia + p.monto_compra;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE ('TOTAL DE PROPIEDADES VENDIDAS: ' || TO_CHAR(ventas%ROWCOUNT));
    DBMS_OUTPUT.PUT_LINE ('DINERO INVERTIDO TOTAL: ' || TO_CHAR(ganancia));
    DBMS_OUTPUT.PUT_LINE ('GANANCIA NETA: ' || TO_CHAR(ganancia - inversion));
END reporte_mensual;

/*
Disparador que revisa que una propiedad no tenga múltiples dueños al mismo tiempo
*/
CREATE OR REPLACE TRIGGER ch_unique_owner_time 
    BEFORE INSERT OR UPDATE ON ser_duenio
    FOR EACH ROW
DECLARE 
    CURSOR otros_duenios IS
        SELECT * 
            FROM ser_duenio 
            WHERE ser_duenio.id_propiedad = :NEW.id_propiedad
                AND (
                    (ser_duenio.fecha_fin IS NULL AND :NEW.fecha_fin IS NULL)
                    OR
                    (ser_duenio.fecha_fin IS NULL AND :NEW.fecha_fin >= ser_duenio.fecha_inicio)
                    OR
                    (ser_duenio.fecha_fin >= :NEW.fecha_inicio AND :NEW.fecha_fin IS NULL)
                    OR 
                    (ser_duenio.fecha_inicio BETWEEN :NEW.fecha_inicio AND :NEW.fecha_fin)
                    OR
                    (ser_duenio.fecha_fin BETWEEN :NEW.fecha_inicio AND :NEW.fecha_fin)
                    OR 
                    (:NEW.fecha_inicio BETWEEN ser_duenio.fecha_inicio AND ser_duenio.fecha_fin)
                    OR
                    (:NEW.fecha_fin BETWEEN ser_duenio.fecha_inicio AND ser_duenio.fecha_fin)
                );
BEGIN
    FOR v in otros_duenios LOOP
        RAISE_APPLICATION_ERROR(-20000, 'NO PUEDE HABER DUEÑOS SIMLTÁNEOS DE UNA PROPIEDAD');
    END LOOP;
END;

/*
Disparador para verificar que todos los departamentos en el mismo edificio tengan
la misma dirección
*/
CREATE OR REPLACE TRIGGER ch_same_building_apartment
    BEFORE INSERT OR UPDATE ON departamento
    FOR EACH ROW
DECLARE 
    propiedad_asoc PROPIEDAD%ROWTYPE;
    CURSOR direcciones IS
        SELECT * 
        FROM (
            SELECT id_propiedad
                FROM departamento
                WHERE departamento.id_edificio = :NEW.id_edificio
        ) NATURAL JOIN propiedad;
BEGIN
    SELECT * INTO propiedad_asoc
        FROM propiedad 
        WHERE propiedad.id_propiedad = :NEW.id_propiedad;
    FOR d IN direcciones LOOP
        IF NOT(d.cp = propiedad_asoc.cp) OR NOT(d.calle = propiedad_asoc.calle) OR NOT(d.num_exterior = propiedad_asoc.num_exterior) THEN
            RAISE_APPLICATION_ERROR(-20001, 'NO SE PUEDEN TENER DEPARTAMENTOS EN MISMO EDIFICIOS CON DIFERENTE DIRECCIONES');
        END IF;
    END LOOP;
END;

/*
Disparador que revisa que todos los dueños que son inmobiliarias no hayan sido
insertados antes como propietarios (personas)
*/
CREATE OR REPLACE TRIGGER ch_duenio_inmobiliaria
    BEFORE INSERT OR UPDATE ON inmobiliaria
    FOR EACH ROW
DECLARE
    CURSOR prop_viol IS
        SELECT id_duenio
            FROM propietario
            WHERE propietario.id_duenio = :NEW.id_duenio;
BEGIN
    FOR p IN prop_viol LOOP
        RAISE_APPLICATION_ERROR(-20002, 'UN PROPIETARIO NO PUEDE SER INMOBILIARIA');
    END LOOP;
END;

/*
Disparador que revisa que todos los dueños que son propietarios (personas) no 
hayan sido insertados antes como inmobiliarias.
*/
CREATE OR REPLACE TRIGGER ch_duenio_propietario
    BEFORE INSERT OR UPDATE ON propietario
    FOR EACH ROW
DECLARE
    CURSOR prop_viol IS
        SELECT id_duenio
            FROM inmobiliaria
            WHERE inmobiliaria.id_duenio = :NEW.id_duenio;
BEGIN
    FOR p IN prop_viol LOOP
        RAISE_APPLICATION_ERROR(-20003, 'UNA INMOBILIARIA NO PUEDE SER PROPIETARIO');
    END LOOP;
END;