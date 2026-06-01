# Etape 2 - Cartographie legacy vers RAP / SAP BTP

## Positionnement

Cette etape traduit les objets analyses dans `src/legacy`, `src/reuse`, `src/managed` et `src/unmanaged` vers une cible `ZFLIGHT_BTP_RAP`.

Decision structurante :

- **Chemin recommande SAP BTP Trial** : RAP managed, tables persistantes Z, CDS view entities `ZI_*`, projections `ZC_*`, service OData V4, Fiori Elements.
- **Chemin pedagogique alternatif** : RAP unmanaged uniquement si l'objectif est de conserver une API legacy procedurale. Dans ce cas, les function modules `/DMO/FLIGHT_TRAVEL_*` doivent etre remplaces par une classe ABAP Cloud compatible, pas appeles directement.

Le depot contient deja des exemples SAP utiles :

- `/DMO/I_Travel_M`, `/DMO/I_Booking_M`, `/DMO/I_BookSuppl_M` : modele managed a reprendre comme inspiration.
- `/DMO/I_Travel_U`, `/DMO/I_Booking_U`, `/DMO/I_BookingSupplement_U` : modele unmanaged adosse au legacy, a ne pas copier tel quel pour ABAP Cloud Trial car il appelle des function modules.
- `/DMO/I_Flight`, `/DMO/I_Carrier`, `/DMO/I_Connection`, `/DMO/I_Customer` : vues reuse directement alignables avec les objets demandes.

## Ajout necessaire : Travel

La demande cible liste :

- `ZI_Flight`
- `ZI_Carrier`
- `ZI_Connection`
- `ZI_Booking`
- `ZI_Customer`

Mais le scenario Flight Reference Scenario complet est structure autour de la racine **Travel** :

```text
Travel
  -> Booking
       -> BookingSupplement
```

Sans `ZI_Travel` / `ZC_Travel`, `ZI_Booking` devient un objet enfant sans racine transactionnelle correcte. La cartographie cible ajoute donc explicitement :

- `ZI_Travel`
- `ZC_Travel`
- behavior root `ZI_Travel`
- projection behavior `ZC_Travel`

Ce n'est pas une invention fonctionnelle : c'est la racine existante `/DMO/TRAVEL` du depot.

## Cartographie tables legacy vers persistence Z et CDS

| Legacy | Role | Cible persistence proposee | CDS interface | CDS projection | Mode |
|---|---|---|---|---|---|
| `/DMO/TRAVEL` | Racine Travel legacy | `ZFLIGHT_TRAVEL` | `ZI_Travel` | `ZC_Travel` | Transactionnel managed |
| `/DMO/BOOKING` | Reservation enfant | `ZFLIGHT_BOOKING` | `ZI_Booking` | `ZC_Booking` | Transactionnel managed, composition de Travel |
| `/DMO/BOOK_SUPPL` | Supplement reservation | `ZFLIGHT_BOOKSUPPL` | `ZI_BookingSupplement` | `ZC_BookingSupplement` | Optionnel mais recommande pour fidelite metier |
| `/DMO/FLIGHT` | Vol disponible | `ZFLIGHT_FLIGHT` ou table `/DMO/FLIGHT` si sample installe | `ZI_Flight` | `ZC_Flight` | Read-only master/value help par defaut |
| `/DMO/CONNECTION` | Connexion aerienne | `ZFLIGHT_CONNECTION` ou `/DMO/CONNECTION` | `ZI_Connection` | `ZC_Connection` | Read-only master/value help par defaut |
| `/DMO/CARRIER` | Compagnie | `ZFLIGHT_CARRIER` ou `/DMO/CARRIER` | `ZI_Carrier` | `ZC_Carrier` | Read-only master/value help, CRUD possible plus tard |
| `/DMO/CUSTOMER` | Client/passager | `ZFLIGHT_CUSTOMER` ou `/DMO/CUSTOMER` | `ZI_Customer` | `ZC_Customer` | Read-only master/value help, CRUD possible plus tard |
| `/DMO/AIRPORT` | Aeroport | `ZFLIGHT_AIRPORT` | `ZI_Airport` | `ZC_Airport` | Value help/support |
| `/DMO/TRVL_STAT`, `/DMO/TRVL_STAT_T` | Statuts Travel | `ZFLIGHT_TRVL_STAT*` ou enum/domain constants | `ZI_TravelStatusVH` | expose service only | Value help |
| `/DMO/BOOK_STAT`, `/DMO/BOOK_STAT_T` | Statuts Booking | `ZFLIGHT_BOOK_STAT*` ou enum/domain constants | `ZI_BookingStatusVH` | expose service only | Value help |
| `/DMO/SUPPLEMENT`, `/DMO/SUPPL_TEXT` | Supplements | `ZFLIGHT_SUPPLEMENT*` | `ZI_Supplement` | `ZC_Supplement` | Value help/support |

