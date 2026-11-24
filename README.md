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
