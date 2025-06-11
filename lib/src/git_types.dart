/// Basic type of any Git reference.
enum ReferenceType {
  /// Invalid reference.
  invalid(0),

  /// A reference that points at an object id.
  direct(1),

  /// A reference that points at another reference.
  symbolic(2),

  /// All reference types.
  all(3);

  const ReferenceType(this.value);
  final int value;

  static ReferenceType fromValue(int value) => switch (value) {
    0 => invalid,
    1 => direct,
    2 => symbolic,
    3 => all,
    _ => throw ArgumentError('Unknown value for ReferenceType: $value'),
  };
}

/// Valid modes for index and tree entries.
enum GitFilemode {
  /// File is unreadable.
  unreadable(0),

  /// Directory (tree) entry.
  tree(16384),

  /// Regular file (blob) entry.
  blob(33188),

  /// Executable file (blob) entry.
  blobExecutable(33261),

  /// Symbolic link entry.
  link(40960),

  /// Submodule (commit) entry.
  commit(57344);

  const GitFilemode(this.value);
  final int value;

  static GitFilemode fromValue(int value) => switch (value) {
    0 => unreadable,
    16384 => tree,
    33188 => blob,
    33261 => blobExecutable,
    40960 => link,
    57344 => commit,
    _ => throw ArgumentError('Unknown value for GitFilemode: $value'),
  };
}

/// Flags to specify the sorting which a revwalk should perform.
enum GitSort {
  /// Sort the output with the same default method from `git`: reverse
  /// chronological order. This is the default sorting for new walkers.
  none(0),

  /// Sort the repository contents in topological order (no parents before
  /// all of its children are shown); this sorting mode can be combined
  /// with time sorting to produce `git`'s `--date-order`.
  topological(1),

  /// Sort the repository contents by commit time;
  /// this sorting mode can be combined with topological sorting.
  time(2),

  /// Iterate through the repository contents in reverse order; this sorting
  /// mode can be combined with any of the above.
  reverse(4);

  const GitSort(this.value);
  final int value;

  static GitSort fromValue(int value) => switch (value) {
    0 => none,
    1 => topological,
    2 => time,
    4 => reverse,
    _ => throw ArgumentError('Unknown value for GitSort: $value'),
  };
}

/// Basic type (loose or packed) of any Git object.
enum GitObjectType {
  /// Object can be any of the following.
  any(-2),

  /// Object is invalid.
  invalid(-1),

  /// A commit object.
  commit(1),

  /// A tree (directory listing) object.
  tree(2),

  /// A file revision object.
  blob(3),

  /// An annotated tag object.
  tag(4),

  /// A delta, base is given by an offset.
  offsetDelta(6),

  /// A delta, base is given by object id.
  refDelta(7);

  const GitObjectType(this.value);
  final int value;

  static GitObjectType fromValue(int value) => switch (value) {
    -2 => any,
    -1 => invalid,
    1 => commit,
    2 => tree,
    3 => blob,
    4 => tag,
    6 => offsetDelta,
    7 => refDelta,
    _ => throw ArgumentError('Unknown value for GitObjectType: $value'),
  };
}

/// Revparse flags, indicate the intended behavior of the spec.
enum GitRevSpec {
  /// The spec targeted a single object.
  single(1),

  /// The spec targeted a range of commits.
  range(2),

  /// The spec used the '...' operator, which invokes special semantics.
  mergeBase(4);

  const GitRevSpec(this.value);
  final int value;

  static GitRevSpec fromValue(int value) => switch (value) {
    1 => single,
    2 => range,
    4 => mergeBase,
    _ => throw ArgumentError('Unknown value for GitRevSpec: $value'),
  };
}

/// Basic type of any Git branch.
enum GitBranch {
  /// Local branch.
  local(1),

  /// Remote branch.
  remote(2),

  /// All branch types.
  all(3);

  const GitBranch(this.value);
  final int value;

  static GitBranch fromValue(int value) => switch (value) {
    1 => local,
    2 => remote,
    3 => all,
    _ => throw ArgumentError('Unknown value for GitBranch: $value'),
  };
}

/// Status flags for a single file.
///
/// A combination of these values will be returned to indicate the status of
/// a file. Status compares the working directory, the index, and the
/// current HEAD of the repository. The `GitStatus.index` set of flags
/// represents the status of file in the index relative to the HEAD, and the
/// `GitStatus.wt` set of flags represent the status of the file in the
/// working directory relative to the index.
enum GitStatus {
  /// No changes.
  current(0),

  /// New file in index.
  indexNew(1),

  /// Modified file in index.
  indexModified(2),

  /// Deleted file in index.
  indexDeleted(4),

  /// Renamed file in index.
  indexRenamed(8),

  /// Type changed file in index.
  indexTypeChange(16),

  /// New file in working directory.
  wtNew(128),

  /// Modified file in working directory.
  wtModified(256),

  /// Deleted file in working directory.
  wtDeleted(512),

  /// Type changed file in working directory.
  wtTypeChange(1024),

  /// Renamed file in working directory.
  wtRenamed(2048),

  /// Unreadable file in working directory.
  wtUnreadable(4096),

  /// Ignored file.
  ignored(16384),

  /// Conflicted file.
  conflicted(32768);

  const GitStatus(this.value);
  final int value;

  static GitStatus fromValue(int value) => switch (value) {
    0 => current,
    1 => indexNew,
    2 => indexModified,
    4 => indexDeleted,
    8 => indexRenamed,
    16 => indexTypeChange,
    128 => wtNew,
    256 => wtModified,
    512 => wtDeleted,
    1024 => wtTypeChange,
    2048 => wtRenamed,
    4096 => wtUnreadable,
    16384 => ignored,
    32768 => conflicted,
    _ => throw ArgumentError('Unknown value for GitStatus: $value'),
  };
}

/// The results of `mergeAnalysis` indicate the merge opportunities.
enum GitMergeAnalysis {
  /// A "normal" merge; both HEAD and the given merge input have diverged
  /// from their common ancestor. The divergent commits must be merged.
  normal(1),

  /// All given merge inputs are reachable from HEAD, meaning the
  /// repository is up-to-date and no merge needs to be performed.
  upToDate(2),

