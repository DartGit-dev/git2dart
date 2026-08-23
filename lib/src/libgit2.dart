import 'dart:ffi';

import 'package:ffi/ffi.dart' show calloc, using;
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/object.dart' as object_bindings;
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Main class for interacting with libgit2 library.
///
/// This class provides access to global libgit2 options and settings.
/// All methods are static as they operate on global libgit2 state.
class Libgit2 {
  Libgit2._(); // coverage:ignore-line

  /// Releases this isolate's managed libgit2 lease.
  ///
  /// Shutdown is rejected while native calls or independently usable native
  /// owners are still active. A successful shutdown is terminal for this
  /// isolate; repeated calls return the original native result.
  static int shutdown() => libgit2Runtime.shutdown();

  /// Get the current libgit2 version number.
  ///
  /// Returns a string in the format "major.minor.revision".
  static String get version {
    return using((arena) {
      final major = arena<Int>();
      final minor = arena<Int>();
      final rev = arena<Int>();
      libgit2Runtime.bindings.git_libgit2_version(major, minor, rev);
      return '${major.value}.${minor.value}.${rev.value}';
    });
  }

  /// Get the features that libgit2 was compiled with.
  ///
  /// Returns a set of [GitFeature] values indicating which features
  /// are available in this build of libgit2Runtime.bindings.
  static Set<GitFeature> get features {
    final featuresInt = libgit2Runtime.bindings.git_libgit2_features();
    return GitFeature.values
        .where((e) => featuresInt & e.value == e.value)
        .toSet();
  }

  /// Prerelease state of the loaded libgit2 library, or `null` for a final
  /// release build.
  static String? get prerelease {
    final result = libgit2Runtime.bindings.git_libgit2_prerelease();
    return result == nullptr ? null : result.toDartString();
  }

  /// Backend details for a compile-time [feature], or `null` if unsupported.
  static String? featureBackend(GitFeature feature) {
    final result = libgit2Runtime.bindings.git_libgit2_feature_backend(
      git_feature_t.fromValue(feature.value),
    );
    return result == nullptr ? null : result.toDartString();
  }

  /// Returns whether [type] is a valid loose object type.
  static bool objectTypeIsLoose(GitObject type) {
    return object_bindings.typeIsLoose(git_object_t.fromValue(type.value));
  }

  /// Returns whether [path] matches one of libgit2's protected gitfile names.
  static bool isGitFile({
    required String path,
    required GitPathGitFile gitfile,
    GitPathFilesystem filesystem = GitPathFilesystem.generic,
  }) {
    return using((arena) {
      final pathC = path.toChar(arena);
      final result = libgit2Runtime.bindings.git_path_is_gitfile(
        pathC,
        path.length,
        git_path_gitfile.fromValue(gitfile.value),
        git_path_fs.fromValue(filesystem.value),
      );
      if (result < 0) {
        throw LibGit2Error(libgit2Runtime.bindings.git_error_last());
      }
      return result > 0;
    });
  }

  /// Get or set the maximum mmap window size.
  ///
  /// This controls the maximum size of memory-mapped files that libgit2
  /// will use. Larger values may improve performance but use more memory.
  static int get mmapWindowSize {
    return using((arena) {
      final out = arena<Int>();
      final error = libgit2Runtime.options.git_libgit2_opts_get_mwindow_size(
        out,
      );
      checkErrorAndThrow(error);
      return out.value;
    });
  }

  static set mmapWindowSize(int value) {
    final error = libgit2Runtime.options.git_libgit2_opts_set_mwindow_size(
      value,
    );
    checkErrorAndThrow(error);
  }

  /// Get or set the maximum total memory that will be mapped by the library.
  ///
  /// The default (0) is unlimited. This is a soft limit that may be
  /// temporarily exceeded.
  static int get mmapWindowMappedLimit {
    return using((arena) {
      final out = arena<Int>();
      final error = libgit2Runtime.options
          .git_libgit2_opts_get_mwindow_mapped_limit(out);
      checkErrorAndThrow(error);
      return out.value;
    });
  }

