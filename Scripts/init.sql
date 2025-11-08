CREATE DATABASE SistemaDeLibreria
GO

USE SistemaDeLibreria
GO

CREATE TABLE Usuario (
    Usuario_ID INT PRIMARY KEY IDENTITY,
    NombreUsuario VARCHAR(100) UNIQUE,
    Contraseña VARCHAR(100),
    Salt VARBINARY(64),
    FechaRegistro DATETIME
);

CREATE TABLE Rol (
    Rol_ID INT PRIMARY KEY IDENTITY,
    NombreRol VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(100),
    Activo BIT DEFAULT 1,
    FechaRegistro DATETIME
);

CREATE TABLE UsuarioRol (
    UsuarioRol_ID INT PRIMARY KEY IDENTITY,
    Usuario_ID INT,
    Rol_ID INT,
    FechaAsignacion DATETIME,
    FOREIGN KEY (Usuario_ID) REFERENCES Usuario(Usuario_ID),
    FOREIGN KEY (Rol_ID) REFERENCES Rol(Rol_ID)
);

CREATE TABLE Clientes (
    Cliente_ID INT PRIMARY KEY IDENTITY,
    Nombre VARCHAR(100),
    Apellido VARCHAR(100) NULL,
    Direccion VARCHAR(255) NULL,
    Telefono VARCHAR(50) NULL,
    Email VARCHAR(100) NULL,
    Activo BIT DEFAULT 1,
    FechaRegistro DATETIME DEFAULT GETDATE()
);

CREATE TABLE Proveedores (
    Proveedor_ID INT PRIMARY KEY IDENTITY,
    NombreEmpresa VARCHAR(255),
    Direccion VARCHAR(255),
    Telefono VARCHAR(50),
    Email VARCHAR(100),
    AceptaDevoluciones BIT DEFAULT 0,
    TiempoDevolucion INT DEFAULT 15,
    PorcentajeCobertura DECIMAL(5,2) DEFAULT 0
);

CREATE TABLE Marcas (
    Marca_ID INT PRIMARY KEY IDENTITY,
    NombreMarca VARCHAR(100),
    Activo BIT,
    FechaRegistro DATETIME
);

CREATE TABLE Categorias (
    Categoria_ID INT PRIMARY KEY IDENTITY,
    NombreCategoria VARCHAR(100),
    Descripcion VARCHAR(100),
    Activo BIT,
    FechaRegistro DATETIME
);

CREATE TABLE Productos (
    Producto_ID INT PRIMARY KEY IDENTITY,
    Marca_ID INT,
    Categoria_ID INT,
    Codigo INT,
    NombreProducto VARCHAR(100) UNIQUE,
    UnidadMedida VARCHAR(20) DEFAULT 'UNIDAD',
    CapacidadUnidad INT DEFAULT 1,
    Cantidad INT DEFAULT 0,
    Activo BIT,
    FechaRegistro DATETIME,
    FOREIGN KEY (Marca_ID) REFERENCES Marcas(Marca_ID),
    FOREIGN KEY (Categoria_ID) REFERENCES Categorias(Categoria_ID)
);

CREATE TABLE PrecioProducto (
    Precio_ID INT PRIMARY KEY IDENTITY(1,1),
    Producto_ID INT,
    CostoCompra DECIMAL(10,2),
    PrecioVenta DECIMAL(10,2),
    MargenGanancia DECIMAL(5,2),
    PorcentajeMargen DECIMAL(5,2),
    Activo BIT,
    FechaRegistro DATETIME,
    UsuarioModificacion VARCHAR(50),
    FOREIGN KEY (Producto_ID) REFERENCES Productos(Producto_ID)
);

CREATE TABLE MovimientoInventario (
    MovimientoInventario_ID INT PRIMARY KEY IDENTITY,
    Producto_ID INT,
    PrecioProducto_ID INT,
    TipoMovimiento VARCHAR(50) CHECK (TipoMovimiento IN ('Entrada', 'Salida', 'Ajuste')),
    Cantidad INT NOT NULL,
    Precio DECIMAL(10,2),
    Referencia_ID INT NULL,
    TipoReferencia VARCHAR(50) NULL,
    FechaMovimiento DATETIME DEFAULT GETDATE(),
    EstadoMovimiento VARCHAR(20) DEFAULT 'Activo' CHECK (EstadoMovimiento IN ('Activo', 'Agotado')),
    FOREIGN KEY (Producto_ID) REFERENCES Productos(Producto_ID),
    FOREIGN KEY (PrecioProducto_ID) REFERENCES PrecioProducto(Precio_ID)
);

