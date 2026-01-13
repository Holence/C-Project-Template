include scripts/setting.mk

all:
	@$(MAKE) -f fixdep.mk
	@$(MAKE) -f kconfig.mk NAME=conf
	@$(MAKE) -f kconfig.mk NAME=mconf

clean-all:
	@$(MAKE) -f fixdep.mk clean-all
	@$(MAKE) -f kconfig.mk NAME=conf clean-all
	@$(MAKE) -f kconfig.mk NAME=mconf clean-all
	-$(RM) -r build

install:
	@$(MAKE) -f fixdep.mk install
	@$(MAKE) -f kconfig.mk NAME=conf install
	@$(MAKE) -f kconfig.mk NAME=mconf install

uninstall:
	@$(MAKE) -f fixdep.mk uninstall
	@$(MAKE) -f kconfig.mk NAME=conf uninstall
	@$(MAKE) -f kconfig.mk NAME=mconf uninstall