  static set mmapWindowMappedLimit(int value) {
    final error = libgit2Runtime.options
        .git_libgit2_opts_set_mwindow_mapped_limit(value);
    checkErrorAndThrow(error);
  }

  /// Get or set the maximum number of files that will be mapped at any time.
  ///
  /// The default (0) is unlimited. This helps control memory usage when
  /// working with many repositories.
  static int get mmapWindowFileLimit {
    return using((arena) {
      final out = arena<Int>();
      final error = libgit2Runtime.options
          .git_libgit2_opts_get_mwindow_file_limit(out);
      checkErrorAndThrow(error);
      return out.value;
    });
  }

  static set mmapWindowFileLimit(int value) {
    final error = libgit2Runtime.options
        .git_libgit2_opts_set_mwindow_file_limit(value);
    checkErrorAndThrow(error);
  }

  /// Get the search path for a given config level.
  ///
  /// [level] must be one of:
  /// - [GitConfigLevel.system]
  /// - [GitConfigLevel.global]
  /// - [GitConfigLevel.xdg]
  /// - [GitConfigLevel.programData]
  ///
  /// Returns the path where config files for this level are stored.
  static String getConfigSearchPath(GitConfigLevel level) {
    return using((arena) {
      final out = arena<git_buf>();
      final error = libgit2Runtime.options.git_libgit2_opts_get_search_path(
        level.value,
        out,
      );
      checkErrorAndThrow(error);
      final result = out.ref.ptr.toDartString(length: out.ref.size);
      libgit2Runtime.bindings.git_buf_dispose(out);
      return result;
    });
  }

  /// Set the search path for a config level.
  ///
  /// [level] must be one of:
  /// - [GitConfigLevel.system]
  /// - [GitConfigLevel.global]
  /// - [GitConfigLevel.xdg]
  /// - [GitConfigLevel.programData]
  ///
  /// [path] lists directories delimited by `:`. Pass null to reset to default.
  /// Use `$PATH` to include the old value (for prepending/appending).
  static void setConfigSearchPath({
    required GitConfigLevel level,
    required String? path,
  }) {
    using((arena) {
      final pathC = path != null ? path.toChar(arena) : nullptr;
      final error = libgit2Runtime.options.git_libgit2_opts_set_search_path(
        level.value,
        pathC,
      );
      checkErrorAndThrow(error);
    });
  }

  /// Set the maximum data size for caching a given object type.
  ///
  /// Setting [value] to zero means objects of that type won't be cached.
  /// Defaults to 0 for blobs and 4k for commits, trees and tags.
  static void setCacheObjectLimit({
    required GitObject type,
    required int value,
  }) {
    final error = libgit2Runtime.options
        .git_libgit2_opts_set_cache_object_limit(type.value, value);
    checkErrorAndThrow(error);
  }

  /// Set the maximum total cache size across all repositories.
  ///
  /// This is a soft limit - the library may briefly exceed it before
  /// aggressively evicting objects. Default is 256MB.
  static void setCacheMaxSize(int bytes) {
    final error = libgit2Runtime.options.git_libgit2_opts_set_cache_max_size(
      bytes,
    );
    checkErrorAndThrow(error);
  }

  /// Get information about the current cache usage.
  ///
  /// Returns a [CachedMemory] object containing the current bytes in cache
  /// and the maximum allowed.
  static CachedMemory get cachedMemory {
    final current = calloc<Int>();
    final allowed = calloc<Int>();
    final error = libgit2Runtime.options.git_libgit2_opts_get_cached_memory(
      current,
      allowed,
    );
    checkErrorAndThrow(error);

    final result = CachedMemory._(
      current: current.value,
      allowed: allowed.value,
    );

    calloc.free(current);
    calloc.free(allowed);
    return result;
  }

  /// Enable object caching.
  ///
  /// This allows libgit2 to cache objects in memory for better performance.
  static void enableCaching() {
    final error = libgit2Runtime.options.git_libgit2_opts_enable_caching(1);
    checkErrorAndThrow(error);
  }

