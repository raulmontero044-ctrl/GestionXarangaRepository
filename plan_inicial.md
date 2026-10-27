# Plan Inicial - Gestión Xaranga

## Objetivo
Crear un monolito modular con arquitectura hexagonal para gestionar: Pagos, Presupuestos, Actividades/Eventos, Material (sudaderas/pulseras/peticiones), Notificaciones/Comunicados, Roles y Permisos, Músicos, Ejercicios, Rotaciones y Tesorería/Reporting. 
Dominio puro sin dependencias de Spring. API REST versionada con Spring Security, permisos por roles (Tesorería, Jefatura, Arreglos, Marketing), validación, documentación Swagger, formato de errores unificado, tests desde el principio, desplegable con Docker (solo dev).

## 1) Arquitectura General

### Hexagonal (Ports & Adapters)
- **Dominio (Core)**: Entidades, Value Objects, Agregados, Servicios de dominio. **SIN** anotaciones Spring (`@Entity`, `@Service`, etc). Solo lógica pura Java.
- **Aplicación (Use Cases/Ports)**: Casos de uso, puertos de entrada (`in`) y salida (`out`). Orquesta dominio. Sin frameworks.
- **Infraestructura (Adapters)**: 
  - `in/web/rest` - Controladores REST
  - `in/event` - Listeners de eventos (comunicación entre módulos)
  - `out/persistence` - Repositorios JPA, entidades JPA mapeadas desde dominio, migraciones Flyway
  - `out/external` - Integraciones externas si las hubiera
  - `config` - Configuración Spring

### Monolito Modular
Cada módulo es un bounded context autónomo. Comunicación entre módulos preferentemente por **puertos** (sin imports directos cruzados). Paquete base: `com.tuxaranga.gestion`.

## 2) Decisiones Clave

| Punto | Decisión |
|---|---|
| Comunicación entre módulos | **Por puertos** (sin ApplicationEventPublisher directo entre módulos). Definir puertos de salida en módulo A e implementación en otro, o usar contratos vía `shared` si fuera necesario. |
| IDs | **Long** autoincremental |
| Auditoría | **Sí** - `createdAt`, `updatedAt`, `createdBy`, `updatedBy` (con `@CreatedDate`, `@LastModifiedDate`, `AuditorAware`). Además tabla `auditoria_accesos` independiente para logins/recuperaciones/bloqueos. |
| Borrado | **Físico** |
| Auth inicial | **Sí** - login/registro desde el inicio (módulo `rolespermisos`) |
| Shared | Excepciones base, value objects comunes, `DomainEvent` base (si se usa), utilidades, `Auditable` |
| BD | `gestion_xaranga` |
| Mappeo | **MapStruct** para dominio<->DTO y dominio<->entidad JPA |
| Material | Ampliable (catálogo, variantes, tallas, peticiones/pedidos, estados) |
| Roles/Permisos | Multi-rol/multi-departamento (un usuario puede pertenecer a varios roles/departamentos). Roles: `TESORERIA`, `JEFATURA`, `ARREGLOS`, `MARKETING` (+ `SOCIO` si aplica) |
| Ejercicios | Divididos en `FALLAS`, `VERANO`, `TEMPORADA_BAJA` (octubre-febrero y abril-mayo) |
| Músicos | Ficha independiente de usuarios. Un usuario puede vincularse a un músico para ver "Mis ganancias". **Sin módulo socios/familiares** (por ahora no acceden a web) |

## 3) Estructura de Paquetes

```text
com.tuxaranga.gestion
├── shared/
│   ├── domain/
│   │   ├── exception/        # DomainException, NotFoundException base
│   │   ├── model/            # AggregateRoot, ValueObject, Auditable
│   │   └── vo/               # Email, Money, etc.
│   ├── application/
│   │   └── port/out/         # Shared ports if any
│   └── infrastructure/
│       ├── config/           # AuditorAware, Jackson, etc.
│       └── exception/        # Global ProblemDetails handler
├── rolespermisos/            # Identidad + RBAC (multi-rol/departamento) + Auth hardening
│   ├── domain/
│   ├── application/
│   └── infrastructure/
├── ejercicios/
├── musicos/
├── actividades/
├── pagos/
├── presupuestos/
├── rotaciones/
├── material/
├── notificaciones/
└── tesoreria/ (o integrado en reporting)
```

