# ADR 022: Mandatory Endpoints Documentation (ENDPOINTS.md)

## Context
As the number of microservices grows, it becomes difficult to track the available API surfaces without starting each service and checking the Swagger/OpenAPI documentation. For AI agents and developers, having a machine-readable and human-readable file at the root of each service is essential for quick context extraction.

## Decision
Every microservice in the Digital Hospital ecosystem MUST include an `ENDPOINTS.md` file in its root directory.

### Requirements for `ENDPOINTS.md`:
1.  **Base Path**: Clearly state the base prefix (e.g., `/v1/auth`).
2.  **Protocol**: State if it's HTTP/REST, gRPC, WebSocket, etc.
3.  **Endpoint List**: For each endpoint, include:
    *   **Verb & Path** (e.g., `POST /login`).
    *   **Request Schema**: Link to the DTO and provide a JSON example.
    *   **Response Schema**: Success and common error codes.
    *   **Authentication**: State if auth is required and what type.
    *   **Side Effects**: Mention cookies, header changes, or external service calls.

## Rationale
*   **AI-Native**: Facilitates LLM context gathering without full repository scanning.
*   **Fast Audit**: Developers can review the API surface directly from the Git repository.
*   **Contract Clarity**: Acts as a high-level contract before diving into implementation.

## Consequences
*   **Maintenance**: Developers must keep this file updated alongside router changes.
*   **Redundancy**: Complements OpenAPI (Swagger) but does not replace it; OpenAPI is for interactive testing, `ENDPOINTS.md` is for documentation and architectural review.
