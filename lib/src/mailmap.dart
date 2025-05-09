import 'dart:ffi';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/mailmap.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// A class representing a Git mailmap, which maps commit author/committer names and emails
/// to their canonical forms.
///
/// Mailmaps are used to normalize author and committer names and emails in a Git repository.
/// This is particularly useful when the same person has committed under different names or
/// email addresses.
class Mailmap {
  /// Initializes a new empty instance of [Mailmap].
  ///
  /// This object is empty, so you'll need to add entries using [addEntry] before you can
  /// use it for resolving names and emails.
  ///
  /// Example:
  /// ```dart
  /// final mailmap = Mailmap.empty();
  /// mailmap.addEntry(
  ///   realName: 'John Doe',
  ///   realEmail: 'john.doe@example.com',
  ///   replaceEmail: 'johndoe@example.com'
  /// );
  /// ```
  Mailmap.empty() {
    libgit2.git_libgit2_init();

    _mailmapPointer = bindings.init();
    _finalizer.attach(this, _mailmapPointer, detach: this);
  }

  /// Initializes a new instance of [Mailmap] from a string buffer containing mailmap data.
  ///
  /// The buffer should contain mailmap entries in the standard Git mailmap format:
  /// ```
  /// Proper Name <commit@email.xx> <commit@email.xx>
  /// ```
  ///
  /// Throws a [LibGit2Error] if the buffer cannot be parsed.
  ///
  /// Example:
  /// ```dart
  /// final mailmap = Mailmap.fromBuffer('''
  ///   John Doe <john.doe@example.com> <johndoe@example.com>
  ///   Jane Smith <jane.smith@example.com> <jsmith@example.com>
  /// ''');
  /// ```
  Mailmap.fromBuffer(String buffer) {
    libgit2.git_libgit2_init();

    _mailmapPointer = bindings.fromBuffer(buffer);
    _finalizer.attach(this, _mailmapPointer, detach: this);
  }

  /// Initializes a new instance of [Mailmap] from a repository, loading mailmap files
  /// based on the repository's configuration.
  ///
  /// Mailmaps are loaded in the following order:
  ///
  /// 1. `.mailmap` in the root of the repository's working directory, if present.
  /// 2. The blob object identified by the `mailmap.blob` config entry, if set.
  ///    Note: `mailmap.blob` defaults to `HEAD:.mailmap` in bare repositories.
  /// 3. The path in the `mailmap.file` config entry, if set.
  ///
  /// Throws a [LibGit2Error] if an error occurs during loading.
  ///
  /// Example:
  /// ```dart
  /// final repo = Repository.open('path/to/repo');
  /// final mailmap = Mailmap.fromRepository(repo);
  /// ```
  Mailmap.fromRepository(Repository repo) {
    _mailmapPointer = bindings.fromRepository(repo.pointer);
    _finalizer.attach(this, _mailmapPointer, detach: this);
  }

  /// Pointer to the underlying Git mailmap object.
  late final Pointer<git_mailmap> _mailmapPointer;

  /// Resolves a name and email to their canonical forms according to the mailmap.
  ///
  /// Returns a list containing two elements:
  /// 1. The resolved real name
  /// 2. The resolved real email
  ///
  /// If no mapping exists for the given name and email, the original values are returned.
  ///
  /// Example:
  /// ```dart
  /// final resolved = mailmap.resolve(
  ///   name: 'John Doe',
  ///   email: 'johndoe@example.com'
  /// );
  /// print('Real name: ${resolved[0]}');
  /// print('Real email: ${resolved[1]}');
  /// ```
  List<String> resolve({required String name, required String email}) {
    return bindings.resolve(
      mailmapPointer: _mailmapPointer,
      name: name,
      email: email,
    );
  }

  /// Resolves a signature to use real names and emails according to the mailmap.
  ///
  /// Returns a new [Signature] object with the resolved name and email.
  ///
  /// Example:
  /// ```dart
  /// final originalSignature = Signature.now('John Doe', 'johndoe@example.com');
  /// final resolvedSignature = mailmap.resolveSignature(originalSignature);
  /// ```
  Signature resolveSignature(Signature signature) {
    return Signature(
      bindings.resolveSignature(
        mailmapPointer: _mailmapPointer,
        signaturePointer: signature.pointer,
      ),
    );
  }

  /// Adds a single entry to the mailmap.
  ///
  /// If an entry already exists for the given replace email, it will be replaced
  /// with the new entry.
  ///
  /// Parameters:
  /// * [realName] - The canonical name to map to (optional)
  /// * [realEmail] - The canonical email to map to (optional)
  /// * [replaceName] - The name to be replaced (optional)
  /// * [replaceEmail] - The email to be replaced (required)
  ///
  /// Throws an [ArgumentError] if [replaceEmail] is empty.
  ///
  /// Example:
  /// ```dart
  /// mailmap.addEntry(
  ///   realName: 'John Doe',
  ///   realEmail: 'john.doe@example.com',
  ///   replaceName: 'Johnny',
  ///   replaceEmail: 'johndoe@example.com'
  /// );
  /// ```
  void addEntry({
    String? realName,
    String? realEmail,
    String? replaceName,
    required String replaceEmail,
  }) {
    if (replaceEmail.trim().isEmpty) {
      throw ArgumentError.value(
        replaceEmail,
        'replaceEmail',
        'Email address cannot be empty',
      );
    }

    bindings.addEntry(
      mailmapPointer: _mailmapPointer,
      realName: realName,
      realEmail: realEmail,
      replaceName: replaceName,
      replaceEmail: replaceEmail,
    );
  }

  /// Releases the memory allocated for this mailmap object.
  ///
  /// This method should be called when the mailmap is no longer needed to prevent
  /// memory leaks. However, if the mailmap was created using one of the constructors,
  /// it will be automatically freed when the object is garbage collected.
  void free() {
    bindings.free(_mailmapPointer);
    _finalizer.detach(this);
  }
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_mailmap>>(
  (pointer) => bindings.free(pointer),
);
// coverage:ignore-end
