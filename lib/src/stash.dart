import 'package:equatable/equatable.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/stash.dart' as bindings;
import 'package:meta/meta.dart';

/// A class representing a Git stash entry.
///
/// A stash is a way to temporarily save your local modifications and revert
/// the working directory to a clean state. Each stash entry contains:
/// - An index indicating its position in the stash list
/// - A message describing the changes
/// - An OID (Object ID) pointing to the commit containing the stashed changes
@immutable
class Stash extends Equatable {
  /// Creates a new instance of [Stash] with the given [index], [message], and [oid].
  ///
  /// This constructor is for internal use only. To create a stash, use [Stash.create]
  /// instead.
  @internal
  const Stash({required this.index, required this.message, required this.oid});

  /// The position of this stash in the stash list (0 being the most recent).
  final int index;

  /// A descriptive message for this stash entry.
  final String message;

  /// The commit [Oid] containing the stashed changes.
  final Oid oid;

  /// Lists all stashed states in the repository, with the most recent stash first.
  ///
  /// Returns a list of [Stash] objects representing all stashed changes in the
  /// repository.
  ///
  /// Throws a [LibGit2Error] if an error occurs while listing stashes.
  static List<Stash> list(Repository repo) => bindings.list(repo.pointer);

  /// Saves the current working directory state to a new stash.
  ///
  /// This method takes a snapshot of your current working directory and index,
  /// saves it to a new stash entry, and reverts the working directory to a clean
  /// state.
  ///
  /// Parameters:
  /// - [repo]: The repository to stash changes from
  /// - [stasher]: The identity of the person performing the stash operation
  /// - [message]: Optional description of the stashed changes
  /// - [flags]: Optional flags to control stash behavior. Defaults to [GitStash.defaults]
  ///
  /// Returns the [Oid] of the newly created stash commit.
  ///
  /// Throws a [LibGit2Error] if an error occurs during the stash operation.
  static Oid create({
    required Repository repo,
    required Signature stasher,
    String? message,
    Set<GitStash> flags = const {GitStash.defaults},
  }) {
    return Oid(
      bindings.save(
        repoPointer: repo.pointer,
        stasherPointer: stasher.pointer,
        message: message,
        flags: flags.fold(0, (int acc, e) => acc | e.value),
      ),
    );
  }

  /// Applies a stashed state to the working directory.
  ///
  /// This method takes a stashed state and applies it to the current working
  /// directory, without removing it from the stash list.
  ///
  /// Parameters:
  /// - [repo]: The repository to apply the stash to
  /// - [index]: The position of the stash to apply (0 being the most recent)
  /// - [reinstateIndex]: Whether to also restore the index state
  /// - [strategy]: Checkout strategy to use when applying changes
  /// - [directory]: Optional alternative checkout path
  /// - [paths]: Optional list of paths to apply the stash to
  ///
  /// Throws a [LibGit2Error] if an error occurs during the apply operation.
  static void apply({
    required Repository repo,
    int index = 0,
    bool reinstateIndex = false,
    Set<GitCheckout> strategy = const {
      GitCheckout.safe,
      GitCheckout.recreateMissing,
    },
    String? directory,
    List<String>? paths,
  }) {
    bindings.apply(
      repoPointer: repo.pointer,
      index: index,
      flags: reinstateIndex ? GitStashApply.reinstateIndex.value : 0,
      strategy: strategy.fold(0, (acc, e) => acc | e.value),
      directory: directory,
      paths: paths,
    );
  }

  /// Removes a stashed state from the stash list.
  ///
  /// This method permanently removes a stash entry from the repository.
  ///
  /// Parameters:
  /// - [repo]: The repository containing the stash
  /// - [index]: The position of the stash to remove (0 being the most recent)
  ///
  /// Throws a [LibGit2Error] if an error occurs during the drop operation.
  static void drop({required Repository repo, int index = 0}) {
    bindings.drop(repoPointer: repo.pointer, index: index);
  }

  /// Applies a stashed state and removes it from the stash list.
  ///
  /// This method combines [apply] and [drop] operations - it applies the stash
  /// to the working directory and then removes it from the stash list if the
  /// apply was successful.
  ///
  /// Parameters:
  /// - [repo]: The repository to apply the stash to
  /// - [index]: The position of the stash to pop (0 being the most recent)
  /// - [reinstateIndex]: Whether to also restore the index state
  /// - [strategy]: Checkout strategy to use when applying changes
  /// - [directory]: Optional alternative checkout path
  /// - [paths]: Optional list of paths to apply the stash to
  ///
  /// Throws a [LibGit2Error] if an error occurs during the pop operation.
  static void pop({
    required Repository repo,
    int index = 0,
    bool reinstateIndex = false,
    Set<GitCheckout> strategy = const {
      GitCheckout.safe,
      GitCheckout.recreateMissing,
    },
    String? directory,
    List<String>? paths,
  }) {
    bindings.pop(
      repoPointer: repo.pointer,
      index: index,
      flags: reinstateIndex ? GitStashApply.reinstateIndex.value : 0,
      strategy: strategy.fold(0, (acc, e) => acc | e.value),
      directory: directory,
      paths: paths,
    );
  }

  @override
  String toString() {
    return 'Stash{index: $index, message: $message, oid: $oid}';
  }

  @override
  List<Object?> get props => [index, message, oid];
}
