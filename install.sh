#!/usr/bin/env bash
# ============================================================
# MONITOR SAR LA RÉUNION — Construction automatisée
# Source : WFS PEIGEO (GeoServer) + API Géo (communes)
# Usage : bash build_monitor.sh
# Prérequis : curl, ogr2ogr (GDAL), python3
# ============================================================
set -euo pipefail

PROJECT="monitor-sar-reunion"
DATA_DIR="$PROJECT/data"
WFS_BASE="http://peigeo.re:8080/geoserver/peigeo/ows"
mkdir -p "$DATA_DIR"

echo "==> Construction du Monitor SAR — La Réunion"

# ------------------------------------------------------------
# 1. Limites communales (API Géo, WGS84 direct)
# ------------------------------------------------------------
echo "[1/3] Téléchargement des communes..."
curl -sL --max-time 60 \
  "https://geo.api.gouv.fr/departements/974/communes?fields=nom,code,contour&format=geojson" \
  -o "$DATA_DIR/communes_reunion.geojson"

# ------------------------------------------------------------
# 2. Couches PEIGEO via WFS (RGR92 → WGS84)
# ------------------------------------------------------------
fetch_wfs() {
  local typeName="$1" out="$2"
  echo "    → $typeName"
  curl -sL --max-time 180 \
    "${WFS_BASE}?service=WFS&version=1.0.0&request=GetFeature&typeName=peigeo:${typeName}&outputFormat=application/json" \
    -o "${out}.raw.json"
  if [ ! -s "${out}.raw.json" ]; then
    echo "      ⚠️  échec, fichier vide"
    return 1
  fi
  ogr2ogr -f GeoJSON -t_srs EPSG:4326 "$out" "${out}.raw.json" 2>/dev/null
  rm -f "${out}.raw.json"
}

echo "[2/3] Téléchargement des couches PEIGEO..."

# Tache urbaine — dernière version (2025) + série historique
fetch_wfs "tache_urbaine_intermediaire_janvier_2025" "$DATA_DIR/sar_tache_urbaine_2025.geojson" || true
fetch_wfs "tache_urbaine_1997"                       "$DATA_DIR/sar_tache_urbaine_1997.geojson" || true
fetch_wfs "enveloppe_urbaine_multi_annee"            "$DATA_DIR/sar_enveloppe_urbaine.geojson" || true

# Occupation du sol
fetch_wfs "mos_re_2017"                              "$DATA_DIR/sar_mos_2017.geojson" || true
fetch_wfs "Mos_Ré_zone_construite_2017"              "$DATA_DIR/sar_mos_zone_construite_2017.geojson" || true
fetch_wfs "Mos_Ré_ananas_maraichage_2017"            "$DATA_DIR/sar_mos_agricole_2017.geojson" || true

# Milieux naturels / agricoles
fetch_wfs "carto_milieux_naturels"                   "$DATA_DIR/sar_milieux_naturels.geojson" || true
fetch_wfs "pai_espace_naturel"                       "$DATA_DIR/sar_pai_espaces_naturels.geojson" || true
fetch_wfs "zae_zonage_2023"                          "$DATA_DIR/sar_zae_2023.geojson" || true

# Friches urbaines
fetch_wfs "BD_FRICHE_URBAINE_974"                    "$DATA_DIR/sar_friches_urbaines.geojson" || true

# Indice de fragmentation
fetch_wfs "zonage_indice_ifm"                        "$DATA_DIR/sar_indice_ifm.geojson" || true

# ------------------------------------------------------------
# 3. Génération du HTML (carte Leaflet multi-couches)
# ------------------------------------------------------------
echo "[3/3] Génération de index.html..."
cat > "$PROJECT/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Monitor SAR — La Réunion</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<style>
  body { margin:0; font-family: system-ui, sans-serif; }
  #map { height:100vh; }
  #panel {
    position:absolute; top:10px; left:10px; z-index:1000;
    background:#fff; padding:12px 16px; border-radius:8px;
    box-shadow:0 2px 8px rgba(0,0,0,.2); max-width:340px;
    max-height:90vh; overflow-y:auto;
  }
  #panel h1 { font-size:15px; margin:0 0 6px; }
  #panel h2 { font-size:12px; margin:10px 0 4px; color:#555; text-transform:uppercase; letter-spacing:.5px; }
  #panel label { display:block; font-size:13px; margin:3px 0; cursor:pointer; }
