# GestionXaranga

Monolito modular con arquitectura hexagonal para la gestión de la Xaranga.

## Tecnologías
- Java 21
- Spring Boot 3.3.4
- Spring Security + JWT
- Spring Data JPA + Hibernate
- MariaDB
- Flyway
- MapStruct
- springdoc-openapi
- Maven
- Docker / Docker Compose
- Testcontainers, ArchUnit

## Estructura
Ver `plan_inicial.md` para detalles completos.

## Ejecutar en desarrollo
```bash
docker-compose up --build
```

API: http://localhost:8080  
Swagger: http://localhost:8080/swagger-ui.html

## Endpoints (v1)

### Auth
| Método | Ruta | Auth | Roles | Descripción |
|---|---|---|---|---|
| POST | `/api/v1/auth/login` | Público | - | Login con access + refresh token |
| POST | `/api/v1/auth/refresh` | Público | - | Rotación de refresh token con detección de reutilización |
| POST | `/api/v1/auth/logout` | Autenticado | - | Revocación de refresh token |
| GET | `/api/v1/auth/sessions` | Autenticado | - | Listado de sesiones activas |
| DELETE | `/api/v1/auth/sessions/{id}` | Autenticado | - | Revocación de sesión |
| POST | `/api/v1/auth/forgot-password` | Público | - | Solicitud de recuperación (mensaje genérico) |
| POST | `/api/v1/auth/reset-password` | Público | - | Restablecer contraseña con token |
| POST | `/api/v1/auth/change-password` | Autenticado | - | Cambio de contraseña (invalida refresh tokens) |

### Auditoría / Seguridad
| Método | Ruta | Auth | Roles | Descripción |
|---|---|---|---|---|
| GET | `/api/v1/auditoria-accesos` | Autenticado | JEFATURA, TESORERIA | Auditoría de accesos paginada/filtrable |
| GET | `/api/v1/login-attempts` | Autenticado | JEFATURA, TESORERIA | Intentos de login |
| POST | `/api/v1/usuarios/{id}/unlock` | Autenticado | JEFATURA, TESORERIA | Desbloqueo manual de usuario |

### Ejercicios
| Método | Ruta | Auth | Roles | Descripción |
|---|---|---|---|---|
| GET | `/api/v1/ejercicios` | Autenticado | Cualquiera | Listado |
| POST | `/api/v1/ejercicios` | Autenticado | JEFATURA, ARREGLOS | Crear |
| GET | `/api/v1/ejercicios/{id}` | Autenticado | Cualquiera | Detalle |
| PUT | `/api/v1/ejercicios/{id}` | Autenticado | JEFATURA, ARREGLOS | Actualizar |

### Músicos
| Método | Ruta | Auth | Roles | Descripción |
|---|---|---|---|---|
| GET | `/api/v1/musicos` | Autenticado | JEFATURA, TESORERIA, ARREGLOS | Listado |
| POST | `/api/v1/musicos` | Autenticado | JEFATURA, ARREGLOS | Crear |
| GET | `/api/v1/musicos/{id}` | Autenticado | JEFATURA, TESORERIA, ARREGLOS | Detalle |
| PUT | `/api/v1/musicos/{id}` | Autenticado | JEFATURA, ARREGLOS | Actualizar |

### Actividades/Eventos
| Método | Ruta | Auth | Roles | Descripción |
|---|---|---|---|---|
| GET | `/api/v1/actividades` | Autenticado | Cualquiera | Listado con plazas libres/ocupadas |
| POST | `/api/v1/actividades` | Autenticado | JEFATURA, ARREGLOS | Crear |
| GET | `/api/v1/actividades/{id}` | Autenticado | Cualquiera | Detalle con músicos asignados |
| POST | `/api/v1/actividades/{id}/asignar` | Autenticado | JEFATURA, ARREGLOS | Asignar músico (congelar importe) |
| POST | `/api/v1/actividades/{id}/lista-espera` | Autenticado | Autenticado | Añadir a lista de espera |
| DELETE | `/api/v1/actividades/{id}/asignaciones/{asignacionId}` | Autenticado | JEFATURA, ARREGLOS | Eliminar asignación |