  /// The given merge input is a fast-forward from HEAD and no merge
  /// needs to be performed. Instead, the client can check out the
  /// given merge input.
  fastForward(4),

  /// The HEAD of the current repository is "unborn" and does not point to
  /// a valid commit. No merge can be performed, but the caller may wish
  /// to simply set HEAD to the target commit(s).
  unborn(8);

  const GitMergeAnalysis(this.value);
  final int value;

  static GitMergeAnalysis fromValue(int value) => switch (value) {
    1 => normal,
    2 => upToDate,
    4 => fastForward,
    8 => unborn,
    _ => throw ArgumentError('Unknown value for GitMergeAnalysis: $value'),
  };
}

/// The user's stated preference for merges.
enum GitMergePreference {
  /// No configuration was found that suggests a preferred behavior for merge.
  none(0),

  /// There is a `merge.ff=false` configuration setting, suggesting that
  /// the user does not want to allow a fast-forward merge.
  noFastForward(1),

  /// There is a `merge.ff=only` configuration setting, suggesting that
  /// the user only wants fast-forward merges.
  fastForwardOnly(2);

  const GitMergePreference(this.value);
  final int value;

  static GitMergePreference fromValue(int value) => switch (value) {
    0 => none,
    1 => noFastForward,
    2 => fastForwardOnly,
    _ => throw ArgumentError('Unknown value for GitMergePreference: $value'),
  };
}

/// Repository state.
///
/// These values represent possible states for the repository to be in,
/// based on the current operation which is ongoing.
enum GitRepositoryState {
  /// Normal state, no operation in progress.
  none(0),

  /// Merge in progress.
  merge(1),

  /// Revert in progress.
  revert(2),

  /// Revert sequence in progress.
  revertSequence(3),

  /// Cherry-pick in progress.
  cherrypick(4),

  /// Cherry-pick sequence in progress.
  cherrypickSequence(5),

  /// Bisect in progress.
  bisect(6),

  /// Rebase in progress.
  rebase(7),

  /// Interactive rebase in progress.
  rebaseInteractive(8),

  /// Rebase merge in progress.
  rebaseMerge(9),

  /// Apply mailbox in progress.
  applyMailbox(10),

  /// Apply mailbox or rebase in progress.
  applyMailboxOrRebase(11);

  const GitRepositoryState(this.value);
  final int value;

  static GitRepositoryState fromValue(int value) => switch (value) {
    0 => none,
    1 => merge,
    2 => revert,
    3 => revertSequence,
    4 => cherrypick,
    5 => cherrypickSequence,
    6 => bisect,
    7 => rebase,
    8 => rebaseInteractive,
    9 => rebaseMerge,
    10 => applyMailbox,
    11 => applyMailboxOrRebase,
    _ => throw ArgumentError('Unknown value for GitRepositoryState: $value'),
  };
}

/// Flags for merge options.
enum GitMergeFlag {
  /// Detect renames that occur between the common ancestor and the "ours"
  /// side or the common ancestor and the "theirs" side. This will enable
  /// the ability to merge between a modified and renamed file.
  findRenames(1),

  /// If a conflict occurs, exit immediately instead of attempting to
  /// continue resolving conflicts. The merge operation will fail with
  /// and no index will be returned.
  failOnConflict(2),

  /// Do not write the REUC extension on the generated index.
  skipREUC(4),

  /// If the commits being merged have multiple merge bases, do not build
  /// a recursive merge base (by merging the multiple merge bases),
  /// instead simply use the first base.
  noRecursive(8);

  const GitMergeFlag(this.value);
  final int value;

  static GitMergeFlag fromValue(int value) => switch (value) {
    1 => findRenames,
    2 => failOnConflict,
    4 => skipREUC,
    8 => noRecursive,
    _ => throw ArgumentError('Unknown value for GitMergeFlag: $value'),
  };
}

/// Merge file favor options to instruct the file-level merging functionality
/// on how to deal with conflicting regions of the files.
enum GitMergeFileFavor {
  /// When a region of a file is changed in both branches, a conflict
  /// will be recorded in the index. This is the default.
  normal(0),

  /// When a region of a file is changed in both branches, the file
  /// created in the index will contain the "ours" side of any conflicting
  /// region. The index will not record a conflict.
  ours(1),

  /// When a region of a file is changed in both branches, the file
  /// created in the index will contain the "theirs" side of any conflicting
  /// region. The index will not record a conflict.
  theirs(2),

  /// When a region of a file is changed in both branches, the file
  /// created in the index will contain each unique line from each side,
  /// which has the result of combining both files. The index will not
  /// record a conflict.
  union(3);

  const GitMergeFileFavor(this.value);
  final int value;

  static GitMergeFileFavor fromValue(int value) => switch (value) {
    0 => normal,
    1 => ours,
    2 => theirs,
    3 => union,
    _ => throw ArgumentError('Unknown value for GitMergeFileFavor: $value'),
  };
}

/// File merging flags.
enum GitMergeFileFlag {
  /// Defaults.
  defaults(0),

  /// Create standard conflicted merge files.
  styleMerge(1),

  /// Create diff3-style files.
  styleDiff3(2),

  /// Condense non-alphanumeric regions for simplified diff file.
  simplifyAlnum(4),

  /// Ignore all whitespace.
  ignoreWhitespace(8),

  /// Ignore changes in amount of whitespace.
  ignoreWhitespaceChange(16),

  /// Ignore whitespace at end of line.
  ignoreWhitespaceEOL(32),

  /// Use the "patience diff" algorithm.
  diffPatience(64),

  /// Take extra time to find minimal diff.
  diffMinimal(128),

  /// Create zdiff3 ("zealous diff3")-style files.
  styleZdiff3(256),

  /// Do not produce file conflicts when common regions have
  /// changed; keep the conflict markers in the file and accept
  /// that as the merge result.
  acceptConflicts(512);

  const GitMergeFileFlag(this.value);
  final int value;

