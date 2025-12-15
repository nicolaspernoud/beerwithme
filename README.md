# beerwithme

A personal database app for beer ratings

## Backend

Backend is made with Actix-web and Rust.

## Frontend

Frontend is made with flutter.

## Upgrade guide

- Regenerate a clean flutter project (see below)
- Upgrade versions in versions.env
- Upgrade flutter dependencies in pubspec.yml
- Upgrade Dockerfile and GitHub actions build.yml
- Upgrade Rust Cargo.toml dependencies

### Regenerate the frontend

```
mv frontend frontend_old
flutter create --template=app --platforms="android,web" --description="Beer with me!" --org="fr.ninico" --project-name="beerwithme" frontend
```