## 4) Autenticación, Seguridad y Hardening

### Access Token + Refresh Token + Rotación + Detección de reutilización
| Entidad | Explicación |
|---|---|
| `RefreshToken` | `id(Long)`, `tokenHash`, `userId`, `familyId` (UUID), `used(boolean)`, `revoked(boolean)`, `expiresAt`, `replacedById`, `userAgent`, `ip`, auditoría. **Nunca guardar en claro**. |
| `UserAuthState` | Estado de autenticación, útil para bloqueo, sesiones activas. |

Flujo:
- **Login**: Genera `accessToken` (corto 10-15 min) + `refreshToken` (7-14 días). Nuevo `familyId`. Guarda hash + metadata.
- **Refresh**: Busca por hash. Si válido -> marca actual como `used=true`, genera nuevo con mismo `familyId`, guarda `replacedById`, devuelve nuevos tokens.
- **Reuse detection**: Si recibe refresh con `used=true` o `revoked=true` -> revoca **TODOS** los refresh del `familyId` -> registra `REFRESH_TOKEN_REUSE_DETECTED` en auditoría -> 401.
- **Logout**: Revoca refresh token enviado.
- **Sesiones activas**: Listado/revocación por usuario o por JEFATURA/TESORERIA.

### Recuperación / Cambio de contraseña
| Entidad | Explicación |
|---|---|
| `PasswordResetToken` | `id(Long)`, `tokenHash`, `userId`, `used(boolean)`, `expiresAt`, `usedAt`, `requestedIp`, `requestedUserAgent`, auditoría. |

Endpoints:
| Endpoint | Método | Acceso | Descripción |
|---|---|---|---|
| `/api/v1/auth/forgot-password` | `POST` | Público | Solicita recuperación. Token un solo uso caducidad 15-30 min. **Mensaje genérico** para evitar enumeración. |
| `/api/v1/auth/reset-password` | `POST` | Público | Valida token, cambia contraseña, marca como usado. Registra en auditoría. |
| `/api/v1/auth/change-password` | `POST` | Autenticado | Requiere `currentPassword`. Tras cambio **invalida todos los refresh tokens activos** del usuario. |

### Bloqueo por intentos fallidos + Auditoría de accesos
| Entidad | Explicación |
|---|---|
| `LoginAttemptState` | `id(Long)`, `userId` (único), `failedCount(int)`, `lockUntil(OffsetDateTime)`, `lastFailedAt`, `lastFailedIp`, `unlockedBy`, `unlockedAt`, auditoría. |
| `LoginAttemptHistory` | Histórico detallado: `id(Long)`, `userId(nullable)`, `usernameOrEmail`, `ip`, `userAgent`, `success(boolean)`, `reason`, `attemptAt`. |
| `AuditoriaAcceso` | **Inmutable, solo lectura**. `id(Long)`, `usuarioId(Long nullable)`, `usernameOrEmail`, `ip`, `userAgent`, `dispositivo`, `exito(boolean)`, `motivo(String/enum)`, `fechaHora(OffsetDateTime)`, `detalle`. Solo accesible JEFATURA/TESORERIA. Paginado/filtrable. |

Motivos registrados: `LOGIN_OK`, `BAD_CREDENTIALS`, `ACCOUNT_LOCKED`, `ACCOUNT_DISABLED`, `TOKEN_REFRESH`, `REFRESH_TOKEN_REUSE_DETECTED`, `LOGOUT`, `PASSWORD_RECOVERY_REQUESTED`, `PASSWORD_RESET_SUCCESS`, `PASSWORD_RESET_FAILED`, `PASSWORD_CHANGED_SELF`, `SESSION_REVOKED_BY_ADMIN`, `USER_UNLOCKED`.