  static GitMergeFileFlag fromValue(int value) => switch (value) {
    0 => defaults,
    1 => styleMerge,
    2 => styleDiff3,
    4 => simplifyAlnum,
    8 => ignoreWhitespace,
    16 => ignoreWhitespaceChange,
    32 => ignoreWhitespaceEOL,
    64 => diffPatience,
    128 => diffMinimal,
    256 => styleZdiff3,
    512 => acceptConflicts,
    _ => throw ArgumentError('Unknown value for GitMergeFileFlag: $value'),
  };
}

/// Checkout behavior flags.
///
/// In libgit2, checkout is used to update the working directory and index
/// to match a target tree. Unlike git checkout, it does not move the HEAD
/// commit for you - use `setHead` or the like to do that.
enum GitCheckout {
  /// Default is a dry run, no actual updates.
  none(0),

  /// Allow safe updates that cannot overwrite uncommitted data.
  /// If the uncommitted changes don't conflict with the checked out files,
  /// the checkout will still proceed, leaving the changes intact.
  ///
  /// Mutually exclusive with [GitCheckout.force].
  /// [GitCheckout.force] takes precedence over [GitCheckout.safe].
  safe(1),

  /// Allow all updates to force working directory to look like index.
  ///
  /// Mutually exclusive with [GitCheckout.safe].
  /// [GitCheckout.force] takes precedence over [GitCheckout.safe].
  force(2),

  /// Allow checkout to recreate missing files.
  recreateMissing(4),

  /// Allow checkout to make safe updates even if conflicts are found.
  allowConflicts(16),

  /// Remove untracked files not in index (that are not ignored).
  removeUntracked(32),

  /// Remove ignored files not in index.
  removeIgnored(64),

  /// Only update existing files, don't create new ones.
  updateOnly(128),

  /// Normally checkout updates index entries as it goes; this stops that.
  /// Implies [GitCheckout.dontWriteIndex].
  dontUpdateIndex(256),

  /// Don't refresh index/config/etc before doing checkout.
  noRefresh(512),

  /// Allow checkout to skip unmerged files.
  skipUnmerged(1024),

  /// For unmerged files, checkout stage 2 from index.
  useOurs(2048),

  /// For unmerged files, checkout stage 3 from index.
  useTheirs(4096),

  /// Treat pathspec as simple list of exact match file paths.
  disablePathspecMatch(8192),

  /// Ignore directories in use, they will be left empty.
  skipLockedDirectories(262144),

  /// Don't overwrite ignored files that exist in the checkout target.
  dontOverwriteIgnored(524288),

  /// Write normal merge files for conflicts.
  conflictStyleMerge(1048576),

  /// Include common ancestor data in diff3 format files for conflicts.
  conflictStyleDiff3(2097152),

  /// Don't overwrite existing files or folders.
  dontRemoveExisting(4194304),

  /// Normally checkout writes the index upon completion; this prevents that.
  dontWriteIndex(8388608),

  /// Show what would be done by a checkout. Stop after sending
  /// notifications; don't update the working directory or index.
  dryRun(16777216),

  /// Include common ancestor data in zdiff3 format for conflicts.
  conflictStyleZdiff3(33554432);

  const GitCheckout(this.value);
  final int value;

  static GitCheckout fromValue(int value) => switch (value) {
    0 => none,
    1 => safe,
    2 => force,
    4 => recreateMissing,
    16 => allowConflicts,
    32 => removeUntracked,
    64 => removeIgnored,
    128 => updateOnly,
    256 => dontUpdateIndex,
    512 => noRefresh,
    1024 => skipUnmerged,
    2048 => useOurs,
    4096 => useTheirs,
    8192 => disablePathspecMatch,
    262144 => skipLockedDirectories,
    524288 => dontOverwriteIgnored,
    1048576 => conflictStyleMerge,
    2097152 => conflictStyleDiff3,
    4194304 => dontRemoveExisting,
    8388608 => dontWriteIndex,
    16777216 => dryRun,
    33554432 => conflictStyleZdiff3,
    _ => throw ArgumentError('Unknown value for GitCheckout: $value'),
  };
}

/// Kinds of reset operation.
enum GitReset {
  /// Move the head to the given commit.
  soft(1),

  /// [GitReset.soft] plus reset index to the commit.
  mixed(2),

  /// [GitReset.mixed] plus changes in working tree discarded.
  hard(3);

  const GitReset(this.value);
  final int value;

  static GitReset fromValue(int value) => switch (value) {
    1 => soft,
    2 => mixed,
    3 => hard,
    _ => throw ArgumentError('Unknown value for GitReset: $value'),
  };
}

/// Flags for diff options. A combination of these flags can be passed.
enum GitDiff {
  /// Normal diff, the default.
  normal(0),

  /// Reverse the sides of the diff.
  reverse(1),

  /// Include ignored files in the diff.
  includeIgnored(2),

  /// Even with [GitDiff.includeUntracked], an entire ignored directory
  /// will be marked with only a single entry in the diff; this flag
  /// adds all files under the directory as IGNORED entries, too.
  recurseIgnoredDirs(4),

  /// Include untracked files in the diff.
  includeUntracked(8),

  /// Even with [GitDiff.includeUntracked], an entire untracked
  /// directory will be marked with only a single entry in the diff
  /// (a la what core Git does in `git status`); this flag adds *all*
  /// files under untracked directories as UNTRACKED entries, too.
  recurseUntrackedDirs(16),

  /// Include unmodified files in the diff.
  includeUnmodified(32),

  /// Normally, a type change between files will be converted into a
  /// DELETED record for the old and an ADDED record for the new; this
  /// options enabled the generation of TYPECHANGE delta records.
  includeTypechange(64),

  /// Even with [GitDiff.includeTypechange], blob->tree changes still
  /// generally show as a DELETED blob. This flag tries to correctly
  /// label blob->tree transitions as TYPECHANGE records with new_file's
  /// mode set to tree. Note: the tree SHA will not be available.
  includeTypechangeTrees(128),

  /// Ignore file mode changes.
  ignoreFilemode(256),

  /// Treat all submodules as unmodified.
  ignoreSubmodules(512),

  /// Use case insensitive filename comparisons.
  ignoreCase(1024),

  /// May be combined with [GitDiff.ignoreCase] to specify that a file
  /// that has changed case will be returned as an add/delete pair.
  includeCaseChange(2048),

