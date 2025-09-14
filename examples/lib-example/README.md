```sh
# compile and install mymath lib
cd mymath
make menuconfig
sudo make install

# compile and run demo
cd demo
make run
# install demo
sudo make install
demo

# uninstall
cd mymath && sudo make uninstall
cd demo && sudo make uninstall
```
