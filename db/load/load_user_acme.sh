#! bin/bash
FileEndPoint="http://localhost:3030/mdr/data"
UpdateEndPoint="http://localhost:3030/mdr/update"
set -
# Sponsor Terminology
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/CT_ACME_CDISC_EXTENSION_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_QS_TERM_STD.ttl" $FileEndPoint
# Load BCTs
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/AE_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/CM_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/MH_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/LB_CD_INT_PQR_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/LB_CD_V2.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/LB_CD_V3.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/LB_INT_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/LB_INT_V2.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/LB_PQR_V2.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/LB_PQR_V3.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/Obs_CD_INT_PQR_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/Obs_CD_INT_PQR_V2.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/Obs_CD_V3.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/Obs_CD_V4.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/Obs_CD_V5.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/Obs_INT_V1.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/Obs_INT_V2.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/Obs_INT_V3.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/Obs_PQR_V3.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/Obs_PQR_V4.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/BCT/Obs_PQR_V5.ttl" $FileEndPoint
# Load BCs
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/MDRCDISCBCs.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_BC_C100392_STD.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_BC_C100393_STD.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_BC_C100394_STD.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_BC_C100395_STD.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_BC_C100396_STD.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_BC_C100397_STD.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_BC_C25208_V2.ttl" $FileEndPoint
# Load Forms
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_DM1 01.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_AEPI1 03.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_CDASH DEMO.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_MIXED_DFT.ttl" $FileEndPoint
curl -v -X POST -H "Content-Type:multipart/form-data" -F "filename=@data/ACME_EQ5D3L_DFT.ttl" $FileEndPoint
#
set +x