  /// If the pathspec is set in the diff options, this flags indicates
  /// that the paths will be treated as literal paths instead of
  /// fnmatch patterns. Each path in the list must either be a full
  /// path to a file or a directory. (A trailing slash indicates that
  /// the path will _only_ match a directory). If a directory is
  /// specified, all children will be included.
  disablePathspecMatch(4096),

  /// Disable updating of the `binary` flag in delta records. This is
  /// useful when iterating over a diff if you don't need hunk and data
  /// callbacks and want to avoid having to load file completely.
  skipBinaryCheck(8192),

  /// When diff finds an untracked directory, to match the behavior of
  /// core Git, it scans the contents for IGNORED and UNTRACKED files.
  /// If *all* contents are IGNORED, then the directory is IGNORED; if
  /// any contents are not IGNORED, then the directory is UNTRACKED.
  /// This is extra work that may not matter in many cases. This flag
  /// turns off that scan and immediately labels an untracked directory
  /// as UNTRACKED (changing the behavior to not match core Git).
  enableFastUntrackedDirs(16384),

  /// When diff finds a file in the working directory with stat
  /// information different from the index, but the OID ends up being the
  /// same, write the correct stat information into the index. Note:
  /// without this flag, diff will always leave the index untouched.
  updateIndex(32768),

  /// Include unreadable files in the diff.
  includeUnreadable(65536),

  /// Include unreadable files in the diff.
  includeUnreadableAsUntracked(131072),

  /// Use a heuristic that takes indentation and whitespace into account
  /// which generally can produce better diffs when dealing with ambiguous
  /// diff hunks.
  indentHeuristic(262144),

  /// Treat all files as text, disabling binary attributes & detection.
  forceText(1048576),

  /// Treat all files as binary, disabling text diffs.
  forceBinary(2097152),

  /// Ignore all whitespace.
  ignoreWhitespace(4194304),

  /// Ignore changes in amount of whitespace.
  ignoreWhitespaceChange(8388608),

  /// Ignore whitespace at end of line.
  ignoreWhitespaceEOL(16777216),

  /// When generating patch text, include the content of untracked
  /// files. This automatically turns on [GitDiff.includeUntracked] but
  /// it does not turn on [GitDiff.recurseUntrackedDirs]. Add that
  /// flag if you want the content of every single UNTRACKED file.
  showUntrackedContent(33554432),

  /// When generating output, include the names of unmodified files if
  /// they are included in the git diff. Normally these are skipped in
  /// the formats that list files (e.g. name-only, name-status, raw).
  /// Even with this, these will not be included in patch format.
  showUnmodified(67108864),

  /// Use the "patience diff" algorithm.
  patience(268435456),

  /// Take extra time to find minimal diff.
  minimal(536870912),

  /// Include the necessary deflate / delta information so that `git-apply`
  /// can apply given diff information to binary files.
  showBinary(1073741824);

  const GitDiff(this.value);
  final int value;

  static GitDiff fromValue(int value) => switch (value) {
    0 => normal,
    1 => reverse,
    2 => includeIgnored,
    4 => recurseIgnoredDirs,
    8 => includeUntracked,
    16 => recurseUntrackedDirs,
    32 => includeUnmodified,
    64 => includeTypechange,
    128 => includeTypechangeTrees,
    256 => ignoreFilemode,
    512 => ignoreSubmodules,
    1024 => ignoreCase,
    2048 => includeCaseChange,
    4096 => disablePathspecMatch,
    8192 => skipBinaryCheck,
    16384 => enableFastUntrackedDirs,
    32768 => updateIndex,
    65536 => includeUnreadable,
    131072 => includeUnreadableAsUntracked,
    262144 => indentHeuristic,
    1048576 => forceText,
    2097152 => forceBinary,
    4194304 => ignoreWhitespace,
    8388608 => ignoreWhitespaceChange,
    16777216 => ignoreWhitespaceEOL,
    33554432 => showUntrackedContent,
    67108864 => showUnmodified,
    268435456 => patience,
    536870912 => minimal,
    1073741824 => showBinary,
    _ => throw ArgumentError('Unknown value for GitDiff: $value'),
  };
}

/// What type of change is described by a git_diff_delta?
///
/// [GitDelta.renamed] and [GitDelta.copied] will only show up if you run
/// `findSimilar()` on the diff object.
///
/// [GitDelta.typechange] only shows up given [GitDiff.includeTypechange]
/// in the option flags (otherwise type changes will be split into ADDED /
/// DELETED pairs).
enum GitDelta {
  /// No changes.
  unmodified(0),

  /// Entry does not exist in old version.
  added(1),

  /// Entry does not exist in new version.
  deleted(2),

  /// Entry content changed between old and new.
  modified(3),

  /// Entry was renamed between old and new.
  renamed(4),

  /// Entry was copied from another old entry.
  copied(5),

  /// Entry is ignored item in workdir.
  ignored(6),

  /// Entry is is untracked item in workdir.
  untracked(7),

  /// Type of entry changed between old and new.
  typechange(8),

  /// Entry is unreadable.
  unreadable(9),

  /// Entry in the index is conflicted.
  conflicted(10);

  const GitDelta(this.value);
  final int value;

  static GitDelta fromValue(int value) => switch (value) {
    0 => unmodified,
    1 => added,
    2 => deleted,
    3 => modified,
    4 => renamed,
    5 => copied,
    6 => ignored,
    7 => untracked,
    8 => typechange,
    9 => unreadable,
    10 => conflicted,
    _ => throw ArgumentError('Unknown value for GitDelta: $value'),
  };
}

/// Flags for the delta object and the file objects on each side.
enum GitDiffFlag {
  /// File(s) treated as binary data.
  binary(1),

  /// File(s) treated as text data.
  notBinary(2),

  /// `id` value is known correct.
  validId(4),

  /// File exists at this side of the delta.
  exists(8);

  const GitDiffFlag(this.value);
  final int value;

  static GitDiffFlag fromValue(int value) => switch (value) {
    1 => binary,
    2 => notBinary,
    4 => validId,
    8 => exists,
    _ => throw ArgumentError('Unknown value for GitDiffFlag: $value'),
  };
}

