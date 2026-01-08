```sh
# compile and install libmymath
cd libmymath
make menuconfig
sudo make install

# compile and run demo
cd demo
make run
# install demo
sudo make install
demo

# uninstall
cd libmymath && sudo make uninstall
cd demo && sudo make uninstall
```
