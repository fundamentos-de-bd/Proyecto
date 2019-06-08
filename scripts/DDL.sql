-- Tabla para los estados
CREATE TABLE estado (
    nombre VARCHAR(20)
);

ALTER TABLE estado
    ADD CONSTRAINT pk_estado
    PRIMARY KEY (nombre);
    
-- Tabla para los municipios
CREATE TABLE municipio (
    nombre VARCHAR(30),
    nombre_estado VARCHAR(20)
);

ALTER TABLE municipio
    ADD CONSTRAINT fk_municipio_estado
    FOREIGN KEY (nombre_estado)
    REFERENCES estado(nombre)
    ON DELETE CASCADE;
    
ALTER TABLE municipio
    ADD CONSTRAINT pk_municipio
    PRIMARY KEY (nombre, nombre_estado);
    
-- Tabla para las colonias
CREATE TABLE colonia (
    cp NUMBER(10),
    nombre VARCHAR(30) NOT NULL,
    nombre_municipio VARCHAR(30) NOT NULL,
    nombre_estado VARCHAR(20) NOT NULL
);

ALTER TABLE colonia 
    ADD CONSTRAINT fk_colonia_municipio
    FOREIGN KEY (nombre_municipio, nombre_estado)
    REFERENCES municipio(nombre, nombre_estado)
    ON DELETE CASCADE;
    
ALTER TABLE colonia
    ADD CONSTRAINT pk_colonia
    PRIMARY KEY (cp);
    
-- Tabla para los habitantes por colonia
CREATE TABLE habitantes_colonia (
    cp NUMBER(10),
    num_habitantes NUMBER(10)
);

ALTER TABLE habitantes_colonia
    ADD CONSTRAINT fk_habitantes_colonia
    FOREIGN KEY (cp)
    REFERENCES colonia(cp)
    ON DELETE CASCADE;
 
 -- Tabla para los medios de transporte
 CREATE TABLE transporte (
    tipo VARCHAR(20),
    nombre VARCHAR(20),
    cp NUMBER(10)
 );
 
 ALTER TABLE transporte
    ADD CONSTRAINT fk_transporte_colonia
    FOREIGN KEY (cp)
    REFERENCES colonia(cp)
    ON DELETE CASCADE;
    
ALTER TABLE transporte
    ADD CONSTRAINT pk_transporte
    PRIMARY KEY (tipo, nombre, cp);

-- Tabla para las tiendas departamentales
CREATE TABLE tienda_departamental (
    nombre VARCHAR(40),
    descripcion VARCHAR(100),
    cp NUMBER(10)
);

ALTER TABLE tienda_departamental
    ADD CONSTRAINT fk_tienda_dep_colonia
    FOREIGN KEY (cp)
    REFERENCES colonia(cp)
    ON DELETE CASCADE;
    
ALTER TABLE tienda_departamental
    ADD CONSTRAINT pk_tienda_dep
    PRIMARY KEY (nombre, cp);
    
-- Tabla para las propiedades
CREATE TABLE propiedad (
    id_propiedad NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    calle VARCHAR(15),
    num_exterior NUMBER(10),
    cp NUMBER(10),
    tamanio VARCHAR(10),
    fecha_construccion DATE,
    estado_propiedad VARCHAR(50),
    valor_castral VARCHAR(10)
);

ALTER TABLE propiedad 
    ADD CONSTRAINT fk_propiedad_colonia
    FOREIGN KEY (cp)
    REFERENCES colonia(cp)
    ON DELETE SET NULL;
    
ALTER TABLE propiedad
    ADD CONSTRAINT pk_propiedad
    PRIMARY KEY (id_propiedad);
    
-- Tabla para los servicios
CREATE TABLE servicio (
    id_servicio NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    tipo_servicio VARCHAR(20),
    monto_anual NUMBER(10) DEFAULT 0,
    id_propiedad NUMBER(10)
);

ALTER TABLE servicio
    ADD CONSTRAINT fk_servicio_propiedad
    FOREIGN KEY (id_propiedad)
    REFERENCES propiedad(id_propiedad)
    ON DELETE CASCADE;
    
