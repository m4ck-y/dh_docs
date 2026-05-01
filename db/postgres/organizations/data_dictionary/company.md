# Data Dictionary: Company

**Context**: `company`  
**Type**: `Database Model`  
**Table**: `company.company`  
**Model File**: `infrastructure/database/models/company.py`

## Overview

Represents a company or organization in the system. Supports hierarchical company structures (parent-subsidiary relationships), industry classification, and service offerings. This is the root aggregate for the company context.

## Fields

| Field Name | Type | Constraints | Description |
|------------|------|-------------|-------------|
| `id` | Integer | PK, NOT NULL, AUTO_INCREMENT | Unique identifier for the company |
| `name` | String(100) | NOT NULL | Full legal name (e.g., "Instituto Mexicano del Seguro Social") |
| `legal_name` | String(255) | NULLABLE | Legal business name with entity type (e.g., "IMSS SA DE CV") |
| `commercial_name` | String(255) | NULLABLE | Short commercial name (e.g., "IMSS") |
| `fiscal_id` | String(255) | NULLABLE | Tax identification number (RFC in Mexico) |
| `url_website` | String(255) | NULLABLE | Company website URL |
| `url_logo` | String(255) | NULLABLE | URL to company logo image |
| `tagline` | String(255) | NULLABLE | Company tagline or slogan |
| `id_industry` | Integer | FK, NOT NULL | Reference to company.industry.id |
| `organization_size` | Enum(EOrganizationSize) | NULLABLE | Size classification (SMALL, MEDIUM, LARGE, ENTERPRISE) |
| `type_organization` | Enum(EOrganizationType) | NULLABLE | Organization type (PUBLIC, PRIVATE, NGO, etc.) |
| `id_parent_company` | Integer | FK, NULLABLE | Reference to parent company (self-referencing) |
| `created_at` | DateTime | NOT NULL, DEFAULT NOW | Timestamp when record was created |
| `updated_at` | DateTime | NULLABLE | Timestamp of last update |
| `is_active` | Boolean | NOT NULL, DEFAULT TRUE | Soft delete flag |

## Relationships

### Many-to-One (Outgoing)
- `industry` → `Industry`: The industry this company belongs to
- `parent_company` → `Company`: Parent company (for subsidiaries)

### One-to-One (Outgoing)
- `location` → `Location`: Physical location of the company

### One-to-Many (Incoming)
- `list_subcompanies` ← `Company[]`: Subsidiary companies
- `list_employees` ← `Employee[]`: Employees working for this company

### Many-to-Many
- `list_services` ↔ `Service[]`: Services offered by this company (through company_services table)

## Business Rules

1. **Name Required**: Company must have at least a `name`
2. **Industry Required**: Every company must belong to an industry
3. **Hierarchical Structure**: Companies can have parent-subsidiary relationships
4. **Self-Referencing**: `id_parent_company` references the same table
5. **Circular Reference Prevention**: System should prevent circular parent-child relationships
6. **One Location**: Each company has one primary location (one-to-one)
7. **Service Pricing**: Services are linked through intermediate table with price and visibility

## Indexes

- `idx_company_name`: Index on `name` for search
- `idx_company_fiscal_id`: Unique index on `fiscal_id` for tax ID lookup
- `idx_company_industry`: Index on `id_industry` for filtering by industry
- `idx_company_parent`: Index on `id_parent_company` for hierarchy queries

## Examples

### Valid Company Record
```json
{
  "id": 1,
  "name": "Instituto Mexicano del Seguro Social",
  "legal_name": "IMSS",
  "commercial_name": "IMSS",
  "fiscal_id": "IMS850101ABC",
  "url_website": "https://www.imss.gob.mx",
  "url_logo": "https://storage.example.com/logos/imss.png",
  "tagline": "Seguridad y Solidaridad Social",
  "id_industry": 5,
  "organization_size": "ENTERPRISE",
  "type_organization": "PUBLIC",
  "id_parent_company": null,
  "created_at": "2024-01-15T10:30:00Z",
  "is_active": true
}
```

### Subsidiary Company Example
```json
{
  "id": 2,
  "name": "IMSS Jalisco",
  "legal_name": "IMSS Jalisco SA DE CV",
  "commercial_name": "IMSS JAL",
  "fiscal_id": "IMJ850101XYZ",
  "id_industry": 5,
  "organization_size": "LARGE",
  "type_organization": "PUBLIC",
  "id_parent_company": 1,
  "created_at": "2024-01-15T10:30:00Z",
  "is_active": true
}
```

## Notes

- Circular reference (parent-subsidiary) requires careful handling to prevent infinite loops
- Consider adding depth limit for company hierarchies
- `fiscal_id` should be unique and validated based on country format
- Service pricing is stored in the intermediate table `company_services`
- Consider adding fields: `founded_date`, `employee_count`, `annual_revenue`