CREATE TABLE Compras (
    Compra_ID INT PRIMARY KEY IDENTITY,
    Usuario_ID INT,
    Proveedor_ID INT,
    CantidadTotal INT,
    MontoTotal DECIMAL(10,2),
    FechaRegistro DATETIME DEFAULT GETDATE(),
    IVATotal DECIMAL(10,2) DEFAULT 0,
    SubTotal DECIMAL(10,2) NOT NULL,
    Total DECIMAL(10,2),
    FOREIGN KEY (Proveedor_ID) REFERENCES Proveedores(Proveedor_ID),
    FOREIGN KEY (Usuario_ID) REFERENCES Usuario(Usuario_ID)
);

CREATE TABLE Detalles_Compra (
    DetalleCompra_ID INT PRIMARY KEY IDENTITY,
    Compra_ID INT,
    Producto_ID INT,
    CantidadUnitaria INT,
    PrecioUnitario DECIMAL(12,2),
    MontoUnitario DECIMAL(10,2),
    IVA DECIMAL(12,2) DEFAULT 0,
    Total DECIMAL(12,2),
    FOREIGN KEY (Compra_ID) REFERENCES Compras(Compra_ID),
    FOREIGN KEY (Producto_ID) REFERENCES Productos(Producto_ID)
);

CREATE TABLE Ventas (
    Venta_ID INT PRIMARY KEY IDENTITY,
    Usuario_ID INT,
    Cliente_ID INT,
    FechaVenta DATETIME,
    CantidadTotal INT,
    MontoRecibido DECIMAL(12,2),
    MontoDevuelto DECIMAL(12,2),
    SubTotal DECIMAL(12,2),
    Descuento DECIMAL(12,2) DEFAULT 0,
    IVA DECIMAL(12,2) DEFAULT 0,
    Total DECIMAL(12,2),
    Estado VARCHAR(20) DEFAULT 'Activo' CHECK (Estado IN ('Activo','Anulado')),
    FOREIGN KEY (Usuario_ID) REFERENCES Usuario(Usuario_ID),
    FOREIGN KEY (Cliente_ID) REFERENCES Clientes(Cliente_ID)
);

CREATE TABLE Detalles_Ventas (
    DetalleVenta_ID INT PRIMARY KEY IDENTITY,
    Venta_ID INT,
    Producto_ID INT,
    Cantidad INT,
    PrecioUnitario DECIMAL(12,2),
    SubTotal DECIMAL(12,2),
    IVA DECIMAL(12,2),
    Total DECIMAL(12,2),
    TipoComprobante VARCHAR(20) NOT NULL CHECK (TipoComprobante IN ('Factura','Ticket')),
    FOREIGN KEY (Venta_ID) REFERENCES Ventas(Venta_ID),
    FOREIGN KEY (Producto_ID) REFERENCES Productos(Producto_ID)
);

CREATE TABLE Factura (
    Factura_ID INT PRIMARY KEY IDENTITY,
    Venta_ID INT NOT NULL,
    Cliente_ID INT NULL,
    NumeroFactura VARCHAR(50) UNIQUE NOT NULL,
    Serie VARCHAR(10) NULL,
    Correlativo VARCHAR(20) NULL,
    FechaFactura DATETIME,
    FechaVencimiento DATETIME NULL,
    SubTotal DECIMAL(12,2) NOT NULL,
    IVA DECIMAL(12,2) DEFAULT 0,
    Descuento DECIMAL(12,2) DEFAULT 0,
    TotalFactura DECIMAL(12,2) NOT NULL,
    Moneda VARCHAR(10) DEFAULT 'Córdoba',
    MetodoPago VARCHAR(50) DEFAULT 'Efectivo',
    TipoPago VARCHAR(50) DEFAULT 'Contado',
    Estado VARCHAR(20) DEFAULT 'Emitida' CHECK (Estado IN ('Emitida', 'Anulada', 'Pagada', 'Pendiente')),
    FOREIGN KEY (Venta_ID) REFERENCES Ventas(Venta_ID),
    FOREIGN KEY (Cliente_ID) REFERENCES Clientes(Cliente_ID)
);

