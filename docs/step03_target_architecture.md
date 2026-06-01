# Etape 3 - Architecture cible SAP BTP / ABAP Cloud / RAP

## Objectif de l'architecture

La cible `ZFLIGHT_BTP_RAP` transforme le scenario Flight Reference Scenario en application cloud-ready :

- persistence autonome en namespace `Z*`;
- RAP managed pour le coeur transactionnel `Travel -> Booking -> BookingSupplement`;
- CDS view entities pour l'exposition semantique;
- projections transactionnelles pour Fiori Elements;
- service definition OData V4 UI;
- logique metier dans behavior implementations et classes helper ABAP Cloud;
- aucun `CALL FUNCTION`, Dynpro, ALV, SAP GUI, `COMMIT WORK` applicatif ou acces direct aux tables depuis l'UI.

## Vue d'ensemble cible

```text
Fiori Elements
  |
  | OData V4 UI
  v
Service Binding ZUI_FLIGHT_SERVICE_O4
  |
  v
Service Definition ZUI_FLIGHT_SERVICE
  |
  v
Projection Layer
  ZC_Travel
    -> ZC_Booking
        -> ZC_BookingSupplement
  ZC_Flight, ZC_Carrier, ZC_Connection, ZC_Customer, ZC_Airport
  |
  v
Interface Layer
  ZI_Travel
    -> ZI_Booking
        -> ZI_BookingSupplement
  ZI_Flight, ZI_Carrier, ZI_Connection, ZI_Customer, ZI_Airport
  ZI_TravelStatusVH, ZI_BookingStatusVH
  |
  v
RAP Behavior Layer
  ZI_Travel behavior managed
  ZI_Booking behavior managed child
  ZI_BookingSupplement behavior managed child
  |
  v
Behavior Implementations / Helpers
  ZBP_I_TRAVEL
  ZBP_I_BOOKING
  ZBP_I_BOOKSUPPL
  ZCL_FLIGHT_RULES
  ZCL_FLIGHT_PRICING
  ZCL_FLIGHT_DEMO_DATA_GEN
  |
  v
Persistence Layer
  ZFLIGHT_TRAVEL
  ZFLIGHT_BOOKING
  ZFLIGHT_BOOKSUPPL
  ZFLIGHT_FLIGHT
  ZFLIGHT_CARRIER
  ZFLIGHT_CONN
  ZFLIGHT_CUSTOMER
  ZFLIGHT_AIRPORT
  ZFLIGHT_* status/value help tables
```

## Couches et responsabilites

| Couche | Objets | Responsabilite |
|---|---|---|
| Package | `ZFLIGHT_BTP_RAP` | Conteneur logiciel pedagogique et transportable |
| Persistence | Tables `ZFLIGHT_*` | Stockage autonome, pas de dependance obligatoire `/DMO/*` |
| Interface CDS | `ZI_*` | Modele canonique, associations, compositions, semantique metier |
| Projection CDS | `ZC_*` | Contrat transactionnel UI, renommage propre, annotations de consommation |
| Behavior Definition | `ZI_*` / `ZC_*` behavior | Operations, validations, determinations, actions, field control |
| Behavior Implementation | `ZBP_I_*` | Code metier RAP, EML, messages `reported`/`failed` |
| Helper Classes | `ZCL_FLIGHT_*` | Regles partagees, calcul prix, donnees demo, fixtures tests |
| Service Definition | `ZUI_FLIGHT_SERVICE` | Exposition OData V4 des entites utiles |
| Service Binding | `ZUI_FLIGHT_SERVICE_O4` | Binding OData V4 UI pour Fiori Elements |
| UI Metadata | annotations dans CDS + metadata extensions | List Report/Object Page, facets, line items, value helps |
| Tests | ABAP Unit | Validations, actions, determinations, EML CUD |

## Aggregate RAP principal

Le coeur transactionnel doit etre modelise comme un aggregate RAP :

```text
ZI_Travel  (root)
  composition [0..*] _Booking -> ZI_Booking
    composition [0..*] _BookingSupplement -> ZI_BookingSupplement
```

Raisons :

