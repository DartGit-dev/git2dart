import 'dart:ffi';

import 'package:ffi/ffi.dart' show calloc, using;
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Main class for interacting with libgit2 library.
///
/// This class provides access to global libgit2 options and settings.
/// All methods are static as they operate on global libgit2 state.
class Libgit2 {
  Libgit2._(); // coverage:ignore-line

  /// Get the current libgit2 version number.
  ///
  /// Returns a string in the format "major.minor.revision".
  static String get version {
    libgit2.git_libgit2_init();
    return using((arena) {
      final major = arena<Int>();
      final minor = arena<Int>();
      final rev = arena<Int>();
      libgit2.git_libgit2_version(major, minor, rev);
      return '${major.value}.${minor.value}.${rev.value}';
    });
  }

  /// Get the features that libgit2 was compiled with.
  ///
  /// Returns a set of [GitFeature] values indicating which features
  /// are available in this build of libgit2.
  static Set<GitFeature> get features {
    libgit2.git_libgit2_init();
    final featuresInt = libgit2.git_libgit2_features();
    return GitFeature.values
        .where((e) => featuresInt & e.value == e.value)
        .toSet();
  }

  /// Get or set the maximum mmap window size.
  ///
  /// This controls the maximum size of memory-mapped files that libgit2
  /// will use. Larger values may improve performance but use more memory.
  static int get mmapWindowSize {
    libgit2.git_libgit2_init();
    return using((arena) {
      final out = arena<Int>();
      libgit2Opts.git_libgit2_opts_get_mwindow_size(out);
      return out.value;
    });
  }

  static set mmapWindowSize(int value) {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_set_mwindow_size(value);
  }

  /// Get or set the maximum total memory that will be mapped by the library.
  ///
  /// The default (0) is unlimited. This is a soft limit that may be
  /// temporarily exceeded.
  static int get mmapWindowMappedLimit {
    libgit2.git_libgit2_init();
    return using((arena) {
      final out = arena<Int>();
      libgit2Opts.git_libgit2_opts_get_mwindow_mapped_limit(out);
      return out.value;
    });
  }

  static set mmapWindowMappedLimit(int value) {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_set_mwindow_mapped_limit(value);
  }

  /// Get or set the maximum number of files that will be mapped at any time.
  ///
  /// The default (0) is unlimited. This helps control memory usage when
  /// working with many repositories.
  static int get mmapWindowFileLimit {
    libgit2.git_libgit2_init();
    return using((arena) {
      final out = arena<Int>();
      libgit2Opts.git_libgit2_opts_get_mwindow_file_limit(out);
      return out.value;
    });
  }

