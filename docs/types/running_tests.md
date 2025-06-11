# Running Tests

To run all tests and generate coverage report make sure to have activated packages and [lcov](https://github.com/linux-test-project/lcov) installed:

```sh
dart pub global activate coverage
```

And run:

```sh
dart pub global run coverage:test_with_coverage
open coverage/index.html
```

---

## Licence

MIT. See [LICENSE](LICENSE) file for more information.


[![Star History Chart](https://api.star-history.com/svg?repos=DartGit-dev/git2dart&type=Date)](https://www.star-history.com/#DartGit-dev/git2dart&Date)
