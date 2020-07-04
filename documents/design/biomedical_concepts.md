# Biomedical Concepts

## Overview

This model details the mechanism by which Biomedical Concepts are structured within the model

## Model

![](diagrams/biomedical_concept.png)

## Nodes

The nodes within the model are described in the following table:

| **Node** | **Description** |
| --- | --- |
| **BiomedicalConcept** | Generic BC class |
| **BiomedicalConceptInstance** | A BC instance |
| **BiomedicalConceptTemplate** | A BC Template |
| **Item** | An item within a BC, Equates to a BRIDG class attribute |
| **Datatype** | The datatype of an item. Simple implementation if ISO 21090 healthcare datatypes |
| **Property** | A property of a datatype |
| **ComplexNode** | Generic class for BC child objects holding common properties |

The relationships are as follows:

| **Relationship** | **Description** | **Cardinality** |
| --- | --- | --- |
| **hasItem** | Links a BC to it child items | 1:M |
| **hasDatatype** | Links an item to its datatype | 1:1 |
| **hasProperty** | Links a datatype to its properties | 1:M |
| **hasComplexDatatype** | A recursive relationship that allows ISO 21090 datatypes to include further ISO 21090 datatypes | 1:1 |

## Enhancements

1. BiomedicalConcept needs to be improved by being an operational item (managed item)