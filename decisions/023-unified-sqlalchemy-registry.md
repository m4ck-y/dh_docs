# ADR 023: Unified SQLAlchemy Registry for Cross-Schema Relationships

## Status
Accepted

## Context
The system uses multiple PostgreSQL schemas (`auth`, `people`, `org`, `iam`) managed by different `DeclarativeBase` classes in `dh_shared`. Initially, each base class created its own `registry`. This caused `KeyError` and `InvalidRequestError` when trying to define relationships between classes in different schemas (e.g., `AuthUser` in `auth` schema referencing `Person` in `people` schema) using string names, because they were in separate name-resolution universes.

## Decision
We will implement a **Unified Registry** (shared registry) in the core of the shared library (`dh_shared.base`).

1. **Shared Registry Definition**: Create a single instance of `sqlalchemy.orm.registry` in `dh_shared/base.py`.
2. **Registry Injection**: All schema-specific `DeclarativeBase` subclasses must explicitly set their `registry` attribute to this shared instance.
3. **Lazy Loading Strategy**: All cross-schema relationships must be defined using the class name string (e.g., `relationship("Person")`) and use `lazy="raise"` by default to force explicit joining/loading via `selectinload` or `joinedload` in async contexts.

## Consequences

### Positive
- **Cross-Schema Navigation**: Enables seamless navigation between entities in different schemas (e.g., `user.person.employees[0].company`).
- **Standardized Name Resolution**: Eliminates `KeyError` during mapper initialization.
- **Single Source of Truth**: All models are part of the same metadata and registry, simplifying complex joins.

### Negative
- **Module Loading Dependency**: All related models must be imported before executing queries that resolve those relationships (handled in `dh_auth/app/main.py`).
- **Potential Name Conflicts**: Requires uniqueness of class names across the entire ecosystem (not an issue currently due to bounded context naming).

## Implementation Example

```python
# dh_shared/base.py
shared_metadata = MetaData()
shared_registry = registry(metadata=shared_metadata)

# dh_shared/models/auth/base.py
class AuthBase(DeclarativeBase):
    registry = shared_registry
    metadata = shared_metadata
```
