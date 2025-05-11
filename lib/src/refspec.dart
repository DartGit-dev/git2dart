import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/refspec.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// A class representing a Git refspec, which defines the mapping between
/// local and remote references.
///
/// A refspec is a string that specifies how references should be transferred
/// between a remote and a local repository. It consists of a source and
/// destination pattern, separated by a colon. For example:
/// - `refs/heads/*:refs/remotes/origin/*` maps all remote branches to local
///   remote-tracking branches
/// - `refs/heads/master:refs/heads/master` maps the remote master branch to
///   the local master branch
///
/// The class provides methods to:
/// - Get source and destination patterns
/// - Check if a reference matches the source or destination pattern
/// - Transform references according to the refspec rules
/// - Determine the direction (fetch or push) and force update settings
@immutable
class Refspec extends Equatable {
  /// Initializes a new instance of the [Refspec] class
  /// from provided pointer to refspec object in memory.
  ///
  /// Note: For internal use only. Use [Remote.getRefspec] to get a refspec
  /// instance.
  @internal
  const Refspec(this._refspecPointer);

  /// Pointer to memory address for allocated refspec object.
  final Pointer<git_refspec> _refspecPointer;

  /// Gets the source pattern of the refspec.
  ///
  /// The source pattern defines which references on the source side
  /// (remote for fetch, local for push) should be included.
  ///
  /// Example: For `refs/heads/*:refs/remotes/origin/*`, returns `refs/heads/*`
  String get source => bindings.source(_refspecPointer);

  /// Gets the destination pattern of the refspec.
  ///
  /// The destination pattern defines where the matching references should
  /// be placed on the destination side (local for fetch, remote for push).
  ///
  /// Example: For `refs/heads/*:refs/remotes/origin/*`, returns `refs/remotes/origin/*`
  String get destination => bindings.destination(_refspecPointer);

  /// Gets whether the refspec forces updates.
  ///
  /// When true, the refspec will force update the destination reference
  /// even if it's not a fast-forward update.
  ///
  /// Example: For `+refs/heads/*:refs/remotes/origin/*`, returns `true`
  bool get force => bindings.force(_refspecPointer);

  /// Gets the complete refspec string.
  ///
  /// Returns the full refspec string including the force flag (+),
  /// source and destination patterns.
  ///
  /// Example: For a force update refspec, returns `+refs/heads/*:refs/remotes/origin/*`
  String get string => bindings.string(_refspecPointer);

  /// Gets the direction of the refspec.
  ///
  /// Returns [GitDirection.fetch] for fetch refspecs and [GitDirection.push]
  /// for push refspecs.
  GitDirection get direction {
    return bindings.direction(_refspecPointer).value == 0
        ? GitDirection.fetch
        : GitDirection.push;
  }

  /// Checks if a reference matches the source pattern of the refspec.
  ///
  /// Returns true if the given reference name matches the source pattern
  /// of this refspec.
  ///
  /// Example:
  /// ```dart
  /// final refspec = Refspec(...); // +refs/heads/*:refs/remotes/origin/*
  /// final matches = refspec.matchesSource('refs/heads/master'); // true
  /// ```
  bool matchesSource(String refname) {
    return bindings.matchesSource(
      refspecPointer: _refspecPointer,
      refname: refname,
    );
  }

  /// Checks if a reference matches the destination pattern of the refspec.
  ///
  /// Returns true if the given reference name matches the destination pattern
  /// of this refspec.
  ///
  /// Example:
  /// ```dart
  /// final refspec = Refspec(...); // +refs/heads/*:refs/remotes/origin/*
  /// final matches = refspec.matchesDestination('refs/remotes/origin/master'); // true
  /// ```
  bool matchesDestination(String refname) {
    return bindings.matchesDestination(
      refspecPointer: _refspecPointer,
      refname: refname,
    );
  }

  /// Transforms a reference to its target following the refspec's rules.
  ///
  /// Applies the refspec transformation rules to convert a reference name
  /// from the source format to the destination format.
  ///
  /// Example:
  /// ```dart
  /// final refspec = Refspec(...); // +refs/heads/*:refs/remotes/origin/*
  /// final transformed = refspec.transform('refs/heads/master');
  /// // Returns 'refs/remotes/origin/master'
  /// ```
  ///
  /// Throws a [LibGit2Error] if the transformation fails.
  String transform(String name) {
    return bindings.transform(refspecPointer: _refspecPointer, name: name);
  }

  /// Transforms a target reference to its source reference following the
  /// refspec's rules.
  ///
  /// Applies the refspec transformation rules in reverse to convert a
  /// reference name from the destination format to the source format.
  ///
  /// Example:
  /// ```dart
  /// final refspec = Refspec(...); // +refs/heads/*:refs/remotes/origin/*
  /// final transformed = refspec.rTransform('refs/remotes/origin/master');
  /// // Returns 'refs/heads/master'
  /// ```
  ///
  /// Throws a [LibGit2Error] if the transformation fails.
  String rTransform(String name) {
    return bindings.rTransform(refspecPointer: _refspecPointer, name: name);
  }

  @override
  String toString() {
    return 'Refspec{source: $source, destination: $destination, force: $force, '
        'string: $string, direction: $direction}';
  }

  @override
  List<Object?> get props => [source, destination, force, string, direction];
}