### Variante Trial minimale

Pour limiter la charge initiale dans SAP BTP Trial :

- creer les tables Z pour `Travel`, `Booking`, `Flight`, `Carrier`, `Connection`, `Customer`;
- garder `BookingSupplement`, `Airport`, statuts et supplements pour une deuxieme vague si necessaire;
- si le sample `/DMO/*` est installe dans le tenant, utiliser les CDS `/DMO/I_*` comme source de reference, mais eviter de les rendre obligatoires dans les objets Z finaux.

## Cartographie fonction modules vers RAP / classes ABAP Cloud

| Function module legacy | Role legacy | Remplacement RAP / ABAP Cloud | Commentaire |
|---|---|---|---|
| `/DMO/FLIGHT_TRAVEL_CREATE` | Creation Travel + sous-noeuds | `create` RAP sur `ZI_Travel`, create-by-association `_Booking`, `_BookingSupplement` | Managed RAP remplace le buffer create |
| `/DMO/FLIGHT_TRAVEL_UPDATE` | Update via structures X | `update` RAP + field control + validations `on save` | Les structures X deviennent inutiles en RAP managed |
| `/DMO/FLIGHT_TRAVEL_DELETE` | Suppression cascade | `delete` root + composition cascade | La cascade est portee par composition/behavior |
| `/DMO/FLIGHT_TRAVEL_READ` | Lecture BO | `READ ENTITIES OF ZI_Travel` ou consommation OData | Plus de API FM read |
| `/DMO/FLIGHT_TRAVEL_SET_BOOKING` | Mettre Travel au statut booked | Action RAP `setStatusBooked` ou `acceptTravel` | Action instance avec result `$self` |
| `/DMO/FLIGHT_TRAVEL_ADJ_NUMBERS` | Late numbering | `early numbering` managed ou numbering method RAP | Recommande : early numbering pour Trial |
| `/DMO/FLIGHT_TRAVEL_SAVE` | Sauvegarde buffer | Managed save RAP | Pas de `COMMIT WORK` applicatif |
| `/DMO/FLIGHT_TRAVEL_INITIALIZE` | Reset buffer | Non necessaire managed RAP | Le cycle transactionnel RAP remplace le buffer |
| `/DMO/FLIGHT_TRAVEL_CALC_PRICE` | Calcul prix de vol selon occupation/distance | Classe helper `ZCL_FLIGHT_PRICING` + determination/action | Ne pas modifier `/DMO/FLIGHT` directement dans le BO Travel |
| `/DMO/FLIGHT_BOOKSUPPL_C/U/D` | Update task supplements dans variante managed sample | Managed child `ZI_BookingSupplement` ou classe saver locale | A eviter en ABAP Cloud cible |

## Cartographie classes legacy vers classes cible

| Classe/interface legacy | Role | Cible proposee | Type cible |
|---|---|---|---|
| `/DMO/CL_FLIGHT_LEGACY` | Facade singleton, buffers, CUD, validations, determinations | Logique repartie entre `ZBP_I_TRAVEL`, `ZBP_I_BOOKING`, `ZCL_FLIGHT_RULES`, `ZCL_FLIGHT_PRICING` | Behavior implementation + helper classes |
| `/DMO/IF_FLIGHT_LEGACY` | Types API, enums, constants | Types DDIC Z + constants dans `ZIF_FLIGHT_CONSTANTS` ou classe constants | Interface ou classe finale ABAP Cloud |
| `/DMO/CX_FLIGHT_LEGACY` | Exceptions/messages | Messages RAP via `reported`/`failed`, message class `ZFLIGHT_MSG` si besoin | Message class + exception optionnelle |
| `/DMO/CL_FLIGHT_DATA_GENERATOR` | Generation donnees demo | `ZCL_FLIGHT_DEMO_DATA_GEN` | Classe utilitaire executable depuis ADT, non UI |
| `/DMO/CL_FLIGHT_AMDP` | Logique AMDP legacy | Remplacer par CDS/ABAP SQL/helper released | Eviter AMDP pour Trial sauf necessite prouvee |
| `/DMO/CM_FLIGHT_MESSAGES` | Messages reuse | `ZCM_FLIGHT_MESSAGES` ou message class `ZFLIGHT_MSG` | Reprise selective des messages |

## Cartographie logique metier procedurale vers RAP

