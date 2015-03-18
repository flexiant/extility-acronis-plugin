DEB_EXTILITY_VERSION ?= 0.0.0-devtree
CURRENT_VERSION := $(DEB_EXTILITY_VERSION)
JADE_INIT:=debian/opt/extility/jade-init

all:
	/bin/mkdir -p ${JADE_INIT}  2>/dev/null && \
	/bin/cp -a provider/fco-acronis-plugin.lua ${JADE_INIT} 2>/dev/null && \
	/bin/cp -a translations ${JADE_INIT} 2>/dev/null && \
	/bin/true 
	
clean:
	/bin/rm -rf debian/opt  2>/dev/null
	/bin/rm -rf debian/etc  2>/dev/null