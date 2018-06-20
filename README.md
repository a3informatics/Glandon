# Current Testing Status

This section provides details of the testing status. The lists provide a simple mechanism that can be used to ensure new releases do not increase the failing test count.

## v2.19.1
```
Finished in 86 minutes 32 seconds (files took 7.22 seconds to load)
2668 examples, 9 failures, 55 pending

Failed examples:

rspec ./spec/features/form_editor_js_spec.rb:501 # Form Editor Curator User allows questions to be updated, check enable and disable on the panel - WILL FAIL CURRENTLY 
rspec ./spec/features/form_editor_js_spec.rb:777 # Form Editor Curator User allows items to be made common and restored, items moved
rspec ./spec/features/form_editor_js_spec.rb:887 # Form Editor Curator User allows the CL to be moved up and down for BC common group - WILL FAIL CURRENTLY
rspec ./spec/features/form_editor_js_spec.rb:921 # Form Editor Curator User allows the CL to be moved up and down for Questions, checks CL Item Panel - WILL FAIL CURRENTLY
rspec ./spec/features/form_editor_js_spec.rb:1148 # Form Editor Curator User allows the edit session to be closed indirectly, saves data
rspec ./spec/features/form_js_spec.rb:221 # Forms Forms allows a form show page to be viewed, view tree details, VS BC - WILL FAIL CURRENTLY
rspec ./spec/models/form_spec.rb:236 # Form can create the sparql for core form
rspec ./spec/models/form_spec.rb:244 # Form can create the sparql for BC form
rspec ./spec/models/sdtm_user_domain_spec.rb:199 # SdtmUserDomain exports the domain as a SAS XPT file - WILL CURRENTLY FAIL (TimeDate Stamp Issue)
```

Intermittent failures as per 2.19.0 also present

## v2.19.0
```
Finished in 95 minutes 59 seconds (files took 6.25 seconds to load)
2664 examples, 8 failures, 55 pending

Failed examples:

rspec ./spec/features/form_editor_js_spec.rb:501 # Form Editor Curator User allows questions to be updated, check enable and disable on the panel - WILL FAIL CURRENTLY 
rspec ./spec/features/form_editor_js_spec.rb:887 # Form Editor Curator User allows the CL to be moved up and down for BC common group - WILL FAIL CURRENTLY
rspec ./spec/features/form_editor_js_spec.rb:921 # Form Editor Curator User allows the CL to be moved up and down for Questions, checks CL Item Panel - WILL FAIL CURRENTLY
rspec ./spec/features/form_js_spec.rb:221 # Forms Forms allows a form show page to be viewed, view tree details, VS BC - WILL FAIL CURRENTLY
rspec ./spec/models/form_spec.rb:236 # Form can create the sparql for core form
rspec ./spec/models/form_spec.rb:244 # Form can create the sparql for BC form
rspec ./spec/models/sdtm_user_domain_spec.rb:199 # SdtmUserDomain exports the domain as a SAS XPT file - WILL CURRENTLY FAIL (TimeDate Stamp Issue)
rspec ./spec/views/imports/terms/index_spec.rb:17 # imports/terms/index.html.erb displays the Terminology import screen

Also getting some intermittent failures, these need to be resolved but are not causing concern.

rspec ./spec/models/background_spec.rb:302 # Background CDISC Term Change Instructions import cdisc term changes, September 2017
rspec ./spec/features/biomedical_concept_editor_js_spec.rb:182 # Biomedical Concept Editor Curator User, Multiple Edit allows 8 BCs to be edited
rspec ./spec/features/scenarios/scenario_2_js_spec.rb:60 # Secnario 2 - Life Cycle Curator User allows an item to move through the lifecyle
rspec ./spec/features/scenarios/scenario_3_js_spec.rb:61 # Scenario 3 - Biomedical Concepts Curator User allows Biomedical Concepts to be created
rspec ./spec/features/sdtm_user_domains_js_spec.rb:110 # SDTM User Domains Users Domains allows for a IG Domain to be exported as TTL
```