Reglas:
- Bloqueo por usuario tras X intentos fallidos (configurable) por Y minutos (configurable)
- Reset de contador al login correcto
- Desbloqueo manual por JEFATURA/TESORERIA con registro
- Bloqueo mientras `lockUntil > now()`

## 5) Módulos de Negocio

| Módulo | Responsabilidades |
|---|---|
| `ejercicios` | Definir ejercicios (nombre, año/curso, temporadas `FALLAS`/`VERANO`/`TEMPORADA_BAJA`, fechas inicio/fin, activo). Base para todo. |
| `musicos` | Ficha de músico (nombre/apellidos, alias, contacto, activo). Enlace opcional con `usuario` de `rolespermisos`. Sin socios/familiares. |
| `actividades` | Eventos por ejercicio/temporada. Control plazas totales/ocupadas/libres, fecha límite asignación, estado, local, observaciones. Asignaciones a músicos. Lista de espera. Mostrar fechas aprobadas, plazas y músicos que van. |
| `rotaciones` | Historial `RotacionHistorial` por ejercicio/músico (numActuaciones, ultimaFechaActuacion, ultimaEventoId). Ranking sugerido para equilibrar (priorizar menor numActuaciones + última actuación más antigua). Registrar `asignadoPor`. |
| `pagos` | Pagos/cobros ligados a asignaciones/eventos. Integrado con tesorería. |
| `presupuestos` | Flujo `BORRADOR` -> `PENDIENTE_APROBACION` -> `APROBADO`/`RECHAZADO`/`CERRADO`. `propuestoPor`, `aprobadoPor`, `fechaPropuesta`, `fechaAprobacion`, `motivoRechazo`, `partidasPresupuesto`, vinculado a ejercicio. |
| `material` | Catálogo ampliable (categorías, atributos, tallas/colores/variantes, peticiones/pedidos, estados, stock/bajo pedido). |
| `notificaciones` | Comunicados/notificaciones con destinatarios por rol, departamento, actividad o grupo concreto. |
| `tesoreria/reporting` | Vistas globales para JEFATURA/TESORERIA (todos los músicos con total ganado/cobrado por ejercicio desglosado por evento). Vista propia "Mis ganancias" para músico logueado. **Importe congelado en `asignacion_evento`** (histórico). |
| `rolespermisos` | Usuarios, roles, permisos granulares, departamentos, multi-rol/multi-departamento, auth completo + hardening. |

## 6) API REST

### Versionado
- Todas las rutas bajo `/api/v1/...`

### Autenticación y Autorización
- **Spring Security** con **JWT stateless** (access + refresh)
- **Roles**: `TESORERIA`, `JEFATURA`, `ARREGLOS`, `MARKETING` (+ `SOCIO` si aplica)
- **Permisos granulares**: `@PreAuthorize` con roles/permisos. Permisos específicos para reporting: `TESORERIA_VER_TODOS`, `JEFATURA_VER_TODOS`, `MUSICO_VER_PROPIO`
- **Multi-rol/multi-departamento** soportado

### Documentación
- **springdoc-openapi** con Swagger UI agrupado por módulo/tags. `/swagger-ui.html` o `/swagger-ui/index.html`

### Validación
- **Bean Validation** (`@Valid`, `@Validated`) en DTOs de request

### Formato de Errores (RFC 7807 Problem Details)
Estructura unificada con `application/problem+json`:
```json
{
  "type": "https://api.tuxaranga.gestion/errors/...",
  "title": "...",
  "status": 404,
  "detail": "...",
  "instance": "/api/v1/...",
  "timestamp": "2026-10-27T10:30:00Z"
}
```
Incluye códigos para auth: `ACCOUNT_LOCKED`, `INVALID_REFRESH_TOKEN`, `REFRESH_TOKEN_REUSE`, `INVALID_RESET_TOKEN`, `TOKEN_EXPIRED`, `PASSWORD_MISMATCH`, etc.

