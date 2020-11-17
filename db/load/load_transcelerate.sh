#! bin/bash
FileEndPoint="http://localhost:3030/mdr/data"
UpdateEndPoint="http://localhost:3030/mdr/update"
set -x
# Load Schema
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO11179Types.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO11179Identification.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO11179Registration.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO11179Concepts.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/annotations.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/business_operational.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/thesaurus.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/framework.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/complex_datatype.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/business_form.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/biomedical_concept.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/protocol.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/enumerated.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/tabulation.ttl" $FileEndPoint
# Load Identification
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/mdr_transcelerate_identification.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/mdr_iso_concept_systems.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/mdr_iso_concept_systems_migration_1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/mdr_iso_concept_systems_migration_2.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/mdr_iso_concept_systems_migration_3.ttl" $FileEndPoint
# Load CDISC Terminology
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V2.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V3.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V4.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V5.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V6.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V7.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V8.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V9.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V10.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V11.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V12.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V13.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V14.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V15.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V16.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V17.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V18.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V19.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V20.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V21.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V22.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V23.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V24.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V25.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V26.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V27.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V28.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V29.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V30.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V31.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V32.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V33.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V34.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V35.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V36.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V37.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V38.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V39.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V40.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V41.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V42.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V43.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V44.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V45.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V46.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V47.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V48.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V49.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V50.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V51.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V52.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V53.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V54.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V55.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V56.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V57.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V58.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V59.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V60.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V61.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V62.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V63.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V64.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V65.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/ct/CT_V66.ttl" $FileEndPoint
# Biomedical Concepts
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/biomedical_concept_instances.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/biomedical_concept_templates.ttl" $FileEndPoint
# Data
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_thesaurus.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_tas.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_indications.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_endpoints.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_objectives.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_parameters.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_protocols.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_protocol_templates.ttl" $FileEndPoint
# Forms
# curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_form_ad.ttl" $FileEndPoint
# curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_form_cibic.ttl" $FileEndPoint
# curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_form_dad.ttl" $FileEndPoint
# curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_form_dm_pilot.ttl" $FileEndPoint
# curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_form_dm.ttl" $FileEndPoint
# curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_form_ecg.ttl" $FileEndPoint
# curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_form_height.ttl" $FileEndPoint
# curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_form_hr_bp.ttl" $FileEndPoint
# curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_form_lab_samples.ttl" $FileEndPoint
# curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_form_vs_diabetes.ttl" $FileEndPoint
# curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_form_vs_influenza.ttl" $FileEndPoint
# curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/hackathon_form_weight.ttl" $FileEndPoint
# Complex Datatypes and References
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/canonical_references.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/complex_datatypes.ttl" $FileEndPoint
# SDTM Model
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/sdtm_model/SDTM_MODEL_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/sdtm_model/SDTM_MODEL_V2.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/sdtm_model/SDTM_MODEL_V3.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/sdtm_model/SDTM_MODEL_V4.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/sdtm_model/SDTM_MODEL_V5.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/sdtm_model/SDTM_MODEL_V6.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/sdtm_model/SDTM_MODEL_V7.ttl" $FileEndPoint
# SDTM IG
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/sdtm_ig/SDTM_IG_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/sdtm_ig/SDTM_IG_V2.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/sdtm_ig/SDTM_IG_V3.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/sdtm_ig/SDTM_IG_V4.ttl" $FileEndPoint
# ADaM IG
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/adam_ig/ADAM_IG_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/adam_ig/ADAM_IG_V2.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/cdisc/adam_ig/ADAM_IG_V3.ttl" $FileEndPoint
set +x