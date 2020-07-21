# Migrations

## General

This section details database migrations and the mechanism used to implement migrations.

## RDBMS

Standard rails DB migrations are used.

## Triple Store

Fuseki migration use rake tasks (rather then migrations) so that more control can be exercised as whethr they should be run or not.

The basic approach for a migration is:

1. Determine if migration is needed by checking to see if certain triples are absent
1. Execute the migration in a series or 1 or more steps
1. Trap any expceptions and report the step that failed
1. Check for success
1. Report success or any errors

Note: 

1. Migrations cannot be rolled back currently
1. A migration should be written for the schema and one for the data
1. Migrations should be named after the version to which they associated. The migration required when Release M.N.P is installed should be named vM_N_P_[schema|data]

## Schema Files

The following should be used for triple store schema files

1. Schema should be based on http://www.a3informatics.com/mdr/schema/<name>
1. Each schema section should contain version/release info using a **owl:versionInfo** triple containing the system version in which the schema section was updated. This should take the form **<subject> owl:versionInfo "v1.2.3"^^string**
1. Only schema sections should use the RDF type **owl:Ontology**, no data should do so

When migrating a schema

1. New triples should be contained within a file suffixed with the data in the form <existing_filename>\_YYYYMMDD.ttl
1. Develop a migration as above to modify or delete existing triples
1. Update the **owl:versionInfo** triple
