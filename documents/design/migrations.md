# Migrations

## General

This section details database migrations and the mechanism used to implement migrations.

## RDBMS

Standard rails DB migrations are used.

## Fuseki

Fuseki migration use rake tasks (rather then migrations) so that more control can be exercised as whethr they should be run or not.

The basic approach for a migration is:

1. Determine if migration is needed by checking to see if crtain triples are absent
1. Execute the migration in a series or 1 or more steps
1. Trap any expceptions and report the step that failed
1. Check for success
1. Report success or any errors

Note: 

1. Migrations cannot be rolled back currently
1. A migration should be written for the schema and one for the data
1. Migrations should be named after the release to which they associated. The migration required when Release M.N.P is installed should be named RM_N_P_[schema|data]