  /// Disable object caching completely.
  ///
  /// Caches are repository-specific, so disabling won't immediately clear
  /// all cached objects. Each cache will be cleared on next update.
  static void disableCaching() {
    final error = libgit2Runtime.options.git_libgit2_opts_enable_caching(0);
    checkErrorAndThrow(error);
  }

  /// Get or set the default template path.
  ///
  /// This is the path used for repository templates when creating new repos.
  static String get templatePath {
    final out = calloc<git_buf>();
    final error = libgit2Runtime.options.git_libgit2_opts_get_template_path(
      out,
    );
    checkErrorAndThrow(error);
    final result = out.ref.ptr.toDartString(length: out.ref.size);

    libgit2Runtime.bindings.git_buf_dispose(out);
    calloc.free(out);

    return result;
  }

  static set templatePath(String path) {
    using((arena) {
      final pathC = path.toChar(arena);
      final error = libgit2Runtime.options.git_libgit2_opts_set_template_path(
        pathC,
      );
      checkErrorAndThrow(error);
    });
  }

  /// Set SSL certificate locations.
  ///
  /// - [file] is a file containing concatenated certificates
  /// - [path] is a directory containing certificate files
  ///
  /// Either parameter may be null, but not both.
  ///
  /// Throws [ArgumentError] if both arguments are null.
  static void setSSLCertLocations({String? file, String? path}) {
    if (file == null && path == null) {
      throw ArgumentError("Both file and path can't be null");
    } else {
      using((arena) {
        final fileC = file != null ? file.toChar(arena) : nullptr;
        final pathC = path != null ? path.toChar(arena) : nullptr;
        final error = libgit2Runtime.options
            .git_libgit2_opts_set_ssl_cert_locations(fileC, pathC);
        checkErrorAndThrow(error);
      });
    }
  }

  /// Get or set the User-Agent header value.
  ///
  /// This value is appended to "git/1.0" for compatibility with other
  /// git clients.
  static String get userAgent {
    return using((arena) {
      final out = arena<git_buf>();
      final error = libgit2Runtime.options.git_libgit2_opts_get_user_agent(out);
      checkErrorAndThrow(error);
      final result = out.ref.ptr.toDartString(length: out.ref.size);
      libgit2Runtime.bindings.git_buf_dispose(out);
      return result;
    });
  }

  static set userAgent(String userAgent) {
    using((arena) {
      final userAgentC = userAgent.toChar(arena);
      final error = libgit2Runtime.options.git_libgit2_opts_set_user_agent(
        userAgentC,
      );
      checkErrorAndThrow(error);
    });
  }

  /// Enable strict input validation for object creation.
  ///
  /// When enabled, validates all inputs when creating new objects.
  /// For example, validates parent(s) and tree inputs when creating commits.
  ///
  /// Enabled by default.
  static void enableStrictObjectCreation() {
    final error = libgit2Runtime.options
        .git_libgit2_opts_enable_strict_object_creation(1);
    checkErrorAndThrow(error);
  }

  /// Disable strict input validation for object creation.
  ///
  /// When disabled, skips validation of inputs when creating new objects.
  ///
  /// Enabled by default.
  static void disableStrictObjectCreation() {
    final error = libgit2Runtime.options
        .git_libgit2_opts_enable_strict_object_creation(0);
    checkErrorAndThrow(error);
  }

  /// Enable validation of symbolic ref targets.
  ///
  /// When enabled, validates that symbolic ref targets are valid refs.
  /// For example, "foobar" is not valid but "refs/heads/foobar" is.
  ///
  /// Enabled by default.
  static void enableStrictSymbolicRefCreation() {
    final error = libgit2Runtime.options
        .git_libgit2_opts_enable_strict_symbolic_ref_creation(1);
    checkErrorAndThrow(error);
  }

