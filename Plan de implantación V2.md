# Plan de Implementación Técnica: Ecosistema Antigravity Soriana

Documento arquitectónico y procedimental alineado a la estructura de carpetas, entidades, sistema de diseño y stack tecnológico definido. Sin código. Diseñado para equipos de desarrollo, control de calidad y despliegue corporativo.

---

## 1. Sistema de Diseño e Identidad Visual

El diseño opera como un sistema de tokens reutilizables que garantiza coherencia, accesibilidad y mantenimiento escalable en todas las plataformas.

| Token | Valor | Uso Principal | Justificación Técnica |
|---|---|---|---|
| Color Primario | #F7C02F (Amarillo Energía) | Botones de acción, encabezados, indicadores de marca | Alta visibilidad, alineado con identidad corporativa |
| Color Secundario | #4CAF50 (Verde Prosperidad) | Confirmaciones, validaciones positivas, métricas financieras | Asociación psicológica con éxito, estabilidad y crecimiento |
| Fondo Base | #FFF9EB (Crema Suave) | Superficies principales, fondos de pantalla | Reduce fatiga visual en sesiones prolongadas de administración |
| Superficie | #FFFFFF (Blanco Puro) | Tarjetas, modales, campos de entrada, contenedores | Contraste óptimo con texto oscuro, jerarquía visual clara |
| Radio de Bordes | 15px / 30px | Contenedores, botones, tarjetas, modales | Elimina agresividad visual, percepción de interfaz amigable |
| Tipografía | Sistema + Google Fonts (Inter/Roboto) | Jerarquía H1-H3, cuerpo, etiquetas, cifras | Legibilidad multiplataforma, pesos optimizados para rendimiento |
| Espaciado | Escala 4pt (4, 8, 12, 16, 24, 32) | Márgenes, padding, gaps entre componentes | Consistencia matemática, adaptación responsive predecible |
| Accesibilidad | Contraste ≥ 4.5:1, targets ≥ 44x44px | Componentes interactivos, enlaces, botones | Cumplimiento WCAG 2.1 AA, navegación táctil y por teclado |

**Estilo Geométrico:** Curvatura controlada, logo centralizado en contenedor circular blanco con borde sutil, alineación a cuadrícula de 8pt, y simetría visual en pantallas de captura y lista.

---

## 2. Estructura de Carpetas y Arquitectura

Organización por capas siguiendo Clean Architecture + BLoC + Inyección de Dependencias. Cada directorio mantiene una responsabilidad única para facilitar pruebas, mantenimiento y escalabilidad.

| Nivel | Carpeta | Responsabilidad | Dependencias Relacionadas |
|---|---|---|---|
| Entrada | `main.dart`, `app.dart` | Inicialización, configuración de DI, tema global, enrutamiento | `get_it`, `injectable`, `flutter_screenutil` |
| Núcleo | `core/` | Constantes, tema, rutas, utilidades, interceptores, validadores globales | `flutter_bloc`, `connectivity_plus`, `intl`, `uuid` |
| Inyección | `core/di/` | Registro de servicios, fábricas, configuración de contenedor DI | `get_it`, `injectable`, `injectable_generator` |
| Datos | `data/local/` | Base de datos Drift/sqflite, DAOs, migraciones, persistencia offline | `drift`, `sqflite`, `path_provider`, `path`, `drift_dev` |
| Datos | `data/remote/` | Clientes HTTP, definiciones Retrofit, interceptores, manejo de red | `dio`, `retrofit`, `retrofit_generator`, `jwt_decoder` |
| Dominio | `domain/entities/` | Objetos de negocio puros, inmutables, independientes de framework | `equatable`, `freezed_annotation`, `freezed` |
| Dominio | `domain/repositories/` | Interfaces abstractas que definen contratos de acceso a datos | `flutter_bloc`, `collection` |
| Dominio | `domain/usecases/` | Casos de uso que orquestan lógica de negocio sin depender de UI/DB | `reactive_forms`, `form_validator` |
| Presentación | `presentation/blocs/` | Gestión de estado reactivo, eventos, streams, mapeo a UI | `flutter_bloc`, `equatable` |
| Presentación | `presentation/screens/` | Vistas de dashboard, captura, lista, configuración, tickets | `flutter_screenutil`, `awesome_dialog`, `fluttertoast` |
| Presentación | `presentation/widgets/` | Componentes reutilizables, tarjetas, loaders, campos formateados | `cached_network_image`, `shimmer`, `barcode_widget` |
| Activos | `assets/` | Imágenes, iconos, fuentes, configuraciones locales, plantillas PDF | `printing`, `pdf`, `qr_flutter` |
| Pruebas | `test/` | Unit, widget, integration, mocks de DI y DB | `flutter_test`, `build_runner`, `json_serializable` |

