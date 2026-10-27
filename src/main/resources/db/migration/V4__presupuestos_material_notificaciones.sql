-- V4__presupuestos_material_notificaciones.sql
CREATE TABLE presupuestos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ejercicio_id BIGINT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    estado VARCHAR(20) NOT NULL,
    importe_total DECIMAL(10,2),
    moneda VARCHAR(3) DEFAULT 'EUR',
    propuesto_por VARCHAR(100),
    aprobado_por VARCHAR(100),
    fecha_propuesta DATETIME(6),
    fecha_aprobacion DATETIME(6),
    motivo_rechazo TEXT,
    observaciones TEXT,
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_presupuestos_ejercicio FOREIGN KEY (ejercicio_id) REFERENCES ejercicios(id)
);

CREATE TABLE partida_presupuesto (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    presupuesto_id BIGINT NOT NULL,
    concepto VARCHAR(150) NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    importe_unitario DECIMAL(10,2),
    importe_total DECIMAL(10,2),
    observaciones TEXT,
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_partida_presupuesto FOREIGN KEY (presupuesto_id) REFERENCES presupuestos(id)
);

CREATE TABLE categorias_material (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE TABLE material (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    categoria_id BIGINT,
    codigo VARCHAR(50) UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    talla VARCHAR(20),
    color VARCHAR(30),
    variante VARCHAR(50),
    stock INT DEFAULT 0,
    precio DECIMAL(10,2),
    moneda VARCHAR(3) DEFAULT 'EUR',
    ampliable BOOLEAN DEFAULT TRUE,
    activo BOOLEAN DEFAULT TRUE,
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_material_categoria FOREIGN KEY (categoria_id) REFERENCES categorias_material(id)
);

CREATE TABLE pedidos_material (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    musico_id BIGINT,
    usuario_id BIGINT,
    estado VARCHAR(20),
    observaciones TEXT,
    fecha_pedido DATETIME(6),
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_pedidos_material_musico FOREIGN KEY (musico_id) REFERENCES musicos(id),
    CONSTRAINT fk_pedidos_material_usuario FOREIGN KEY (usuario_id) REFERENCES users(id)
);

CREATE TABLE detalle_pedido_material (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pedido_id BIGINT NOT NULL,
    material_id BIGINT NOT NULL,
    cantidad INT NOT NULL,
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (pedido_id) REFERENCES pedidos_material(id),
    CONSTRAINT fk_detalle_material FOREIGN KEY (material_id) REFERENCES material(id)
);

CREATE TABLE notificaciones (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo VARCHAR(30),
    remitente_id BIGINT,
    fecha_envio DATETIME(6),
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE TABLE notificacion_destinatarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    notificacion_id BIGINT NOT NULL,
    usuario_id BIGINT,
    rol_id BIGINT,
    departamento_id BIGINT,
    actividad_id BIGINT,
    leido BOOLEAN DEFAULT FALSE,
    fecha_lectura DATETIME(6),
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_notif_dest_notif FOREIGN KEY (notificacion_id) REFERENCES notificaciones(id)
);