  static set mmapWindowFileLimit(int value) {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_set_mwindow_file_limit(value);
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
    libgit2.git_libgit2_init();
    return using((arena) {
      final out = arena<git_buf>();
      libgit2Opts.git_libgit2_opts_get_search_path(level.value, out);
      final result = out.ref.ptr.toDartString(length: out.ref.size);
      libgit2.git_buf_dispose(out);
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
    libgit2.git_libgit2_init();
    using((arena) {
      final pathC = path != null ? path.toChar(arena) : nullptr;
      libgit2Opts.git_libgit2_opts_set_search_path(level.value, pathC);
    });
  }

  /// Set the maximum data size for caching a given object type.
  ///
  /// Setting [value] to zero means objects of that type won't be cached.
  /// Defaults to 0 for blobs and 4k for commits, trees and tags.
  static void setCacheObjectLimit({
    required GitObjectType type,
    required int value,
  }) {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_set_cache_object_limit(type.value, value);
  }

  /// Set the maximum total cache size across all repositories.
  ///
  /// This is a soft limit - the library may briefly exceed it before
  /// aggressively evicting objects. Default is 256MB.
  static void setCacheMaxSize(int bytes) {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_set_cache_max_size(bytes);
  }

  /// Get information about the current cache usage.
  ///
  /// Returns a [CachedMemory] object containing the current bytes in cache
  /// and the maximum allowed.
  static CachedMemory get cachedMemory {
    libgit2.git_libgit2_init();

    final current = calloc<Int>();
    final allowed = calloc<Int>();
    libgit2Opts.git_libgit2_opts_get_cached_memory(current, allowed);

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
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_caching(1);
  }

  /// Disable object caching completely.
  ///
  /// Caches are repository-specific, so disabling won't immediately clear
  /// all cached objects. Each cache will be cleared on next update.
  static void disableCaching() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_caching(0);
  }

  /// Get or set the default template path.
  ///
  /// This is the path used for repository templates when creating new repos.
  static String get templatePath {
    libgit2.git_libgit2_init();

    final out = calloc<git_buf>();
    libgit2Opts.git_libgit2_opts_get_template_path(out);
    final result = out.ref.ptr.toDartString(length: out.ref.size);

    libgit2.git_buf_dispose(out);
    calloc.free(out);

    return result;
  }

  static set templatePath(String path) {
    libgit2.git_libgit2_init();
    using((arena) {
      final pathC = path.toChar(arena);
      libgit2Opts.git_libgit2_opts_set_template_path(pathC);
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
      libgit2.git_libgit2_init();
      using((arena) {
        final fileC = file != null ? file.toChar(arena) : nullptr;
        final pathC = path != null ? path.toChar(arena) : nullptr;
        libgit2Opts.git_libgit2_opts_set_ssl_cert_locations(fileC, pathC);
      });
    }
  }

  /// Get or set the User-Agent header value.
  ///
  /// This value is appended to "git/1.0" for compatibility with other
  /// git clients.
  static String get userAgent {
    libgit2.git_libgit2_init();
    return using((arena) {
      final out = arena<git_buf>();
      libgit2Opts.git_libgit2_opts_get_user_agent(out);
      final result = out.ref.ptr.toDartString(length: out.ref.size);
      libgit2.git_buf_dispose(out);
      return result;
    });
  }

  static set userAgent(String userAgent) {
    libgit2.git_libgit2_init();
    using((arena) {
      final userAgentC = userAgent.toChar(arena);
      libgit2Opts.git_libgit2_opts_set_user_agent(userAgentC);
    });
  }

  /// Enable strict input validation for object creation.
  ///
  /// When enabled, validates all inputs when creating new objects.
  /// For example, validates parent(s) and tree inputs when creating commits.
  ///
  /// Enabled by default.
  static void enableStrictObjectCreation() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_strict_object_creation(1);
  }

  /// Disable strict input validation for object creation.
  ///
  /// When disabled, skips validation of inputs when creating new objects.
  ///
  /// Enabled by default.
  static void disableStrictObjectCreation() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_strict_object_creation(0);
  }

