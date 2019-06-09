--Consultas para la base de datos

--Reportar las propiedades con valor castral superior a 10 millones de pesos
--cuyos dueños son inmoviliarias
SELECT *
    FROM (SELECT * 
            FROM propiedad
            WHERE valor_castral > 10)
        NATURAL JOIN
        (SELECT id_propiedad
            FROM inmobiliaria NATURAL JOIN ser_duenio);
--===========================================================================


--Encontrar el (varios si hay empate) asesor con más ventas en el último año
SELECT *
    FROM (SELECT rfc 
            FROM (SELECT rfc, rfcC, MAX(rfcC) rfcCM
                    FROM (SELECT rfc, COUNT(rfc) rfcC
                            FROM vender
                            GROUP BY rfc)
                    GROUP bY  rfc, rfcC)
            WHERE rfcC = rfcCM) NATURAL JOIN asesor;
--===========================================================================


--Obtener los datos de los dueños particulares de propiedades cuyas 
--adquisiciones ocurrieron en los últimos 6 meses (y actualmente son dueños)
SELECT *
    FROM (SELECT DISTINCT id_duenio
            FROM ser_duenio
            WHERE (CURRENT_DATE - fecha_inicio) < 30 AND fecha_fin IS NULL
         ) NATURAL JOIN persona;
--===========================================================================


--Obtener los datos de los terrenos más caros registrados 
--(que tienen el mayor valor castral entre los terrenos).
SELECT *
    FROM (SELECT id_propiedad
            FROM ((SELECT AVG(valor_castral) prom
                     FROM ( (SELECT id_propiedad 
                             FROM terreno)
                          NATURAL JOIN propiedad)) 
                    CROSS JOIN (SELECT id_propiedad, valor_castral
                                 FROM ( (SELECT id_propiedad 
                                         FROM terreno)
                                      NATURAL JOIN propiedad)))
            WHERE valor_castral > prom) NATURAL JOIN terreno NATURAL JOIN propiedad;
--===========================================================================


--Promedio de valor castral (en Millones de Pesos) de las propiedades que son 
--departamentos dentro del estado "CMX" en los que su edificio cuenta con una alberca.
SELECT AVG(valor_castral) promedio
    FROM propiedad
         NATURAL JOIN
        (SELECT id_propiedad
            FROM ((SELECT cp
                    FROM ((SELECT nombre as nombre_estado FROM estado) 
                         NATURAL JOIN (SELECT nombre as nombre_municipio, nombre_estado FROM municipio) 
                         NATURAL JOIN colonia)
                    WHERE nombre_estado = 'CMX')        
                  NATURAL JOIN departamento)
                  NATURAL JOIN
                  (SELECT id_edificio
                     FROM edificio
                     WHERE piscina = 1));
--===========================================================================


--Reportar los valores castrales promedio (en Millones de pesos) de todos los 
--departamentos, casas y Terrenos (3 promedios, uno por cada tipo)
SELECT *
    FROM(
        (SELECT AVG(valor_castral) promedio_departamentos
            FROM(departamento NATURAL JOIN propiedad))
        CROSS JOIN 
        (SELECT AVG(valor_castral) promedio_casas
            FROM(casa NATURAL JOIN propiedad))
        CROSS JOIN 
        (SELECT AVG(valor_castral) promedio_terreno
            FROM(terreno NATURAL JOIN propiedad))
    );
--===========================================================================


--Obtener el total de las ventas realizadas en los últimos 3 años junto con 
--la parte total que se pagó como comisión a los asesores (en millones de pesos)
SELECT SUM(precio)/1000000 total, SUM(hola)/1000000 comisiones
    FROM (SELECT precio, precio*porcentaje_comision/100 as hola 
            FROM vender);
--===========================================================================


--Buscar la información de las propiedades que son o casas o departamentos 
--(inmuebles) que tienen internet y al menos 2 baños con su costo por m^2 en vez
--del valor castral en pesos normales (supone que tamaño/valor = costo por m^2).
SELECT id_propiedad, calle, num_exterior, cp, tamanio, fecha_construccion, 
        estado_propiedad,(valor_castral*1000000)/tamanio costo_por_metro
        FROM (SELECT id_propiedad
                FROM inmueble NATURAL JOIN servicio
                WHERE tipo_servicio = 'internet' AND num_banios >= 2)
            NATURAL JOIN propiedad;
