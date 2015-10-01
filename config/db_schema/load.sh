#! bin/bash
Fuseki="F"
Ontotext="O"

DB=$Ontotext

if [ "$DB" = "$Fuseki" ]; then
	FileEndPoint="http://192.168.2.101:3030/mdr/data"
	UpdateEndPoint="http://192.168.2.101:3030/mdr/update"
else
	FileEndPoint="https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements"
	UpdateEndPoint="https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements"
fi

set -x
if [ "$DB" = "$Fuseki" ]; then
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@ISO11179Types.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@ISO11179Basic.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@ISO11179Identification.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@ISO11179Registration.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@ISO11179Data.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@ISO11179Concepts.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@ISO25964.ttl" $FileEndPoint
else
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T ISO11179Types.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T ISO11179Basic.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T ISO11179Identification.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T ISO11179Registration.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T ISO11179Data.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T ISO11179Concepts.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T ISO25964.ttl $FileEndPoint
fi

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDROrganizations#>
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

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDROrganizations#>
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

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDROrganizations#>
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
  :RAI-123456789 isoB:registrationAuthorityNamespaceRelationship :NS-ACME . 
  :RA-123456789 rdf:type isoR:RegistrationAuthority . 
  :RA-123456789 isoR:registrationAuthorityIdentifierRelationship :RAI-123456789 ; 
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDROrganizations#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :II-CDISC_CT-34 rdf:type isoI:ScopedIdentifier .
	 :II-CDISC_CT-34 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :II-CDISC_CT-34 isoI:version "34"^^xsd:string .
	 :II-CDISC_CT-34 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDROrganizations#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :II-CDISC_CT-35 rdf:type isoI:ScopedIdentifier .
	 :II-CDISC_CT-35 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :II-CDISC_CT-35 isoI:version "35"^^xsd:string .
	 :II-CDISC_CT-35 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDROrganizations#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :II-CDISC_CT-36 rdf:type isoI:ScopedIdentifier .
	 :II-CDISC_CT-36 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :II-CDISC_CT-36 isoI:version "36"^^xsd:string .
	 :II-CDISC_CT-36 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDROrganizations#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :II-CDISC_CT-37 rdf:type isoI:ScopedIdentifier .
	 :II-CDISC_CT-37 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :II-CDISC_CT-37 isoI:version "37"^^xsd:string .
	 :II-CDISC_CT-37 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDROrganizations#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :II-CDISC_CT-38 rdf:type isoI:ScopedIdentifier .
	 :II-CDISC_CT-38 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :II-CDISC_CT-38 isoI:version "38"^^xsd:string .
	 :II-CDISC_CT-38 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDROrganizations#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :II-CDISC_CT-39 rdf:type isoI:ScopedIdentifier .
	 :II-CDISC_CT-39 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :II-CDISC_CT-39 isoI:version "39"^^xsd:string .
	 :II-CDISC_CT-39 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDROrganizations#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :II-CDISC_CT-40 rdf:type isoI:ScopedIdentifier .
	 :II-CDISC_CT-40 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :II-CDISC_CT-40 isoI:version "40"^^xsd:string .
	 :II-CDISC_CT-40 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'update=PREFIX : <http://www.assero.co.uk/MDROrganizations#>
PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
INSERT DATA 
{
   :II-CDISC_CT-41 rdf:type isoI:ScopedIdentifier .
	 :II-CDISC_CT-41 isoI:identifier "CDISC Terminology"^^xsd:string .
	 :II-CDISC_CT-41 isoI:version "41"^^xsd:string .
	 :II-CDISC_CT-41 isoI:scopeRelationship :NS-CDISC ;
}' $UpdateEndPoint

if [ "$DB" = "$Fuseki" ]; then
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@CT_V34.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@CT_V35.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@CT_V36.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@CT_V37.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@CT_V38.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@CT_V39.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@CT_V40.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@CT_V41.ttl" $FileEndPoint
	curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@CT_V42.ttl" $FileEndPoint
else
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T CT_V34.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T CT_V35.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T CT_V36.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T CT_V37.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T CT_V38.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T CT_V39.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T CT_V40.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T CT_V41.ttl $FileEndPoint
	curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T CT_V42.ttl $FileEndPoint
fi

set +x