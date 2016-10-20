#! bin/bash
FileEndPoint="http://localhost:3030/mdr/data"
UpdateEndPoint="http://localhost:3030/mdr/update"
set -
# Sponsor Terminology
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_ACME_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_UCB_AE EXT_1-0.ttl" $FileEndPoint
# Load BCs
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRISO21090.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRBRIDG.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRCDISCBCT_PQR.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRCDISCBCT_CD.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRCDISCBCs.ttl" $FileEndPoint
# Load Forms
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/UCB_DM1 01_0-1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/UCB_DM1 01_1-0.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/UCB_DM1 01_1-1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/UCB_MH1 01_0-1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/UCB_MH1 01_0-2.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/UCB_AEPI1 03_0-1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/UCB_AEPI1 03_0-2.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/UCB_VS DILI_0-1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/UCB_VS SAFETY_0-1.ttl" $FileEndPoint
set +x