| Regle legacy observee | Source | Cible RAP | Niveau |
|---|---|---|---|
| Agence obligatoire/existante | `_check_agency` Travel | `validation validateAgency on save` | `ZI_Travel` |
| Client obligatoire/existant | `_check_customer` Travel/Booking | `validation validateCustomer on save` | `ZI_Travel`, `ZI_Booking` |
| Dates Travel coherentes | `_check_dates` | `validation validateDates on save` | `ZI_Travel` |
| Statut Travel autorise (`N`, `P`, `B`, `X`) | enum `/DMO/IF_FLIGHT_LEGACY=>travel_status` | `validation validateStatus on save` + value help | `ZI_Travel` |
| Devise valide | `_check_currency_code` | `validation validateCurrencyCode on save` avec `I_Currency` ou `I_CurrencyStdVH` | Travel/Booking/Supplement |
| Booking date obligatoire/coherente | `_check_booking_date` | `validation validateBookingDate on save` | `ZI_Booking` |
| Vol existe pour carrier/connection/date | `_check_flight` | `validation validateFlight on save` contre `ZI_Flight` | `ZI_Booking` |
| Prix booking derive du vol | `_determine` Booking | `determination determineFlightPrice on modify` | `ZI_Booking` |
| Total Travel = fee + bookings + supplements | `_determine_travel_total_price` | `determination calculateTotalPrice on modify` + internal action `ReCalcTotalPrice` | `ZI_Travel` |
| Mise au statut booked | `set_status_to_booked` | Action `setStatusBooked result [1] $self` | `ZI_Travel` |
| Copie d'un travel | sample managed `copyTravel` | Factory action `copyTravel [1]` | `ZI_Travel` |
| Late numbering | `adjust_numbers` | Preferer `early numbering`; late numbering seulement si pedagogie legacy | Behavior root/children |
| Messages T100 legacy | `convert_messages` | `reported`/`failed` RAP avec `new_message` | Behavior impl |

## Cartographie acces SQL directs

| Pattern legacy | Exemple observe | Remplacement cible |
|---|---|---|
| `SELECT * FROM /DMO/TRAVEL ...` | lecture legacy root | CDS `ZI_Travel` + `READ ENTITIES` dans behavior |
| `SELECT * FROM /DMO/BOOKING ...` | lecture child | CDS `ZI_Booking` + association `_Booking` |
| `SELECT SINGLE ... FROM /DMO/FLIGHT` | validation/derivation vol | `SELECT` sur `ZI_Flight` ou association CDS `_Flight` dans `ZI_Booking` |
| `INSERT/UPDATE/DELETE /DMO/TRAVEL` | buffer save | Managed RAP persistence table `ZFLIGHT_TRAVEL` |
| `INSERT/UPDATE/DELETE /DMO/BOOKING` | buffer save | Managed RAP persistence table `ZFLIGHT_BOOKING` |
| `UPDATE /DMO/FLIGHT` | recalcul legacy prix de vols | Action/admin service separe, pas dans le BO Travel par defaut |
| `COMMIT WORK` | data generator | Pas dans behavior; uniquement dans programme utilitaire si autorise par contexte ADT |
| `CALL FUNCTION /DMO/FLIGHT_TRAVEL_*` | unmanaged adapter sample | Classe ABAP Cloud ou operations RAP natives |

## Cartographie UI legacy vers Fiori Elements

Le depot analyse ne montre pas de Dynpro, ALV classique ou SAP GUI UI active pour le scenario principal. La cible UI sera donc directement Fiori Elements :

| Ancien modele d'interaction | Cible |
|---|---|
| Lecture liste vols | List Report `ZC_Flight` ou section read-only dans service |
| Gestion travels/bookings | Fiori Elements List Report/Object Page sur `ZC_Travel` |
| Detail Travel | Object Page `ZC_Travel` avec facets `Bookings`, `Customer`, `Carrier`, `Agency` |
| Reservations associees | Composition child `_Booking` vers `ZC_Booking` |
| Client associe | Association `_Customer`, text/value help |
| Compagnie aerienne associee | Association `_Carrier`, text/value help |
| Connexion/vol associe | Associations `_Connection`, `_Flight`, value helps dependant carrier |

## Noms cible proposes

### Package

| Objet | Nom cible |
|---|---|
| Package | `ZFLIGHT_BTP_RAP` |

### Persistence layer

| Objet | Nom cible |
|---|---|
| Table Travel | `ZFLIGHT_TRAVEL` |
| Table Booking | `ZFLIGHT_BOOKING` |
| Table Booking Supplement | `ZFLIGHT_BOOKSUPPL` |
| Table Flight | `ZFLIGHT_FLIGHT` |
| Table Carrier | `ZFLIGHT_CARRIER` |
| Table Connection | `ZFLIGHT_CONN` |
| Table Customer | `ZFLIGHT_CUSTOMER` |
| Table Airport | `ZFLIGHT_AIRPORT` |
| Statuts/value helps | `ZFLIGHT_*_STAT*` ou constantes + CDS VH |

### CDS interface et projections