/// Formatting options for diff stats.
enum GitDiffStats {
  /// No stats.
  none(0),

  /// Full statistics, equivalent of `--stat`.
  full(1),

  /// Short statistics, equivalent of `--shortstat`.
  short(2),

  /// Number statistics, equivalent of `--numstat`.
  number(4),

  /// Extended header information such as creations, renames and mode changes,
  /// equivalent of `--summary`.
  includeSummary(8);

  const GitDiffStats(this.value);
  final int value;

  static GitDiffStats fromValue(int value) => switch (value) {
    0 => none,
    1 => full,
    2 => short,
    4 => number,
    8 => includeSummary,
    _ => throw ArgumentError('Unknown value for GitDiffStats: $value'),
  };
}

/// Formatting options for diff stats.
enum GitDiffFind {
  /// Obey `diff.renames`. Overridden by any other [GitDiffFind] flag.
  byConfig(0),

  /// Look for renames, equivalent of `--find-renames`
  renames(1),

  /// Consider old side of MODIFIED for renames, equivalent of
  /// `--break-rewrites=N`
  renamesFromRewrites(2),

  /// Look for copies, equivalent of `--find-copies`
  copies(4),

  /// Consider UNMODIFIED as copy sources, equivalent of `--find-copies-harder`
  ///
  /// For this to work correctly, use [GitDiff.includeUnmodified] when
  /// the initial git diff is being generated.
  copiesFromUnmodified(8),

  /// Mark significant rewrites for split, equivalent of `--break-rewrites=/M`
  rewrites(16),

  /// Actually split large rewrites into delete/add pairs.
  breakRewrites(32),

  /// Mark rewrites for split and break into delete/add pairs.
  andBreakRewrites(48),

  /// Find renames/copies for UNTRACKED items in working directory.
  ///
  /// For this to work correctly, use [GitDiff.includeUntracked] when the
  /// initial git diff is being generated (and obviously the diff must
  /// be against the working directory for this to make sense).
  forUntracked(64),

  /// Turn on all finding features.
  all(255),

  /// Measure similarity ignoring all whitespace.
  ignoreWhitespace(4096),

  /// Measure similarity including all data.
  dontIgnoreWhitespace(8192),

  /// Measure similarity only by comparing SHAs (fast and cheap).
  exactMatchOnly(16384),

  /// Do not break rewrites unless they contribute to a rename.
  ///
  /// Normally, [GitDiffFind.andBreakRewrites] will measure the self-
  /// similarity of modified files and split the ones that have changed a
  /// lot into a DELETE / ADD pair. Then the sides of that pair will be
  /// considered candidates for rename and copy detection.
  ///
  /// If you add this flag in and the split pair is *not* used for an
  /// actual rename or copy, then the modified record will be restored to
  /// a regular MODIFIED record instead of being split.
  breakRewritesForRenamesOnly(32768),

  /// Remove any UNMODIFIED deltas after find_similar is done.
  ///
  /// Using [GitDiffFind.copiesFromUnmodified] to emulate the
  /// --find-copies-harder behavior requires building a diff with the
  /// [GitDiff.includeUnmodified] flag. If you do not want UNMODIFIED
  /// records in the final result, pass this flag to have them removed.
  removeUnmodified(65536);

  const GitDiffFind(this.value);
  final int value;

  static GitDiffFind fromValue(int value) => switch (value) {
    0 => byConfig,
    1 => renames,
    2 => renamesFromRewrites,
    4 => copies,
    8 => copiesFromUnmodified,
    16 => rewrites,
    32 => breakRewrites,
    48 => andBreakRewrites,
    64 => forUntracked,
    255 => all,
    4096 => ignoreWhitespace,
    8192 => dontIgnoreWhitespace,
    16384 => exactMatchOnly,
    32768 => breakRewritesForRenamesOnly,
    65536 => removeUnmodified,
    _ => throw ArgumentError('Unknown value for GitDiffFind: $value'),
  };
}

/// Line origin, describing where a line came from.
enum GitDiffLine {
  /// Line is from the common ancestor.
  context(32),

  /// Line is from the new file.
  addition(43),

  /// Line is from the old file.
  deletion(45),

  /// Both files have no LF at end.
  contextEOFNL(61),

  /// Old has no LF at end, new does.
  addEOFNL(62),

  /// Old has LF at end, new does not.
  delEOFNL(60),

  /// File header.
  fileHeader(70),

  /// Hunk header.
  hunkHeader(72),

  /// For "Binary files x and y differ"
  binary(66);

  const GitDiffLine(this.value);
  final int value;

  static GitDiffLine fromValue(int value) => switch (value) {
    32 => context,
    43 => addition,
    45 => deletion,
    61 => contextEOFNL,
    62 => addEOFNL,
    60 => delEOFNL,
    70 => fileHeader,
    72 => hunkHeader,
    66 => binary,
    _ => throw ArgumentError('Unknown value for GitDiffLine: $value'),
  };
}

/// Possible application locations for `apply()`
class GitApplyLocation {
  const GitApplyLocation._(this._value, this._name);
  final int _value;
  final String _name;

  /// Apply the patch to the workdir, leaving the index untouched.
  /// This is the equivalent of `git apply` with no location argument.
  static const workdir = GitApplyLocation._(0, 'workdir');

  /// Apply the patch to the index, leaving the working directory
  /// untouched. This is the equivalent of `git apply --cached`.
  static const index = GitApplyLocation._(1, 'index');

  /// Apply the patch to both the working directory and the index.
  /// This is the equivalent of `git apply --index`.
  static const both = GitApplyLocation._(2, 'both');

  static const List<GitApplyLocation> values = [workdir, index, both];

  int get value => _value;

  @override
  String toString() => 'GitApplyLocation.$_name';
}

/// Priority level of a config file.
/// These priority levels correspond to the natural escalation logic
/// (from higher to lower) when searching for config entries in git.
enum GitConfigLevel {
  /// System-wide on Windows, for compatibility with portable git.
  programData(1),

  /// System-wide configuration file; /etc/gitconfig on Linux systems.
  system(2),

  /// XDG compatible configuration file; typically ~/.config/git/config
  xdg(3),

  /// User-specific configuration file (also called Global configuration
  /// file); typically ~/.gitconfig
  global(4),

