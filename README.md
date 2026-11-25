<h1 align="center">E.T. Nº12 D.E. 1º "Libertador Gral. José de San Martín"</h1>
<h1 align="center"> Buffet Express </h1>
<p align="center">
  <img width="259" height="324" alt="image" src="https://github.com/user-attachments/assets/1cd285c6-aeba-46ba-b38d-4ef0b6ce5a65" />

### Buffet MVP

Versión inicial de Buffet Express, una aplicación de buffet desarrollada con Flutter y organizada mediante una arquitectura por capas.
Integrantes
Sebastian cardozo - Product Owner
Jhon Aucachi - Developer
Ruth Lezcano - Developer
Nayeli Chavez - Scrum Master

## Características

Inicio de sesión con interfaz Material.
Catálogo de productos agrupados por categorías.
Carrito de compras mediante Provider.
Gestión de pedidos.
Esquema SQL para MySQL.
Compatible con Android, iOS, web y escritorio.

## arquitectura técnica
La arquitectura del MVP es  El patrón de repositorio.
## buffet_express
```
┣ core/
 ┃ ┣ theme/
 ┃ ┗ utils/
 ┣ data/
 ┃ ┣ models/
 ┃ ┣ repositories/ (Implementaciones)
 ┃ ┗ datasources/ (Llamadas a API/Mock)
 ┣ domain/
 ┃ ┣ entities/
 ┃ ┗ repositories/ (Contratos/Interfaces)
 ┣ presentation/
 ┃ ┣ providers/
 ┃ ┣ screens/
 ┃ ┗ widgets/
 ┗ main.dart
```
## buffet_backend
```
buffet_backend/
 ┣ 📂 lib/
 ┃ ┗ 📂 src/
 ┃   ┗ 📜 database.dart       
 ┣ 📂 routes/
 ┃ ┣ 📂 orders/
 ┃ ┃ ┗ 📜 index.dart          
 ┃ ┣ 📂 products/
 ┃ ┃ ┗ 📜 index.dart         
 ┃ ┗ 📜 index.dart            
 ┣ 📜 .env                    
 ┣ 📜 pubspec.yaml            
 ┗ 📜 README.md               
```
## Tablero ágil

https://trello.com/invite/b/6ae09d1764068a2a62d39d3c/ATTI10b8bcbc659bbda6c5e1030efbb36a895BB0575B/sprint-del-bufet

## Tecnologías

Flutter y Dart
Provider
Google Fonts
Material UI
MySQL
HTTP

## Base de datos

El archivo scrips/DDL.sql crea la base de datos buffet_express y las tablas:
users
categories
products
orders
order_items

## Instalación
```
bash
git clone https://github.com/jhonaucachiet12-code/Buffet_MVP.git
cd Buffet_MVP/buffet_express
flutter pub get
flutter run
```
## Ejecutar pruebas
```
bash
flutter test
```
## Ejecución web
```
bash
flutter run -d chrome
```
## Base de datos

-- ==========================================
-- BASE DE DATOS: BUFFET EXPRESS MVP
-- ==========================================

-- (Opcional) Si ya habías creado la base, puedes borrarla para empezar de cero
DROP DATABASE IF EXISTS defaultdb;
CREATE DATABASE defaultdb;
USE defaultdb;

-- 1. TABLA DE USUARIOS (Alumnos y Administradores)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dni VARCHAR(20) UNIQUE, -- Agregado para el login del vendedor
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('student', 'admin') NOT NULL,
    course VARCHAR(20) -- Solo se usa si el rol es 'student'
);

-- 2. TABLA DE CATEGORÍAS
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    icon VARCHAR(50) -- Para guardar el nombre del icono (ej: 'cup', 'cookie')
);

-- 3. TABLA DE PRODUCTOS
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    price DECIMAL(10,2) NOT NULL,
    -- Cambiamos is_available por un ENUM de 3 estados para el panel del vendedor
    status ENUM('inSale', 'unavailable', 'outOfSale') DEFAULT 'inSale',
    unavailable_reason VARCHAR(100) DEFAULT 'Sin stock', 
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- 4. TABLA DE PEDIDOS (Comandas)
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL, -- Puede ser nulo si el alumno compra sin loguearse
    student_name VARCHAR(100) NOT NULL,
    student_course VARCHAR(20) NOT NULL,
    ticket_code VARCHAR(20) UNIQUE NOT NULL,
    -- Estados que coinciden con el OrderProvider de Flutter
    status ENUM('Pending_Payment', 'Preparing', 'Cancelled', 'Rejected') NOT NULL,
    payment_method ENUM('MercadoPago', 'Cash') NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 5. TABLA DE DETALLE DEL PEDIDO
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
);

-- ==========================================
-- DATOS DE PRUEBA (SEED DATA)
-- ==========================================

-- Insertar Categorías
INSERT IGNORE INTO categories (id, name, icon) VALUES 
(1, 'Bebidas', 'cup'), 
(2, 'Snacks', 'cookie'), 
(3, 'Menús', 'restaurant');

-- Insertar Productos (Usando los 3 estados nuevos)
INSERT IGNORE INTO products (id, category_id, name, description, price, status, unavailable_reason) VALUES 
(1, 1, 'Agua mineral', '500 ml', 1200.00, 'inSale', NULL),
(2, 1, 'Jugo de naranja', '200 ml', 1500.00, 'inSale', NULL),
(3, 2, 'Alfajor de chocolate', '1 unidad', 1000.00, 'inSale', NULL),
(4, 2, 'Papas fritas', 'Bolsa de 40 g', 1300.00, 'unavailable', 'Sin stock'), -- Simula el estado naranja
(5, 3, 'Sándwich de milanesa', '1 unidad', 3500.00, 'inSale', NULL),
(6, 3, 'Tarta de verdura', '1 porción', 3200.00, 'outOfSale', 'No se vende hoy'); -- Simula el estado gris

-- Insertar Administradores (Héctor y Asistente)
-- Nota: En un sistema real, el password_hash debe ser encriptado (ej: bcrypt). Para el MVP lo dejamos simple.
INSERT IGNORE INTO users (dni, name, email, password_hash, role) VALUES 
('12345678', 'Héctor', 'hector@buffet.com', '123456', 'admin'),
('87654321', 'Asistente', 'asistente@buffet.com', '123456', 'admin');