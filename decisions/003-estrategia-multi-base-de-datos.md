# ADR 003: Estrategia de Persistencia Multi-Base de Datos

## Estado
Aceptado

## Contexto
El Hospital Digital requiere manejar diversos tipos de datos: transacciones médicas (PostgreSQL), catálogos documentales dinámicos (MongoDB) y catálogos masivos de baja mutabilidad para análisis y consulta rápida (ClickHouse). Un solo motor de base de datos no es óptimo para cubrir todos estos casos de uso con el rendimiento requerido.

## Decisión
Se ha decidido diversificar la capa de persistencia utilizando una estrategia de **Políglota Persistence**:

1.  **PostgreSQL**: Se mantiene como la base de datos transaccional primaria para todas las entidades ACID (Personas, Cuentas, Formularios, etc.).
2.  **MongoDB**: Se incorpora para almacenar catálogos que se benefician de un esquema flexible o que son de naturaleza documental.
3.  **ClickHouse**: Se incorpora específicamente para la lectura de catálogos masivos y para futuros módulos de analítica, aprovechando su motor columnar.

## Consecuencias
- **Positivas**: 
    - **Rendimiento**: Cada tipo de dato se almacena en el motor que mejor lo procesa.
    - **Escalabilidad**: Evita cuellos de botella en PostgreSQL al delegar lecturas masivas a ClickHouse.
- **Negativas**: 
    - **Complejidad de Infraestructura**: Mayor carga operativa al mantener tres motores distintos.
    - **Consistencia**: Requiere mecanismos de sincronización (sincronía o asincronía) entre la base de datos transaccional y los almacenes de catálogos.
