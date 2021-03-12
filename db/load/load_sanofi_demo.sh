#! bin/bash
FileEndPoint="http://localhost:3030/mdr/data"
UpdateEndPoint="http://localhost:3030/mdr/update"
set -x
# Dump
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@../../spec/fixtures/files/models/import/data/sanofi/sanofi_protocol_base_2.nq.gz" $FileEndPoint
# Extra Schema
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/protocol.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@schema/enumerated.ttl" $FileEndPoint
# Extra Data
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@../../spec/fixtures/files/models/import/data/sanofi/a_protocol_templates.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@../../spec/fixtures/files/models/import/data/sanofi/b_parameters.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@../../spec/fixtures/files/models/import/data/sanofi/c_endpoints.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@../../spec/fixtures/files/models/import/data/sanofi/c_objectives.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@../../spec/fixtures/files/models/import/data/sanofi/d_indications.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@../../spec/fixtures/files/models/import/data/sanofi/d_therapeutic_areas.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@../../spec/fixtures/files/models/import/data/sanofi/zdummymed_protocols.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@../../spec/fixtures/files/models/import/data/sanofi/zinvestdev1_protocols.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@../../spec/fixtures/files/models/import/data/sanofi/zinvestdev2_protocols.ttl" $FileEndPoint
set +x
