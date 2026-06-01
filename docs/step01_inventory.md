# Etape 1 - Inventaire technique Flight Reference Scenario

## Source analysee

- Depot local analyse : `/home/khalid/projets-vscode/migration-sflight.sauve/source-refscen-flight`
- Remote : `https://github.com/SAP-samples/abap-platform-refscen-flight.git`
- Branche locale : `ABAP-platform-cloud`
- Format : objets ABAPGit sous `src/`

Le workspace cible `/home/khalid/projets-vscode/migration-sflight` etait vide au demarrage. Aucun code cible RAP n'a encore ete genere dans cette etape.

## Vue d'ensemble des objets

Le depot contient deja un scenario RAP pedagogique complet autour du domaine Flight/Travel, avec plusieurs variantes :

| Package source | Role observe |
|---|---|
| `src/legacy` | Tables legacy `/DMO/TRAVEL`, `/DMO/BOOKING`, `/DMO/BOOK_SUPPL`, `/DMO/FLIGHT`, API type BAPI par function modules, classe facade `/DMO/CL_FLIGHT_LEGACY`, generateur de donnees |
| `src/reuse` | Donnees et vues reutilisables : carrier, customer, airport, connection, flight, statuses, agency, supplement, value helps |
| `src/managed` | Variante RAP managed sur tables `/DMO/TRAVEL_M`, `/DMO/BOOKING_M`, `/DMO/BOOKSUPPL_M` avec validations, determinations, actions et service OData |
| `src/unmanaged` | Variante RAP unmanaged adossee a l'API legacy `/DMO/FLIGHT_TRAVEL_*` |
| `src/draft`, `src/colldraft`, `src/rec`, `src/xbo` | Variantes avancees RAP : draft, collaborative draft, extensibility/XBO, recommendations |
| `src/readonly` | Services read-only pour vols et connexions |
| `src/ana`, `src/hierarchy` | Scenarios analytiques et hierarchiques |

Comptage des principaux types d'objets :

| Type ABAPGit | Nombre |
|---|---:|
| CDS `ddls` | 116 |
| Tables/structures `tabl` | 74 |
| Classes ABAP | 59 |
| Behavior definitions | 32 |
| Metadata extensions `ddlx` | 27 |
| Service definitions | 18 |
| Service bindings | 21 |
| ABAP Unit test classes | 22 |
| Function groups/modules | 2 groupes, plusieurs includes FM |

## Objets legacy principaux

### Tables metier

| Table | Role | Champs clefs ou importants observes |
|---|---|---|
| `/DMO/TRAVEL` | Racine legacy Travel | `TRAVEL_ID`, include `/DMO/TRAVEL_DATA`, include `/DMO/TRAVEL_ADMIN` |
| `/DMO/BOOKING` | Child Booking | `TRAVEL_ID`, `BOOKING_ID`, include `/DMO/BOOKING_DATA` |
| `/DMO/BOOK_SUPPL` | Child Booking Supplement | `TRAVEL_ID`, `BOOKING_ID`, `BOOKING_SUPPLEMENT_ID`, include `/DMO/BOOK_SUPPL_DATA` |
| `/DMO/FLIGHT` | Vol planifie | `CARRIER_ID`, `CONNECTION_ID`, `FLIGHT_DATE`, `PRICE`, `CURRENCY_CODE`, `PLANE_TYPE_ID`, `SEATS_MAX`, `SEATS_OCCUPIED` |
| `/DMO/CONNECTION` | Connexion aerienne | `CARRIER_ID`, `CONNECTION_ID`, aeroports depart/arrivee, horaires, distance |
| `/DMO/CUSTOMER` | Client/passager | `CUSTOMER_ID`, nom, adresse, pays, telephone, email, champs admin cloud |
| `/DMO/CARRIER` | Compagnie aerienne | `CARRIER_ID`, `NAME`, `CURRENCY_CODE`, champs admin cloud |
| `/DMO/AIRPORT` | Aeroport | utilise par les vues reuse et connexions |
| `/DMO/TRVL_STAT`, `/DMO/TRVL_STAT_T` | Statuts travel et textes | value help |
| `/DMO/BOOK_STAT`, `/DMO/BOOK_STAT_T` | Statuts booking et textes | value help |
| `/DMO/SUPPLEMENT`, `/DMO/SUPPL_TEXT`, `/DMO/SUPPLCAT*` | Supplements et textes | value help et composition supplement |

### Structures/includes legacy

