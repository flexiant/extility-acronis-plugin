DEB_EXTILITY_VERSION ?= 0.0.0-devtree
CURRENT_VERSION := $(DEB_EXTILITY_VERSION)
EXTERNAL_FDL:=debian/opt/extility/jade-init/external-fdl

all:
	/bin/mkdir -p ${EXTERNAL_FDL}  2>/dev/null && \
	/bin/cp -a provider/fco-acronis-plugin.lua ${EXTERNAL_FDL} 2>/dev/null && \
	/bin/cp -a translations ${EXTERNAL_FDL} 2>/dev/null && \
	/bin/true 
	
clean:
	/bin/rm -rf debian/opt  2>/dev/null
	/bin/rm -rf debian/etc  2>/dev/null