include scripts/setting.mk

all: fixdep conf mconf

fixdep:
	@$(MAKE) -s -f fixdep.mk

conf:
	@$(MAKE) -s -f kconfig.mk NAME=conf

mconf:
	@$(MAKE) -s -f kconfig.mk NAME=mconf

clean-all:
	@$(MAKE) -f fixdep.mk clean-all
	@$(MAKE) -f kconfig.mk NAME=conf clean-all
	@$(MAKE) -f kconfig.mk NAME=mconf clean-all
	-$(RM) -r build

install:
	@$(MAKE) -s -f fixdep.mk install
	@$(MAKE) -s -f kconfig.mk NAME=conf install
	@$(MAKE) -s -f kconfig.mk NAME=mconf install

uninstall:
	@$(MAKE) -f fixdep.mk uninstall
	@$(MAKE) -f kconfig.mk NAME=conf uninstall
	@$(MAKE) -f kconfig.mk NAME=mconf uninstall
