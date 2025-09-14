# C-Project-Template

To download latest scripts into your project, just run this command:

```
wget -O fetch-scripts.sh https://raw.githubusercontent.com/Holence/C-Project-Template/refs/heads/main/fetch-scripts.sh && bash fetch-scripts.sh
```

## Feature

- makefile + kconfig
- `make STATIC=1 SHARE=1` to build static/shared library
- `make install`/`make uninstall` to install/uninstall "executable" / "static/shared library" / "library headers" into `/usr/local`