### CORS
Configurado para desarrollo con Angular (`http://localhost:4200`)

## 7) Persistencia

- **Base de datos**: MariaDB `gestion_xaranga`
- **Migraciones**: Flyway en `src/main/resources/db/migration/` organizados por módulo con prefijo (`V1__rolespermisos.sql`, etc.)
- **ORM**: Spring Data JPA/Hibernate
- **Mapeo**: Entidades JPA en `infrastructure/adapter/out/persistence/entity` mapeadas a dominio (no usar entidades JPA como dominio)
- **MapStruct**: Mappers entre dominio<->DTO y dominio<->entidad JPA
- **Transacciones**: En capa aplicación/servicio
- **Auditoría JPA**: `@EnableJpaAuditing` + `AuditorAware`
- **Borrado físico** (sin soft delete)

## 8) Infraestructura Docker (solo dev)

- **Dockerfile**: Multi-stage build (Maven)
- **docker-compose.yml**: Servicios `app` + `mariadb`. Volúmenes para datos. Red interna. Healthchecks para MariaDB.
- **application.yml**, **application-dev.yml**: Configurados para conectar a MariaDB vía servicio docker (`host mariadb`)
- **.env**: Credenciales/dev
- **Perfil**: Solo `dev`

## 9) Testing desde el principio

- **Unitarios**: Dominio y casos de uso (sin Spring context)
- **Integración**: Controladores REST con `@WebMvcTest` o `@SpringBootTest` + MockMvc
- **Persistencia**: Repositorios con `@DataJpaTest`
- **Testcontainers**: Para tests de integración con MariaDB real (perfil `test`)
- **ArchUnit**: Para validar reglas arquitectónicas (dominio sin Spring, separación hexagonal, puertos/adapters, comunicación por puertos)
- **Cobertura**: JUnit 5, Mockito, AssertJ

## 10) Dependencias Clave (Maven)

```xml
<!-- Core -->
spring-boot-starter-web
spring-boot-starter-data-jpa
spring-boot-starter-validation
spring-boot-starter-security
spring-boot-starter-actuator

<!-- DB -->
mariadb-java-client
flyway-core
flyway-mysql

<!-- JWT -->
jjwt-api, jjwt-impl, jjwt-jackson

<!-- OpenAPI -->
springdoc-openapi-starter-webmvc-ui

<!-- Mapping -->
mapstruct

<!-- Utils -->
lombok (opcional)

<!-- Test -->
spring-boot-starter-test
testcontainers
testcontainers-junit-jupiter
testcontainers-mariadb
archunit-junit5
```

## 11) Estrategia Git + GitHub

### Ramas
| Rama | Uso |
|---|---|
| `main` / `master` | Rama estable. Solo merge desde `develop` tras revisión. |
| `develop` | Rama de integración. Todas las `features` se mergearán aquí. |
| `feature/<nombre-descriptivo>` | Una por bloque funcional. Creada SIEMPRE desde `develop`. |

### Flujo
1. Configurar remoto `origin` con repo GitHub
2. Commit inicial (archivos base)
3. Crear `develop` desde rama por defecto
4. Por cada feature: crear rama desde develop, implementar, commits atómicos, push, merge a develop
5. Al final: revisión íntegra de todo el código + actualizar `README.md` con **TODOS** los endpoints (método, ruta, auth/roles, descripción y breve guía de uso)

## 12) Features Planificadas