### Árbol de Carpetas Detallado

```
antigravity_soriana/
│
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   ├── app_spacing.dart
│   │   │   └── app_strings.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── app_decorations.dart
│   │   ├── routes/
│   │   │   ├── app_router.dart
│   │   │   └── app_routes.dart
│   │   ├── utils/
│   │   │   ├── date_formatter.dart
│   │   │   ├── currency_formatter.dart
│   │   │   ├── uuid_generator.dart
│   │   │   └── validators.dart
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart
│   │   │   └── connectivity_interceptor.dart
│   │   └── di/
│   │       ├── injection.dart
│   │       └── injection.config.dart
│   │
│   ├── data/
│   │   ├── local/
│   │   │   ├── database/
│   │   │   │   ├── app_database.dart
│   │   │   │   └── app_database.g.dart
│   │   │   ├── daos/
│   │   │   │   ├── empleado_dao.dart
│   │   │   │   ├── venta_dao.dart
│   │   │   │   ├── producto_dao.dart
│   │   │   │   ├── inventario_dao.dart
│   │   │   │   ├── cliente_dao.dart
│   │   │   │   ├── orden_compra_dao.dart
│   │   │   │   └── promocion_dao.dart
│   │   │   ├── tables/
│   │   │   │   ├── empleado_table.dart
│   │   │   │   ├── datos_empleado_table.dart
│   │   │   │   ├── contador_global_table.dart
│   │   │   │   ├── metadatos_sistema_table.dart
│   │   │   │   ├── venta_table.dart
│   │   │   │   ├── detalle_venta_table.dart
│   │   │   │   ├── devolucion_table.dart
│   │   │   │   ├── caja_registradora_table.dart
│   │   │   │   ├── cliente_table.dart
│   │   │   │   ├── tarjeta_lealtad_table.dart
│   │   │   │   ├── movimiento_puntos_table.dart
│   │   │   │   ├── producto_table.dart
│   │   │   │   ├── categoria_table.dart
│   │   │   │   ├── proveedor_table.dart
│   │   │   │   ├── precio_historico_table.dart
│   │   │   │   ├── inventario_table.dart
│   │   │   │   ├── orden_compra_table.dart
│   │   │   │   ├── detalle_orden_table.dart
│   │   │   │   ├── lote_table.dart
│   │   │   │   ├── sucursal_table.dart
│   │   │   │   ├── departamento_table.dart
│   │   │   │   ├── promocion_table.dart
│   │   │   │   └── producto_promocion_table.dart
│   │   │   └── migrations/
│   │   │       ├── migration_v1.dart
│   │   │       └── migration_v2.dart
│   │   ├── remote/
│   │   │   ├── api/
│   │   │   │   ├── soriana_api.dart
│   │   │   │   └── soriana_api.g.dart
│   │   │   ├── dto/
│   │   │   │   ├── empleado_dto.dart
│   │   │   │   ├── venta_dto.dart
│   │   │   │   ├── producto_dto.dart
│   │   │   │   └── cliente_dto.dart
│   │   │   └── datasources/
│   │   │       ├── empleado_remote_ds.dart
│   │   │       ├── venta_remote_ds.dart
│   │   │       └── producto_remote_ds.dart
│   │   └── repositories/
│   │       ├── empleado_repository_impl.dart
│   │       ├── venta_repository_impl.dart
│   │       ├── producto_repository_impl.dart
│   │       ├── inventario_repository_impl.dart
│   │       ├── cliente_repository_impl.dart
│   │       └── orden_compra_repository_impl.dart
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── empleado.dart
│   │   │   ├── datos_empleado.dart
│   │   │   ├── contador_global.dart
│   │   │   ├── metadatos_sistema.dart
│   │   │   ├── venta.dart
│   │   │   ├── detalle_venta.dart
│   │   │   ├── devolucion.dart
│   │   │   ├── caja_registradora.dart
│   │   │   ├── cliente.dart
│   │   │   ├── tarjeta_lealtad.dart
│   │   │   ├── movimiento_puntos.dart
│   │   │   ├── producto.dart
│   │   │   ├── categoria.dart
│   │   │   ├── proveedor.dart
│   │   │   ├── precio_historico.dart
│   │   │   ├── inventario.dart
│   │   │   ├── orden_compra.dart
│   │   │   ├── detalle_orden.dart
│   │   │   ├── lote.dart
│   │   │   ├── sucursal.dart
│   │   │   ├── departamento.dart
│   │   │   ├── promocion.dart
│   │   │   └── producto_promocion.dart
│   │   ├── repositories/
│   │   │   ├── i_empleado_repository.dart
│   │   │   ├── i_venta_repository.dart
│   │   │   ├── i_producto_repository.dart
│   │   │   ├── i_inventario_repository.dart
│   │   │   ├── i_cliente_repository.dart
│   │   │   └── i_orden_compra_repository.dart
│   │   └── usecases/
│   │       ├── empleado/
│   │       │   ├── registrar_empleado.dart
│   │       │   ├── obtener_empleados.dart
│   │       │   └── actualizar_empleado.dart
│   │       ├── venta/
│   │       │   ├── procesar_venta.dart
│   │       │   ├── cancelar_venta.dart
│   │       │   └── obtener_historial_ventas.dart
│   │       ├── producto/
│   │       │   ├── buscar_producto.dart
│   │       │   ├── escanear_codigo.dart
│   │       │   └── actualizar_precio.dart
│   │       ├── inventario/
│   │       │   ├── verificar_stock.dart
│   │       │   └── generar_orden_reabasto.dart
│   │       └── cliente/
│   │           ├── registrar_cliente.dart
│   │           ├── acumular_puntos.dart
│   │           └── canjear_puntos.dart
│   │
│   └── presentation/
│       ├── blocs/
│       │   ├── empleado/
│       │   │   ├── empleado_bloc.dart
│       │   │   ├── empleado_event.dart
│       │   │   └── empleado_state.dart
│       │   ├── venta/
│       │   │   ├── venta_bloc.dart
│       │   │   ├── venta_event.dart
│       │   │   └── venta_state.dart
│       │   ├── producto/
│       │   │   ├── producto_bloc.dart
│       │   │   ├── producto_event.dart
│       │   │   └── producto_state.dart
│       │   ├── inventario/
│       │   │   ├── inventario_bloc.dart
│       │   │   ├── inventario_event.dart
│       │   │   └── inventario_state.dart
│       │   ├── cliente/
│       │   │   ├── cliente_bloc.dart
│       │   │   ├── cliente_event.dart
│       │   │   └── cliente_state.dart
│       │   └── auth/
│       │       ├── auth_bloc.dart
│       │       ├── auth_event.dart
│       │       └── auth_state.dart
│       ├── screens/
│       │   ├── auth/
│       │   │   ├── login_screen.dart
│       │   │   └── biometria_screen.dart
│       │   ├── dashboard/
│       │   │   └── dashboard_screen.dart
│       │   ├── venta/
│       │   │   ├── punto_venta_screen.dart
│       │   │   ├── carrito_screen.dart
│       │   │   └── pago_screen.dart
│       │   ├── producto/
│       │   │   ├── catalogo_screen.dart
│       │   │   └── detalle_producto_screen.dart
│       │   ├── inventario/
│       │   │   ├── inventario_screen.dart
│       │   │   └── orden_compra_screen.dart
│       │   ├── cliente/
│       │   │   ├── clientes_screen.dart
│       │   │   └── lealtad_screen.dart
│       │   ├── empleado/
│       │   │   ├── empleados_screen.dart
│       │   │   └── registro_empleado_screen.dart
│       │   ├── reportes/
│       │   │   ├── reportes_screen.dart
│       │   │   └── graficas_screen.dart
│       │   └── configuracion/
│       │       └── configuracion_screen.dart
│       └── widgets/
│           ├── common/
│           │   ├── app_button.dart
│           │   ├── app_text_field.dart
│           │   ├── app_card.dart
│           │   ├── app_loader.dart
│           │   └── app_shimmer.dart
│           ├── venta/
│           │   ├── producto_card.dart
│           │   ├── carrito_item.dart
│           │   └── ticket_preview.dart
│           ├── dashboard/
│           │   ├── metrica_card.dart
│           │   └── grafica_ventas.dart
│           └── scanner/
│               └── barcode_scanner_widget.dart
│
├── assets/
│   ├── images/
│   │   └── logo_soriana.png
│   ├── icons/
│   ├── fonts/
│   │   ├── Inter-Regular.ttf
│   │   ├── Inter-Medium.ttf
│   │   └── Inter-Bold.ttf
│   └── templates/
│       └── ticket_template.dart
│
├── test/
│   ├── unit/
│   │   ├── usecases/
│   │   ├── repositories/
│   │   └── validators/
│   ├── widget/
│   │   ├── screens/
│   │   └── widgets/
│   └── integration/
│       └── flows/
│
└── pubspec.yaml
```