ALTER TABLE servicio
    ADD CONSTRAINT uq_servicio_propiedad
    UNIQUE (tipo_servicio, id_propiedad);
    
ALTER TABLE servicio
    ADD CONSTRAINT pk_servicio
    PRIMARY KEY (id_servicio);
    
-- Tabla para los terrenos
CREATE TABLE terreno (
    id_propiedad NUMBER(10),
    construccion NUMBER(1) DEFAULT 0
);

ALTER TABLE terreno 
    ADD CONSTRAINT ch_terreno_construc
    CHECK (construccion IN (0, 1));
    
ALTER TABLE terreno
    ADD CONSTRAINT fk_terreno_propiedad
    FOREIGN KEY (id_propiedad)
    REFERENCES propiedad(id_propiedad)
    ON DELETE CASCADE;
    
ALTER TABLE terreno
    ADD CONSTRAINT pk_terreno
    PRIMARY KEY (id_propiedad);
    
-- Tabla para los inmuebles
CREATE TABLE inmueble (
    id_propiedad NUMBER(10),
    num_banios NUMBER(5) DEFAULT 0,
    num_habitaciones NUMBER(5) DEFAULT 0,
    num_estacionamientos NUMBER(5) DEFAULT 0
);

ALTER TABLE inmueble
    ADD CONSTRAINT fk_inmuelbe_propiedad
    FOREIGN KEY (id_propiedad)
    REFERENCES propiedad(id_propiedad)
    ON DELETE CASCADE;
    
ALTER TABLE inmueble
    ADD CONSTRAINT pk_inmueble
    PRIMARY KEY (id_propiedad);
    
-- Tabla para casas
CREATE TABLE casa (
    id_propiedad NUMBER(10),
    area_habitable NUMBER(5) DEFAULT 0,
    num_niveles NUMBER(5) DEFAULT 0
);

ALTER TABLE casa
    ADD CONSTRAINT fk_casa_inmueble
    FOREIGN KEY (id_propiedad)
    REFERENCES inmueble(id_propiedad);
    
ALTER TABLE casa
    ADD CONSTRAINT pk_casa
    PRIMARY KEY (id_propiedad);
    
-- Tabla para los edificios de departamento
CREATE TABLE edificio (
    id_edificio NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    num_departamentos NUMBER(5) DEFAULT 0,
    roof_garden NUMBER(1) DEFAULT 0,
    elevador NUMBER(1) DEFAULT 0,
    salon_eventos NUMBER(1) DEFAULT 0,
    gimnasio NUMBER(1) DEFAULT 0,
    piscina NUMBER(1) DEFAULT 0
);

ALTER TABLE edificio 
    ADD CONSTRAINT ch_edificio_roof_garden
    CHECK (roof_garden IN (0, 1));

ALTER TABLE edificio 
    ADD CONSTRAINT ch_edificio_elevador
    CHECK (elevador IN (0, 1));

ALTER TABLE edificio 
    ADD CONSTRAINT ch_edificio_salon_eventos
    CHECK (salon_eventos IN (0, 1));
    
ALTER TABLE edificio 
    ADD CONSTRAINT ch_edificio_gimnasio
    CHECK (gimnasio IN (0, 1));
    
ALTER TABLE edificio 
    ADD CONSTRAINT ch_edificio_piscina
    CHECK (piscina IN (0, 1));
    
ALTER TABLE edificio
    ADD CONSTRAINT pk_edificio
    PRIMARY KEY (id_edificio);
    
-- Tabla para los departamentos
CREATE TABLE departamento (
    id_propiedad NUMBER(10),
    id_edificio NUMBER(10),
    area_lavado NUMBER(1) DEFAULT 0,
    numero VARCHAR(10),
    balcon NUMBER(1) DEFAULT 0,
    piso NUMBER(5)
);

ALTER TABLE departamento 
    ADD CONSTRAINT ch_departamento_area_lavado
    CHECK (area_lavado IN (0, 1));
    
ALTER TABLE departamento 
    ADD CONSTRAINT ch_departamento_balcon
    CHECK (balcon IN (0, 1));
    
