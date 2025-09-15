# C-Project-Template

To download latest scripts into your project, just run this command:

```
wget -O fetch-scripts.sh https://raw.githubusercontent.com/Holence/C-Project-Template/refs/heads/main/fetch-scripts.sh && bash fetch-scripts.sh
```

## Feature

- Makefile with rules for compiling and linking .s, .S, .c, .cpp, and static/dynamic library
- support kconfig + fixdep
- install/uninstall
  - executable to `/usr/local/bin`
  - static/shared library to `/usr/local/lib`
  - library headers to `/usr/local/include`
