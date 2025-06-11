# Troubleshooting

#### Linux

If you are developing on Linux using non-Debian based distrib you might encounter these errors:

- Failed to load dynamic library: libpcre.so.3: cannot open shared object file: No such file or directory
- Failed to load dynamic library: libpcreposix.so.3: cannot open shared object file: No such file or directory

That happens because dynamic library is precompiled on Ubuntu and Arch/Fedora/RedHat names for those libraries are `libpcre.so` and `libpcreposix.so`.

To fix these errors create symlinks:

```shell
sudo ln -s /usr/lib64/libpcre.so /usr/lib64/libpcre.so.3
sudo ln -s /usr/lib64/libpcreposix.so /usr/lib64/libpcreposix.so.3
```