| Interface | Projection | Role |
|---|---|---|
| `ZI_Travel` | `ZC_Travel` | Racine transactionnelle |
| `ZI_Booking` | `ZC_Booking` | Reservation enfant |
| `ZI_BookingSupplement` | `ZC_BookingSupplement` | Supplement enfant, recommande mais optionnel |
| `ZI_Flight` | `ZC_Flight` | Vol, read-only/master |
| `ZI_Carrier` | `ZC_Carrier` | Compagnie |
| `ZI_Connection` | `ZC_Connection` | Connexion |
| `ZI_Customer` | `ZC_Customer` | Client |
| `ZI_Airport` | `ZC_Airport` | Aeroport/value help |
| `ZI_TravelStatusVH` | expose only | Value help |
| `ZI_BookingStatusVH` | expose only | Value help |

### Behaviors

| Objet | Type | Justification |
|---|---|---|
| `ZI_Travel` behavior | Managed root | Compatible Trial, clean, remplace buffers/FM |
| `ZI_Booking` behavior | Managed child | Composition sous Travel |
| `ZI_BookingSupplement` behavior | Managed child | Composition sous Booking |
| `ZC_*` behavior | Projection behavior | Exposition controlee UI/OData |
| `ZI_Flight`, `ZI_Carrier`, `ZI_Connection`, `ZI_Customer` | Read-only initialement | Master data dans ce scenario |

### Classes

| Classe | Role |
|---|---|
| `ZBP_I_TRAVEL` | Behavior implementation root |
| `ZBP_I_BOOKING` | Behavior implementation Booking |
| `ZBP_I_BOOKSUPPL` | Behavior implementation supplement |
| `ZCL_FLIGHT_RULES` | Validations reutilisables, sans state global |
| `ZCL_FLIGHT_PRICING` | Calcul prix et total |
| `ZCL_FLIGHT_DEMO_DATA_GEN` | Chargement donnees demo compatible ADT |
| `ZCL_FLIGHT_TEST_ENV` | Fixtures ABAP Unit si necessaire |

### Service

| Objet | Nom cible |
|---|---|
| Service definition | `ZUI_FLIGHT_SERVICE` |
| Service binding | `ZUI_FLIGHT_SERVICE_O4` ou `ZUI_FLIGHT_SERVICE_BINDING` |
| Binding type | OData V4 - UI |

## Objets a ne pas reprendre tels quels

| Objet/pattern | Raison |
|---|---|
| Function modules `/DMO/FLIGHT_TRAVEL_*` | Non idiomatique ABAP Cloud, remplace par RAP/behavior/classes |
| Buffers singleton de `/DMO/CL_FLIGHT_LEGACY` | Cycle transactionnel RAP gere l'unite de travail |
| Structures X legacy | RAP field control et `UPDATE FIELDS` les remplacent |
| `COMMIT WORK` dans logique applicative | Interdit/inadapte dans behavior RAP |
| `UPDATE /DMO/FLIGHT` depuis un calcul global | Effet de bord hors aggregate Travel |
| AMDP legacy | Non necessaire pour la migration pedagogique BTP Trial |
| References obligatoires `/DMO/*` dans les objets Z finaux | Risque Trial si le sample n'est pas installe |

## Limites identifiees

- La migration exacte des types DDIC `/DMO/*` vers types Z depend de ce qui existe dans le tenant Trial. Pour etre portable, il faudra creer des data elements/tables Z ou utiliser des built-in types dans les DDL table definitions.
- Les service bindings OData V4 sont mieux crees/actives dans ADT. On peut fournir le nom et les etapes, mais le transport texte seul ne suffit pas toujours selon l'environnement.
- La conversion de devise dans le legacy doit etre simplifiee ou branchee sur des APIs released disponibles dans le tenant. Il ne faut pas supposer la presence de toutes les tables taux de change classiques.
- Les statuts et textes peuvent etre modelises en petites tables Z ou en domain fixed values ; pour Fiori Elements, des value helps CDS restent preferables.
- `ZI_Flight` peut etre read-only au depart. Rendre Flight transactionnel impliquerait une autorite differente de l'aggregate Travel et doit etre traite comme master data separee.

## Choix pour l'etape 3

L'architecture cible proposera donc :

1. Persistence Z autonome pour Trial.
2. Interface views `ZI_*` sur tables Z.
3. Projection views `ZC_*`.
4. RAP managed pour `Travel -> Booking -> BookingSupplement`.
5. Read-only projections pour `Flight`, `Carrier`, `Connection`, `Customer` au demarrage.
6. OData V4 UI service `ZUI_FLIGHT_SERVICE`.
7. Fiori Elements Object Page centree sur `Travel`, avec facets bookings et associations vers client/compagnie/vol.
8. ABAP Unit sur validations, determinations, actions, et EML create/update/delete.

