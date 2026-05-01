# Data Dictionary: Service

**Context**: `company`  
**Type**: `Database Model`  
**Table**: `company.service`  
**Model File**: `infrastructure/database/models/service.py`

## Overview

Catalog of services that can be offered by companies. Services are linked to companies through a many-to-many relationship with pricing and visibility information stored in the intermediate table.

## Fields

| Field Name | Type | Constraints | Description |
|------------|------|-------------|-------------|
| `id` | Integer | PK, NOT NULL, AUTO_INCREMENT | Unique identifier |
| `name` | String(50) | NULLABLE | Service name |
| `key_service` | String(10) | NULLABLE | Service code/key for programmatic reference |
| `id_type_service` | Integer | FK, NOT NULL | Reference to company.type_service.id |
| `created_at` | DateTime | NOT NULL, DEFAULT NOW | Timestamp when created |
| `updated_at` | DateTime | NULLABLE | Timestamp of last update |
| `is_active` | Boolean | NOT NULL, DEFAULT TRUE | Soft delete flag |

## Relationships

### Many-to-One (Outgoing)
- `type_service` → `TypeService`: The category/type of this service

### Many-to-Many
- `list_companies` ↔ `Company[]`: Companies offering this service (through company_services)

## Intermediate Table: company_services

| Field Name | Type | Constraints | Description |
|------------|------|-------------|-------------|
| `id_company` | Integer | FK, NOT NULL | Reference to company.company.id |
| `id_service` | Integer | FK, NOT NULL | Reference to company.service.id |
| `price` | Float | NOT NULL | Price for this service at this company |
| `visible_to_public` | Boolean | NOT NULL, DEFAULT TRUE | Whether service is publicly visible |

## Business Rules

1. **Catalog Table**: Services are predefined catalog items
2. **Type Required**: Each service must have a type
3. **Company-Specific Pricing**: Price is stored in intermediate table
4. **Visibility Control**: Services can be hidden from public view per company
5. **Unique Keys**: `key_service` should be unique for programmatic access

## Examples

### Service Record
```json
{
  "id": 1,
  "name": "Consulta General",
  "key_service": "CONS_GEN",
  "id_type_service": 1
}
```

### Company-Service Link
```json
{
  "id_company": 1,
  "id_service": 1,
  "price": 500.00,
  "visible_to_public": true
}
```

## Notes

- Consider adding `description`, `duration`, `requirements` fields
- Price should include currency field in intermediate table
- Consider adding service availability schedule