  /// Disable validation of symbolic ref targets.
  ///
  /// When disabled, allows arbitrary strings as symbolic ref targets.
  ///
  /// Enabled by default.
  static void disableStrictSymbolicRefCreation() {
    final error = libgit2Runtime.options
        .git_libgit2_opts_enable_strict_symbolic_ref_creation(0);
    checkErrorAndThrow(error);
  }

  /// Enable use of offset deltas in packfiles.
  ///
  /// Offset deltas store base locations as offsets within the packfile,
  /// providing shorter encoding and smaller packfiles.
  ///
  /// Enabled by default.
  static void enableOffsetDelta() {
    final error = libgit2Runtime.options.git_libgit2_opts_enable_offset_delta(
      1,
    );
    checkErrorAndThrow(error);
  }

  /// Disable use of offset deltas in packfiles.
  ///
  /// Packfiles containing offset deltas can still be read.
  ///
  /// Enabled by default.
  static void disableOffsetDelta() {
    final error = libgit2Runtime.options.git_libgit2_opts_enable_offset_delta(
      0,
    );
    checkErrorAndThrow(error);
  }

  /// Enable synchronized writes to gitdir.
  ///
  /// Uses fsync (or platform equivalent) to ensure object data is written
  /// to permanent storage, not just cached.
  ///
  /// Disabled by default.
  static void enableFsyncGitdir() {
    final error = libgit2Runtime.options.git_libgit2_opts_enable_fsync_gitdir(
      1,
    );
    checkErrorAndThrow(error);
  }

  /// Disable synchronized writes to gitdir.
  ///
  /// Disabled by default.
  static void disableFsyncGitdir() {
    final error = libgit2Runtime.options.git_libgit2_opts_enable_fsync_gitdir(
      0,
    );
    checkErrorAndThrow(error);
  }

  /// Enable strict hash verification.
  ///
  /// When enabled, verifies object hashsums when reading from disk.
  /// This may impact performance due to additional checksum calculations.
  ///
  /// Enabled by default.
  static void enableStrictHashVerification() {
    final error = libgit2Runtime.options
        .git_libgit2_opts_enable_strict_hash_verification(1);
    checkErrorAndThrow(error);
  }

  /// Disable strict hash verification.
  ///
  /// When disabled, skips hash verification when reading objects.
  ///
  /// Enabled by default.
  static void disableStrictHashVerification() {
    final error = libgit2Runtime.options
        .git_libgit2_opts_enable_strict_hash_verification(0);
    checkErrorAndThrow(error);
  }

  /// Enable unsaved index safety checks.
  ///
  /// When enabled, checks for unsaved changes in the index before
  /// operations that reload it (e.g., checkout).
  ///
  /// Enabled by default.
  static void enableUnsavedIndexSafety() {
    final error = libgit2Runtime.options
        .git_libgit2_opts_enable_unsaved_index_safety(1);
    checkErrorAndThrow(error);
  }

  /// Disable unsaved index safety checks.
  ///
  /// When disabled, allows operations that may overwrite unsaved index changes.
  ///
  /// Enabled by default.
  static void disableUnsavedIndexSafety() {
    final error = libgit2Runtime.options
        .git_libgit2_opts_enable_unsaved_index_safety(0);
    checkErrorAndThrow(error);
  }

  /// Get or set the maximum number of objects in a pack file.
  ///
  /// This limits memory usage when fetching from untrusted remotes.
  static int get packMaxObjects {
    final out = calloc<Int>();
    final error = libgit2Runtime.options.git_libgit2_opts_get_pack_max_objects(
      out,
    );
    checkErrorAndThrow(error);
    final result = out.value;
    calloc.free(out);

    return result;
  }

  static set packMaxObjects(int value) {
    final error = libgit2Runtime.options.git_libgit2_opts_set_pack_max_objects(
      value,
    );
    checkErrorAndThrow(error);
  }

  /// Get or set the maximum declared object size allowed in a pack file.
  ///
  /// This limits memory usage when downloading pack files from untrusted
  /// remotes. The libgit2 default is 2 GiB.
  ///
  /// Setting a negative value throws a [RangeError].
  static int get packMaxObjectSize {
    return using((arena) {
      final out = arena<Size>();
      final error = libgit2Runtime.options
          .git_libgit2_opts_get_pack_max_object_size(out);
      checkErrorAndThrow(error);
      return out.value;
    });
  }

