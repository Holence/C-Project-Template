# 这里需要依赖 FORCE 是因为 target 是文件
# 如果没有 FORCE, 那么如果文件存在, 就不会进去 make 了

LIBS-$(CONFIG_USE_LIBA) += third-party/liba/liba.a
# liba.a 的制作需要进入 liba 目录去 make
third-party/liba/liba.a: FORCE
	@$(MAKE) --no-print-directory -C third-party/liba
clean::
	@$(MAKE) --no-print-directory -C third-party/liba clean

LIBS-$(CONFIG_USE_LIBB) += third-party/libb/libb.so
# libb.so 的制作需要进入 libb 目录去 make
third-party/libb/libb.so: FORCE
	@$(MAKE) --no-print-directory -C third-party/libb
clean::
	@$(MAKE) --no-print-directory -C third-party/libb clean
