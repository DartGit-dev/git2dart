import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Couples a Dart wrapper's lifetime to the companion runtime owner lease.
final class ManagedNativeOwner {
  ManagedNativeOwner._(this._lease);

  /// Acquires and attaches an exact-once native owner lease to [owner].
  factory ManagedNativeOwner.attach(
    Object owner, {
    required String debugLabel,
    required void Function() destroy,
  }) {
    final lease = libgit2Runtime.acquireOwner(debugLabel: debugLabel)
      ..bindDestructor(destroy);
    final token = ManagedNativeOwner._(lease);
    _finalizer.attach(owner, token, detach: owner);
    return token;
  }

  final Libgit2OwnerLease _lease;

  /// Destroys the native owner and completes its runtime lease once.
  void release(Object owner) {
    _lease.release();
    if (_lease.isCompleted) _finalizer.detach(owner);
  }

  /// Completes the lease after native ownership has been transferred.
  void transfer(Object owner) {
    _lease.transfer();
    if (_lease.isCompleted) _finalizer.detach(owner);
  }

  static final Finalizer<ManagedNativeOwner> _finalizer = Finalizer(
    (owner) => owner._lease.releaseFromFinalizer(),
  );
}
