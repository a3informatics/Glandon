set -x
FileEndPoint="https://s4h7h1e8absr:47q8uce2r1b4cri@rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements"
curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/ISO11179Concepts.ttl $FileEndPoint
curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/ISO21090.ttl $FileEndPoint
curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/BRIDG.ttl $FileEndPoint
curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T schema/CDISCBiomedicalConcept.ttl $FileEndPoint
curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRISO21090.ttl $FileEndPoint
curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRBRIDG.ttl $FileEndPoint
curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRCDISCBCs.ttl $FileEndPoint
curl -v -X POST -H "Content-Type:application/x-turtle;charset=UTF-8" -T data/MDRCDISCBCTs.ttl $FileEndPoint
set +x
