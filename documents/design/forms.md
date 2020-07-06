# Forms

## Overview

This model details the mechanism by which Forms are structured within the model

## Model

![](diagrams/form.png)

## Nodes

The nodes within the model are implemented:

| **Node** | **Description** |
| --- | --- |
| **BiomedicalConcept** | Core BC classs |
| **BiomedicalConceptInstance** | A BC instance |
| **BiomedicalConceptTemplate** | A BC Template |
| **Item** | An item within a BC, a logical until of information |
| **ComplexDatatype** | The complex datatype of an item. An ISO 21090 healthcare datatype |
| **Property** | A property of a datatype, th value, the units etc |

Nodes not noted in the above table have not been implemented as yet.

## Relationships

The following relationships are implemented:

| **Relationship** | **Description** | **Cardinality** |
| --- | --- | --- |
| **hasItem** | Links a BC to it child items | 1:M |
| **hasComplexDatatype** | Links an item to its datatype. Note this is 1:M to allow for selection from templates but also flexibility in the future for BC instances and selecting a data type. | 1:M |
| **hasProperty** | Links a datatype to its properties | 1:M |
| **hasCodeValue** | A relationship to coded responses | 1:M |

Relationships not noted in the above table have not been implemented as yet.

## Enhancements

1. BiomedicalConcept needs to be improved by being an operational item (managed item)