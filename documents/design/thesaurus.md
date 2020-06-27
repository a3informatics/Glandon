# Terminology (Thesaurus)

## Overview

This model details how terminologies are stored and constructed. The model is based on the W3C SKOS standard but has also taken into consideration the ISO 25964 standard.

Three levels of information are modelled

1. Terminology - A complete terminology that is named and version managed. Referred to as a thesaurus.
1. Code List - A set of terms. Named and version managed. Referred to as a Managed Concepts
1. Code List Item - An item within a code list. Not version managed. Referred to as Unmanaged Concepts

## Model

![](diagrams/thesaurus.png)

<img src="diagrams/thesaurus.png" alt="Thesaurus Model"/>

The nodes within the model are described in the following table:

| **Node** | **Description** |
| --- | --- |
| **Thesaurus** | The managed item representing the terminology |
| **ThesaurusConcept** | A concept within the terminology. |

The relationships are as follows:

| **Relationship** | **Description** | **Cardinality** |
| --- | --- | --- |
| **hasConcept** | Links a thesaurus to the top-level concepts | 1:M |
| **hasChild** | Links a thesaurus concept with the child concepts | 1:M |

## Standard Code Lists

Standard code lists are those that contain items created solely for this code list or references toitems from other code lists

## Extensions

Extended code lists are those code lists that are owned that extend code lists owned by other organisations with codes from other code lists. Extensions allow for items to be created.

## Subsets

Subsets are those code lists formed from a subset of items from a single other code list and that are placed in some order

## Ranked

A ranked code list is one that has a rank value associated with each item within it.

## Paired

A paired code list is one where there is a TEST/TESTCD relationship between the two code lists
