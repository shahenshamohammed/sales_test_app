
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


>>Project Structure
lib/
src/
core/                 # theme, routes, utils, constants
data/
models/             # DTOs: customer, product, invoice, report, ref items
repositories/       # repository interfaces + Firestore/Storage implementations
presentation/
blocs/              # BLoC/Cubit for each feature
screens/            # UI pages (login, dashboard, customers, products, invoice, report)
widgets/            # reusable UI: dropdowns, pickers, fields, cards


>>credentials for user login 

Email: shahenshamohammedam@gmail.com
Password: shahensha12

