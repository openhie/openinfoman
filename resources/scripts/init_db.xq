

import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
import module namespace csd_psd = "https://github.com/openhie/openinfoman/csd_psd";
import module namespace csd_lsc = "https://github.com/openhie/openinfoman/csd_lsc";
import module namespace svs_lsvs = "https://github.com/openhie/openinfoman/svs_lsvs";

(csr_proc:init()
,csd_lsc:init_cache_meta()
,csd_psd:init()
,svs_lsvs:init_store()
)
