# Data Dictionary: Location

**Context**: `company`  
**Type**: `Database Model`  
**Table**: `company.location`  
**Model File**: `infrastructure/database/models/location.py`

## Overview

Stores the physical location of a company. Designed for international support with flexible administrative levels (country, state, city, municipality, neighborhood). One-to-one relationship with Company.

## Fields

| Field Name | Type | Constraints | Description |
|------------|------|-------------|-------------|
| `id` | Integer | PK, NOT NULL, AUTO_INCREMENT | Unique identifier |
| `id_company` | Integer | FK, NOT NULL, UNIQUE | Reference to company.company.id (one-to-one) |
| `key_country` | String(50) | NULLABLE | Country code (ISO 3166-1 alpha-2) |
| `key_state` | String(50) | NULLABLE | State/province code (ISO 3166-2) |
| `key_city` | String(50) | NULLABLE | City code |
| `key_municipality` | String(50) | NULLABLE | Municipality/county code |
| `key_neighborhood` | String(50) | NULLABLE | Neighborhood/colony code |
| `address` | String(255) | NULLABLE | Street address |
| `address_complement` | String(255) | NULLABLE | Additional address info (suite, floor, etc.) |
| `postal_code` | String(20) | NULLABLE | Postal/ZIP code |
| `latitude` | Float | NULLABLE | GPS latitude coordinate |
| `longitude` | Float | NULLABLE | GPS longitude coordinate |
| `created_at` | DateTime | NOT NULL, DEFAULT NOW | Timestamp when created |
| `updated_at` | DateTime | NULLABLE | Timestamp of last update |
| `is_active` | Boolean | NOT NULL, DEFAULT TRUE | Soft delete flag |

## Relationships

### One-to-One (Outgoing)
- `company` → `Company`: The company at this location

## Business Rules

1. **One Location Per Company**: UNIQUE constraint on `id_company`
2. **International Support**: Uses ISO codes for standardization
3. **Flexible Hierarchy**: Not all levels are required (country-specific)
4. **Geolocation**: Latitude/longitude for mapping and proximity searches

## Examples

```json
{
  "id": 1,
  "id_company": 1,
  "key_country": "MX",
  "key_state": "JAL",
  "key_city": "GDL",
  "key_municipality": "039",
  "key_neighborhood": "CENTRO",
  "address": "Av. Juárez 500",
  "address_complement": "Piso 3, Oficina 301",
  "postal_code": "44100",
  "latitude": 20.6737,
  "longitude": -103.3444
}
```

## Notes

- TODO: Use ISO 3166 codes for country/state validation
- Consider adding timezone field
- Geolocation should be calculated if not provided
