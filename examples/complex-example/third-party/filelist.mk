LIBS-$(CONFIG_USE_LIBA) += third-party/liba/build/liba.a
third-party/liba/build/liba.a:
	@$(MAKE) -C third-party/liba
clean-all::
	@$(MAKE) -C third-party/liba clean-all

LIBS-$(CONFIG_USE_LIBB) += third-party/libb/build/libb.so
third-party/libb/build/libb.so:
	@$(MAKE) -C third-party/libb
clean-all::
	@$(MAKE) -C third-party/libb clean-all