ALTER TABLE departamento
    ADD CONSTRAINT fk_departamento_edificio
    FOREIGN KEY (id_edificio)
    REFERENCES edificio(id_edificio)
    ON DELETE CASCADE;
    
ALTER TABLE departamento
    ADD CONSTRAINT fk_departamento_inmueble
    FOREIGN KEY (id_propiedad)
    REFERENCES inmueble(id_propiedad)
    ON DELETE CASCADE;

ALTER TABLE departamento
    ADD CONSTRAINT pk_departamento
    PRIMARY KEY (id_propiedad);
    
-- Tabla para los seguros
CREATE TABLE seguro (
    num_poliza NUMBER(10),
    id_propiedad NUMBER(10),
    cobertura VARCHAR(20),
    monto_anual NUMBER(10) DEFAULT 0,
    empresa VARCHAR(30)
);

ALTER TABLE seguro
    ADD CONSTRAINT fk_seguro_propiedad
    FOREIGN KEY (id_propiedad)
    REFERENCES propiedad(id_propiedad)
    ON DELETE CASCADE;
    
ALTER TABLE seguro
    ADD CONSTRAINT pk_seguro
    PRIMARY KEY (num_poliza);

-- Tabla para los dueños
CREATE TABLE duenio (
    id_duenio NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    monto_invertido NUMBER(10)
);

ALTER TABLE duenio
    ADD CONSTRAINT pk_duenio
    PRIMARY KEY (id_duenio);
    
-- Tabla para la relación 'ser dueño'
CREATE TABLE ser_duenio (
    id_propiedad NUMBER(10),
    id_duenio NUMBER(10),
    fecha_inicio DATE DEFAULT CURRENT_DATE,
    fecha_fin DATE,
    monto_compra NUMBER(10)
);

ALTER TABLE ser_duenio 
    ADD CONSTRAINT fk_ser_duenio_duenio
    FOREIGN KEY (id_duenio)
    REFERENCES duenio(id_duenio)
    ON DELETE CASCADE;
    
ALTER TABLE ser_duenio 
    ADD CONSTRAINT fk_ser_duenio_propiedad
    FOREIGN KEY (id_propiedad)
    REFERENCES propiedad(id_propiedad)
    ON DELETE CASCADE;
    
-- Tabla para las personas que son dueños
CREATE TABLE persona (
    curp VARCHAR(20),
    fecha_nac DATE,
    nombre VARCHAR(20),
    paterno VARCHAR(20),
    materno VARCHAR(20)
);

ALTER TABLE persona 
    ADD CONSTRAINT pk_persona
    PRIMARY KEY (curp);

-- Tabla para propietarios
CREATE TABLE propietario (
    curp VARCHAR(20),
    id_duenio NUMBER(10)
);

ALTER TABLE propietario
    ADD CONSTRAINT fk_propietario_duenio
    FOREIGN KEY (id_duenio)
    REFERENCES duenio(id_duenio)
    ON DELETE CASCADE;
    
ALTER TABLE propietario
    ADD CONSTRAINT fk_propietario_persona
    FOREIGN KEY (curp)
    REFERENCES persona(curp)
    ON DELETE CASCADE;
    
ALTER TABLE propietario
    ADD CONSTRAINT pk_propietario
    PRIMARY KEY (curp, id_duenio);
    
-- Tabla para correos electrónicos
CREATE TABLE correo_electronico (
    curp VARCHAR(20),
    id_duenio NUMBER(10),
    correo_electronico VARCHAR(40) NOT NULL
);

ALTER TABLE correo_electronico
    ADD CONSTRAINT fk_correo_persona
    FOREIGN KEY (curp, id_duenio)
    REFERENCES propietario(curp, id_duenio)
    ON DELETE CASCADE;
    
-- Tabla para las inmobiliarias
CREATE TABLE inmobiliaria (
    id_inmobiliaria NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_duenio NUMBER(10)
);

ALTER TABLE inmobiliaria 
    ADD CONSTRAINT fk_inmobiliaria_duenio
    FOREIGN KEY (id_duenio)
    REFERENCES duenio(id_duenio)
    ON DELETE CASCADE;
    
