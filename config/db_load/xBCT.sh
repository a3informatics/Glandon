curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'query=PREFIX : <http://www.assero.co.uk/MDRBCTs#>
PREFIX cbc: <http://www.assero.co.uk/CDISCBiomedicalConcept#> 
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
CONSTRUCT 
{  
  ?a ?b ?c .  
  ?d ?e ?f . 
  ?g ?h ?i . 
  ?j ?k ?l . 
  ?m ?n ?o .  
  ?p ?q ?r . 
} 
WHERE 
{ 
  ?a rdf:type cbc:BiomedicalConceptTemplate . 
  ?a ?b ?c . 
  ?a cbc:hasItem ?d . 
  ?d ?e ?f . 
  ?d cbc:hasDatatype ?g . 
  ?g ?h ?i . 
  ?g cbc:hasProperty ?j . 
  ?j ?k ?l . 
  OPTIONAL
  { 
    ?j cbc:hasComplexDatatype ?m .  
    ?m ?n ?o . 
    OPTIONAL 
    {  
      ?m cbc:hasProperty ?p . 
      ?p ?q ?r .  
    } 
  } 
}' http://localhost:3030/mdr/query