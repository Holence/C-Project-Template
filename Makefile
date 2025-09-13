help:
	@echo 'Target:'
	@echo '    clean-all        - run clean-all for all examples'
	@echo '    help             - show help text'

clean-all:
	$(eval examples:=$(shell find ./examples/ -maxdepth 1 -mindepth 1 -type d))
	@$(foreach dir, $(examples), $(MAKE) -C $(dir) clean-all;)