| Structure/include | Role |
|---|---|
| `/DMO/TRAVEL_DATA` | `AGENCY_ID`, `CUSTOMER_ID`, dates, `BOOKING_FEE`, `TOTAL_PRICE`, `CURRENCY_CODE`, `DESCRIPTION`, `STATUS` |
| `/DMO/BOOKING_DATA` | `BOOKING_DATE`, `CUSTOMER_ID`, `CARRIER_ID`, `CONNECTION_ID`, `FLIGHT_DATE`, `FLIGHT_PRICE`, `CURRENCY_CODE` |
| `/DMO/TRAVEL_ADMIN` | champs administratifs legacy |
| `/DMO/S_TRAVEL_IN*`, `/DMO/S_BOOKING_IN*`, `/DMO/S_BOOKING_SUPPLEMENT_IN*` | structures d'entree et structures X pour l'API fonctionnelle legacy |
| `/DMO/S_TRAVEL_KEY`, `/DMO/S_BOOKING_KEY`, `/DMO/S_BOOKING_SUPPLEMENT_KEY` | structures de clefs |

### API legacy procedurale

Function group `src/legacy/#dmo#flight_travel_api.fugr` :

| Function module | Role |
|---|---|
| `/DMO/FLIGHT_TRAVEL_CREATE` | Creation Travel avec bookings/supplements |
| `/DMO/FLIGHT_TRAVEL_UPDATE` | Mise a jour Travel et sous-noeuds via structures X |
| `/DMO/FLIGHT_TRAVEL_DELETE` | Suppression Travel |
| `/DMO/FLIGHT_TRAVEL_READ` | Lecture Travel, Booking, Booking Supplement |
| `/DMO/FLIGHT_TRAVEL_SET_BOOKING` | Action metier de mise a statut booked |
| `/DMO/FLIGHT_TRAVEL_ADJ_NUMBERS` | Late numbering |
| `/DMO/FLIGHT_TRAVEL_SAVE` | Persistance du buffer |
| `/DMO/FLIGHT_TRAVEL_INITIALIZE` | Nettoyage du buffer |
| `/DMO/FLIGHT_TRAVEL_CALC_PRICE` | Recalcul du prix des vols selon occupation/distance |

Classe facade legacy :

| Classe | Role |
|---|---|
| `/DMO/CL_FLIGHT_LEGACY` | Singleton public encapsulant create/update/delete/read/save/initialize, buffers internes, validations, determinations, conversion de messages |
| `/DMO/CX_FLIGHT_LEGACY` | Exceptions et messages T100 legacy |
| `/DMO/IF_FLIGHT_LEGACY` | Types API, enums action/status, late numbering, types de messages |
| `/DMO/CL_FLIGHT_DATA_GENERATOR` | Generation de donnees legacy |
| `/DMO/CL_FLIGHT_AMDP` | Objet AMDP present dans legacy, a verifier avant reprise en ABAP Cloud |

## Acces SQL directs et dependances techniques

Acces SQL directs observes dans le legacy :

- `SELECT`, `SELECT SINGLE`, `FOR ALL ENTRIES` sur `/DMO/TRAVEL`, `/DMO/BOOKING`, `/DMO/BOOK_SUPPL`, `/DMO/FLIGHT`, `/DMO/AGENCY`, `/DMO/CUSTOMER`, `/DMO/SUPPLEMENT`.
- `INSERT`, `UPDATE`, `DELETE` directs dans les buffers legacy pour `/DMO/TRAVEL`, `/DMO/BOOKING`, `/DMO/BOOK_SUPPL`.
- `UPDATE /DMO/FLIGHT` dans `/DMO/FLIGHT_TRAVEL_CALC_PRICE`.
- `COMMIT WORK` dans le generateur de donnees legacy.
- `ROLLBACK WORK` dans des classes de test legacy.

Dependances non souhaitees pour une cible ABAP Cloud pure :

- `CALL FUNCTION` vers `/DMO/FLIGHT_TRAVEL_*` dans `src/unmanaged`.
- Function modules `/DMO/FLIGHT_BOOKSUPPL_C/U/D` dans `src/managed` pour une logique update task liee aux supplements.
- AMDP legacy a eviter ou a remplacer par CDS/ABAP Cloud released APIs si non indispensable.

Aucun usage actif observe dans les packages analyses de `CALL TRANSACTION`, `GUI_DOWNLOAD`, `GUI_UPLOAD`, `cl_gui*` ou interface Dynpro/ALV classique.

## Regles metier observees

Regles centrales dans `/DMO/CL_FLIGHT_LEGACY` :

- Verification Travel : agence existante, client existant, dates coherentes, statut autorise, devise valide.
- Verification Booking : date de booking, client, vol existant (`carrier_id`, `connection_id`, `flight_date`), devise, prix.
- Verification Booking Supplement : supplement existant, devise, prix.
- Determinations : calcul `TOTAL_PRICE` du travel a partir du booking fee, bookings et supplements, avec conversion de devises.
- Determinations Booking : recuperation du prix/devise du vol depuis `/DMO/FLIGHT`.
- Actions : mise a statut booked.
- Numbering : early/late numbering selon seuil `90000000`.
- Save sequence : logique de buffer puis `INSERT/UPDATE/DELETE` table par table.

