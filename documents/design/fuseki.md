# Fuseki

## General

This chapter details the fuseki class. This class is responsbile for impelementing the Active Model functionality for the triple store. All classes interacting with the triple store should inherit from this class.

The class employs metadata programming to create class attributes to align with those defined by the triple store schema. An internal class structure is maintained that holds all the necessary information for the execution of rad and write operations

## Base

Implements the base class allowing for the setup of the resources and intialization of any attributes (named properties within the implementation)

## Resources

### General

Implements the methods for the creation of properties. Two types of property can be declared, data and object. Data properties are for single data values whiel object properties hold relationships between the class and other classes.

The properties declared must be defined within the triple store schema.

### Configure

This allows the basic configuration of the class of the base RDF type and the method to be used for class instance URI generation

```
configure rdf_type: <uri>, uri_suffix: <string>, uri_unique: <boolean>, uri_property: <data property>, base_uri: <uri>, key_property: <>, cache: <boolean>
```

| Name | Values | Purpose|
| :rdf_type | URI | the URI from the schema tha defines the subject and the associated properties |
| :uri_suffix | Class name as string or class | Defines the class at the other end of the relationship |
| :uri_unique | boolean or property | Generate a unique URI for instances. If true use a unique random string. If a property name is quoted will uses a SHA1 digest of the property value |
| :base_uri | URI | the URI to be used as the base for any instance URIs generated |
| :key_property | symbol | the property that acts as a key for the class |
| :cache | boolean | indicates whether reads of the class should be cached |

### Data Property

The data property allows a single data property. Definitions take the form

```
data_property <name as symbol>, <option>, <option>
```

| Name | Values | Purpose|
| :default | any | the desired default value of the correct type |

### Object Property

The object property allows a relationship from the class to be defined. The property can be a single reference or an array of references. Definitions take the form

```
data_property <name as symbol>, <option>, <option>
```

| Name | Values | Purpose|
| :cardinatlity | :one or :many | Defines whether a single or array of relationships |
| :model_class | Class name as string or class | Defines the class at the other end of the relationship |
| :model_classes | Array of class names as string or class | Defines the classes at the other end of the relationship |

Classes inheriting from a class may need to add to the class list for an object. This can be achieved by

```
object_property_class :has_item, <option> 
```

| Name | Values | Purpose|
| :model_class | Class name as string or class | Defines the class at the other end of the relationship |
| :model_classes | Array of class names as string or class | Defines the classes at the other end of the relationship |

## Persistance

Implements all the expected operations for reading and writing to the database in line with the Active Model approach.

_More detail here for available methods_

## Diff

Implements class and instance methods for difference.

## Utility

Implements useful class and instance methods.

## Schema

Concern that reads the schema and builds a hash stored as a class variable within the base class to minimise the times it needs reading.