  /// Enable validation of symbolic ref targets.
  ///
  /// When enabled, validates that symbolic ref targets are valid refs.
  /// For example, "foobar" is not valid but "refs/heads/foobar" is.
  ///
  /// Enabled by default.
  static void enableStrictSymbolicRefCreation() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_strict_symbolic_ref_creation(1);
  }

  /// Disable validation of symbolic ref targets.
  ///
  /// When disabled, allows arbitrary strings as symbolic ref targets.
  ///
  /// Enabled by default.
  static void disableStrictSymbolicRefCreation() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_strict_symbolic_ref_creation(0);
  }

  /// Enable use of offset deltas in packfiles.
  ///
  /// Offset deltas store base locations as offsets within the packfile,
  /// providing shorter encoding and smaller packfiles.
  ///
  /// Enabled by default.
  static void enableOffsetDelta() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_offset_delta(1);
  }

  /// Disable use of offset deltas in packfiles.
  ///
  /// Packfiles containing offset deltas can still be read.
  ///
  /// Enabled by default.
  static void disableOffsetDelta() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_offset_delta(0);
  }

  /// Enable synchronized writes to gitdir.
  ///
  /// Uses fsync (or platform equivalent) to ensure object data is written
  /// to permanent storage, not just cached.
  ///
  /// Disabled by default.
  static void enableFsyncGitdir() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_fsync_gitdir(1);
  }

  /// Disable synchronized writes to gitdir.
  ///
  /// Disabled by default.
  static void disableFsyncGitdir() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_fsync_gitdir(0);
  }

  /// Enable strict hash verification.
  ///
  /// When enabled, verifies object hashsums when reading from disk.
  /// This may impact performance due to additional checksum calculations.
  ///
  /// Enabled by default.
  static void enableStrictHashVerification() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_strict_hash_verification(1);
  }

  /// Disable strict hash verification.
  ///
  /// When disabled, skips hash verification when reading objects.
  ///
  /// Enabled by default.
  static void disableStrictHashVerification() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_strict_hash_verification(0);
  }

  /// Enable unsaved index safety checks.
  ///
  /// When enabled, checks for unsaved changes in the index before
  /// operations that reload it (e.g., checkout).
  ///
  /// Enabled by default.
  static void enableUnsavedIndexSafety() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_unsaved_index_safety(1);
  }

  /// Disable unsaved index safety checks.
  ///
  /// When disabled, allows operations that may overwrite unsaved index changes.
  ///
  /// Enabled by default.
  static void disableUnsavedIndexSafety() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_unsaved_index_safety(0);
  }

  /// Get or set the maximum number of objects in a pack file.
  ///
  /// This limits memory usage when fetching from untrusted remotes.
  static int get packMaxObjects {
    libgit2.git_libgit2_init();

    final out = calloc<Int>();
    libgit2Opts.git_libgit2_opts_get_pack_max_objects(out);
    final result = out.value;
    calloc.free(out);

    return result;
  }

  static set packMaxObjects(int value) {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_set_pack_max_objects(value);
  }

  /// Enable .keep file checks for packfiles.
  ///
  /// When enabled, checks for .keep files when accessing packfiles.
  static void enablePackKeepFileChecks() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_disable_pack_keep_file_checks(0);
  }

  /// Disable .keep file checks for packfiles.
  ///
  /// This can improve performance with remote filesystems.
  static void disablePackKeepFileChecks() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_disable_pack_keep_file_checks(1);
  }

  /// Enable HTTP expect/continue for NTLM/Negotiate auth.
  ///
  /// When enabled, uses expect/continue when POSTing data with NTLM
  /// or Negotiate authentication.
  ///
  /// Not available on Windows.
  static void enableHttpExpectContinue() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_http_expect_continue(1);
  }

  /// Disable HTTP expect/continue for NTLM/Negotiate auth.
  ///
  /// Not available on Windows.
  static void disableHttpExpectContinue() {
    libgit2.git_libgit2_init();
    libgit2Opts.git_libgit2_opts_enable_http_expect_continue(0);
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
    libgit2.git_libgit2_init();

    final array = calloc<git_strarray>();
    libgit2Opts.git_libgit2_opts_get_extensions(array);

    final result = <String>[
      for (var i = 0; i < array.ref.count; i++)
        array.ref.strings[i].cast<Char>().toDartString(),
    ];

    calloc.free(array);

    return result;
  }

  static set extensions(List<String> extensions) {
    libgit2.git_libgit2_init();
    using((arena) {
      final array = arena<Pointer<Char>>(extensions.length);
      for (var i = 0; i < extensions.length; i++) {
        array[i] = extensions[i].toChar(arena);
      }
      libgit2Opts.git_libgit2_opts_set_extensions(array, extensions.length);
    });
  }

  /// Get or set owner validation for repository directories.
  ///
  /// When enabled, validates repository directory ownership.
  ///
  /// Enabled by default.
  static bool get ownerValidation {
    libgit2.git_libgit2_init();

    final out = calloc<Int>();
    libgit2Opts.git_libgit2_opts_get_owner_validation(out);
    final result = out.value;
    calloc.free(out);

    return result == 1 || false;
  }

  static set ownerValidation(bool value) {
    libgit2.git_libgit2_init();

    final valueC = value ? 1 : 0;
    libgit2Opts.git_libgit2_opts_set_owner_validation(valueC);
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
