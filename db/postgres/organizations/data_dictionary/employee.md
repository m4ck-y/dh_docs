# Data Dictionary: Employee

**Context**: `employee`  
**Type**: `Database Model`  
**Table**: `employee.employee`  
**Model File**: `infrastructure/database/models/employee.py`

## Overview

Represents an employment relationship between a person and a company. A person can have multiple employment records (different companies or time periods). Includes contract type, status, and performance scoring.

## Fields

| Field Name | Type | Constraints | Description |
|------------|------|-------------|-------------|
| `id` | Integer | PK, NOT NULL, AUTO_INCREMENT | Unique identifier |
| `id_person` | Integer | FK, NOT NULL | Reference to person.person.id |
| `id_company` | Integer | FK, NOT NULL | Reference to company.company.id |
| `date_entry` | DateTime(timezone=True) | NULLABLE | Employment start date |
| `date_exit` | DateTime(timezone=True) | NULLABLE | Employment end date (if terminated) |
| `status` | Enum(EStatusEmployee) | NOT NULL, DEFAULT 'PENDING' | Employment status |
| `type_contract` | Enum(EContractType) | NOT NULL, DEFAULT 'FULL_TIME' | Contract type |
| `score` | Float | NOT NULL, DEFAULT 5.0 | Performance score (0-10 scale) |
| `created_at` | DateTime | NOT NULL, DEFAULT NOW | Timestamp when created |
| `updated_at` | DateTime | NULLABLE | Timestamp of last update |
| `is_active` | Boolean | NOT NULL, DEFAULT TRUE | Soft delete flag |

## Enums

### EStatusEmployee
- `INACTIVE` (0): Inactivo
- `ACTIVE` (1): Activo
- `PENDING` (2): Pendiente
- `SUSPENDED` (4): Suspendido
- `TERMINATED` (5): De baja

### EContractType
- `FULL_TIME` (1): Tiempo completo
- `PART_TIME` (2): Medio tiempo
- `TEMPORARY` (3): Temporal
- `CONTRACTOR` (4): Freelance/Contratista
- `INTERN` (5): Pasante

## Relationships

### Many-to-One (Outgoing)
- `person` → `Person`: The person employed
- `company` → `Company`: The employing company

### One-to-One (Outgoing)
- `employee_mexican` → `EmployeeMexican`: Mexico-specific employment data

### Many-to-Many
- `roles` ↔ `Role[]`: Security roles assigned to employee (through employee_roles)

## Business Rules

1. **Multiple Employments**: A person can have multiple employment records
2. **Active Employment**: Only one active employment per person per company
3. **Date Validation**: `date_exit` must be after `date_entry`
4. **Status Transitions**: Define valid status transition rules
5. **Score Range**: Performance score should be 0-10
6. **Contract Type**: Determines benefits and working hours

## Indexes

- `idx_employee_person`: Index on `id_person` for person lookup
- `idx_employee_company`: Index on `id_company` for company lookup
- `idx_employee_status`: Index on `status` for filtering
- `idx_employee_dates`: Index on `date_entry`, `date_exit` for date queries

## Examples

### Active Employee
```json
{
  "id": 1,
  "id_person": 123,
  "id_company": 5,
  "date_entry": "2024-01-15T08:00:00-06:00",
  "date_exit": null,
  "status": "ACTIVE",
  "type_contract": "FULL_TIME",
  "score": 8.5,
  "created_at": "2024-01-15T10:30:00Z"
}
```

### Terminated Employee
```json
{
  "id": 2,
  "id_person": 124,
  "id_company": 5,
  "date_entry": "2023-01-01T08:00:00-06:00",
  "date_exit": "2024-12-31T17:00:00-06:00",
  "status": "TERMINATED",
  "type_contract": "TEMPORARY",
  "score": 7.0
}
```

## Notes

- TODO: Fix `company` relationship back_populates
- Consider adding fields: `position`, `department`, `salary`, `benefits`
- Implement status transition validation
- Score calculation should be documented
- Consider adding performance review history
