# Etape 6 - Behavior Implementations et helpers ABAP Cloud

## Perimetre genere

Repertoire :

```text
zflight_btp_rap/step06_behavior_implementation/classes/
```

Fichiers generes :

| Fichier | Role |
|---|---|
| `zcl_flight_rules.clas.abap` | Constantes et validations pures |
| `zcl_flight_pricing.clas.abap` | Calcul total et prix de vol |
| `zbp_i_travel.clas.abap` | Classe behavior globale root |
| `zbp_i_travel.clas.locals_imp.abap` | Handler `lhc_travel` |
| `zbp_i_booking.clas.abap` | Classe behavior globale child Booking |
| `zbp_i_booking.clas.locals_imp.abap` | Handler `lhc_booking` |
| `zbp_i_booksuppl.clas.abap` | Classe behavior globale child Booking Supplement |
| `zbp_i_booksuppl.clas.locals_imp.abap` | Handler `lhc_bookingsupplement` |

## Ce qui est implemente

### Travel

| Behavior element | Implementation |
|---|---|
| `validateAgency` | Controle valeur obligatoire |
| `validateCustomer` | Controle existence dans `zflight_customer` |
| `validateDates` | Controle dates non initiales et `EndDate >= BeginDate` |
| `validateStatus` | Controle statuts `N`, `P`, `B`, `X` |
| `validateCurrencyCode` | Controle devise obligatoire |
| `validateBookingFee` | Controle montant non negatif |
| `calculateTotalPrice` | Appelle `ReCalcTotalPrice` |
| `ReCalcTotalPrice` | Lit bookings/supplements via EML local et met a jour `TotalPrice` |
| `setStatusBooked` | Met `OverallStatus = B` |
| `setStatusCancelled` | Met `OverallStatus = X` |
| `copyTravel` | Cree une copie simple du Travel sans enfants |

### Booking

| Behavior element | Implementation |
|---|---|
| `validateBookingDate` | Controle date obligatoire |
| `validateCustomer` | Controle existence dans `zflight_customer` |
| `validateFlight` | Controle existence dans `zflight_flight` |
| `validateStatus` | Controle statuts `N`, `B`, `X` |
| `validateCurrencyCode` | Controle devise obligatoire |
| `determineFlightPrice` | Lit prix/devise depuis `zflight_flight` |
| `requestTravelTotalRecalc` | Execute l'action interne root `ReCalcTotalPrice` |

### Booking Supplement

| Behavior element | Implementation |
|---|---|
| `validateSupplement` | Controle existence dans `zflight_suppl` |
| `validatePrice` | Controle prix non negatif |
| `validateCurrencyCode` | Controle devise obligatoire |
| `determineSupplementPrice` | Lit prix/devise depuis `zflight_suppl` |
| `requestTravelTotalRecalc` | Execute l'action interne root `ReCalcTotalPrice` |

## Choix techniques

- Les validations utilisent `READ ENTITIES ... IN LOCAL MODE` pour lire les instances RAP en cours.
- Les determinations utilisent `MODIFY ENTITIES ... IN LOCAL MODE` pour rester dans le cycle transactionnel RAP.
- Les messages utilisent `new_message_with_text` pour eviter de creer une message class trop tot.
- La conversion de devise est volontairement simplifiee : seuls les montants dans la meme devise que le Travel sont additionnes.
- `copyTravel` copie seulement la racine dans cette premiere version. La copie profonde des bookings/supplements sera ajoutee quand les create-by-association seront stabilises dans ADT.
- Aucun function module legacy n'est appele.

## Points d'activation ADT a surveiller

Ces fichiers sont concus comme base de generation pedagogique. L'activation dans un tenant ABAP Environment peut demander des ajustements mineurs :

1. **Noms de composants RAP**  
   Les alias CDS comme `TravelID`, `CustomerID`, `BookingStatus` peuvent etre normalises par ADT. Si necessaire, adapter la casse ou le nom de composant dans les handlers.

2. **Types `TABLE FOR UPDATE` children**  
   Les types `TYPE TABLE FOR UPDATE zi_travel\\booking` et `zi_travel\\bookingsupplement` suivent le pattern RAP. Selon l'activation, ADT peut proposer la forme exacte.

3. **Internal action `ReCalcTotalPrice`**  
   L'appel depuis un child vers une action root peut exiger une table de cles root complete. Si ADT refuse `TravelID = ...`, utiliser `%tky` root obtenu via lecture parent.

4. **`new_message_with_text`**  
   Si la release impose une autre fabrique de messages, remplacer par `new_message` avec une message class `ZFLIGHT_MSG`.

5. **Early numbering**  
   Le BDEF declare `early numbering`, mais les methods de numbering ne sont pas encore implementees explicitement. Certains environnements peuvent exiger `FOR NUMBERING` methods si la clef n'est pas managed automatiquement. Dans ce cas, ajouter `earlynumbering_create`, `earlynumbering_cba_booking`, `earlynumbering_cba_bookingsupplement`.

## Limites fonctionnelles restantes

- Pas encore de message class traduisible `ZFLIGHT_MSG`.
- Pas encore de controle d'existence agence, car la table `zflight_agency` n'a pas ete retenue en vague 1. `AgencyID` est obligatoire mais pas valide contre une master data.
- Pas encore de conversion de devise via API released.
- Pas encore de copie profonde des bookings/supplements.
- Pas encore de gestion d'autorisations metier.
- Pas encore de tests ABAP Unit.

## Import ADT recommande

1. Importer/creer les helpers :
   - `ZCL_FLIGHT_RULES`
   - `ZCL_FLIGHT_PRICING`
2. Importer/creer les classes behavior globales :
   - `ZBP_I_TRAVEL`
   - `ZBP_I_BOOKING`
   - `ZBP_I_BOOKSUPPL`
3. Ajouter les local implementations correspondantes.
4. Activer avec le BDEF `ZI_Travel`.
5. Corriger les messages ADT de typage RAP si la release precise une syntaxe differente.

## Prochaine etape

La suite logique est de generer :

- les projection views `ZC_*`;
- les projection behavior definitions;
- puis le service definition `ZUI_FLIGHT_SERVICE`.

Cela remet l'ordre initial sur les rails : exposition OData V4 et Fiori Elements apres les implementations de base.

