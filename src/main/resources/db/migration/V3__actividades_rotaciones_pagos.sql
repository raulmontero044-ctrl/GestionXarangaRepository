-- V3__actividades_rotaciones_pagos.sql
CREATE TABLE actividades (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ejercicio_id BIGINT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    fecha DATETIME(6),
    local VARCHAR(150),
    plazas_totales INT NOT NULL DEFAULT 0,
    plazas_ocupadas INT NOT NULL DEFAULT 0,
    fecha_limite_asignacion DATETIME(6),
    estado VARCHAR(20),
    observaciones TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_actividades_ejercicio FOREIGN KEY (ejercicio_id) REFERENCES ejercicios(id)
);

CREATE TABLE asignacion_evento (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    actividad_id BIGINT NOT NULL,
    musico_id BIGINT NOT NULL,
    importe_congelado DECIMAL(10,2),
    moneda VARCHAR(3) DEFAULT 'EUR',
    asignado_por VARCHAR(100),
    fecha_asignacion DATETIME(6),
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_asignacion_actividad FOREIGN KEY (actividad_id) REFERENCES actividades(id),
    CONSTRAINT fk_asignacion_musico FOREIGN KEY (musico_id) REFERENCES musicos(id)
);

CREATE TABLE lista_espera (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    actividad_id BIGINT NOT NULL,
    musico_id BIGINT NOT NULL,
    fecha_solicitud DATETIME(6),
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_lista_espera_actividad FOREIGN KEY (actividad_id) REFERENCES actividades(id),
    CONSTRAINT fk_lista_espera_musico FOREIGN KEY (musico_id) REFERENCES musicos(id)
);

CREATE TABLE rotacion_historial (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ejercicio_id BIGINT NOT NULL,
    musico_id BIGINT NOT NULL,
    num_actuaciones INT DEFAULT 0,
    ultima_fecha_actuacion DATETIME(6),
    ultima_evento_id BIGINT,
    asignado_por VARCHAR(100),
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_rotacion_ejercicio FOREIGN KEY (ejercicio_id) REFERENCES ejercicios(id),
    CONSTRAINT fk_rotacion_musico FOREIGN KEY (musico_id) REFERENCES musicos(id)
);

CREATE TABLE pagos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    asignacion_evento_id BIGINT,
    musico_id BIGINT NOT NULL,
    importe DECIMAL(10,2) NOT NULL,
    moneda VARCHAR(3) DEFAULT 'EUR',
    estado VARCHAR(20),
    fecha_pago DATETIME(6),
    observaciones TEXT,
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_pagos_asignacion FOREIGN KEY (asignacion_evento_id) REFERENCES asignacion_evento(id),
    CONSTRAINT fk_pagos_musico FOREIGN KEY (musico_id) REFERENCES musicos(id)
);
