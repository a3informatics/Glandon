#! bin/bash
FileEndPoint="http://localhost:3030/mdr/data"
UpdateEndPoint="http://localhost:3030/mdr/update"
set -
# Sponsor Terminology
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_ACME_CDISC_EXTENSION_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_QS_TERM_STD.ttl" $FileEndPoint
# Load BCs
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRISO21090.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRBRIDG.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDR_Finding_BCT_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRCDISCBCs.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_BC_C100392_STD.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_BC_C100393_STD.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_BC_C100394_STD.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_BC_C100395_STD.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_BC_C100396_STD.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_BC_C100397_STD.ttl" $FileEndPoint
# Load Forms
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_DM1 01.ttl" $FileEndPoint
#curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_MH1 01.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_AEPI1 03.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_CDASH DEMO.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_MIXED_DFT.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_EQ5D3L_DFT.ttl" $FileEndPoint
# Domains
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_QS_Domain.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_VS_Domain.ttl" $FileEndPoint
set +x