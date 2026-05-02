# ADR 019: Silent Refresh at Gateway Level

## Context
In a microservices architecture with a frontend client, managing JWT expiration often requires complex logic in the frontend (interceptors, handling 401s, queuing requests during refresh). To simplify the frontend and improve security, we need a mechanism to refresh tokens transparently.

## Decision
We will implement a **Silent Refresh** strategy at the **Gateway Level** (`api_middleware`).

1.  **Dual Cookie Strategy**: `dh_auth` will issue two HttpOnly, Secure, and SameSite=Lax cookies:
    *   `access_token`: Short-lived (e.g., 15 minutes).
    *   `refresh_token`: Long-lived (e.g., 30 days), stored in the database for revocation.
2.  **Gateway Orchestration**: The `api_middleware` will be responsible for:
    *   Intercepting requests with an expired or "about to expire" `access_token`.
    *   Calling `dh_auth/v1/auth/refresh` internally using the `refresh_token` cookie.
    *   Updating the client's cookies with the new `access_token` in the response header.
    *   Retrying the original request with the new token.

## Rationale
*   **Frontend Simplicity**: The frontend does not need to know about token expiration or refresh logic. It just sends requests and receives data.
*   **Security**: By using HttpOnly cookies and handling the refresh at the gateway, we minimize the exposure of tokens to the browser's JavaScript environment.
*   **Consistency**: Ensures a uniform authentication experience across all microservices.

## Consequences
*   **Middleware Complexity**: The `api_middleware` logic becomes more sophisticated as it must handle internal retries and cookie synchronization.
*   **Performance**: A small latency overhead during the refresh cycle (one extra internal call), but this only happens once every 15 minutes per user.
*   **Database Dependency**: `dh_auth` must persist refresh tokens to allow session revocation (logout from all devices, security breaches).

## Implementation Status
*   **dh_auth**: Must implement `/v1/auth/refresh` and dual-cookie issuance.
*   **api_middleware**: Must implement the refresh interception logic.
