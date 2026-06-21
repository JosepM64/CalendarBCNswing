# BCN Swing Events

Aplicació mòbil per consultar els esdeveniments de ball swing de Barcelona.

## Funcionalitats

- Llistat d'esdeveniments propers
- Filtrar per categoria (Ballada amb DJ, Concert amb ball, Festival, Workshop, etc.)
- Filtrar per data (inici i fi)
- Cerca per paraula clau
- Detall d'esdeveniment amb descripció, lloc i enllaç al web
- Pull-to-refresh
- Paginació automàtica
- Suport dark/light mode

## API

Utilitza l'API REST de The Events Calendar (WordPress):
- `GET /wp-json/tribe/events/v1/events` - Llistat d'esdeveniments
- `GET /wp-json/tribe/events/v1/categories` - Categories

Categories excloses: "Classe oberta"

## Executar

```bash
flutter pub get
flutter run
```

## Compilar APK

```bash
flutter build apk --release
```

## Compilar iOS

```bash
flutter build ios --release
```
