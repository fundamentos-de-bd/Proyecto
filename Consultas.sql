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


--Obtener los datos del dueño-propiedad con mayor antiguedad (que sigue siendolo)
--y el total anual que paga por sus servicios
SELECT *
    FROM (SELECT id_propiedad, id_duenio
            FROM ((SELECT MIN(fecha_inicio) hola
                    FROM ser_duenio) CROSS JOIN ser_duenio)
            WHERE hola = fecha_inicio AND fecha_fin IS NULL)
         NATURAL JOIN propiedad NATURAL JOIN dueño;
--===========================================================================


--Mostrar el total de las ganancias de cada asesor registrado por medio de ventas
SELECT SUM()
    FROM vender
--===========================================================================


--Buscar la propiedad más barata en el estado X que cuente con al menos una
--amenidad y tenga un aeropuerto cercano
--===========================================================================


--Mostrar el promedio de los valores castrales de las propiedades por estado
--===========================================================================


--Buscar la propeidad que ha tenido más dueños registrada y reportar los
--datos de cada dueño que ha tenido.
--===========================================================================


--Buscar la inmoviliaria que es dueña de la mayor cantidad de propiedades 
--===========================================================================


--Dar el total de costos de las 'inversiones' que ha hecho la inmoviliaria X
--en las propiedades de las que es dueña
--===========================================================================
