-- V2__ejercicios_musicos.sql
CREATE TABLE ejercicios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ano_curso VARCHAR(20),
    temporada VARCHAR(20) NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE,
    activo BOOLEAN DEFAULT TRUE,
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE TABLE musicos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(150) NOT NULL,
    alias VARCHAR(50),
    contacto VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE,
    usuario_id BIGINT,
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_musicos_usuario FOREIGN KEY (usuario_id) REFERENCES users(id)
);