  static set packMaxObjectSize(int value) {
    if (value < 0) {
      throw RangeError.range(value, 0, null, 'value');
    }
    final error = libgit2Runtime.options
        .git_libgit2_opts_set_pack_max_object_size(value);
    checkErrorAndThrow(error);
  }

  /// Enable .keep file checks for packfiles.
  ///
  /// When enabled, checks for .keep files when accessing packfiles.
  static void enablePackKeepFileChecks() {
    final error = libgit2Runtime.options
        .git_libgit2_opts_disable_pack_keep_file_checks(0);
    checkErrorAndThrow(error);
  }

  /// Disable .keep file checks for packfiles.
  ///
  /// This can improve performance with remote filesystems.
  static void disablePackKeepFileChecks() {
    final error = libgit2Runtime.options
        .git_libgit2_opts_disable_pack_keep_file_checks(1);
    checkErrorAndThrow(error);
  }

  /// Enable HTTP expect/continue for NTLM/Negotiate auth.
  ///
  /// When enabled, uses expect/continue when POSTing data with NTLM
  /// or Negotiate authentication.
  ///
  /// Not available on Windows.
  static void enableHttpExpectContinue() {
    final error = libgit2Runtime.options
        .git_libgit2_opts_enable_http_expect_continue(1);
    checkErrorAndThrow(error);
  }

  /// Disable HTTP expect/continue for NTLM/Negotiate auth.
  ///
  /// Not available on Windows.
  static void disableHttpExpectContinue() {
    final error = libgit2Runtime.options
        .git_libgit2_opts_enable_http_expect_continue(0);
    checkErrorAndThrow(error);
  }

  /// Get or set the list of supported git extensions.
  ///
  /// This includes both built-in and custom extensions.
  ///
  /// Extensions can be negated with "!" prefix. For example:
  /// `["!noop", "newext"]` disables "noop" but enables "newext".
  ///
  /// Negated extensions are not returned.
  static List<String> get extensions {
    final array = calloc<git_strarray>();
    final error = libgit2Runtime.options.git_libgit2_opts_get_extensions(array);
    checkErrorAndThrow(error);

    final result = <String>[
      for (var i = 0; i < array.ref.count; i++)
        array.ref.strings[i].cast<Char>().toDartString(),
    ];

    calloc.free(array);

    return result;
  }

  static set extensions(List<String> extensions) {
    using((arena) {
      final array = arena<Pointer<Char>>(extensions.length);
      for (var i = 0; i < extensions.length; i++) {
        array[i] = extensions[i].toChar(arena);
      }
      final error = libgit2Runtime.options.git_libgit2_opts_set_extensions(
        array,
        extensions.length,
      );
      checkErrorAndThrow(error);
    });
  }

  /// Get or set owner validation for repository directories.
  ///
  /// When enabled, validates repository directory ownership.
  ///
  /// Enabled by default.
  static bool get ownerValidation {
    final out = calloc<Int>();
    final error = libgit2Runtime.options.git_libgit2_opts_get_owner_validation(
      out,
    );
    checkErrorAndThrow(error);
    final result = out.value;
    calloc.free(out);

    return result == 1 || false;
  }

  static set ownerValidation(bool value) {
    final valueC = value ? 1 : 0;
    final error = libgit2Runtime.options.git_libgit2_opts_set_owner_validation(
      valueC,
    );
    checkErrorAndThrow(error);
  }
}

/// Information about current cache usage.
///
/// Contains the current number of bytes in cache and the maximum allowed.
class CachedMemory {
  const CachedMemory._({required this.current, required this.allowed});

  /// Current number of bytes in cache.
  final int current;

  /// Maximum number of bytes allowed in cache.
  final int allowed;

  @override
  String toString() {
    return 'CachedMemory{current: $current, allowed: $allowed}';
  }
}
