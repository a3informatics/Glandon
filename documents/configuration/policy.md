# Policy

## Purpose
File containing the access policies to be used. The file should not be modified. There should be entry for the base ApplicationPolicy class and then other desired policy classes.

## Structure
The file is a single YAML file. The structure of the file is as follows

| Structure | | |
|---|---|---|
|[policy_class]: |||
|  policies:|||
|    [action]:|||
|      [user role]: | [true|false] | Set to true enables the action for the user role. There should be an entry for each role defined in the roles.yml file.|
|  alias: |||
|    [action]: | [alias_action] | The alias action name to be used for the action name. Should be a name found in the policies section. No need for the ? at the end |

# Example
```
defaults: &defaults
  ApplicationPolicy:
    policies:
      index:
        sys_admin: false
        community_reader: false
        term_reader: false
        term_curator: false
        reader: true
        curator: true
        content_admin: true
      show:
        sys_admin: false
        community_reader: false
        term_reader: false
        term_curator: false
        reader: true
        curator: true
        content_admin: true
    alias:
      show_data: show
```