  /// Repository specific configuration file; $WORK_DIR/.git/config on
  /// non-bare repos.
  local(5),

  /// Application specific configuration file; freely defined by applications.
  app(6),

  /// Represents the highest level available config file (i.e. the most
  /// specific config file available that actually is loaded).
  highest(-1);

  const GitConfigLevel(this.value);
  final int value;

  static GitConfigLevel fromValue(int value) {
    switch (value) {
      case 1:
        return GitConfigLevel.programData;
      case 2:
        return GitConfigLevel.system;
      case 3:
        return GitConfigLevel.xdg;
      case 4:
        return GitConfigLevel.global;
      case 5:
        return GitConfigLevel.local;
      case 6:
        return GitConfigLevel.app;
      case -1:
        return GitConfigLevel.highest;
      default:
        throw ArgumentError('Invalid GitConfigLevel value: $value');
    }
  }
}

/// Stash flags.
enum GitStash {
  /// No option, default.
  defaults(0),

  /// All changes already added to the index are left intact in
  /// the working directory.
  keepIndex(1),

  /// All untracked files are also stashed and then cleaned up
  /// from the working directory.
  includeUntracked(2),

  /// All ignored files are also stashed and then cleaned up from
  /// the working directory.
  includeIgnored(4);

  const GitStash(this.value);
  final int value;

  static GitStash fromValue(int value) => switch (value) {
    0 => defaults,
    1 => keepIndex,
    2 => includeUntracked,
    4 => includeIgnored,
    _ => throw ArgumentError('Unknown value for GitStash: $value'),
  };
}

/// Stash application flags.
enum GitStashApply {
  /// Default options.
  defaults(0),

  /// Try to reinstate not only the working tree's changes,
  /// but also the index's changes.
  reinstateIndex(1);

  const GitStashApply(this.value);
  final int value;

  static GitStashApply fromValue(int value) => switch (value) {
    0 => defaults,
    1 => reinstateIndex,
    _ => throw ArgumentError('Unknown value for GitStashApply: $value'),
  };
}

/// Direction of the connection.
enum GitDirection {
  /// Fetch from remote.
  fetch(0),

  /// Push to remote.
  push(1);

  const GitDirection(this.value);
  final int value;

  static GitDirection fromValue(int value) => switch (value) {
    0 => fetch,
    1 => push,
    _ => throw ArgumentError('Unknown value for GitDirection: $value'),
  };
}

/// Acceptable prune settings when fetching.
enum GitFetchPrune {
  /// Use the setting from the configuration.
  unspecified(0),

  /// Force pruning on. Removes any remote branch in the local repository
  /// that does not exist in the remote
  prune(1),

  /// Force pruning off. Keeps the remote branches.
  noPrune(2);

  const GitFetchPrune(this.value);
  final int value;

  static GitFetchPrune fromValue(int value) => switch (value) {
    0 => unspecified,
    1 => prune,
    2 => noPrune,
    _ => throw ArgumentError('Unknown value for GitFetchPrune: $value'),
  };
}

/// Option flags for [Repository] init.
enum GitRepositoryInit {
  /// Create a bare repository with no working directory.
  bare(1),

  /// Return an GIT_EEXISTS error if the repo path appears to already be
  /// an git repository.
  noReinit(2),

  /// Normally a "/.git/" will be appended to the repo path for
  /// non-bare repos (if it is not already there), but passing this flag
  /// prevents that behavior.
  noDotGitDir(4),

  /// Make the repo path (and workdir path) as needed. Init is always willing
  /// to create the ".git" directory even without this flag. This flag tells
  /// init to create the trailing component of the repo and workdir paths
  /// as needed.
  mkdir(8),

  /// Recursively make all components of the repo and workdir paths as
  /// necessary.
  mkpath(16),

  /// libgit2 normally uses internal templates to initialize a new repo.
  /// This flags enables external templates, looking the [templatePath] from
  /// the options if set, or the `init.templatedir` global config if not,
  /// or falling back on "/usr/share/git-core/templates" if it exists.
  externalTemplate(32),

  /// If an alternate workdir is specified, use relative paths for the gitdir
  /// and core.worktree.
  relativeGitlink(64);

  const GitRepositoryInit(this.value);
  final int value;

  static GitRepositoryInit fromValue(int value) => switch (value) {
    1 => bare,
    2 => noReinit,
    4 => noDotGitDir,
    8 => mkdir,
    16 => mkpath,
    32 => externalTemplate,
    64 => relativeGitlink,
    _ => throw ArgumentError('Unknown value for GitRepositoryInit: $value'),
  };
}

/// Supported credential types.
///
/// This represents the various types of authentication methods supported by
/// the library.
enum GitCredential {
  /// A vanilla user/password request.
  userPassPlainText(1),

  /// An SSH key-based authentication request.
  sshKey(2),

  /// An SSH key-based authentication request, with a custom signature.
  sshCustom(4),

  /// An NTLM/Negotiate-based authentication request.
  defaultAuth(8),

  /// An SSH interactive authentication request.
  sshInteractive(16),

  /// Username-only authentication request.
  ///
  /// Used as a pre-authentication step if the underlying transport
  /// (eg. SSH, with no username in its URL) does not know which username
  /// to use.
  username(32),

  /// An SSH key-based authentication request.
  ///
  /// Allows credentials to be read from memory instead of files.
  /// Note that because of differences in crypto backend support, it might
  /// not be functional.
  sshMemory(64);

  const GitCredential(this.value);
  final int value;

  static GitCredential fromValue(int value) => switch (value) {
    1 => userPassPlainText,
    2 => sshKey,
    4 => sshCustom,
    8 => defaultAuth,
    16 => sshInteractive,
    32 => username,
    64 => sshMemory,
    _ => throw ArgumentError('Unknown value for GitCredential: $value'),
  };

  static Set<GitCredential> fromFlag(int value) =>
      GitCredential.values.where((e) => value & e.value == e.value).toSet();
}

/// Combinations of these values describe the features with which libgit2
/// was compiled.
enum GitFeature {
  /// If set, libgit2 was built thread-aware and can be safely used from
  /// multiple threads.
  threads(1),