--===========================================================================


--Obtener los datos del los dueños-propiedad con mayor antiguedad (que siguen
--siendo los dueños) y el total anual que paga por sus servicios
SELECT *
    FROM ((SELECT id_propiedad, id_duenio
            FROM ((SELECT MIN(fecha_inicio) hola
                    FROM ser_duenio) CROSS JOIN ser_duenio)
            WHERE hola = fecha_inicio AND fecha_fin IS NULL)
        NATURAL JOIN propiedad NATURAL JOIN duenio
        NATURAL JOIN 
        (SELECT id_propiedad, SUM(monto_anual) anualidad_servicios
            FROM ((SELECT id_propiedad, id_duenio
                    FROM ((SELECT MIN(fecha_inicio) hola
                            FROM ser_duenio) CROSS JOIN ser_duenio)
                    WHERE hola = fecha_inicio AND fecha_fin IS NULL)
                    NATURAL JOIN servicio)
            GROUP BY id_propiedad)
        );
--===========================================================================


--Mostrar el total de las ganancias de cada asesor registrado por medio de ventas
--junto con el número de ventas que representa y sus datos.
SELECT *
    FROM asesor 
        NATURAL JOIN
        (SELECT rfc, COUNT(rfc) ventas_realizadas, SUM(precio*porcentaje_comision/100) ganancia_asesor
            FROM vender
            GROUP BY rfc);
--===========================================================================


--Recuperar todos los datos de los departamentos que tienen al menos una
--amenidad ordenados por su valor castral.
SELECT *
    FROM (SELECT id_edificio
            FROM edificio
                UNPIVOT (numero
                        FOR amenidad
                        IN (roof_garden, elevador, salon_eventos, gimnasio, piscina)
                )
            GROUP BY id_edificio
            HAVING SUM(numero) >= 1)
            NATURAL JOIN departamento NATURAL JOIN propiedad
    ORDER BY valor_castral;
--===========================================================================


--Mostrar el promedio de los valores castrales de las propiedades por estado
SELECT estado, AVG(valor_castral) promedio_valor_castral
    FROM propiedad
        NATURAL JOIN 
        (SELECT cp, estado
            FROM colonia
                NATURAL JOIN
                (SELECT nombre nombre_municipio, nombre_estado estado FROM municipio)
        )
    GROUP BY estado;

--===========================================================================


--Buscar la propiedad que ha tenido más dueños registrada y reportar los
--datos de cada dueño que ha tenido.
--===========================================================================
SELECT 
    FROM
    WHERE num_propietarios = 
    SELECT MAX(num_propietarios)
    FROM (
        SELECT id_propiedad, COUNT(curp) num_propietarios
        FROM ((persona NATURAL JOIN propietario) NATURAL JOIN (duenio NATURAL JOIN ser_duenio))
        GROUP BY id_propiedad;
    )



--Buscar la inmoviliaria que es dueña de la mayor cantidad de propiedades 
--===========================================================================
SELECT id_inmobiliaria, num_propiedades
    FROM inmobiliaria 
        NATURAL JOIN
    (
        SELECT id_duenio, COUNT(id_propiedad) num_propiedades
            FROM ser_duenio
        GROUP BY id_duenio
    )
    WHERE num_propiedades = 
    (
    SELECT MAX(num_propiedades)
    FROM inmobiliaria 
        NATURAL JOIN
    (
        SELECT id_duenio, COUNT(id_propiedad) num_propiedades
            FROM ser_duenio
        GROUP BY id_duenio
    )
    );

--Dar el total de costos de las 'inversiones' que ha hecho la inmoviliaria 1
--en las propiedades de las que es dueña
--===========================================================================
SELECT id_inmobiliaria, SUM(monto_invertido) total_inversion
    FROM inmobiliaria NATURAL JOIN duenio
    GROUP BY id_inmobiliaria;