- le depot source modelise deja `Booking` et `BookingSupplement` comme sous-noeuds de `Travel`;
- les operations create/update/delete sont coherentes au niveau Travel;
- le recalcul du total Travel depend des enfants;
- la suppression cascade est naturelle via composition;
- Fiori Elements peut generer une Object Page Travel avec table de bookings.

## Persistence layer

### Tables transactionnelles

| Table cible | Clef | Champs principaux | Remarque |
|---|---|---|---|
| `ZFLIGHT_TRAVEL` | `client`, `travel_id` | `agency_id`, `customer_id`, `begin_date`, `end_date`, `booking_fee`, `total_price`, `currency_code`, `description`, `overall_status`, audit fields | Reprend l'esprit `/DMO/TRAVEL_M` |
| `ZFLIGHT_BOOKING` | `client`, `travel_id`, `booking_id` | `booking_date`, `customer_id`, `carrier_id`, `connection_id`, `flight_date`, `flight_price`, `currency_code`, `booking_status`, `last_changed_at` | Child de Travel |
| `ZFLIGHT_BOOKSUPPL` | `client`, `travel_id`, `booking_id`, `booking_supplement_id` | `supplement_id`, `price`, `currency_code`, `last_changed_at` | Option recommande pour fidelite metier |

### Tables reference/master data

| Table cible | Role |
|---|---|
| `ZFLIGHT_FLIGHT` | Vols disponibles, prix de reference, places |
| `ZFLIGHT_CARRIER` | Compagnies aeriennes |
| `ZFLIGHT_CONN` | Connexions aeriennes |
| `ZFLIGHT_CUSTOMER` | Clients/passagers |
| `ZFLIGHT_AIRPORT` | Aeroports |
| `ZFLIGHT_SUPPLEMENT`, `ZFLIGHT_SUPPL_TEXT` | Supplements de reservation |
| `ZFLIGHT_TRVL_STAT`, `ZFLIGHT_TRVL_STATT` | Statuts Travel et textes |
| `ZFLIGHT_BOOK_STAT`, `ZFLIGHT_BOOK_STATT` | Statuts Booking et textes |

### Pourquoi ne pas pointer directement sur `/DMO/*`

Pointer sur `/DMO/*` serait rapide si le sample SAP est installe, mais moins portable :

- le tenant Trial peut ne pas contenir les objets `/DMO/*`;
- les objets Z deviendraient dependants d'un namespace sample;
- la migration Clean Core doit etre autonome et explicite.

Le code genere pourra toutefois signaler une variante "reuse `/DMO/*`" si l'utilisateur veut accelerer un prototype.

## Interface CDS layer

| CDS | Source | Type | Associations principales |
|---|---|---|---|
| `ZI_Travel` | `ZFLIGHT_TRAVEL` | root view entity | `_Booking`, `_Customer`, `_Currency`, `_TravelStatus` |
| `ZI_Booking` | `ZFLIGHT_BOOKING` | child view entity | parent `_Travel`, `_BookSupplement`, `_Customer`, `_Carrier`, `_Connection`, `_Flight`, `_BookingStatus` |
| `ZI_BookingSupplement` | `ZFLIGHT_BOOKSUPPL` | child view entity | parent `_Booking`, `_Supplement`, `_SupplementText` |
| `ZI_Flight` | `ZFLIGHT_FLIGHT` | view entity read-only | `_Carrier`, `_Connection`, `_Currency` |
| `ZI_Carrier` | `ZFLIGHT_CARRIER` | view entity read-only | `_Currency` |
| `ZI_Connection` | `ZFLIGHT_CONN` | view entity read-only | `_Carrier`, `_DepartureAirport`, `_DestinationAirport` |
| `ZI_Customer` | `ZFLIGHT_CUSTOMER` | view entity read-only | `_Country` |
| `ZI_Airport` | `ZFLIGHT_AIRPORT` | view entity read-only | `_Country` |
| `ZI_TravelStatusVH` | status table or constants table | value help | `_Text` if text table created |
| `ZI_BookingStatusVH` | status table or constants table | value help | `_Text` if text table created |

