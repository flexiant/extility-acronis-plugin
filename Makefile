DEB_EXTILITY_VERSION ?= 0.0.0-devtree
CURRENT_VERSION := $(DEB_EXTILITY_VERSION)
EXTERNAL_FDL:=debian/opt/extility/jade-init/external-fdl
JADE_UTILS:=debian/opt/extility/jade-utils/fco-acronis-plugin
BLOBS_FOLDER:=debian/opt/extility/jade-init/external-fdl/_skyline/blobs

all:
	/bin/mkdir -p ${EXTERNAL_FDL}  2>/dev/null && \
	/bin/mkdir -p ${JADE_UTILS} 2>/dev/null && \
	/bin/mkdir -p ${BLOBS_FOLDER} 2>/dev/null && \
	/bin/cp -a provider/fco-acronis-plugin.lua ${EXTERNAL_FDL} 2>/dev/null && \
	/bin/cp -a translations ${EXTERNAL_FDL} 2>/dev/null && \
	/bin/cp -a scripts ${JADE_UTILS} 2>/dev/null && \
	/bin/cp -a scripts/fco-acronis-setup-script.pl ${BLOBS_FOLDER} 2>/dev/null && \
	/bin/true 
	
clean:
	/bin/rm -rf debian/opt  2>/dev/null
	/bin/rm -rf debian/etc  2>/dev/null