ALTER TABLE inmobiliaria
    ADD CONSTRAINT pk_inmobiiaria
    PRIMARY KEY (id_inmobiliaria, id_duenio);
    
-- Tabla para le relación 'revender'
CREATE TABLE revender (
    id_propiedad NUMBER(10),
    id_duenio NUMBER(10),
    id_inmobiliaria NUMBER(10),
    precio NUMBER(10)
);

ALTER TABLE revender
    ADD CONSTRAINT fk_revender_propiedad
    FOREIGN KEY (id_propiedad)
    REFERENCES propiedad(id_propiedad)
    ON DELETE SET NULL;
    
ALTER TABLE revender
    ADD CONSTRAINT fk_revender_inmobiliaria
    FOREIGN KEY (id_inmobiliaria, id_duenio)
    REFERENCES inmobiliaria(id_inmobiliaria, id_duenio)
    ON DELETE SET NULL;

-- Tabla para la relación 'venta_historial'
CREATE TABLE venta_historial (
    id_propiedad NUMBER(10),
    id_duenio NUMBER(10),
    id_inmobiliaria NUMBER(10),
    fecha DATE DEFAULT CURRENT_DATE,
    precio NUMBER(10)
);

ALTER TABLE venta_historial
    ADD CONSTRAINT fk_venta_historial_propiedad
    FOREIGN KEY (id_propiedad)
    REFERENCES propiedad(id_propiedad)
    ON DELETE SET NULL;
    
ALTER TABLE venta_historial
    ADD CONSTRAINT fk_venta_historial_inmobiliaria
    FOREIGN KEY (id_inmobiliaria, id_duenio)
    REFERENCES inmobiliaria(id_inmobiliaria, id_duenio)
    ON DELETE SET NULL;

-- Tabla para los asesores
CREATE TABLE asesor (
    rfc VARCHAR(15),
    nombre VARCHAR(20),
    paterno VARCHAR(20),
    materno VARCHAR(20),
    fecha_nac VARCHAR(20)
);

ALTER TABLE asesor 
    ADD CONSTRAINT pk_asesor
    PRIMARY KEY (rfc);
    
-- Tabla para las direcciones de los asesores
CREATE TABLE direccion_asesor (
    rfc VARCHAR(15),
    calle VARCHAR(20),
    numero VARCHAR(20),
    cp NUMBER(10)
);

ALTER TABLE direccion_asesor
    ADD CONSTRAINT fk_direccion_asesor
    FOREIGN KEY (rfc)
    REFERENCES asesor(rfc);
    
-- Tabla para la relacion 'vender'
CREATE TABLE vender (
    id_propiedad NUMBER(10),
    rfc VARCHAR(20),
    precio NUMBER(10),
    fecha DATE DEFAULT CURRENT_DATE,
    porcentaje_comision NUMBER(5)
);

ALTER TABLE vender
    ADD CONSTRAINT ck_vender_comision
    CHECK (porcentaje_comision <= 100);

ALTER TABLE vender 
    ADD CONSTRAINT fk_vender_propiedad
    FOREIGN KEY (id_propiedad)
    REFERENCES propiedad(id_propiedad)
    ON DELETE SET NULL;
    
ALTER TABLE vender
    ADD CONSTRAINT fk_vender_asesor
    FOREIGN KEY (rfc)
    REFERENCES asesor(rfc)
    ON DELETE SET NULL;
    
-- Tabla para la relación de 'ser_encargado'
CREATE TABLE ser_encargado (
    id_propiedad NUMBER(10),
    rfc VARCHAR(20)
);

ALTER TABLE ser_encargado   
    ADD CONSTRAINT fk_ser_encargado_propiedad
    FOREIGN KEY (id_propiedad)
    REFERENCES propiedad(id_propiedad)
    ON DELETE CASCADE;
    
ALTER TABLE ser_encargado
    ADD CONSTRAINT fk_ser_encargado_asesor
    FOREIGN KEY (rfc)
    REFERENcES asesor(rfc)
    ON DELETE CASCADE;