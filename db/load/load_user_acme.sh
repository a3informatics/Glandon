#! bin/bash
FileEndPoint="http://localhost:3030/mdr/data"
UpdateEndPoint="http://localhost:3030/mdr/update"
set -
# Sponsor Terminology
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_ACME_CDISC_EXTENSION_V1.ttl" $FileEndPoint
# Load BCs
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRISO21090.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRBRIDG.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRCDISCBCTs.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRCDISCBCs.ttl" $FileEndPoint
# Load Forms
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_DM1 01.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_MH1 01.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_AEPI1 03.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_VS BASELINE.ttl" $FileEndPoint
set +x