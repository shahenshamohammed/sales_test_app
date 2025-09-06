
# Sales Test App


## Setup
- Flutter 3.x
- `flutter pub get`
- Run with `flutter run --dart-define=API_BASE_URL=https://your.api`


## Packages
- flutter_bloc, dio, flutter_secure_storage, json_serializable, equatable, intl, formz


## Architecture
- Clean Architecture (domain/data/presentation)
- Navigator 2.0 custom RouterDelegate


## Features
- Login (token stored in secure storage)
- Customer & Product CRUD (with dropdown master data, image upload)
- Sales Invoice (multi-line items, qty/rate/discount, totals)
- Sales Report (table + date & customer filters)


## Endpoints (example)
- POST /auth/login
- GET/POST/PUT/DELETE /customers
- GET/POST/PUT/DELETE /products
- POST /uploads (image)
- POST /sales (master + details)
- GET /sales/report?from=...&to=...&customer=...