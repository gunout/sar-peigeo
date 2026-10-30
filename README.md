# 🗺️ Monitor SAR — La Réunion

[![MapLibre](https://img.shields.io/badge/MapLibre-6.11.2-295DAA?logo=maplibre&logoColor=white)](https://maplibre.org/)
[![OpenFreeMap](https://img.shields.io/badge/OpenFreeMap-Liberty-00A86B?logo=openstreetmap&logoColor=white)](https://openfreemap.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub Pages](https://img.shields.io/badge/Demo-GitHub_Pages-222222?logo=github&logoColor=white)](https://gunout.github.io/sar-peigeo/)
[![Status](https://img.shields.io/badge/Status-Production-ff1493)](https://github.com/gunout/sar-peigeo)
[![Made with](https://img.shields.io/badge/Made_with-❤️_for_La_Réunion-ff1493)](https://github.com/gunout/sar-peigeo)

> Tableau de bord cartographique interactif pour le suivi du **Schéma d'Aménagement Régional (SAR)** de La Réunion.

---

## 📋 Table des matières

- [Aperçu](#-aperçu)
- [Fonctionnalités](#-fonctionnalités)
- [Stack technique](#-stack-technique)
- [Couches cartographiques](#-couches-cartographiques)
- [Installation](#-installation)
- [Utilisation](#-utilisation)
- [Architecture](#-architecture)
- [Mise à jour des données](#-mise-à-jour-des-données)
- [Couches manquantes](#-couches-manquantes)
- [Contribuer](#-contribuer)
- [Licence](#-licence)

---

## 🎯 Aperçu

Le **Monitor SAR** est un tableau de bord cartographique qui permet de visualiser et d'analyser les dynamiques territoriales de La Réunion à travers **12 couches de données géographiques** issues du WFS public de **PEIGEO** (plateforme de l'AGORAH).

L'outil s'inscrit dans le cadre du suivi du **Schéma d'Aménagement Régional** et permet de croiser :

- L'**étalement urbain** (taches urbaines 1997 → 2025)
- L'**occupation du sol** (MOS 2017)
- Les **espaces naturels** et agricoles
- La **fragmentation** des milieux

🌐 **Démo en ligne** : [gunout.github.io/sar-peigeo](https://gunout.github.io/sar-peigeo/)

---

## ✨ Fonctionnalités

- 🗺️ **Fond vectoriel** (OpenFreeMap Liberty) avec routes, noms de rues et POI
- 🛰️ **Bascule Plan / Satellite** intégrée (Esri World Imagery)
- 🎨 **Interface glassmorphism** noir & rose fluo, panneau déplaçable
- 📊 **12 couches GeoJSON** superposables avec popups d'attributs
- 🔍 **Zoom, déplacement, survol** avec curseur contextuel
- 📱 **Responsive** (souris + tactile)
- ⚡ **Chargement asynchrone** avec compteur de progression
- 🔓 **100% open source**, sans clé API

---

## 🛠️ Stack technique

| Composant | Technologie | Version | Rôle |
|-----------|-------------|---------|------|
| **Rendu cartographique** | [MapLibre GL JS](https://maplibre.org/) | 6.11.2 | Moteur WebGL vectoriel |
| **Fond vectoriel** | [OpenFreeMap](https://openfreemap.org/) | Liberty | Routes, noms, POI (sans clé API) |
| **Fond satellite** | [Esri World Imagery](https://www.arcgis.com/) | REST | Imagerie satellite (sans clé API) |
| **Source de données** | [PEIGEO WFS](http://peigeo.re:8080/geoserver/peigeo/ows) | GeoServer | 12 couches GeoJSON |
| **Conversion** | [GDAL/OGR](https://gdal.org/) | 3.x | RGR92 (EPSG:2975) → WGS84 |
| **Hébergement** | [GitHub Pages](https://pages.github.com/) | - | Démo en ligne |

---

## 🗂️ Couches cartographiques

### Étalement urbain

| Couche | Fichier | Indicateur SAR | Source |
|--------|---------|----------------|--------|
| Tache urbaine 1997 | `sar_tache_urbaine_1997.geojson` | P3 | PEIGEO |
| Tache urbaine 2020 | `sar_tache_urbaine_2020.geojson` | P3 | PEIGEO |
| Tache urbaine 2025 | `sar_tache_urbaine_2025.geojson` | P3 | PEIGEO |
| Enveloppe urbaine | `sar_enveloppe_urbaine.geojson` | P3 | PEIGEO |
| Friches urbaines | `sar_friches_urbaines.geojson` | P3 | PEIGEO |

### Occupation du sol

| Couche | Fichier | Indicateur SAR | Source |
|--------|---------|----------------|--------|
| Zones construites 2017 | `sar_mos_zone_construite_2017.geojson` | P1 | PEIGEO |
| Cultures 2017 | `sar_mos_agricole_2017.geojson` | P1 | PEIGEO |
| ZAE 2023 | `sar_zae_2023.geojson` | P1 | PEIGEO |

### Naturel & fragmentation

| Couche | Fichier | Indicateur SAR | Source |
|--------|---------|----------------|--------|
| Milieux naturels | `sar_milieux_naturels.geojson` | P2 | PEIGEO |
| PAI espaces naturels | `sar_pai_espaces_naturels.geojson` | P2 | PEIGEO |
| Indice de fragmentation | `sar_indice_ifm.geojson` | P4 | PEIGEO |

### Contexte

| Couche | Fichier | Source |
|--------|---------|--------|
| Limites communales | `communes_reunion.geojson` | [API Géo](https://geo.api.gouv.fr/) |

---

## 🚀 Installation

### Prérequis

- Un navigateur moderne supportant **WebGL2** (Chrome, Firefox, Safari, Edge)
- **Python 3** (pour le serveur local)

### Cloner le dépôt

    git clone https://github.com/gunout/sar-peigeo.git
    cd sar-peigeo

### Lancer en local

    python3 -m http.server 8000

Ouvrir http://localhost:8000 dans votre navigateur.

---

## 🎮 Utilisation

1. **Déplacer le panneau** : attraper l'en-tête « Monitor SAR » et glisser
2. **Basculer Plan / Satellite** : bouton segmenté en haut du panneau
3. **Activer une couche** : cocher la case correspondante
4. **Voir les attributs** : cliquer sur un polygone → popup avec les champs
5. **Zoomer** : molette, boutons +/-, ou double-clic
6. **Survoler** : le curseur devient pointeur sur les couches actives

---

## 🏗️ Architecture

    sar-peigeo/
    ├── index.html              # Monitor MapLibre (interface complète)
    ├── install.sh              # Script de (re)téléchargement des données
    ├── README.md               # Ce fichier
    ├── LICENSE                 # Licence MIT
    ├── .gitattributes          # Désactivation LFS sur les GeoJSON
    ├── .gitignore              # Exclusions
    ├── .nojekyll               # Empêche Jekyll de traiter les fichiers
    └── data/
        ├── communes_reunion.geojson
        ├── sar_enveloppe_urbaine.geojson
        ├── sar_friches_urbaines.geojson
        ├── sar_indice_ifm.geojson
        ├── sar_milieux_naturels.geojson
        ├── sar_mos_agricole_2017.geojson
        ├── sar_mos_zone_construite_2017.geojson
        ├── sar_pai_espaces_naturels.geojson
        ├── sar_tache_urbaine_1997.geojson
        ├── sar_tache_urbaine_2020.geojson
        ├── sar_tache_urbaine_2025.geojson
        └── sar_zae_2023.geojson

---

## 🔄 Mise à jour des données

Le script `install.sh` télécharge les couches depuis le WFS PEIGEO et les convertit en GeoJSON WGS84 :

    bash install.sh

**Pipeline** :

1. `curl` → WFS GeoServer (format `application/json`)
2. `ogr2ogr` → conversion RGR92 (EPSG:2975) → WGS84 (EPSG:4326)
3. `-simplify` → réduction de la taille pour le rendu navigateur
4. Déplacement vers `data/`

---

## ⏳ Couches manquantes

Les couches suivantes **ne sont pas exposées** dans le WFS public de PEIGEO et doivent être demandées à l'**AGORAH** (Shapefile/GeoPackage) :

- 🌾 **Espaces agricoles du SAR** (indicateur 4.9 / 4.10)
- 🌳 **Espaces naturels de forte valeur** (indicateur 4.4 / 4.7)
- 🚧 **Coupures d'urbanisation** (indicateur 4.8)

Une fois reçues, les convertir en GeoJSON WGS84 et les déposer dans `data/`, puis ajouter les entrées dans `registry` (index.html).

---

## 🤝 Contribuer

Les contributions sont bienvenues ! Pour proposer une amélioration :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/amelioration`)
3. Commiter (`git commit -m "feat: ajout de..."`)
4. Pousser (`git push origin feature/amelioration`)
5. Ouvrir une Pull Request

---

## 📄 Licence

Ce projet est sous licence **MIT**. Voir [LICENSE](LICENSE) pour plus de détails.

### Sources de données

- **PEIGEO** (AGORAH) : données publiques, licence ouverte
- **OpenFreeMap** : [licence OpenFreeMap](https://openfreemap.org/)
- **Esri World Imagery** : © Esri, Maxar, Earthstar Geographics
- **API Géo** : © IGN / data.gouv.fr

---

## 👤 Auteur

**gunout** — [GitHub](https://github.com/gunout)

---

## 🙏 Remerciements

- **AGORAH** pour la mise à disposition des données via PEIGEO
- **MapLibre** et **OpenFreeMap** pour les outils open source
- La communauté **OpenStreetMap** pour les données de base

---

<p align="center">
  <sub>Fait avec ❤️ pour La Réunion · 2026</sub>
</p>
