#! bin/bash
FileEndPoint="http://localhost:3030/mdr/data"
UpdateEndPoint="http://localhost:3030/mdr/update"
set -x
# Load Schema
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO11179Types.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO11179Identification.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO11179Registration.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO11179Concepts.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/thesaurus.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO21090.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/BRIDG.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/CDISCTerm.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/CDISCBiomedicalConcept.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/BusinessOperational.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/BusinessForm.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/BusinessDomain.ttl" $FileEndPoint	
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/business_cross_reference.ttl" $FileEndPoint  
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/business_operational_extension.ttl" $FileEndPoint  
# Load Identification
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRIdentificationACME.ttl" $FileEndPoint
# Load Terminology
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
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V36.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V37.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V38.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V39.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V40.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V41.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V42.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V43.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V44.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V45.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V46.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V47.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V48.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V49.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V50.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V51.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V52.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V53.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V54.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CDISC_CT_Instructions_V44.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CDISC_CT_Instructions_V49.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CDISC_CT_Instructions_V50.ttl" $FileEndPoint
# Load SDTM
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/SDTM_Model_1-2.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/SDTM_IG_3-1-2.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/SDTM_Model_1-3.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/SDTM_IG_3-1-3.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/SDTM_Model_1-4.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/SDTM_IG_3-2.ttl" $FileEndPoint
set +x