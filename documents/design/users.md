# User Management

## Overview

User management and access control is provided by a combination of three Rails Gems:

| **Name** | **Purpose** |
| --- | --- |
| **Devise** | See [https://github.com/plataformatec/devise](https://github.com/plataformatec/devise), for user management (including passwords) |
| **Rolify** | See [https://github.com/RolifyCommunity/rolify](https://github.com/RolifyCommunity/rolify), for roles |
| **Pundit** | See [https://github.com/elabs/pundit](https://github.com/elabs/pundit), for role/user authorization to system functions |

A small wrapper is placed around these to implement user login, logout, password management, roles and authorisation to system functions. Devise handles the bulk of the work with an associated class User to provide some basic user management (create, delete and amend roles). 

Roles are seeded within the database and there is not ability to change or amend other than to assign roles to users. Access to system functions is handled by Pundit using policy files.

All controller actions should be authenticated (valid user) and authorised (user can perform function given their role)

So as to enable Audit Trail logging the devise session controller is extended