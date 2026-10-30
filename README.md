# Monitor SAR — La Réunion

Construit automatiquement depuis le **WFS PEIGEO** (GeoServer public)
et l'**API Géo** (communes). Conversion RGR92 (EPSG:2975) → WGS84 (EPSG:4326)
via `ogr2ogr`.

## Lancer
```bash
cd monitor-sar-reunion
python3 -m http.server 8000
# → http://localhost:8000
