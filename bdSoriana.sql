-- =============================================
-- Proyecto: Antigravity - Soriana Vania
-- Script: bdSoriana.sql
-- Descripción: Modelo relacional para Retail de gran escala
-- =============================================

CREATE DATABASE IF NOT EXISTS bdSoriana;
USE bdSoriana;

-- -----------------------------------------------------
-- DOMINIO: ORGANIZACIÓN
-- -----------------------------------------------------

CREATE TABLE SUCURSAL (
    id_sucursal INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    formato ENUM('Hiper', 'Súper', 'Mercado', 'City') NOT NULL,
    calle VARCHAR(150) NOT NULL,
    ciudad VARCHAR(80) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    codigo_postal CHAR(5) NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE DEPARTAMENTO (
    id_departamento INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    id_sucursal INT NOT NULL,
    CONSTRAINT fk_dept_sucursal FOREIGN KEY (id_sucursal) REFERENCES SUCURSAL(id_sucursal)
);

CREATE TABLE EMPLEADO (
    id_empleado INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    curp CHAR(18) UNIQUE,
    rfc VARCHAR(13) UNIQUE,
    puesto VARCHAR(80) NOT NULL,
    id_departamento INT NOT NULL,
    id_sucursal INT NOT NULL,
    salario DECIMAL(10,2),
    fecha_ingreso DATE NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_emp_dept FOREIGN KEY (id_departamento) REFERENCES DEPARTAMENTO(id_departamento),
    CONSTRAINT fk_emp_sucursal FOREIGN KEY (id_sucursal) REFERENCES SUCURSAL(id_sucursal)
);

-- -----------------------------------------------------
-- DOMINIO: CATÁLOGO Y PROVEEDORES
-- -----------------------------------------------------

CREATE TABLE CATEGORIA (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    id_categoria_padre INT,
    nivel TINYINT NOT NULL,
    CONSTRAINT fk_cat_padre FOREIGN KEY (id_categoria_padre) REFERENCES CATEGORIA(id_categoria)
);

CREATE TABLE PROVEEDOR (
    id_proveedor INT PRIMARY KEY AUTO_INCREMENT,
    razon_social VARCHAR(150) NOT NULL,
    rfc VARCHAR(13) UNIQUE NOT NULL,
    contacto VARCHAR(100),
    telefono VARCHAR(15),
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE PRODUCTO (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    codigo_barras VARCHAR(20) UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    id_categoria INT NOT NULL,
    id_proveedor INT NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    precio_costo DECIMAL(10,2) NOT NULL,
    unidad_medida ENUM('Pieza', 'kg', 'Litro', 'Caja') NOT NULL,
    es_perecedero BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_prod_cat FOREIGN KEY (id_categoria) REFERENCES CATEGORIA(id_categoria),
    CONSTRAINT fk_prod_prov FOREIGN KEY (id_proveedor) REFERENCES PROVEEDOR(id_proveedor)
);

-- -----------------------------------------------------
-- DOMINIO: CLIENTES Y LEALTAD (Club Soriana)
-- -----------------------------------------------------

CREATE TABLE CLIENTE (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE,
    codigo_postal CHAR(5),
    fecha_registro DATE NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE TARJETA_LEALTAD (
    id_tarjeta INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    numero_tarjeta CHAR(16) UNIQUE NOT NULL,
    puntos_acumulados INT DEFAULT 0,
    nivel ENUM('Básico', 'Silver', 'Gold', 'Platinum') NOT NULL,
    estatus ENUM('Activa', 'Bloqueada', 'Vencida') NOT NULL,
    CONSTRAINT fk_tarjeta_cliente FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
);

-- -----------------------------------------------------
-- DOMINIO: PUNTO DE VENTA (Transaccional)
-- -----------------------------------------------------

CREATE TABLE CAJA_REGISTRADORA (
    id_caja INT PRIMARY KEY AUTO_INCREMENT,
    id_sucursal INT NOT NULL,
    numero_caja TINYINT NOT NULL,
    tipo ENUM('Regular', 'Express', 'Autoservicio') NOT NULL,
    CONSTRAINT fk_caja_sucursal FOREIGN KEY (id_sucursal) REFERENCES SUCURSAL(id_sucursal)
);

CREATE TABLE VENTA (
    id_venta INT PRIMARY KEY AUTO_INCREMENT,
    id_sucursal INT NOT NULL,
    id_cliente INT,
    id_cajero INT NOT NULL,
    id_caja INT NOT NULL,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(12,2) NOT NULL,
    iva DECIMAL(12,2) NOT NULL,
    total DECIMAL(12,2) NOT NULL,
    metodo_pago ENUM('Efectivo', 'Tarjeta', 'Puntos', 'Mixto') NOT NULL,
    folio_ticket VARCHAR(30) UNIQUE,
    CONSTRAINT fk_venta_sucursal FOREIGN KEY (id_sucursal) REFERENCES SUCURSAL(id_sucursal),
    CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente),
    CONSTRAINT fk_venta_cajero FOREIGN KEY (id_cajero) REFERENCES EMPLEADO(id_empleado),
    CONSTRAINT fk_venta_caja FOREIGN KEY (id_caja) REFERENCES CAJA_REGISTRADORA(id_caja)
);

CREATE TABLE DETALLE_VENTA (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad DECIMAL(10,3) NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    importe DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_det_venta FOREIGN KEY (id_venta) REFERENCES VENTA(id_venta),
    CONSTRAINT fk_det_prod FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto)
);

-- -----------------------------------------------------
-- DOMINIO: INVENTARIO Y ABASTO
-- -----------------------------------------------------

CREATE TABLE INVENTARIO (
    id_inventario INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    id_sucursal INT NOT NULL,
    stock_actual DECIMAL(10,3) NOT NULL,
    stock_minimo DECIMAL(10,3) NOT NULL,
    stock_maximo DECIMAL(10,3) NOT NULL,
    CONSTRAINT fk_inv_prod FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto),
    CONSTRAINT fk_inv_sucursal FOREIGN KEY (id_sucursal) REFERENCES SUCURSAL(id_sucursal)
);

CREATE TABLE ORDEN_COMPRA (
    id_orden INT PRIMARY KEY AUTO_INCREMENT,
    id_proveedor INT NOT NULL,
    id_sucursal INT NOT NULL,
    fecha_orden DATE NOT NULL,
    estatus ENUM('Pendiente', 'Enviada', 'Recibida', 'Cancelada') NOT NULL,
    total DECIMAL(14,2) NOT NULL,
    CONSTRAINT fk_orden_prov FOREIGN KEY (id_proveedor) REFERENCES PROVEEDOR(id_proveedor),
    CONSTRAINT fk_orden_sucursal FOREIGN KEY (id_sucursal) REFERENCES SUCURSAL(id_sucursal)
);
