# Purpose
The file provides the single configuration file that is NOT configured in github. This file is unique for each installation of the system. Since it is not configured it also holds any system passwords etc that need to be configured.

# Structure
The file is a single YAML file. The file is a set of name value pairs. No other structures are currently permitted.

# Updates
## Release 2.37.0
Add in ability to have specific configuration files for a customer installation. To allow for this an additional field ```installation: <name>``` has been added to set the name of the installation directory to be used, see below.

# Fields
| Group | Field  | Description |
|---|---|---|
| Email | EMAIL_DOMAIN  | Email domain |
|   | EMAIL_SMTP | SMTP server |
|   | EMAIL_PORT | Email port |
|   | EMAIL_USERNAME | Email account username  |
|   | EMAIL_PASSWORD | Email account password |
|   | EMAIL_AUTHENTICATION | Either 'plain' of 'login' |
| Host Details  | HOST_NAME | The host name. |
|   | HOST_PORT | The port to be used.|
|   | HOST_PROTOCOL | Protocol to be used, either http or https|
| API details  | api_username | the MDR's API username|
|   | api_password | the MDR's API username|
| CDISC Library API details | cdisc_library_api_enabled | 'true' or 'false'|
|   | cdisc_library_api_username | CDISC API username. Need to be registered with CDISC to obtain an account.|
|   | cdisc_library_api_password | CDISC API password|
| Other installation parameters  | organization_navbar | Title for the navigation bar. Add a space at the end.| 
|   | organization_title | Installation organisation title|
|   | organization_image_file | File in images directory for organization image|
|   | token_timeout |  Edit lock timeout in seconds. Note must be a string|
| Devise settings  | min_password_length |  Minimum number of characters in password. Integer as a string.|
|   | password_timeout | Password timeout in minutes. Integer as a string.|
|   | expire_password_after | Expire password after N days. Integer as a string|
|   | password_archiving_count | Number of passwords kept to prevent re-use. Integer as a string.|
| Semantic Triple Store: Fuseki   | SEMANTIC_DB_API_KEY | Semantic DB username. Set empty.|
|   | SEMANTIC_DB_API_SECRET |  Semantic DB password. Set empty.|
|   | SEMANTIC_DB_PROTOCOL |  Semantic DB protocol, either 'http' or 'https'|
|   | SEMANTIC_DB_HOST | Semantic DB host|
|   | SEMANTIC_DB_PORT | Semantic DB port|
|   | SEMANTIC_DB_DATASET | Semantic DB dataset|
| RDBMS: Postgresql  | RDBMS_HOST_NAME |  RDBMS host name|
|   | RDBMS_PASSWORD | RDBMS password|
| Base URL authority | url_authority | The URL for building some URIs within the system.|
| Welcome Text | welcome_text | The desired welcome text on login page|
| Installation | installation | The directory name of sponsor specific configuration.|


# Example
```
defaults: &defaults
  # Email options
  EMAIL_DOMAIN: gmail.com
  EMAIL_SMTP: smtp.gmail.com
  EMAIL_PORT: '587'
  EMAIL_USERNAME: glandon.development@gmail.com
  EMAIL_PASSWORD: xxxxxxxx
  EMAIL_AUTHENTICATION: plain # Set to either 'plain' or 'login'
  # Host Name
  HOST_NAME: localhost
  HOST_PORT: "3000"
  HOST_PROTOCOL: "https"
  # API details
  api_username: "xxxxxx"
  api_password: "xxxxxx"
  # CDISC Library API details
  cdisc_library_api_enabled: 'false' # true or false as a string
  cdisc_library_api_username: "xxxxx"
  cdisc_library_api_password: "xxxxx"
  # Other installation parameters
  organization_navbar: 'Dev ' # Installation navbar title. Note should have space at the end.
  organization_title: A3 Informatics # Installation organisation title
  organization_image_file: a3.jpg # File in images directory for orgnaization image
  token_timeout: '600' # Edit lock timeout in seconds. Note must be a string
  # Devise settings
  min_password_length: '8' # minimum number of characters in password
  password_timeout: '20' # password tmeout in minutes
  expire_password_after: '30' # Expire password after N days
  password_archiving_count: '5' # Number of passwords kept to prevent re-use
  # Semantic Triple Store: Fuseki 
  SEMANTIC_DB_API_KEY: ""
  SEMANTIC_DB_API_SECRET: ""
  SEMANTIC_DB_PROTOCOL: "http"
  SEMANTIC_DB_HOST: "localhost"
  SEMANTIC_DB_PORT: "3030"
  SEMANTIC_DB_DATASET: "mdr"
  # RDBMS: Postgresql
  RDBMS_HOST_NAME: localhost
  RDBMS_PASSWORD: ""
  # Base URL authority
  url_authority: "www.assero.co.uk"
  welcome_text: "Teh desired welcome text on login page"
  # Installation
  installation: "dir name of sponsor specific configuration"

development:
  <<: *defaults
  organization_navbar: 'Demo ' # Installation navbar title
  token_timeout: '300' # Edit lock timeout in seconds. Note must be a string
  # API details
  api_username: "xxxxxxx"
  api_password: "xxxxxxxx"
  # Host Name
  HOST_PROTOCOL: 'http'

production:
  <<: *defaults
  organization_navbar: 'Demo ' # Installation navbar title
  token_timeout: '1200' # Edit lock timeout in seconds. Note must be a string
  # Host Name
  #HOST_NAME: www.assero-demo.co.uk
  HOST_PROTOCOL: 'https'

test:
  <<: *defaults
  organization_title: 'ACME Test' # Changing these upsets results files
  organization_image_file: acme.jpg # Changing these upsets results files
  organization_navbar: 'TEST ' # Installation navbar title
  token_timeout: '300' # Edit lock timeout in seconds. Note must be a string
  # API details
  api_username: "xxxxxxx"
  api_password: "xxxxxxx"
  # Triple Store
  SEMANTIC_DB_DATASET: "test"
  # Base URL authority
  url_authority: "www.assero.co.uk" # Changing upsets results files
  # Host Name
  #HOST_NAME: www.assero-demo.co.uk
  HOST_PROTOCOL: "https"
  welcome_text: "Welcome text displayed here."
  # Installation
  installation: "test" # Keep this as test
```