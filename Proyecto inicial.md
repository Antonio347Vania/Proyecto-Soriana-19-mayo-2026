*Actúa como un administrador de base de datos: proyecto Soriana, que entidades se necesitan para su gestion**
<img width="727" height="390" alt="image" src="https://github.com/user-attachments/assets/ed06df16-f2a9-4253-ad8f-2f9131a5725f" />


Para el proyecto Soriana (cadena de supermercados), aquí están las entidades clave. Dado que es un retail de gran escala, el modelo abarca desde la cadena de suministro hasta la experiencia del cliente.Las entidades se agrupan en 5 dominios principales:

**Punto de venta:** `VENTA` y `DETALLE_VENTA` son el núcleo transaccional. Cada ticket registra sucursal, cajero, cliente (opcional) y método de pago.

**Clientes y lealtad:** `CLIENTE` y `TARJETA_LEALTAD` gestionan el programa Club Soriana — acumulación de puntos, historial de compras y segmentación.

**Catálogo de productos:** `PRODUCTO`, `CATEGORIA` (con jerarquía padre-hijo para agrupar perecederos, electrónica, ropa, etc.) y `PROVEEDOR`.

**Inventario y abasto:** `INVENTARIO` controla el stock por sucursal con niveles mínimos y máximos. Las `ORDEN_COMPRA` y su detalle cierran el ciclo de reabastecimiento con proveedores.

**Estructura organizacional:** `SUCURSAL` (con campo `formato` para distinguir Hiper, Súper, Mercado, City) y `DEPARTAMENTO` para la gestión de `EMPLEADOS`.

**Entidades complementarias a considerar según el alcance del proyecto:**
- `CAJA_REGISTRADORA` — si se necesita trazabilidad por terminal
- `LOTE` / `CADUCIDAD` — para perecederos con control de fecha
- `DEVOLUCION` — gestión de devoluciones y cambios
- `PRESUPUESTO_DEPARTAMENTO` — si el sistema incluye finanzas
- `AUDITORIA_INVENTARIO` — para registrar conteos físicos periódicos

¿Quieres profundizar en algún dominio específico, como el modelo de lealtad, la gestión de inventario o el esquema de precios y promociones?

**Las entidades con sus atributos y tipo en forma de tabla para cada una de las entidades**
<img width="737" height="458" alt="image" src="https://github.com/user-attachments/assets/ff91a688-b2ca-4760-9c5b-85c06883cb71" />
<img width="749" height="661" alt="image" src="https://github.com/user-attachments/assets/e4468543-19e2-4f49-8619-cd9167bafec3" />
<img width="737" height="657" alt="image" src="https://github.com/user-attachments/assets/dd46c27b-9213-44ca-a395-e01d59242005" />
<img width="754" height="663" alt="image" src="https://github.com/user-attachments/assets/162f8eb7-9f5e-4a86-897e-1e17fa1d7de0" />
<img width="752" height="504" alt="image" src="https://github.com/user-attachments/assets/b0ed448a-7f76-436b-8f37-6bf42b530b3e" />
<img width="742" height="588" alt="image" src="https://github.com/user-attachments/assets/7c2123e0-0e56-408a-9f6f-b42f191f4cab" />
<img width="742" height="653" alt="image" src="https://github.com/user-attachments/assets/8ce57574-88e4-45d4-a955-f3bf9d585d1f" />
<img width="733" height="652" alt="image" src="https://github.com/user-attachments/assets/022a4a65-4aac-4261-99fb-4fc2ff37990b" />
<img width="738" height="351" alt="image" src="https://github.com/user-attachments/assets/3a01f97f-f53b-45a2-8ed6-449e4cc5ae94" />
<img width="734" height="509" alt="image" src="https://github.com/user-attachments/assets/4a178aad-6066-4de3-9723-32f0b9e1185f" />
<img width="761" height="668" alt="image" src="https://github.com/user-attachments/assets/6ae4bb02-c53c-4250-9944-7a5b164dee8d" />
<img width="753" height="595" alt="image" src="https://github.com/user-attachments/assets/1f0f6f92-257a-45e0-8691-ca29565ac06d" />



**deacuerdo a tu respuesta anterior puedes generar un script en sql para descargar con el nombre de bdSoriana.sql para las entidades relacionadas**
Script completo bdsoriana.sql