  /// If set, libgit2 was built with and linked against a TLS implementation.
  /// Custom TLS streams may still be added by the user to support HTTPS
  /// regardless of this.
  https(2),

  /// If set, libgit2 was built with and linked against libssh2. A custom
  /// transport may still be added by the user to support libssh2 regardless of
  /// this.
  ssh(4),

  /// If set, libgit2 was built with support for sub-second resolution in file
  /// modification times.
  nsec(8);

  const GitFeature(this.value);
  final int value;

  static GitFeature fromValue(int value) => switch (value) {
    1 => threads,
    2 => https,
    4 => ssh,
    8 => nsec,
    _ => throw ArgumentError('Unknown value for GitFeature: $value'),
  };
}

/// Combinations of these values determine the lookup order for attribute.
enum GitAttributeCheck {
  /// Check file first, then index.
  fileThenIndex(0),

  /// Check index first, then file.
  indexThenFile(1),

  /// Check index only.
  indexOnly(2),

  /// Do not check system attributes.
  noSystem(4),

  /// Include HEAD in the check.
  includeHead(8),

  /// Include commit in the check.
  includeCommit(16);

  const GitAttributeCheck(this.value);
  final int value;

  static GitAttributeCheck fromValue(int value) => switch (value) {
    0 => fileThenIndex,
    1 => indexThenFile,
    2 => indexOnly,
    4 => noSystem,
    8 => includeHead,
    16 => includeCommit,
    _ => throw ArgumentError('Unknown value for GitAttributeCheck: $value'),
  };
}

/// Flags for indicating option behavior for git blame APIs.
enum GitBlameFlag {
  /// Normal blame, the default.
  normal(0),

  /// Track lines that have moved within a file (like `git blame -M`).
  ///
  /// This is not yet implemented and reserved for future use.
  trackCopiesSameFile(1),

  /// Track lines that have moved across files in the same commit
  /// (like `git blame -C`).
  ///
  /// This is not yet implemented and reserved for future use.
  trackCopiesSameCommitMoves(2),

  /// Track lines that have been copied from another file that exists
  /// in the same commit (like `git blame -CC`). Implies SAME_FILE.
  ///
  /// This is not yet implemented and reserved for future use.
  trackCopiesSameCommitCopies(4),

  /// Track lines that have been copied from another file that exists in
  /// *any* commit (like `git blame -CCC`). Implies SAME_COMMIT_COPIES.
  ///
  /// This is not yet implemented and reserved for future use.
  trackCopiesAnyCommitCopies(8),

  /// Restrict the search of commits to those reachable following only
  /// the first parents.
  firstParent(16),

  /// Use mailmap file to map author and committer names and email
  /// addresses to canonical real names and email addresses. The
  /// mailmap will be read from the working directory, or HEAD in a
  /// bare repository.
  useMailmap(32),

  /// Ignore whitespace differences.
  ignoreWhitespace(64);

  const GitBlameFlag(this.value);
  final int value;

  static GitBlameFlag fromValue(int value) => switch (value) {
    0 => normal,
    1 => trackCopiesSameFile,
    2 => trackCopiesSameCommitMoves,
    4 => trackCopiesSameCommitCopies,
    8 => trackCopiesAnyCommitCopies,
    16 => firstParent,
    32 => useMailmap,
    64 => ignoreWhitespace,
    _ => throw ArgumentError('Unknown value for GitBlameFlag: $value'),
  };
}

/// Type of rebase operation in-progress after calling rebase's `next()`.
enum GitRebaseOperation {
  /// The given commit is to be cherry-picked. The client should commit
  /// the changes and continue if there are no conflicts.
  pick(0),

  /// The given commit is to be cherry-picked, but the client should prompt
  /// the user to provide an updated commit message.
  reword(1),

  /// The given commit is to be cherry-picked, but the client should stop
  /// to allow the user to edit the changes before committing them.
  edit(2),

  /// The given commit is to be squashed into the previous commit. The
  /// commit message will be merged with the previous message.
  squash(3),

  /// The given commit is to be squashed into the previous commit. The
  /// commit message from this commit will be discarded.
  fixup(4),

  /// No commit will be cherry-picked. The client should run the given
  /// command and (if successful) continue.
  exec(5);

  const GitRebaseOperation(this.value);
  final int value;

  static GitRebaseOperation fromValue(int value) => switch (value) {
    0 => pick,
    1 => reword,
    2 => edit,
    3 => squash,
    4 => fixup,
    5 => exec,
    _ => throw ArgumentError('Unknown value for GitRebaseOperation: $value'),
  };
}

/// Reference lookup strategy.
///
/// These behave like the --tags and --all options to git-describe,
/// namely they say to look for any reference in either refs/tags/ or
/// refs/ respectively.
enum GitDescribeStrategy {
  /// Only match annotated tags.
  defaultStrategy(0),

  /// Match everything under `refs/tags/` (includes lightweight tags).
  tags(1),

  /// Match everything under `refs/` (includes branches).
  all(2);

  const GitDescribeStrategy(this.value);
  final int value;

  static GitDescribeStrategy fromValue(int value) => switch (value) {
    0 => defaultStrategy,
    1 => tags,
    2 => all,
    _ => throw ArgumentError('Unknown value for GitDescribeStrategy: $value'),
  };
}

/// Submodule ignore values.
///
/// These values represent settings for the `submodule.$name.ignore`
/// configuration value which says how deeply to look at the working
/// directory when getting submodule status.
enum GitSubmoduleIgnore {
  /// Use the submodule's configuration.
  unspecified(-1),

  /// Don't ignore any change - i.e. even an untracked file, will mark the
  /// submodule as dirty. Ignored files are still ignored, of course.
  none(1),

  /// Ignore untracked files; only changes to tracked files, or the index or
  /// the HEAD commit will matter.
  untracked(2),

  /// Ignore changes in the working directory, only considering changes if
  /// the HEAD of submodule has moved from the value in the superproject.
  dirty(3),

  /// Never check if the submodule is dirty.
  all(4);

  const GitSubmoduleIgnore(this.value);
  final int value;