</style>
</head>
<body>
<div id="map"></div>
<div id="panel">
  <h1>Monitor SAR — La Réunion</h1>
  <h2>Contexte</h2>
  <label><input type="checkbox" data-layer="communes" checked> Limites communales</label>
  <h2>Étalement urbain (P3)</h2>
  <label><input type="checkbox" data-layer="tache_urbaine_2025"> Tache urbaine 2025</label>
  <label><input type="checkbox" data-layer="tache_urbaine_1997"> Tache urbaine 1997</label>
  <label><input type="checkbox" data-layer="enveloppe_urbaine"> Enveloppe urbaine multi-année</label>
  <label><input type="checkbox" data-layer="friches_urbaines"> Friches urbaines</label>
  <h2>Occupation du sol / agricole (P1)</h2>
  <label><input type="checkbox" data-layer="mos_2017"> MOS 2017</label>
  <label><input type="checkbox" data-layer="mos_zone_construite_2017"> Zones construites 2017</label>
  <label><input type="checkbox" data-layer="mos_agricole_2017"> Cultures 2017</label>
  <label><input type="checkbox" data-layer="zae_2023"> ZAE 2023</label>
  <h2>Naturel (P2) / fragmentation (P4)</h2>
  <label><input type="checkbox" data-layer="milieux_naturels"> Milieux naturels</label>
  <label><input type="checkbox" data-layer="pai_espaces_naturels"> PAI espaces naturels</label>
  <label><input type="checkbox" data-layer="indice_ifm"> Indice de fragmentation</label>
</div>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
const map = L.map('map').setView([-21.1, 55.5], 9);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution:'© OpenStreetMap', maxZoom:18
}).addTo(map);

const registry = {
  communes:                { file:'communes_reunion.geojson',         style:{color:'#444',weight:1,fillOpacity:0} },
  tache_urbaine_2025:      { file:'sar_tache_urbaine_2025.geojson',   style:{color:'#c62828',weight:1,fillColor:'#c62828',fillOpacity:.35} },
  tache_urbaine_1997:      { file:'sar_tache_urbaine_1997.geojson',   style:{color:'#8d6e63',weight:1,fillColor:'#8d6e63',fillOpacity:.35} },
  enveloppe_urbaine:       { file:'sar_enveloppe_urbaine.geojson',    style:{color:'#ef6c00',weight:1,fillColor:'#ef6c00',fillOpacity:.25} },
  friches_urbaines:        { file:'sar_friches_urbaines.geojson',     style:{color:'#6a1b9a',weight:1,fillColor:'#6a1b9a',fillOpacity:.4} },
  mos_2017:                { file:'sar_mos_2017.geojson',             style:{color:'#0288d1',weight:0,fillColor:'#0288d1',fillOpacity:.35} },
  mos_zone_construite_2017:{ file:'sar_mos_zone_construite_2017.geojson', style:{color:'#ad1457',weight:0,fillColor:'#ad1457',fillOpacity:.4} },
  mos_agricole_2017:       { file:'sar_mos_agricole_2017.geojson',    style:{color:'#2e7d32',weight:0,fillColor:'#2e7d32',fillOpacity:.45} },
  zae_2023:                { file:'sar_zae_2023.geojson',             style:{color:'#66bb6a',weight:1,fillColor:'#66bb6a',fillOpacity:.35} },
  milieux_naturels:        { file:'sar_milieux_naturels.geojson',     style:{color:'#1565c0',weight:0,fillColor:'#1565c0',fillOpacity:.35} },
  pai_espaces_naturels:    { file:'sar_pai_espaces_naturels.geojson', style:{color:'#00695c',weight:1,fillColor:'#00695c',fillOpacity:.3} },
  indice_ifm:              { file:'sar_indice_ifm.geojson',           style:{color:'#f9a825',weight:1,fillColor:'#f9a825',fillOpacity:.3} }
};

const layers = {};

function popupHTML(props) {
  const keys = Object.keys(props).filter(k => props[k] !== null && props[k] !== '');
  if (!keys.length) return '—';
  return keys.slice(0, 5).map(k => `<b>${k}</b> : ${props[k]}`).join('<br>');
}

Object.entries(registry).forEach(([key, cfg]) => {
  fetch('data/' + cfg.file)
    .then(r => r.json())
    .then(data => {
      if (!data.features || !data.features.length) return;
      const layer = L.geoJSON(data, {
        style: cfg.style,
        onEachFeature: (f, l) => { l.bindPopup(popupHTML(f.properties || {})); }
      });
      layers[key] = layer;
      const cb = document.querySelector(`input[data-layer="${key}"]`);
      if (cb) {
        cb.addEventListener('change', e => {
          e.target.checked ? layer.addTo(map) : map.removeLayer(layer);
        });
        if (cb.checked) layer.addTo(map);
      }
    })
    .catch(() => {
      const cb = document.querySelector(`input[data-layer="${key}"]`);
      if (cb) cb.disabled = true;
    });
});
</script>
</body>
</html>
HTML

# ------------------------------------------------------------
# 4. README
# ------------------------------------------------------------
cat > "$PROJECT/README.md" <<'MD'
# Monitor SAR — La Réunion

Construit automatiquement depuis le **WFS PEIGEO** (GeoServer public)
et l'**API Géo** (communes). Conversion RGR92 (EPSG:2975) → WGS84 (EPSG:4326)
via `ogr2ogr`.

## Lancer
```bash
cd monitor-sar-reunion
python3 -m http.server 8000
# → http://localhost:8000