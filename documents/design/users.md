# User Management

## Overview

User management and access control is provided by a combination of three Rails Gems:

| **Name** | **Purpose** |
| --- | --- |
| **Devise** | See [https://github.com/plataformatec/devise](https://github.com/plataformatec/devise), for user management (including passwords) |
| **Rolify** | See [https://github.com/RolifyCommunity/rolify](https://github.com/RolifyCommunity/rolify), for roles |
| **Pundit** | See [https://github.com/elabs/pundit](https://github.com/elabs/pundit), for role/user authorization to system functions |

A small wrapper is placed around these to implement user login, logout, password management, roles and authorisation to system functions. Devise handles the bulk of the work with an associated class User to provide some basic user management (create, delete and amend roles). 

## User Roles

Roles are handled by the Rolify gem

Roles are seeded within the database and there is no ability to change or amend other than to assign roles to users. Access to system functions is handled by Pundit using policy files.

## Controller Action Authentication and Authorisation

All controller actions should be authenticated (valid user) and authorised (user can perform function given their role)

The authentication of users is provided by the Devise gem.

The authorisation is provided by the Pundit gem. Access to a given system function is controlled by a policy for each controller. A set of methods for the policy class are generated based on the settings within the policy.yml configuration file. There is the ability to 

1. set for an action the access for each role
1. set for an action the name of another method that determines access

## Notes

1. So as to enable Audit Trail logging the devise session controller is extended