CREATE TABLE Detalles_Factura (
    DetalleFactura_ID INT PRIMARY KEY IDENTITY,
    Factura_ID INT NOT NULL,
    Venta_ID INT NOT NULL,
    DetalleVenta_ID INT NOT NULL,
    Producto_ID INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(12,2) NOT NULL,
    Subtotal DECIMAL(12,2) NOT NULL,
    IVA DECIMAL(12,2) DEFAULT 0,
    Descuento DECIMAL(12,2) DEFAULT 0,
    Total DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (Factura_ID) REFERENCES Factura(Factura_ID),
    FOREIGN KEY (Venta_ID) REFERENCES Ventas(Venta_ID),
    FOREIGN KEY (DetalleVenta_ID) REFERENCES Detalles_Ventas(DetalleVenta_ID),
    FOREIGN KEY (Producto_ID) REFERENCES Productos(Producto_ID)
);

CREATE TABLE Devoluciones (
    Devolucion_ID INT PRIMARY KEY IDENTITY,
    Venta_ID INT NOT NULL,
    FechaDevolucion DATETIME,
    CantidadDevuelta INT NOT NULL,
    SubTotalDevuelto DECIMAL(12,2) NOT NULL,
    TotalDevuelto DECIMAL(12,2),
    Motivo VARCHAR(255),
    TipoDevolucion VARCHAR(20) DEFAULT 'Parcial' CHECK (TipoDevolucion IN ('Parcial','Total')),
    Estado VARCHAR(20) DEFAULT 'Procesada',
    FOREIGN KEY (Venta_ID) REFERENCES Ventas(Venta_ID)
);

CREATE TABLE Detalles_Devoluciones (
    DetalleDevolucion_ID INT PRIMARY KEY IDENTITY,
    Devolucion_ID INT NOT NULL,
    DetalleVenta_ID INT NOT NULL,
    Producto_ID INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(12,2) NOT NULL,
    IVADevuelto DECIMAL(12,2),
    SubtotalDevuelto DECIMAL(12,2) NOT NULL,
    EstadoProducto VARCHAR(50) CHECK (EstadoProducto IN ('Bueno','Defectuoso')),
    FOREIGN KEY (Devolucion_ID) REFERENCES Devoluciones(Devolucion_ID),
    FOREIGN KEY (DetalleVenta_ID) REFERENCES Detalles_Ventas(DetalleVenta_ID),
    FOREIGN KEY (Producto_ID) REFERENCES Productos(Producto_ID)
);

CREATE TABLE Bitacora (
    Bitacora_ID INT IDENTITY PRIMARY KEY,
    Usuario_ID INT,
    Tabla VARCHAR(100) NOT NULL,
    UsuarioNombre VARCHAR(100),
    Accion VARCHAR(15) NOT NULL CHECK (Accion IN ('Insert', 'Update', 'Delete', 'Login', 'Logout')),
    Descripcion VARCHAR(500) NOT NULL,
    DatosAnteriores VARCHAR(MAX),
    DatosNuevos VARCHAR(MAX),
    Fecha DATETIME DEFAULT GETDATE(),
    IPAddress VARCHAR(50),
    Aplicacion VARCHAR(150),
    FOREIGN KEY (Usuario_ID) REFERENCES Usuario(Usuario_ID)
);

CREATE TABLE PerdidasInventario (
    Perdida_ID INT PRIMARY KEY IDENTITY,
    Producto_ID INT NOT NULL,
    Cantidad INT NOT NULL,
    Motivo VARCHAR(100) CHECK (Motivo IN ('Defectuoso', 'Vencimiento', 'Dañado')),
    FechaRegistro DATETIME DEFAULT GETDATE(),
    Usuario_ID INT,
    FOREIGN KEY (Producto_ID) REFERENCES Productos(Producto_ID),
    FOREIGN KEY (Usuario_ID) REFERENCES Usuario(Usuario_ID)
);

CREATE TABLE ReclamosProveedor (
    Reclamo_ID INT PRIMARY KEY IDENTITY,
    Proveedor_ID INT NOT NULL,
    Producto_ID INT NOT NULL,
    Cantidad INT NOT NULL,
    Motivo VARCHAR(100),
    Estado VARCHAR(20) DEFAULT 'Pendiente' CHECK (Estado IN ('Pendiente', 'Aprobado', 'Rechazado')),
    MontoReclamado DECIMAL(12,2),
    MontoRecuperado DECIMAL(12,2) DEFAULT 0,
    FechaReclamo DATETIME DEFAULT GETDATE(),
    FechaRespuesta DATETIME NULL,
    FOREIGN KEY (Proveedor_ID) REFERENCES Proveedores(Proveedor_ID),
    FOREIGN KEY (Producto_ID) REFERENCES Productos(Producto_ID)
);