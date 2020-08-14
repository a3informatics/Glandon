# Tabulation

## Overview

This model details the mechanism by which Tabulations are structured within the model

## Model

![](diagrams/tabulation.png)

## Nodes

The nodes within the model are implemented:

| **Node** | **Description** |
| --- | --- |
| **Tabulation** | A tabulation. A set of columns |
| **Column** | Column within a tabulation |
| **Model** | A document published detailing a model |
| **SdtmModelVariable** | A SDTM CDISC model variable. Building block for a class variable (shared across classes) |
| **SdtmClass** | A CDISC class. Building block for a SDTM IG domain |
| **SdtmClassVariable** | A SDTM CDISC domain class variable. Building block for a SDTM variable |
| **SdtmDomain** | A domain as defined within an implementation guide |
| **SdtmDomainVariable** | A variable as defined within an implementation guide |
| **ImplementationGuide** | A document published as a implementation guide |
| **SDTMImplementationGuide** | A document published as a SDTM implementation guide |
| **ADaMImplementationGuide** | A document published as a ADaM implementation guide |

Nodes not noted in the above table have not been implemented as yet.

## Relationships

The following relationships are implemented:

| **Relationship** | **Description** | **Cardinality** |
| --- | --- | --- |
| **includesVariable** | Relationship to relate tabulations with the containing document/standard | 1:M |
| **includesColumn** | Relates columns to tabulations | 1:M |
| **basedOnClass** | Notes which domain class a domain is based on | 1:M |
| **basedOnModelVariable** | Notes which domain class variable a variable is based on | 1:M |
| **basedOnClassVariable** | Notes which domain class variable a variable is based on | 1:M |
| **classifiedAs** | The variable classification | 1:M |
| **typedAs** | The variable datatype | 1:M |
| **compliance** | The variable compliance | 1:M |
| **hasBiomedicalConcept** | Reference to a Biomedical Concept  | 1:M |


Relationships not noted in the above table have not been implemented as yet.

## Enhancements

1. 