Principes CDS :

- utiliser `define root view entity` pour `ZI_Travel`;
- utiliser `composition` pour les enfants;
- utiliser `association to parent` pour les children;
- poser `@Semantics.amount.currencyCode` sur tous les montants;
- poser `@Semantics.systemDateTime.*` sur champs audit;
- eviter les `SELECT *` et champs techniques inutiles dans les projections.

## Projection layer

| Projection | Role UI/API |
|---|---|
| `ZC_Travel` | Entite principale du List Report/Object Page |
| `ZC_Booking` | Table enfant dans Object Page Travel + detail Booking |
| `ZC_BookingSupplement` | Table enfant dans detail Booking |
| `ZC_Flight` | Liste read-only des vols et value help |
| `ZC_Carrier` | Read-only master data/value help |
| `ZC_Connection` | Read-only master data/value help |
| `ZC_Customer` | Read-only master data/value help |
| `ZC_Airport` | Read-only master data/value help |

Les projections transactionnelles utiliseront :

- `provider contract transactional_query` pour `ZC_Travel`;
- redirections de composition : `_Booking : redirected to composition child ZC_Booking`;
- redirections parent : `_Travel : redirected to parent ZC_Travel`;
- annotations UI et consumption value helps au niveau projection ou metadata extension.

## Behavior definitions

### Behavior root `ZI_Travel`

Mode cible :

```abap
managed implementation in class ZBP_I_TRAVEL unique;
strict ( 2 );
```

Operations :

- `create`
- `update`
- `delete`
- `early numbering`
- lock master
- etag master `last_changed_at`
- authorization master `none` au depart, extensible plus tard

Fields :

- readonly : clef `travel_id`, champs audit, `total_price`
- mandatory : `agency_id`, `customer_id`, `begin_date`, `end_date`, `booking_fee`, `currency_code`, `overall_status`

Validations :

- `validateAgency`
- `validateCustomer`
- `validateDates`
- `validateStatus`
- `validateCurrencyCode`
- `validateBookingFee`

Determinations :

- `calculateTotalPrice on modify`
- internal action `ReCalcTotalPrice` si necessaire pour propagation depuis enfants

Actions :

- `setStatusBooked result [1] $self`
- `setStatusCancelled result [1] $self`
- `copyTravel [1]` en factory action

Associations :

- `_Booking { create; }`

### Behavior child `ZI_Booking`

Operations :

- `update`
- create by association depuis Travel
- delete optionnel en vague 1; recommande si recalcul total bien couvert

Fields :

- readonly : `travel_id`, `booking_id`, `last_changed_at`
- mandatory : `booking_date`, `customer_id`, `carrier_id`, `connection_id`, `flight_date`, `currency_code`, `booking_status`
- readonly/update-control : `flight_price` peut etre determine depuis `ZI_Flight`

Validations :

- `validateBookingDate`
- `validateCustomer`
- `validateFlight`
- `validateCurrencyCode`
- `validateStatus`

Determinations :

- `determineFlightPrice on modify` pour recuperer prix/devise du vol;
- declencher recalcul total Travel apres changement du prix.

Associations :

- `_BookSupplement { create; }`
- `_Travel { }`

### Behavior child `ZI_BookingSupplement`

Operations :

- `update`
- create by association depuis Booking
- delete optionnel en vague 1

Fields :

- readonly : clefs, `last_changed_at`
- mandatory : `supplement_id`, `price`, `currency_code`

Validations :

- `validateSupplement`
- `validatePrice`
- `validateCurrencyCode`

Determinations :

- determiner prix/devise depuis `ZI_Supplement` si master data disponible;
- declencher recalcul total Travel.

## Behavior implementations

| Classe | Responsabilites |
|---|---|
| `ZBP_I_TRAVEL` | validations root, actions statut/copie, early numbering Travel, recalcul total, orchestration EML locale |
| `ZBP_I_BOOKING` | validations booking, derivation prix de vol, early numbering child, propagation recalcul total |
| `ZBP_I_BOOKSUPPL` | validations supplement, derivation prix supplement, early numbering child |
| `ZCL_FLIGHT_RULES` | checks purs : date, statut, montant, existence clefs |
| `ZCL_FLIGHT_PRICING` | calcul total Travel, conversion devise simplifiee, calcul prix vol si action admin retenue |

