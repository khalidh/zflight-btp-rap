# ZFLIGHT_BTP_RAP

Migration pedagogique du SAP Flight Reference Scenario vers une architecture SAP BTP moderne :

- ABAP Cloud
- RAP managed
- CDS view entities
- behavior definitions / implementations
- service OData V4 a generer dans ADT
- Fiori Elements
- Clean Core

## Import dans Eclipse ADT

Prerequis :

- SAP BTP ABAP Environment ou systeme ABAP Cloud compatible.
- Plugin abapGit installe dans Eclipse ADT ou abapGit disponible cote systeme.
- Package cible recommande : `ZFLIGHT_BTP_RAP`.

Etapes :

1. Dans ADT, creer ou selectionner le package `ZFLIGHT_BTP_RAP`.
2. Ouvrir abapGit.
3. Ajouter ce repository GitHub.
4. Choisir le package `ZFLIGHT_BTP_RAP`.
5. Importer les objets.
6. Activer en deux passes si necessaire :
   - tables/source definitions et CDS interface;
   - behavior definitions et classes.

## Structure

```text
src/
  package.devc.xml
  *.ddls.asddls     CDS/table source definitions
  *.ddls.xml        metadata abapGit
  *.bdef.asbdef     behavior definition
  *.clas.abap       global classes
  *.locals_imp.abap local behavior handlers

docs/
  step01_inventory.md
  step02_legacy_to_rap_mapping.md
  step03_target_architecture.md
  step04_cds_generation.md
  step05_behavior_definitions.md
  step06_behavior_implementation.md

generated-source/
  sources lisibles par etape
```

## Remarques importantes

Ce repository est une base de migration/import. Selon la release ABAP Environment, ADT peut demander de petits ajustements syntaxiques :

- DDL table definitions source-based selon support abapGit/systeme.
- `TABLE FOR UPDATE zi_travel\\booking` et `zi_travel\\bookingsupplement`.
- Appel de l'action interne `ReCalcTotalPrice` depuis les handlers children.
- `new_message_with_text`, remplacable par une message class `ZFLIGHT_MSG`.
- Numbering methods si le `early numbering` declaratif n'est pas suffisant pour les clefs NUMC.

Les documents dans `docs/` expliquent ces points et l'ordre de construction.

## Etat actuel

Genere :

- persistence/source definitions `ZFLIGHT_*`
- CDS interface `ZI_*`
- behavior definition managed `ZI_Travel`
- classes behavior implementation starter
- helpers `ZCL_FLIGHT_RULES` et `ZCL_FLIGHT_PRICING`

A venir :

- projection views `ZC_*`
- projection behavior definitions
- service definition `ZUI_FLIGHT_SERVICE`
- service binding OData V4 UI dans ADT
- annotations Fiori Elements
- ABAP Unit

