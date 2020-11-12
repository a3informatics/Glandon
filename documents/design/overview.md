# Overview

## General

The application is a Ruby on Rails (RoR) application using the standard Model View Controller (MVC) methodology. However, rather than usig a single relational database the application deploys two, a relational one using ActiveRecord and a second triple store that uses a simplified set of ActiveRecord functionality. In this way both forms of models shall be able to interact without difficulty.

The two database technologies are used such that the application can undertake the:
1. Management of clinical research metadata via its creation, modification and use. This includes the version management of such items. These functions are implemented using the triple store
1. Functions such as user management and audit functionality where relational database implementation or  the use standard industry gems makes sense.

## Metadata Functionality

This is core role of the application and is undertaken within the triple store.

1. [Core metadata management functions](core.md)
1. [Management of Terminologies and Code Lists](thesaurus.md)
1. [Canonical Reference](canonical_reference.md)
1. [Complex Datatypes](complex_datatypes.md)
1. [Management of Biomedical Concepts](biomedical_concepts.md), both instances and templates

## Support Functions

1. [Users](users.md)
1. Audit

## Infrastucture and Utility Functions

1. [Utilties](utilities.md)

## Other Considerations

1. [Security](security.md)