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
	
#	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/meta-model-schema.owl" $FileEndPoint
#	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/ct-schema.owl" $FileEndPoint

	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/CDISCBiomedicalConcept.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/BusinessOperational.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/BusinessForm.ttl" $FileEndPoint
#	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/CDISCSDTM.ttl" $FileEndPoint	
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

#	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/meta-model-schema.owl $FileEndPoint
#	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/ct-schema.owl $FileEndPoint

	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/CDISCBiomedicalConcept.ttl $FileEndPoint	
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/BusinessOperational.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/BusinessForm.ttl $FileEndPoint
#	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/CDISCSDTM.ttl $FileEndPoint
fi

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDRItems#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{ 
   :O-CDISC rdf:type isoB:Organization . 
   :O-CDISC isoB:name "Clinical Data Interchange Standards Consortium"^^xsd:string . 
   :O-CDISC isoB:shortName "CDISC"^^xsd:string . 
   :NS-CDISC rdf:type isoI:Namespace . 
   :NS-CDISC isoI:namingAuthorityRelationship :O-CDISC . 
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDRItems#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{ 
   :O-ACME rdf:type isoB:Organization . 
   :O-ACME isoB:name "ACME Pharma"^^xsd:string . 
   :O-ACME isoB:shortName "ACME"^^xsd:string . 
   :NS-ACME rdf:type isoI:Namespace . 
   :NS-ACME isoI:namingAuthorityRelationship :O-ACME . 
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDRItems#>
PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#>
PREFIX isoR: <http://www.assero.co.uk/ISO11179Registration#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{ 
  :RAI-123456789 rdf:type isoB:RegistrationAuthorityIdentifier . 
  :RAI-123456789 isoB:organizationIdentifier "123456789"^^xsd:string . 
  :RAI-123456789 isoB:internationalCodeDesignator "DUNS"^^xsd:string . 
  :RAI-123456789 isoB:name "ACME Pharma"^^xsd:string . 
  :RAI-123456789 isoB:shortName "ACME"^^xsd:string . 
  :RA-123456789 rdf:type isoR:RegistrationAuthority . 
  :RA-123456789 isoR:registrationAuthorityIdentifierRelationship :RAI-123456789 ; 
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDRItems#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :SI-CDISC_CT-34 rdf:type isoI:ScopedIdentifier .
	 :SI-CDISC_CT-34 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :SI-CDISC_CT-34 isoI:version "34"^^xsd:string .
	 :SI-CDISC_CT-34 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDRItems#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :SI-CDISC_CT-35 rdf:type isoI:ScopedIdentifier .
	 :SI-CDISC_CT-35 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :SI-CDISC_CT-35 isoI:version "35"^^xsd:string .
	 :SI-CDISC_CT-35 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDRItems#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :SI-CDISC_CT-36 rdf:type isoI:ScopedIdentifier .
	 :SI-CDISC_CT-36 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :SI-CDISC_CT-36 isoI:version "36"^^xsd:string .
	 :SI-CDISC_CT-36 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDRItems#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :SI-CDISC_CT-37 rdf:type isoI:ScopedIdentifier .
	 :SI-CDISC_CT-37 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :SI-CDISC_CT-37 isoI:version "37"^^xsd:string .
	 :SI-CDISC_CT-37 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDRItems#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :SI-CDISC_CT-38 rdf:type isoI:ScopedIdentifier .
	 :SI-CDISC_CT-38 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :SI-CDISC_CT-38 isoI:version "38"^^xsd:string .
	 :SI-CDISC_CT-38 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDRItems#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :SI-CDISC_CT-39 rdf:type isoI:ScopedIdentifier .
	 :SI-CDISC_CT-39 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :SI-CDISC_CT-39 isoI:version "39"^^xsd:string .
	 :SI-CDISC_CT-39 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDRItems#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :SI-CDISC_CT-40 rdf:type isoI:ScopedIdentifier .
	 :SI-CDISC_CT-40 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :SI-CDISC_CT-40 isoI:version "40"^^xsd:string .
	 :SI-CDISC_CT-40 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDRItems#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :SI-CDISC_CT-41 rdf:type isoI:ScopedIdentifier .
	 :SI-CDISC_CT-41 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :SI-CDISC_CT-41 isoI:version "41"^^xsd:string .
	 :SI-CDISC_CT-41 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDRItems#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :SI-CDISC_CT-42 rdf:type isoI:ScopedIdentifier .
	 :SI-CDISC_CT-42 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :SI-CDISC_CT-42 isoI:version "42"^^xsd:string .
	 :SI-CDISC_CT-42 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

if [ "$DB" = "$Fuseki" ]; then
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V34.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V35.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V36.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V37.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V38.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V39.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V40.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V41.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_V42.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRISO21090.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRBRIDG.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRCDISCBCs.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRCDISCBCTs.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRForms.ttl" $FileEndPoint
else
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V34.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V35.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V36.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V37.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V38.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V39.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V40.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V41.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/CT_V42.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRISO21090.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRBRIDG.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRCDISCBCs.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRCDISCBCTs.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRForms.ttl $FileEndPoint
fi

set +x