Regles de implementation :

- utiliser `READ ENTITIES ... IN LOCAL MODE` pour lire l'aggregate pendant les validations/determinations;
- utiliser `MODIFY ENTITIES ... IN LOCAL MODE` pour determinations qui mettent a jour `total_price`, `flight_price` ou statut;
- utiliser `reported` et `failed`, pas d'exceptions non gerees vers l'UI;
- pas de singleton mutable;
- pas de `COMMIT WORK`;
- pas de function module legacy.

## Service definition

Service cible :

```abap
@EndUserText.label: 'Flight RAP service'
@ObjectModel.leadingEntity.name: 'ZC_Travel'
define service ZUI_FLIGHT_SERVICE {
  expose ZC_Travel as Travel;
  expose ZC_Booking as Booking;
  expose ZC_BookingSupplement as BookingSupplement;
  expose ZC_Flight as Flight;
  expose ZC_Carrier as Carrier;
  expose ZC_Connection as Connection;
  expose ZC_Customer as Customer;
  expose ZC_Airport as Airport;
  expose ZI_TravelStatusVH as TravelStatus;
  expose ZI_BookingStatusVH as BookingStatus;
  expose I_CurrencyStdVH as Currency;
  expose I_CountryVH as Country;
}
```

Remarque Trial :

- `I_CurrencyStdVH` et `I_CountryVH` sont des vues standard souvent disponibles/released dans ABAP Environment, mais elles devront etre verifiees dans ADT.
- Si indisponibles, creer `ZI_CurrencyVH` et `ZI_CountryVH` simplifiees ou retirer temporairement les value helps.

## Service binding

| Parametre | Valeur |
|---|---|
| Nom | `ZUI_FLIGHT_SERVICE_O4` |
| Service definition | `ZUI_FLIGHT_SERVICE` |
| Binding type | OData V4 - UI |
| Protocole | OData V4 |
| Usage | Fiori Elements preview / application |

Etapes ADT attendues :

1. Creer le service binding.
2. Choisir `OData V4 - UI`.
3. Activer.
4. Publier le service.
5. Ouvrir Fiori Elements preview sur entity set `Travel`.

## Fiori Elements UI

### Liste principale

Entite principale : `ZC_Travel`.

Champs liste :

- `TravelID`
- `AgencyID` + texte agence si disponible
- `CustomerID` + `CustomerName`
- `BeginDate`
- `EndDate`
- `TotalPrice`
- `CurrencyCode`
- `OverallStatus`

Actions ligne :

- `copyTravel`
- `setStatusBooked`
- `setStatusCancelled`

### Object Page Travel

Facets :

| Facet | Type | Cible |
|---|---|---|
| Travel | Identification | Champs principaux Travel |
| Bookings | Line item reference | `_Booking` |
| Customer | Identification/field group | association `_Customer` |
| Status/Price | Field group | statut, montant, devise |

### Detail Booking

Champs :

- `BookingID`
- `BookingDate`
- `CustomerID`
- `CarrierID`
- `ConnectionID`
- `FlightDate`
- `FlightPrice`
- `CurrencyCode`
- `BookingStatus`

Value helps dependantes :

- `CarrierID` depuis `ZC_Flight`;
- `ConnectionID` filtre/resultat par `CarrierID`;
- `FlightDate` filtre/resultat par `CarrierID` + `ConnectionID`;
- `FlightPrice` et `CurrencyCode` en result binding.

### Detail Booking Supplement

Champs :

- `BookingSupplementID`
- `SupplementID`
- `Price`
- `CurrencyCode`

## Tests ABAP Unit

### Scope minimum

