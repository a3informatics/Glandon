set -x
curl -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T ISO11179Types.ttl https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements
curl -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T ISO11179Basic.ttl https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements
curl -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T ISO11179Identification.ttl https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements
curl -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T ISO11179Registration.ttl https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements
curl -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T ISO11179Data.ttl https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements
curl -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T ISO11179Concepts.ttl https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements
curl -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T ISO25964.ttl https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements

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
}' https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements

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
}' https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements

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
}' https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements
set +x