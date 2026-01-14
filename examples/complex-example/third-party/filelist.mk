# 这里需要依赖 FORCE 是因为 target 是文件
# 如果没有 FORCE, 那么如果文件存在, 就不会进去 make 了

LIBS-$(CONFIG_USE_LIBA) += third-party/liba/build/liba.a
# liba.a 的制作需要进入 liba 目录去 make
third-party/liba/build/liba.a: FORCE
	@$(MAKE) -s -C third-party/liba
clean-all::
	@$(MAKE) -s -C third-party/liba clean-all

LIBS-$(CONFIG_USE_LIBB) += third-party/libb/build/libb.so
# libb.so 的制作需要进入 libb 目录去 make
third-party/libb/build/libb.so: FORCE
	@$(MAKE) -s -C third-party/libb
clean-all::
	@$(MAKE) -s -C third-party/libb clean-all
