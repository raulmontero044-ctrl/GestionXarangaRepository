-- V1__rolespermisos.sql
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE TABLE permissions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    account_non_locked BOOLEAN DEFAULT TRUE,
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles(id)
);

CREATE TABLE user_permissions (
    user_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, permission_id),
    CONSTRAINT fk_user_permissions_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_user_permissions_permission FOREIGN KEY (permission_id) REFERENCES permissions(id)
);

CREATE TABLE departments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE TABLE user_departments (
    user_id BIGINT NOT NULL,
    department_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, department_id),
    CONSTRAINT fk_user_departments_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_user_departments_dept FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE refresh_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    token_hash VARCHAR(255) NOT NULL,
    user_id BIGINT NOT NULL,
    family_id VARCHAR(36) NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    revoked BOOLEAN DEFAULT FALSE,
    expires_at DATETIME(6) NOT NULL,
    replaced_by_id BIGINT,
    user_agent VARCHAR(255),
    ip VARCHAR(45),
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_refresh_tokens_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE user_auth_state (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    sessions_active INT DEFAULT 0,
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_user_auth_state_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE password_reset_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    token_hash VARCHAR(255) NOT NULL,
    user_id BIGINT NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    expires_at DATETIME(6) NOT NULL,
    used_at DATETIME(6),
    requested_ip VARCHAR(45),
    requested_user_agent VARCHAR(255),
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_password_reset_tokens_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE login_attempt_state (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    failed_count INT DEFAULT 0,
    lock_until DATETIME(6),
    last_failed_at DATETIME(6),
    last_failed_ip VARCHAR(45),
    unlocked_by VARCHAR(100),
    unlocked_at DATETIME(6),
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_login_attempt_state_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE login_attempt_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    username_or_email VARCHAR(100),
    ip VARCHAR(45),
    user_agent VARCHAR(255),
    success BOOLEAN DEFAULT FALSE,
    reason VARCHAR(50),
    attempt_at DATETIME(6),
    created_at DATETIME(6),
    updated_at DATETIME(6),
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE TABLE auditoria_accesos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT,
    username_or_email VARCHAR(100),
    ip VARCHAR(45),
    user_agent VARCHAR(255),
    dispositivo VARCHAR(100),
    exito BOOLEAN DEFAULT FALSE,
    motivo VARCHAR(50),
    fecha_hora DATETIME(6) NOT NULL,
    detalle VARCHAR(500)
);

INSERT INTO roles (name, description, created_at) VALUES
('TESORERIA', 'Tesorería', NOW(6)),
('JEFATURA', 'Jefatura', NOW(6)),
('ARREGLOS', 'Arreglos', NOW(6)),
('MARKETING', 'Marketing', NOW(6)),
('SOCIO', 'Socio', NOW(6));
