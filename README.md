# git2dart
![Pub Version](https://img.shields.io/pub/v/git2dart)
![Pub Monthly Downloads](https://img.shields.io/pub/dm/git2dart)
![Pub Likes](https://img.shields.io/pub/likes/git2dart)

## Dart bindings to libgit2

git2dart package provides ability to use [libgit2](https://github.com/libgit2/libgit2) in Dart/Flutter.

This is a hardfork of [libgit2dart](https://github.com/SkinnyMind/libgit2dart)

Currently supported platforms are 64-bit Windows, Linux and macOS on both Flutter and Dart VM.

# Documentation

See the [docs directory](docs/README.md) for full documentation and usage examples.

---

## Contributing

Fork git2dart, improve git2dart, send a pull request.

---

## Development

### Troubleshooting

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

### Running Tests

To run all tests and generate coverage report make sure to have activated packages and [lcov](https://github.com/linux-test-project/lcov) installed:

```sh
dart pub global activate coverage
```

And run:

```sh
./coverage.sh
open coverage/index.html
```

---

## Licence

MIT. See [LICENSE](LICENSE) file for more information.


[![Star History Chart](https://api.star-history.com/svg?repos=DartGit-dev/git2dart&type=Date)](https://www.star-history.com/#DartGit-dev/git2dart&Date)