| Classe test | Cas |
|---|---|
| `LTCL_TRAVEL_VALIDATIONS` dans `ZBP_I_TRAVEL` | agence/client/status/devise/dates invalides |
| `LTCL_BOOKING_VALIDATIONS` dans `ZBP_I_BOOKING` | vol inexistant, client invalide, statut booking |
| `LTCL_PRICING` dans `ZCL_FLIGHT_PRICING` | total Travel, montants multi-lignes, devise identique |
| `LTCL_ACTIONS` | `setStatusBooked`, `setStatusCancelled`, `copyTravel` |
| `LTCL_EML_CRUD` | create Travel, create Booking by association, update, delete |

### Strategie de test

- utiliser `MODIFY ENTITIES` et `READ ENTITIES` pour tester comme un consommateur RAP;
- isoler les calculs purs dans `ZCL_FLIGHT_PRICING` pour tests rapides;
- prevoir des fixtures de master data dans `ZCL_FLIGHT_TEST_ENV` ou tables test locales selon capacites du tenant;
- ne pas dependre du sample `/DMO/*` pour les tests finaux.

## Objets autorises / Clean Core

Autorise dans la cible :

- CDS view entities;
- behavior definitions et implementations RAP;
- ABAP classes globales;
- EML;
- Open SQL sur tables Z et CDS Z;
- value helps standard released si disponibles;
- Fiori Elements via OData V4 UI.

Exclu :

- `CALL FUNCTION /DMO/*`;
- `CALL TRANSACTION`;
- Dynpro/Screen Painter;
- ALV/SAP GUI comme UI finale;
- `GUI_DOWNLOAD` / `GUI_UPLOAD`;
- `WRITE` list comme interface;
- `COMMIT WORK` dans behavior implementations;
- modifications standard SAP;
- dependance obligatoire au namespace `/DMO/*`.

## Variantes de realisation

### Variante A - Portable Trial autonome

Cette variante sera retenue pour la generation :

- cree tables Z;
- cree CDS `ZI_*` et `ZC_*`;
- charge un petit jeu de donnees demo via classe ou instructions ADT;
- ne reference `/DMO/*` que dans la documentation de migration.

Avantage : compatible Trial et Clean Core.

Limite : plus de code de persistence a generer.

### Variante B - Prototype rapide sur sample installe

- `ZI_*` peut selectionner depuis `/DMO/*` ou projeter `/DMO/I_*`;
- moins d'objets Z de persistence;
- utile pour demo rapide.

Limite : dependance au sample SAP et moins representatif d'une migration autonome.

### Variante C - Unmanaged pedagogique

- remplace les function modules par `ZCL_FLIGHT_LEGACY_ADAPTER`;
- behavior unmanaged conserve late numbering et saver;
- utile pour montrer une migration progressive depuis API procedurale.

Limite : plus complexe et moins recommande pour demarrer sur BTP Trial.

## Ordre de generation propose

1. Package `ZFLIGHT_BTP_RAP`.
2. Tables persistence Z et eventuelles value help tables.
3. Interface CDS `ZI_Carrier`, `ZI_Connection`, `ZI_Flight`, `ZI_Customer`, puis `ZI_Travel`, `ZI_Booking`, `ZI_BookingSupplement`.
4. Projection CDS `ZC_*`.
5. Behavior definitions managed pour `ZI_Travel`, `ZI_Booking`, `ZI_BookingSupplement`.
6. Behavior projection definitions pour `ZC_*`.
7. Classes `ZBP_I_*`, `ZCL_FLIGHT_RULES`, `ZCL_FLIGHT_PRICING`.
8. Service definition `ZUI_FLIGHT_SERVICE`.
9. Service binding OData V4 UI dans ADT.
10. Metadata extensions UI si les annotations sont separees.
11. ABAP Unit.
12. Guide import/execution ADT.

## Decision pour l'etape 4

L'etape 4 generera les CDS view entities progressivement.

Pour rester coherent avec SAP BTP Trial, la generation doit commencer par une base portable :

- soit inclure les DDL table definitions avant les CDS;
- soit documenter que les tables Z sont prealablement creees dans ADT.

Comme les CDS `ZI_*` dependent des tables, la prochaine generation devra probablement produire d'abord les tables `ZFLIGHT_*` minimales, puis les CDS interface. Cela ajoute une micro-etape technique necessaire, sans changer la methode globale.

