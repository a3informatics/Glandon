# Fuseki

## General

This chapter details the fuseki class. This class is responsbile for impelementing the Active Model functionality for the triple store. All classes interacting with the triple store should inherit from this class.

The class employs metadata programming to create class attributes to align with those defined by the triple store schema. An internal class structure is maintained that holds all the necessary information for the execution of rad and write operations

## Base

Implements the base class allowing for the setup of the resources and intialization of any attributes (named properties within the implementation)

## Resources

Implements the methods for the creation of properties.

_More detail here for resource methods_

## Persistance

Implements all the expected operations for reading and writing to the database in line with the Active Model approach.

_More detail here for available methods_

## Diff

Implements class and instance methods for difference.

## Utility

Implements useful class and instance methods.

## Schema

Concern that reads the schema and builds a hash stored as a class variable within the base class to minimise the times it needs reading.