Regles RAP deja disponibles dans `src/managed` :

- Validations `validateCustomer`, `validateAgency`, `validateDates`, `validateStatus`, `validateCurrencyCode`, `validateBookingFee`.
- Determination `calculateTotalPrice`.
- Actions `acceptTravel`, `rejectTravel`, `copyTravel`.
- Early numbering pour Travel et Booking.
- Service OData pour Fiori Elements avec projections et annotations UI.

Regles RAP unmanaged dans `src/unmanaged` :

- Behavior unmanaged avec late numbering.
- Appels directs aux function modules legacy dans les behavior implementations.
- Action `set_status_booked`.
- Saver unmanaged : `finalize`, `check_before_save`, `adjust_numbers`, `save`, `cleanup`, `cleanup_finalize`.

## CDS et services existants utiles

Vues interface reuse directement pertinentes :

| CDS existante | Source | Role |
|---|---|---|
| `/DMO/I_Flight` | `/DMO/FLIGHT` | Vol |
| `/DMO/I_Carrier` | `/DMO/CARRIER` | Compagnie |
| `/DMO/I_Connection` | `/DMO/CONNECTION` | Connexion |
| `/DMO/I_Customer` | `/DMO/CUSTOMER` | Client/passager |
| `/DMO/I_Airport` | `/DMO/AIRPORT` | Aeroport |
| `/DMO/I_*_StdVH` | tables reuse/standard | Value helps |

Vues RAP managed existantes :

| CDS existante | Source |
|---|---|
| `/DMO/I_Travel_M` | `/DMO/TRAVEL_M` |
| `/DMO/I_Booking_M` | `/DMO/BOOKING_M` |
| `/DMO/I_BookSuppl_M` | `/DMO/BOOKSUPPL_M` |
| `/DMO/C_Travel_Processor_M` | projection transactionnelle |
| `/DMO/C_Booking_Processor_M` | projection child |
| `/DMO/C_BookSuppl_Processor_M` | projection child |

Services existants pertinents :

| Service | Type |
|---|---|
| `/DMO/UI_TRAVEL_Processor_M` | service definition managed |
| `/DMO/TRAVEL_U` | service definition unmanaged |
| `/DMO/FLIGHT_R` | service read-only flight |
| `/DMO/FLIGHT_LEGACY` | service legacy read-only |

## Evaluation ABAP Cloud / BTP Trial

Pour une cible `ZFLIGHT_BTP_RAP`, deux options realistes apparaissent :

1. **Managed RAP recommande pour BTP Trial** : creer des tables Z persistantes ou s'appuyer sur des tables custom Z generees depuis les structures `/DMO/*`, puis exposer `ZI_*` et `ZC_*`. C'est l'option la plus Clean Core et la plus compatible ABAP Cloud.
2. **Unmanaged RAP pedagogique** : reproduire l'adaptateur `src/unmanaged`, mais remplacer les function modules par une classe ABAP Cloud compatible. A reserver si l'objectif est de montrer la migration d'une API legacy procedurale vers une facade objet.

Contraintes Trial a garder :

- Les objets namespace `/DMO/*` peuvent ne pas etre disponibles dans un tenant Trial vierge sauf import du sample SAP.
- Les types DDIC `/DMO/*` ne doivent pas etre references dans les objets Z si le sample n'est pas installe.
- Les function modules ne sont pas une bonne cible ABAP Cloud ; ils doivent devenir classes/methodes ou logique RAP.
- Les update tasks, AMDP et commits explicites doivent etre evites dans le runtime applicatif RAP.
- Service binding OData V4 UI : a creer dans ADT, pas toujours representable uniquement par un fichier texte portable selon le flux d'import.

## Decision provisoire pour l'etape suivante

Pour la cartographie legacy -> RAP, la base la plus pedagogique et realiste sera :

- reprendre le domaine legacy `Travel -> Booking -> BookingSupplement`, meme si la demande utilisateur liste surtout Flight/Carrier/Connection/Booking/Customer ;
- exposer `Flight`, `Carrier`, `Connection`, `Customer` en master/value help read-only ;
- rendre `Travel` et `Booking` transactionnels via RAP managed ;
- transformer la logique de `/DMO/CL_FLIGHT_LEGACY` et des function modules en validations, determinations, actions et classes helper ABAP Cloud ;
- signaler explicitement que `ZI_Flight`, `ZI_Carrier`, `ZI_Connection`, `ZI_Booking`, `ZI_Customer` ne couvrent pas a eux seuls la racine metier complete : il faut ajouter `ZI_Travel` si l'objectif est de migrer le scenario Flight Reference Scenario complet.