### Rotaciones
| Método | Ruta | Auth | Roles | Descripción |
|---|---|---|---|---|
| GET | `/api/v1/rotaciones/ranking` | Autenticado | JEFATURA, ARREGLOS | Ranking sugerido (menor actuaciones + más antigua última actuación) |
| GET | `/api/v1/rotaciones/historial` | Autenticado | JEFATURA, ARREGLOS | Historial por ejercicio/músico |

### Presupuestos
| Método | Ruta | Auth | Roles | Descripción |
|---|---|---|---|---|
| GET | `/api/v1/presupuestos` | Autenticado | JEFATURA, TESORERIA | Listado |
| POST | `/api/v1/presupuestos` | Autenticado | JEFATURA, TESORERIA | Crear borrador |
| PUT | `/api/v1/presupuestos/{id}` | Autenticado | JEFATURA, TESORERIA | Actualizar borrador |
| POST | `/api/v1/presupuestos/{id}/enviar-aprobacion` | Autenticado | JEFATURA, TESORERIA | Enviar a aprobación |
| POST | `/api/v1/presupuestos/{id}/aprobar` | Autenticado | JEFATURA | Aprobar |
| POST | `/api/v1/presupuestos/{id}/rechazar` | Autenticado | JEFATURA | Rechazar con motivo |
| POST | `/api/v1/presupuestos/{id}/cerrar` | Autenticado | JEFATURA, TESORERIA | Cerrar |

### Pagos
| Método | Ruta | Auth | Roles | Descripción |
|---|---|---|---|---|
| GET | `/api/v1/pagos` | Autenticado | TESORERIA, JEFATURA | Listado |
| POST | `/api/v1/pagos` | Autenticado | TESORERIA | Registrar pago |
| GET | `/api/v1/pagos/{id}` | Autenticado | TESORERIA, JEFATURA | Detalle |

### Material
| Método | Ruta | Auth | Roles | Descripción |
|---|---|---|---|---|
| GET | `/api/v1/material/categorias` | Autenticado | Cualquiera | Categorías |
| GET | `/api/v1/material/catalogo` | Autenticado | Cualquiera | Catálogo (variantes/tallas/colores) |
| POST | `/api/v1/material/pedidos` | Autenticado | Autenticado | Crear petición/pedido |
| GET | `/api/v1/material/pedidos` | Autenticado | TESORERIA, JEFATURA, MARKETING | Listado pedidos |
| PUT | `/api/v1/material/pedidos/{id}/estado` | Autenticado | TESORERIA, JEFATURA, MARKETING | Cambiar estado |

### Notificaciones/Comunicados
| Método | Ruta | Auth | Roles | Descripción |
|---|---|---|---|---|
| POST | `/api/v1/notificaciones` | Autenticado | JEFATURA, MARKETING | Crear comunicado |
| GET | `/api/v1/notificaciones/mis-notificaciones` | Autenticado | Autenticado | Mis notificaciones |
| PUT | `/api/v1/notificaciones/{id}/leer` | Autenticado | Autenticado | Marcar como leída |

### Tesorería / Reporting
| Método | Ruta | Auth | Roles | Descripción |
|---|---|---|---|---|
| GET | `/api/v1/tesoreria/ganancias/todos` | Autenticado | TESORERIA, JEFATURA | Todos los músicos con totales por ejercicio (desglosado por evento) |
| GET | `/api/v1/tesoreria/ganancias/mis-ganancias` | Autenticado | Autenticado | "Mis ganancias" (importe congelado en asignación) |

### Roles y Permisos
| Método | Ruta | Auth | Roles | Descripción |
|---|---|---|---|---|
| GET | `/api/v1/roles` | Autenticado | JEFATURA | Listado roles |
| GET | `/api/v1/usuarios` | Autenticado | JEFATURA | Listado usuarios con roles/departamentos |
| POST | `/api/v1/usuarios/{id}/roles` | Autenticado | JEFATURA | Asignar rol/departamento (multi-rol/multi-departamento) |
| DELETE | `/api/v1/usuarios/{id}/roles/{roleId}` | Autenticado | JEFATURA | Quitar rol |

**Nota:** Todos los endpoints bajo `/api/v1/`. Errores unificados en formato RFC7807 `application/problem+json`.