  static GitSubmoduleIgnore fromValue(int value) => switch (value) {
    -1 => unspecified,
    1 => none,
    2 => untracked,
    3 => dirty,
    4 => all,
    _ => throw ArgumentError('Unknown value for GitSubmoduleIgnore: $value'),
  };
}

/// Submodule update values
///
/// These values represent settings for the `submodule.$name.update`
/// configuration value which says how to handle `git submodule update` for
/// this submodule. The value is usually set in the `.gitmodules` file and
/// copied to `.git/config` when the submodule is initialized.
enum GitSubmoduleUpdate {
  /// The default; when a submodule is updated, checkout the new detached HEAD
  /// to the submodule directory.
  checkout(1),

  /// Update by rebasing the current checked out branch onto the commit from
  /// the superproject.
  rebase(2),

  /// Update by merging the commit in the superproject into the current checkout
  /// out branch of the submodule.
  merge(3),

  /// Do not update this submodule even when the commit in the superproject is
  /// updated.
  none(4);

  const GitSubmoduleUpdate(this.value);
  final int value;

  static GitSubmoduleUpdate fromValue(int value) => switch (value) {
    1 => checkout,
    2 => rebase,
    3 => merge,
    4 => none,
    _ => throw ArgumentError('Unknown value for GitSubmoduleUpdate: $value'),
  };
}

/// A combination of these flags will be returned to describe the status of a
/// submodule. Depending on the "ignore" property of the submodule, some of
/// the flags may never be returned because they indicate changes that are
/// supposed to be ignored.
///
/// Submodule info is contained in 4 places: the HEAD tree, the index, config
/// files (both .git/config and .gitmodules), and the working directory. Any
/// or all of those places might be missing information about the submodule
/// depending on what state the repo is in. We consider all four places to
/// build the combination of status flags.
enum GitSubmoduleStatus {
  /// Superproject head contains submodule.
  inHead(1),

  /// Superproject index contains submodule.
  inIndex(2),

  /// Superproject gitmodules has submodule.
  inConfig(4),

  /// Superproject workdir has submodule.
  inWorkdir(8),

  /// In index, not in head.
  indexAdded(16),

  /// In head, not in index.
  indexDeleted(32),

  /// Index and head don't match.
  indexModified(64),

  /// Workdir contains empty directory.
  workdirUninitialized(128),

  /// In workdir, not index.
  workdirAdded(256),

  /// In index, not workdir.
  workdirDeleted(512),

  /// Index and workdir head don't match.
  workdirModified(1024),

  /// Submodule workdir index is dirty.
  workdirIndexModified(2048),

  /// Submodule workdir has modified files.
  smWorkdirModified(4096),

  /// Workdir contains untracked files.
  workdirUntracked(8192);

  const GitSubmoduleStatus(this.value);
  final int value;

  static GitSubmoduleStatus fromValue(int value) => switch (value) {
    1 => inHead,
    2 => inIndex,
    4 => inConfig,
    8 => inWorkdir,
    16 => indexAdded,
    32 => indexDeleted,
    64 => indexModified,
    128 => workdirUninitialized,
    256 => workdirAdded,
    512 => workdirDeleted,
    1024 => workdirModified,
    2048 => workdirIndexModified,
    4096 => smWorkdirModified,
    8192 => workdirUntracked,
    _ => throw ArgumentError('Unknown value for GitSubmoduleStatus: $value'),
  };
}

/// Capabilities of system that affect index actions.
enum GitIndexCapability {
  /// Ignore case when comparing file names.
  ignoreCase(1),

  /// Do not use file mode.
  noFileMode(2),

  /// Do not use symbolic links.
  noSymlinks(4),

  /// Use owner's capabilities.
  fromOwner(-1);

  const GitIndexCapability(this.value);
  final int value;

  static GitIndexCapability fromValue(int value) => switch (value) {
    1 => ignoreCase,
    2 => noFileMode,
    4 => noSymlinks,
    -1 => fromOwner,
    _ => throw ArgumentError('Unknown value for GitIndexCapability: $value'),
  };
}

/// Flags to control the functionality of blob content filtering.
enum GitBlobFilter {
  /// When set, filters will not be applied to binary files.
  checkForBinary(1),

  /// When set, filters will not load configuration from the
  /// system-wide `gitattributes` in `/etc` (or system equivalent).
  noSystemAttributes(2),

  /// When set, filters will be loaded from a `.gitattributes` file
  /// in the HEAD commit.
  attributesFromHead(4),

  /// When set, filters will be loaded from a `.gitattributes` file
  /// in the specified commit.
  attributesFromCommit(8);

  const GitBlobFilter(this.value);
  final int value;

  static GitBlobFilter fromValue(int value) => switch (value) {
    1 => checkForBinary,
    2 => noSystemAttributes,
    4 => attributesFromHead,
    8 => attributesFromCommit,
    _ => throw ArgumentError('Unknown value for GitBlobFilter: $value'),
  };
}

/// Flags for APIs that add files matching pathspec.
enum GitIndexAddOption {
  /// Default options.
  defaults(0),

  /// Skip the checking of ignore rules.
  force(1),

  /// Disable glob expansion and force exact matching of files in working
  /// directory.
  disablePathspecMatch(2),

  /// Check that each entry in the pathspec is an exact match to a filename on
  /// disk is either not ignored or already in the index.
  checkPathspec(4);

  const GitIndexAddOption(this.value);
  final int value;

  static GitIndexAddOption fromValue(int value) => switch (value) {
    0 => defaults,
    1 => force,
    2 => disablePathspecMatch,
    4 => checkPathspec,
    _ => throw ArgumentError('Unknown value for GitIndexAddOption: $value'),
  };
}

/// Flags to alter working tree pruning behavior.
enum GitWorktree {
  /// Prune working tree even if working tree is valid.
  pruneValid(1),

  /// Prune working tree even if it is locked.
  pruneLocked(2),

  /// Prune checked out working tree.
  pruneWorkingTree(4);

  const GitWorktree(this.value);
  final int value;

  static GitWorktree fromValue(int value) => switch (value) {
    1 => pruneValid,
    2 => pruneLocked,
    4 => pruneWorkingTree,
    _ => throw ArgumentError('Unknown value for GitWorktree: $value'),
  };
}
