# Etape 4 - Generation des tables Z et CDS interface

## Perimetre genere

Cette etape genere les prerequis persistence et les CDS view entities d'interface.

Repertoire :

```text
zflight_btp_rap/step04_cds/
  tables/
  cds/
```

Les projections `ZC_*`, behaviors, service definition, service binding et annotations UI detaillees seront generes dans les etapes suivantes. Ici, l'objectif est d'obtenir une base de modele de donnees stable.

## Ce qui est migre

| Source legacy | Cible generee | Commentaire |
|---|---|---|
| `/DMO/TRAVEL` | `zflight_travel`, `ZI_Travel` | Racine transactionnelle ajoutee explicitement |
| `/DMO/BOOKING` | `zflight_booking`, `ZI_Booking` | Child de Travel |
| `/DMO/BOOK_SUPPL` | `zflight_booksuppl`, `ZI_BookingSupplement` | Child de Booking |
| `/DMO/FLIGHT` | `zflight_flight`, `ZI_Flight` | Master/read-only initialement |
| `/DMO/CARRIER` | `zflight_carrier`, `ZI_Carrier` | Master/read-only initialement |
| `/DMO/CONNECTION` | `zflight_conn`, `ZI_Connection` | Master/read-only initialement |
| `/DMO/CUSTOMER` | `zflight_customer`, `ZI_Customer` | Master/read-only initialement |
| `/DMO/AIRPORT` | `zflight_airport`, `ZI_Airport` | Support value help |
| `/DMO/SUPPLEMENT` | `zflight_supplement`, `ZI_Supplement` | Support Booking Supplement |
| `/DMO/TRVL_STAT*` | `zflight_trvl_stat`, `ZI_TravelStatusVH` | Value help simplifiee |
| `/DMO/BOOK_STAT*` | `zflight_book_stat`, `ZI_BookingStatusVH` | Value help simplifiee |

## Pourquoi ces choix

- Les tables sont en namespace `Z*` pour eviter une dependance obligatoire au sample `/DMO/*`.
- Les types utilisent principalement `abap.*` pour rester portables dans SAP BTP ABAP Environment Trial.
- `Travel` est ajoute car `Booking` est un enfant du scenario source, pas une racine autonome.
- Les statuts sont modelises en petites tables simples avec texte embarque pour demarrer vite. Des tables texte separees pourront etre ajoutees si la localisation devient prioritaire.
- `Flight`, `Carrier`, `Connection`, `Customer`, `Airport`, `Supplement` sont modelises comme master data read-only au depart. Le CRUD master data pourra etre ajoute plus tard avec behaviors separes.

## Fichiers generes

### Tables

| Fichier | Objet |
|---|---|
| `zflight_btp_rap/step04_cds/tables/zflight_travel.ddls` | `zflight_travel` |
| `zflight_btp_rap/step04_cds/tables/zflight_booking.ddls` | `zflight_booking` |
| `zflight_btp_rap/step04_cds/tables/zflight_booksuppl.ddls` | `zflight_booksuppl` |
| `zflight_btp_rap/step04_cds/tables/zflight_carrier.ddls` | `zflight_carrier` |
| `zflight_btp_rap/step04_cds/tables/zflight_conn.ddls` | `zflight_conn` |
| `zflight_btp_rap/step04_cds/tables/zflight_flight.ddls` | `zflight_flight` |
| `zflight_btp_rap/step04_cds/tables/zflight_customer.ddls` | `zflight_customer` |
| `zflight_btp_rap/step04_cds/tables/zflight_airport.ddls` | `zflight_airport` |
| `zflight_btp_rap/step04_cds/tables/zflight_supplement.ddls` | `zflight_supplement` |
| `zflight_btp_rap/step04_cds/tables/zflight_trvl_stat.ddls` | `zflight_trvl_stat` |
| `zflight_btp_rap/step04_cds/tables/zflight_book_stat.ddls` | `zflight_book_stat` |

### CDS interface

| Fichier | Objet |
|---|---|
| `zflight_btp_rap/step04_cds/cds/zi_travel.ddls` | `ZI_Travel` |
| `zflight_btp_rap/step04_cds/cds/zi_booking.ddls` | `ZI_Booking` |
| `zflight_btp_rap/step04_cds/cds/zi_booking_supplement.ddls` | `ZI_BookingSupplement` |
| `zflight_btp_rap/step04_cds/cds/zi_flight.ddls` | `ZI_Flight` |
| `zflight_btp_rap/step04_cds/cds/zi_carrier.ddls` | `ZI_Carrier` |
| `zflight_btp_rap/step04_cds/cds/zi_connection.ddls` | `ZI_Connection` |
| `zflight_btp_rap/step04_cds/cds/zi_customer.ddls` | `ZI_Customer` |
| `zflight_btp_rap/step04_cds/cds/zi_airport.ddls` | `ZI_Airport` |
| `zflight_btp_rap/step04_cds/cds/zi_supplement.ddls` | `ZI_Supplement` |
| `zflight_btp_rap/step04_cds/cds/zi_travel_status_vh.ddls` | `ZI_TravelStatusVH` |
| `zflight_btp_rap/step04_cds/cds/zi_booking_status_vh.ddls` | `ZI_BookingStatusVH` |

## Ordre d'import ADT recommande

1. Creer le package `ZFLIGHT_BTP_RAP`.
2. Creer/activer les tables :
   - `zflight_carrier`
   - `zflight_airport`
   - `zflight_conn`
   - `zflight_flight`
   - `zflight_customer`
   - `zflight_supplement`
   - `zflight_trvl_stat`
   - `zflight_book_stat`
   - `zflight_travel`
   - `zflight_booking`
   - `zflight_booksuppl`
3. Creer/activer les CDS master data :
   - `ZI_Carrier`
   - `ZI_Airport`
   - `ZI_Connection`
   - `ZI_Flight`
   - `ZI_Customer`
   - `ZI_Supplement`
   - `ZI_TravelStatusVH`
   - `ZI_BookingStatusVH`
4. Creer/activer les CDS transactionnels :
   - `ZI_Travel`
   - `ZI_Booking`
   - `ZI_BookingSupplement`

Note : si ADT exige les children avant le root a cause des compositions, activer en deux passes est normal : creer tous les CDS, puis activer massivement le package.

## Limites SAP BTP Trial a verifier

- La syntaxe exacte des DDL table definitions peut varier legerement selon release ABAP Environment. Les types `abap.utclong`, `abap.unit`, `abap.cuky` sont choisis pour eviter les data elements `/DMO/*`, mais ADT reste l'arbitre.
- Les champs audit sont prepares pour RAP managed, mais les annotations/champs definitifs pourront etre ajustes au moment des behavior definitions.
- Les value helps devise/pays standard (`I_CurrencyStdVH`, `I_CountryVH`) ne sont pas references dans cette etape pour garder les CDS autonomes. Elles seront ajoutees dans les projections si disponibles.
- Les donnees demo ne sont pas encore chargees. Une classe `ZCL_FLIGHT_DEMO_DATA_GEN` sera prevue plus tard.
- Les projections `ZC_*` ne sont pas encore generees. Elles viendront avant le service OData V4 et porteront l'essentiel des annotations Fiori Elements.

## Prochaine etape

Etape 5 : generation des behavior definitions managed pour :

- `ZI_Travel`
- `ZI_Booking`
- `ZI_BookingSupplement`

Il faudra declarer les operations, validations, determinations, actions, compositions, numbering, lock et etag.

