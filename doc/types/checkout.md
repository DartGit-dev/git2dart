# Checkout

Perform different types of checkout:

```dart
// Update files in the index and the working directory to match the
// content of the commit pointed at by HEAD
Checkout.head(repo: repo);

// Update files in the working directory to match the content of the index
Checkout.index(repo: repo);

// Update files in the working directory to match the content of the tree
// pointed at by the reference target
Checkout.reference(repo: repo, name: 'refs/heads/master');

// Update files in the working directory to match the content of the tree
// pointed at by the commit
Checkout.commit(repo: repo, commit: commit);

// Perform checkout using various strategies
Checkout.head(repo: repo, strategy: {GitCheckout.force});

// Checkout only required files
Checkout.head(repo: repo, paths: ['some/file.txt']);
```

---


For more examples see [test/checkout_test.dart](../../test/checkout_test.dart).