---

## 3. Entidades y Modelo de Datos (Numeradas)

Estructura conceptual alineada al motor de datos y a la capa de dominio. Diseñada para persistencia relacional local (Drift/sqflite) y exposición reactiva mediante BLoC.

| # | Entidad / Tabla | Campos Estructurales | Propósito en el Negocio | Estrategia de Persistencia |
|---|---|---|---|---|
| 1 | `Empleado` | `id`, `nombreCompleto`, `puesto`, `salario`, `codigoBarra`, `fechaRegistro`, `activo` | Unidad mínima de nómina y operación. Centraliza identidad, rol y remuneración. | Entidad inmutable en dominio. Tabla relacional local con índices por ID y código. |
| 2 | `datosEmpleado` | `empleadoId` (FK), `tipoOperacion`, `monto`, `timestamp`, `referenciaTicket`, `usuarioAuditor` | Historial de movimientos por empleado. Base para reportes, nómina y auditoría. | Tabla relacional con relación 1:N hacia `Empleado`. Indexada por fecha y empleado. |
| 3 | `ContadorGlobal` | `nombreSecuencia`, `ultimoValor`, `prefijo`, `resetFecha`, `bloqueado` | Generador incremental de identidad. Garantiza unicidad y orden cronológico estricto. | Tabla de configuración con acceso atómico. Actualizado vía transacción Drift. |
| 4 | `MetadatosSistema` | `versionEsquema`, `totalRegistros`, `masaSalarial`, `ultimaSincronizacion`, `modoOperativo` | Panel de control interno para métricas rápidas, validación de integridad y estado offline/online. | Vista materializada o consulta agregada. No se modifica directamente, se recalcula bajo demanda. |
| 5 | `VENTA` | `id`, `sucursal`, `cliente`, `cajero`, `caja`, `fechaHora`, `subtotal`, `iva`, `total`, `metodoPago`, `estatus`, `folioTicket` | Registro transaccional central del punto de venta. | Tabla central con FK hacia Sucursal, Cliente y Empleado. |
| 6 | `DETALLE_VENTA` | `id`, `venta`, `producto`, `cantidad`, `precioUnitario`, `descuento`, `importe`, `promocion` | Renglones de cada venta procesada. | Tabla 1:N hacia Venta, indexada por producto. |
| 7 | `DEVOLUCION` | `id`, `ventaOrigen`, `producto`, `cajero`, `cantidad`, `motivo`, `montoReembolso`, `fechaHora`, `tipoReembolso` | Gestión de devoluciones y reembolsos con trazabilidad completa. | Tabla vinculada a Venta original. |
| 8 | `CAJA_REGISTRADORA` | `id`, `sucursal`, `numeroCaja`, `estatus`, `tipo` | Control de terminales POS activas por sucursal. | Tabla con FK hacia Sucursal. |
| 9 | `CLIENTE` | `id`, `nombre`, `email`, `telefono`, `fechaNacimiento`, `genero`, `codigoPostal`, `segmento`, `fechaRegistro`, `activo` | Gestión del perfil del comprador y segmentación. | Tabla con índice único en email. |
| 10 | `TARJETA_LEALTAD` | `id`, `cliente`, `numeroTarjeta`, `puntosAcumulados`, `puntosCanjeados`, `nivel`, `fechaEmision`, `fechaVencimiento`, `estatus` | Programa Club Soriana, acumulación y canje de puntos. | Tabla 1:1 con Cliente, índice único en numeroTarjeta. |
| 11 | `MOVIMIENTO_PUNTOS` | `id`, `tarjeta`, `venta`, `tipo`, `puntos`, `saldoAnterior`, `saldoPosterior`, `fechaHora` | Trazabilidad completa del saldo de puntos por movimiento. | Tabla 1:N hacia TarjetaLealtad, inmutable. |
| 12 | `PRODUCTO` | `id`, `codigoBarras`, `nombre`, `descripcion`, `categoria`, `proveedor`, `precioVenta`, `precioCosto`, `unidadMedida`, `pesoNeto`, `marca`, `activo`, `esPerecedero` | Catálogo maestro de productos disponibles. | Tabla con índice único en codigoBarras. |
| 13 | `CATEGORIA` | `id`, `nombre`, `categoriaPadre`, `nivel`, `descripcion`, `activo` | Jerarquía de clasificación de productos por departamento. | Tabla autorreferenciada con índice en categoriaPadre. |
| 14 | `PROVEEDOR` | `id`, `razonSocial`, `rfc`, `nombreContacto`, `telefono`, `email`, `direccion`, `condicionesPago`, `activo` | Gestión de proveedores y condiciones comerciales. | Tabla con índice único en RFC. |
| 15 | `PRECIO_HISTORICO` | `id`, `producto`, `precio`, `fechaInicio`, `fechaFin`, `motivoCambio` | Auditoría y trazabilidad de cambios de precio. | Tabla 1:N hacia Producto, inmutable. |
| 16 | `INVENTARIO` | `id`, `producto`, `sucursal`, `stockActual`, `stockMinimo`, `stockMaximo`, `ubicacionPasillo`, `fechaUltimaEntrada`, `fechaUltimoConteo` | Control de existencias y puntos de reorden por sucursal. | Tabla con índice compuesto producto+sucursal. |
| 17 | `ORDEN_COMPRA` | `id`, `proveedor`, `sucursal`, `empleado`, `fechaOrden`, `fechaEntregaEst`, `fechaEntregaReal`, `estatus`, `total`, `notas` | Ciclo de reabastecimiento con proveedores. | Tabla con FK hacia Proveedor y Sucursal. |
| 18 | `DETALLE_ORDEN` | `id`, `orden`, `producto`, `cantidadSolicitada`, `cantidadRecibida`, `precioCompra`, `importe` | Renglones de cada orden de compra emitida. | Tabla 1:N hacia OrdenCompra. |
| 19 | `LOTE` | `id`, `producto`, `sucursal`, `orden`, `numeroLote`, `fechaFabricacion`, `fechaCaducidad`, `cantidadInicial`, `cantidadActual` | Control de caducidad en productos perecederos. | Tabla con índice en fechaCaducidad. |
| 20 | `SUCURSAL` | `id`, `nombre`, `formato`, `calle`, `colonia`, `ciudad`, `estado`, `codigoPostal`, `telefono`, `region`, `metrosCuadrados`, `fechaApertura`, `activo` | Unidad operativa física de la cadena comercial. | Tabla raíz del modelo organizacional. |
| 21 | `DEPARTAMENTO` | `id`, `nombre`, `sucursal`, `responsable`, `activo` | Organización interna por área dentro de la sucursal. | Tabla con FK hacia Sucursal y Empleado. |
| 22 | `PROMOCION` | `id`, `nombre`, `descripcion`, `tipo`, `valor`, `fechaInicio`, `fechaFin`, `aplicaTarjeta`, `activo` | Campañas y ofertas comerciales por temporada. | Tabla con índice en fechas de vigencia. |
| 23 | `PRODUCTO_PROMOCION` | `idProducto`, `idPromocion`, `idSucursal`, `precioPromocional` | Relación producto-oferta aplicable por sucursal. | Tabla pivote con PK compuesta. |

