# Etape 5 - Behavior Definitions RAP managed

## Perimetre genere

Fichier genere :

```text
zflight_btp_rap/step05_behaviors/zi_travel.bdef
```

Ce BDEF couvre l'aggregate transactionnel complet :

```text
ZI_Travel
  -> ZI_Booking
       -> ZI_BookingSupplement
```

Les implementations ABAP des validations, determinations, actions et numbering seront generees dans l'etape suivante.

## Ce qui est migre

| Legacy | Cible behavior |
|---|---|
| `/DMO/FLIGHT_TRAVEL_CREATE` | `create` sur `Travel` + create by association `_Booking`, `_BookingSupplement` |
| `/DMO/FLIGHT_TRAVEL_UPDATE` | `update` managed + validations `on save` |
| `/DMO/FLIGHT_TRAVEL_DELETE` | `delete` managed root/children |
| `/DMO/FLIGHT_TRAVEL_SET_BOOKING` | action `setStatusBooked` |
| Statut cancelled legacy | action `setStatusCancelled` |
| `copyTravel` du sample managed | factory action `copyTravel [1]` |
| `_check_*` legacy | validations RAP |
| `_determine_travel_total_price` | determination `calculateTotalPrice` + internal action `ReCalcTotalPrice` |
| Derivation prix booking depuis `/DMO/FLIGHT` | determination `determineFlightPrice` |
| Derivation prix supplement | determination `determineSupplementPrice` |
| Buffers legacy + save FM | managed save RAP |

## Behavior root `ZI_Travel`

Mode :

- managed implementation `ZBP_I_TRAVEL`;
- persistent table `zflight_travel`;
- `strict ( 2 )`;
- lock master;
- etag master `LastChangedAt`;
- early numbering;
- authorization master `none` pour la version pedagogique.

Operations :

- `create`
- `update`
- `delete`

Fields :

- readonly : `TravelID`, `TotalPrice`, champs audit;
- mandatory : `AgencyID`, `CustomerID`, `BeginDate`, `EndDate`, `BookingFee`, `CurrencyCode`, `OverallStatus`.

Validations :

- `validateAgency`
- `validateCustomer`
- `validateDates`
- `validateStatus`
- `validateCurrencyCode`
- `validateBookingFee`

Determinations/actions :

- `calculateTotalPrice`
- internal action `ReCalcTotalPrice`
- `setStatusBooked`
- `setStatusCancelled`
- factory action `copyTravel`

## Behavior child `ZI_Booking`

Mode :

- managed implementation `ZBP_I_BOOKING`;
- persistent table `zflight_booking`;
- dependent lock/etag/authorization by `_Travel`;
- early numbering.

Operations :

- `update`
- `delete`
- create via association `_Booking` exposee depuis `Travel`.

Fields :

- readonly : `TravelID`, `BookingID`, `FlightPrice`, `LastChangedAt`;
- mandatory : `BookingDate`, `CustomerID`, `CarrierID`, `ConnectionID`, `FlightDate`, `CurrencyCode`, `BookingStatus`.

Validations :

- `validateBookingDate`
- `validateCustomer`
- `validateFlight`
- `validateStatus`
- `validateCurrencyCode`

Determinations :

- `determineFlightPrice`
- `requestTravelTotalRecalc`

## Behavior child `ZI_BookingSupplement`

Mode :

- managed implementation `ZBP_I_BOOKSUPPL`;
- persistent table `zflight_bksuppl`;
- dependent lock/etag/authorization by `_Travel`;
- early numbering.

Operations :

- `update`
- `delete`
- create via association `_BookingSupplement` exposee depuis `Booking`.

Fields :

- readonly : `TravelID`, `BookingID`, `BookingSupplementID`, `LastChangedAt`;
- mandatory : `SupplementID`, `Price`, `CurrencyCode`.

Validations :

- `validateSupplement`
- `validatePrice`
- `validateCurrencyCode`

Determinations :

- `determineSupplementPrice`
- `requestTravelTotalRecalc`

## Pourquoi managed

Le managed scenario est retenu car il remplace proprement :

- les buffers singleton de `/DMO/CL_FLIGHT_LEGACY`;
- les structures X legacy;
- les function modules CUD;
- les appels explicites save/initialize;
- la logique transactionnelle manuelle.

Le runtime RAP prend en charge l'unite de travail, le save sequence, l'ETag et le locking. Le code metier se concentre sur les validations, determinations et actions.

## Limites et points ADT a verifier

- Selon la release ABAP Environment, ADT peut demander un ajustement de syntaxe pour `early numbering` ou pour certaines determinations qui combinent `create`, `update` et `field`.
- Les classes `ZBP_I_TRAVEL`, `ZBP_I_BOOKING`, `ZBP_I_BOOKSUPPL` ne sont pas encore generees ; l'activation du BDEF seul signalera donc des objets manquants tant que l'etape implementation n'est pas importee.
- Les behavior projection definitions `ZC_*` ne sont pas encore generees. Elles viendront avec les projection views/service UI.
- La logique d'autorisation est volontairement `none` en version initiale. Un objet d'autorisation ou IAM business catalog pourra etre ajoute plus tard.
- Les statuts et messages ne sont pas encore centralises dans une message class `ZFLIGHT_MSG`; cela sera necessaire pour une UX Fiori propre.

## Prochaine etape

Etape 6 proposee :

1. Generer les classes behavior implementation `ZBP_I_TRAVEL`, `ZBP_I_BOOKING`, `ZBP_I_BOOKSUPPL`.
2. Generer les helpers `ZCL_FLIGHT_RULES` et `ZCL_FLIGHT_PRICING`.
3. Implementer progressivement :
   - validations simples;
   - actions statut;
   - determinations de prix;
   - recalcul total Travel;
   - numbering minimal.

