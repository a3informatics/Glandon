#! bin/bash
FileEndPoint="http://localhost:3030/mdr/data"
UpdateEndPoint="http://localhost:3030/mdr/update"
set -
# Sponsor Terminology
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_ACME_V1.ttl" $FileEndPoint
# Load BCs
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRISO21090.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRBRIDG.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRCDISCBCTs.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRCDISCBCs.ttl" $FileEndPoint
# Load Forms
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/UCB_DM1 01.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/UCB_MH1 01.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/UCB_AEPI1 03.ttl" $FileEndPoint
set +x