---

## 4. Dependencias (`pubspec.yaml`)

```yaml
name: antigravity_soriana
description: Ecosistema de punto de venta móvil para Soriana - Clean Architecture + BLoC
version: 1.0.0+1
publish_to: none

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter

  # 1. Base y Estado
  flutter_bloc: ^8.1.3        # Gestión de estado reactivo, eventos y streams
  equatable: ^2.0.5           # Comparación eficiente de objetos en BLoC/estados
  get_it: ^7.6.4              # Contenedor de inyección de dependencias
  injectable: ^2.3.2          # Generación automática de anotaciones DI

  # 2. Base de Datos Local
  sqflite: ^2.3.0             # Motor SQLite nativo para persistencia estructural
  drift: ^2.14.1              # ORM seguro y tipado sobre SQLite
  path_provider: ^2.1.1       # Resolución de rutas de almacenamiento nativas
  path: ^1.8.3                # Manipulación segura de rutas y archivos

  # 3. Red y API
  dio: ^5.4.0                 # Cliente HTTP avanzado con interceptores
  retrofit: ^4.1.0            # Generación de clientes REST tipados
  connectivity_plus: ^5.0.2   # Detección de estado de red en tiempo real

  # 4. Autenticación y Seguridad
  flutter_secure_storage: ^9.0.0  # Almacenamiento cifrado de tokens y credenciales
  local_auth: ^2.1.7              # Biometría nativa (huella/rostro)
  jwt_decoder: ^2.0.1             # Decodificación y validación de tokens JWT

  # 5. Lector de Código de Barras
  mobile_scanner: ^3.5.5      # Escaneo nativo de QR y códigos de producto
  barcode_widget: ^2.0.3      # Renderizado de códigos para etiquetas y tickets

  # 6. Impresión de Tickets
  bluetooth_print: ^4.2.0     # Comunicación con impresoras térmicas vía Bluetooth
  esc_pos_utils: ^1.1.0       # Generación de comandos ESC/POS para tickets
  pdf: ^3.10.7                # Construcción de documentos PDF programáticos
  printing: ^5.11.1           # Vista previa y envío a impresoras/sistemas nativos

  # 7. UI y Componentes
  flutter_screenutil: ^5.9.0      # Adaptación responsiva por densidad y pantalla
  cached_network_image: ^3.3.0    # Descarga, cacheo y optimización de imágenes
  shimmer: ^3.0.0                 # Indicadores de carga progresiva (skeletons)
  fluttertoast: ^8.2.4            # Mensajes ligeros de confirmación o error
  awesome_dialog: ^3.1.0          # Modales y diálogos estructurados con acciones

  # 8. Formularios y Validación
  reactive_forms: ^16.1.1     # Gestión declarativa de formularios complejos
  form_validator: ^2.1.1      # Reglas de validación reutilizables y tipadas

  # 9. Pagos y Facturación
  stripe_flutter: ^10.1.0     # Integración de pasarela de pagos segura
  qr_flutter: ^4.1.0          # Generación de códigos QR para cobros o referencias

  # 10. Utilidades
  intl: ^0.19.0               # Formato de fechas, monedas y localización
  uuid: ^4.3.3                # Generación de identificadores únicos universales
  shared_preferences: ^2.2.2  # Persistencia ligera de configuraciones
  collection: ^1.18.0         # Operaciones avanzadas sobre listas y mapas
  freezed_annotation: ^2.4.1  # Anotaciones para inmutabilidad y serialización

  # 11. Gráficas y Reportes
  fl_chart: ^0.66.2                     # Visualización ligera de métricas y tendencias
  syncfusion_flutter_charts: ^24.1.41   # Gráficas empresariales de alto rendimiento

dev_dependencies:
  flutter_test:
    sdk: flutter

  # 12. Generadores de Código
  build_runner: ^2.4.8            # Ejecución centralizada de generadores
  injectable_generator: ^2.4.1    # Producción automática de registro DI
  retrofit_generator: ^8.1.0      # Creación de clientes HTTP desde anotaciones
  freezed: ^2.4.6                 # Inmutabilidad, unión tipada y copyWith
  drift_dev: ^2.14.1              # Compilación de esquemas y consultas Drift
  json_serializable: ^6.7.1       # Mapeo automático JSON ↔ Dart objects

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/icons/
    - assets/fonts/
    - assets/templates/

  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

---

## 5. Gestión de Estado y Lógica de Negocio (BLoC + Agente)

El concepto del "Agente" se formaliza mediante una capa de Casos de Uso + Repositorios + BLoC, garantizando flujo unidireccional, inmutabilidad y desacople total.

| Capa | Responsabilidad | Flujo de Ejecución | Manejo de Errores |
|---|---|---|---|
| Presentación (BLoC) | Escucha eventos, emite estados, orquesta UI | `Evento → BLoC → Caso de Uso → Repositorio → Estado` | Estados de `Loading`, `Success`, `Failure` con mensajes tipados |
| Dominio (UseCase) | Aplica reglas de negocio, valida límites operativos | Recepción limpia → Validación → Ejecución → Retorno puro | Excepciones de negocio capturadas y mapeadas a fallos controlados |
| Datos (Repository) | Abstrae fuente de datos (local/remote) | Selección de estrategia → Consulta/Inserción → Mapeo a entidad | Fallback offline, reintentos, registro de fallos estructurados |
| Inyección (GetIt) | Resuelve dependencias en tiempo de ejecución | Registro en `main` → Resolución automática por anotaciones | Fallos de inicialización detectados en fase de arranque |

---

## 6. Cronograma de Implementación (Fases Técnicas)

| Fase | Duración | Entregables | Criterio de Cierre |
|---|---|---|---|
| 1. Configuración Base | 2-3 días | Estructura de carpetas, tema global, rutas, tokens, DI base | `flutter analyze` limpio, compilación en 4 plataformas |
| 2. Motor de Datos | 3-4 días | Esquema Drift, entidades, contenedor de secuencias, migraciones | Pruebas unitarias de esquema, inserción atómica validada |
| 3. Red y Escáner | 3-4 días | Clientes HTTP, interceptor de red, integración `mobile_scanner` | Decodificación de códigos, manejo de desconexión, logs estructurados |
| 4. Lógica y Estado | 5-6 días | Casos de uso, repositorios, BLoC, validadores de formulario | Flujo completo sin fugas, estados inmutables, DI funcional |
| 5. Interfaz y Pagos | 6-7 días | Screens, widgets adaptativos, `reactive_forms`, `stripe`, impresión | Responsive validado, tickets generados, pagos simulados/exitosos |
| 6. Pruebas y Release | 4-5 días | Cobertura de tests, profiling, builds firmados, documentación | ≥ 75% cobertura, sin warnings críticos, checklist de despliegue |

---

## 7. Criterios de Validación y Calidad

| Tipo de Prueba | Alcance | Herramienta | Métrica de Éxito |
|---|---|---|---|
| Unitarias | Validadores, generación de ID, casos de uso, mapeos | `flutter_test`, `mockito`/`mocktail` | 100% cobertura de reglas de negocio, ejecución determinista |
| Widget | Formularios, tarjetas, loaders, diálogos | `flutter_test` | Interacciones correctas, rebuilds controlados, sin parpadeos |
| Integración | Flujo: captura → validación → DB → lista → ticket | `integration_test` | Ejecución estable en dispositivo real, datos persistidos |
| Rendimiento | Consumo RAM, FPS, tiempo de respuesta DB/UI | DevTools Profiler | ≥ 55 FPS, pico RAM < 200MB, consulta < 30ms |
| Seguridad | Almacenamiento cifrado, tokens, biometría | `flutter_secure_storage`, `local_auth` | Sin exposición de credenciales en logs o memoria volátil |
| Accesibilidad | Contraste, navegación, escalado, semántica | Accessibility Inspector | Cumplimiento WCAG 2.1 AA, targets ≥ 44x44px |

---

## 8. Notas Arquitectónicas y Buenas Prácticas

- Separación estricta entre presentación, dominio y datos. La UI nunca accede directamente a la base de datos ni a clientes HTTP.
- El diccionario `datosEmpleado` se reemplaza conceptualmente por consultas indexadas en Drift, manteniendo acceso O(log n) y trazabilidad relacional.
- Todos los estados BLoC deben ser inmutables (`freezed`) y comparables (`equatable`) para evitar rebuilds innecesarios.
- La inyección de dependencias (`get_it` + `injectable`) centraliza el ciclo de vida de repositorios, servicios y casos de uso.
- Preparar estructura para futura sincronización en la nube manteniendo interfaces abstractas en `domain/repositories/`.
- Documentar cada decisión arquitectónica (ADR), versionar esquemas de base de datos y mantener registro de cambios en tokens visuales.

---

**Próximo entregable recomendado:** Matriz de validaciones por campo del formulario, diagrama de flujo de estados BLoC para el ciclo de captura/almacenamiento, o especificación de generación de tickets ESC/POS + PDF. Indique cuál requiere prioridad para continuar con la fase de desarrollo.

# PROMT 

Actúa como Arquitecto Senior y Desarrollador Experto en Flutter/Dart. Tu misión es implementar el sistema "Antigravity" para Soriana Vania, siguiendo estrictamente este Plan de Implementación Técnica:

🎨 1. ADN Visual y UI (Tokens de Diseño)
Colores: Primario #F7C02F (Amarillo Energía), Secundario #4CAF50 (Verde Prosperidad), Fondo #FFF9EB (Crema Suave).

Estética: Bordes ultra redondeados (BorderRadius de 15 a 30).

Identidad: Logo obligatorio desde URL en CircleAvatar blanco: https://raw.githubusercontent.com/Antonio347Vania/im-genes-para-flutter-6toI-11-Feb-2026/refs/heads/main/logo.jpg.

Componentes: Uso de app_bar personalizado, tarjetas con elevación sutil y botones con el estilo de marca.

🏗️ 2. Arquitectura de Archivos y Código
Debes estructurar el proyecto bajo una lógica de Clean Architecture simplificada:

lib/main.dart: Enrutamiento nombrado (/, /captura, /lista) y tema global.

lib/inicio.dart: Dashboard principal.

lib/capturaempleados.dart: Formulario reactivo.

lib/verempleados.dart: ListView optimizado.

Persistencia: Archivo diccionarioempleado.dart con un Map<int, Empleado> datosEmpleado y un contador global.

Lógica de Escritura: Clase GuardarDatosAgente en guardardatosdiccionario.dart.

📊 3. Entidad de Negocio
Clase Empleado con:

int id (Autonumérico).

String nombre.

String puesto.

double salario.

🛠️ 4. Reglas de Ejecución
Código Completo: Cada vez que solicite una pantalla, genera el código íntegro del archivo, listo para copiar y pegar.

Ubicación Exacta: Especifica la ruta de la carpeta donde debe vivir el archivo dentro de la estructura lib/.

Estilo de Respuesta: Directo, ingenioso, peer-to-peer. Evita rollos teóricos innecesarios. No uses LaTeX para texto plano; solo para fórmulas matemáticas si llegáramos a necesitarlas.

Prioridad: Funcionalidad inmediata sobre abstracciones complejas.
