#! bin/bash
Fuseki="F"
Ontotext="O"

DB=$Fuseki

if [ "$DB" = "$Fuseki" ]; then
#	FileEndPoint="http://192.168.2.101:3030/mdr/data"
#	UpdateEndPoint="http://192.168.2.101:3030/mdr/update"
	FileEndPoint="http://localhost:3030/mdr/data"
	UpdateEndPoint="http://localhost:3030/mdr/update"
else
	FileEndPoint="https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements"
	UpdateEndPoint="https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements"
fi

set -x
if [ "$DB" = "$Fuseki" ]; then
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO11179Types.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO11179Basic.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO11179Identification.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO11179Registration.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO11179Data.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO11179Concepts.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO25964.ttl" $FileEndPoint

	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ISO21090.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/BRIDG.ttl" $FileEndPoint
	
	#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/meta-model-schema.owl" $FileEndPoint
	#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/cdisc-schema.owl" $FileEndPoint

	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/CDISCTerm.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/CDISCBiomedicalConcept.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/BusinessOperational.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/BusinessForm.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/BusinessDomain.ttl" $FileEndPoint	
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/BusinessStandard.ttl" $FileEndPoint	
else
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/ISO11179Types.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/ISO11179Basic.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/ISO11179Identification.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/ISO11179Registration.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/ISO11179Data.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/ISO11179Concepts.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/ISO25964.ttl $FileEndPoint
	
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/ISO21090.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/BRIDG.ttl $FileEndPoint

	#curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/meta-model-schema.owl $FileEndPoint
	#curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/cdisc-schema.owl $FileEndPoint

	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/CDISCTerm.ttl $FileEndPoint	
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/CDISCBiomedicalConcept.ttl $FileEndPoint	
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/BusinessOperational.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/BusinessForm.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/BusinessDomain.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/BusinessStandard.ttl $FileEndPoint
fi

if [ "$DB" = "$Fuseki" ]; then
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRIdentification.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V34.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V35.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V36.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V37.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V38.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V39.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V40.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V41.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V42.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V43.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V44.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRISO21090.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRBRIDG.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRCDISCBCs.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRCDISCBCTs.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRFormsVSBaseline.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRFormsVSWeekly.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRFormsDemo1.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRFormsDemo2.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_DM1 01.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_MH1 01.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_AEPI1 03.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_PLACEHOLDER TEST.ttl" $FileEndPoint
	#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/sdtmig-3-1-2.ttl" $FileEndPoint
	#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/SDTMIG_3-1-2_V1.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_ACME_V1.ttl" $FileEndPoint
else
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRIdentification.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V34.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V35.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V36.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V37.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V38.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V39.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V40.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V41.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V42.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V43.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V44.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRISO21090.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRBRIDG.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRCDISCBCs.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRCDISCBCTs.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRFormsVSBaseline.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRFormsVSWeekly.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRFormsDemo1.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRFormsDemo2.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/ACME_DM1 01.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/ACME_MH1 01.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/ACME_AEPI1 03.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/ACME_PLACEHOLDER TEST.ttl $FileEndPoint
	#curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/sdtmig3-1-2.ttl $FileEndPoint
	#curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/SDTMIG_3-1-2_V1.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_ACME_V1.ttl $FileEndPoint
fi

set +x