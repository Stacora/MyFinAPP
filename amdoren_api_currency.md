# Legacy Currency API (Amdoren) and Ongoing Migration

## Historical Context

In early versions of this application, currency conversion was implemented using a third-party API from **Amdoren** (a paid currency API service).\
The file `amdoren_api_currency.pages`, located at the project root, contains legacy notes and configuration details related to that integration.

-   The original API key associated with the Amdoren account is **no longer valid**.
-   The Amdoren integration is considered **deprecated** and will not be used going forward.

## Migration Status: Open Exchange Rates (In Progress)

The application is currently **in the process of being migrated** to use **Open Exchange Rates** (`openexchangerates.org`) as the new currency data provider.

-   Planned implementation script: `python/openexchangerates_api.py`
-   Once completed, this script will:
    -   Download the latest exchange rates from\
        `https://openexchangerates.org/api/latest.json`
    -   Build two data frames:
        -   `df_exchange`: exchange rates
        -   `df_meta`: metadata about the request and provider
    -   Expose these objects to the Shiny application via `reticulate`

**Important**\
At the time of sharing this project, the migration to Open Exchange Rates **has not been fully completed yet**.\
Some components may still rely on legacy logic, placeholders, or partial implementations.

## API Key Management (Planned)

As part of the migration, API key handling is being refactored to follow best practices.

-   The Open Exchange Rates API key **will not be hard-coded** in source files.
-   Instead, it will be loaded from a `.env` file:

``` text
  APP_ID=YOUR_OPENEXCHANGERATES_APP_ID
```

-   The Python implementation will rely on `python-dotenv` to load environment variables at runtime.

This change is intended to:

-   Prevent accidental exposure of secrets in the repository
-   Simplify local and production deployments

## Summary

-   **Amdoren API**: Legacy and deprecated; API key expired.
-   **Open Exchange Rates API**: Target provider; migration **in progress**.
-   **Current state**: Currency API refactor not finalized.
-   **Security direction**: Environment-based configuration via `.env`.