| Feature | Alcance | Notas |
|---|---|---|
| `feature/auth-access-refresh-rotation` | Access/Refresh, `RefreshToken` con `familyId`, rotación, reuse detection + revocación de familia | **Prioritario** |
| `feature/auth-password-recovery-change` | `PasswordResetToken`, `/forgot-password`, `/reset-password`, `/change-password`, invalidación tras cambio | Flujo completo |
| `feature/auth-failed-attempts-access-audit` | `LoginAttemptState`, `LoginAttemptHistory`, `AuditoriaAcceso`, bloqueo por umbral, desbloqueo manual, registro motivos | Los 3 bloques solicitados |
| `feature/hexagonal-base-structure` | Estructura paquetes, `shared/`, configuración base Maven, naming | Esqueleto base |
| `feature/shared-kernel-auditing` | `shared/domain`, excepciones, `Auditable`, `AuditorAware` | Auditoría base |
| `feature/rolespermisos-rbac-multirole` | Multi-rol/multi-departamento, permisos granulares | Núcleo transversal |
| `feature/ejercicios` | Módulo ejercicios (temporadas, fechas, activo) | Base para todo |
| `feature/musicos` | Módulo músicos + vínculo usuario | Sin socios/familiares |
| `feature/eventos-plazas-asignaciones` | Eventos con plazas, fecha límite, asignaciones, lista de espera | Fechas, plazas, músicos por evento |
| `feature/rotaciones-equilibrado` | `RotacionHistorial`, contadores, ranking sugerido, `asignadoPor` | Equilibrar actuaciones/ganancias |
| `feature/presupuestos-flujo-aprobacion` | Estados, trazabilidad, partidas, motivo rechazo | Flujo completo |
| `feature/pagos-module` | Módulo pagos | Integrado con tesorería |
| `feature/tesoreria-reporting-ganancias` | Vista global JEFATURA/TESORERIA + "Mis ganancias" músico, importe congelado | Cumple requisitos |
| `feature/material-module` | Catálogo ampliable, tallas/variantes, peticiones/pedidos/estados | Ampliable |
| `feature/notificaciones-module` | Comunicados con destinatarios | Mantener |
| `feature/security-openapi-problemdetails` | SecurityConfig, JwtFilter, OpenApiConfig, GlobalExceptionHandler RFC7807 | Unificado |
| `feature/persistence-flyway-docker` | Flyway, Dockerfile multi-stage, docker-compose, application-dev.yml, BD gestion_xaranga | Solo dev |
| `feature/mapstruct-mappers-validation` | MapStruct, mappers, `@Valid`/`@Validated` | Tal como pedido |
| `feature/tests-archunit-testcontainers` | Unitarios, integración, Testcontainers, ArchUnit | Desde el principio |
| `feature/docs-readme-endpoints` | README con TODOS los endpoints, auth/roles, descripción, guía uso | Obligatorio al final |

## 13) Checklist Revisión Final

- [ ] Arquitectura hexagonal: `domain/` sin imports Spring
- [ ] Comunicación entre módulos solo por puertos
- [ ] RBAC multi-rol/multi-departamento
- [ ] Auth: Access+Refresh, rotación, reuse detection, logout, sesiones activas
- [ ] Recuperación/cambio contraseña con tokens un solo uso
- [ ] Bloqueo por intentos + auditoría accesos (inmutable, solo lectura, permisos)
- [ ] API versionada `/api/v1/`, validación, Problem Details RFC7807, Swagger
- [ ] Persistencia: Flyway, mapeo dominio-entidad, MapStruct, Long IDs, auditoría, borrado físico
- [ ] Músicos+Ejercicios+Eventos con plazas/asignaciones+Rotaciones
- [ ] Presupuestos con flujo + trazabilidad
- [ ] Tesorería: vista global + "Mis ganancias", importe congelado
- [ ] Material ampliable
- [ ] Docker dev funcional
- [ ] Tests + ArchUnit + Testcontainers
- [ ] README completo con todos los endpoints

**Fecha**: 27/10/2026  
**Proyecto**: Gestión Xaranga  
**Tecnologías**: Spring Boot, Java, Hexagonal + Monolito Modular, MariaDB, Flyway, Spring Security + JWT, MapStruct, springdoc-openapi, Docker, Testcontainers, ArchUnit
