import 'package:git2dart/git2dart.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:test/test.dart';

void compareEnums(List dartValues, List ffiValues) {
  final dartSet = {for (var e in dartValues) (e as dynamic).value as int};
  final ffiSet = {for (var e in ffiValues) (e as dynamic).value as int};
  expect(dartSet, ffiSet);
}

void main() {
  group('enum values match bindings', () {
    test('ReferenceType', () {
      compareEnums(ReferenceType.values, git_reference_t.values);
    });
    test('GitFilemode', () {
      compareEnums(GitFilemode.values, git_filemode_t.values);
    });
    test('GitSort', () {
      compareEnums(GitSort.values, git_sort_t.values);
    });
    test('GitObject', () {
      compareEnums(GitObject.values, git_object_t.values);
    });
    test('GitRevSpec', () {
      compareEnums(GitRevSpec.values, git_revspec_t.values);
    });
    test('GitBranch', () {
      compareEnums(GitBranch.values, git_branch_t.values);
    });
    test('GitStatus', () {
      compareEnums(GitStatus.values, git_status_t.values);
    });
    test('GitMergeAnalysis', () {
      compareEnums(GitMergeAnalysis.values, git_merge_analysis_t.values);
    });
    test('GitMergePreference', () {
      compareEnums(GitMergePreference.values, git_merge_preference_t.values);
    });
    test('GitRepositoryState', () {
      compareEnums(GitRepositoryState.values, git_repository_state_t.values);
    });
    test('GitMergeFlag', () {
      compareEnums(GitMergeFlag.values, git_merge_flag_t.values);
    });
    test('GitMergeFileFavor', () {
      compareEnums(GitMergeFileFavor.values, git_merge_file_favor_t.values);
    });
    test('GitMergeFileFlag', () {
      compareEnums(GitMergeFileFlag.values, git_merge_file_flag_t.values);
    });
    test('GitCheckout', () {
      compareEnums(GitCheckout.values, git_checkout_strategy_t.values);
    });
    test('GitReset', () {
      compareEnums(GitReset.values, git_reset_t.values);
    });
    test('GitDiff', () {
      compareEnums(GitDiff.values, git_diff_option_t.values);
    });
    test('GitDelta', () {
      compareEnums(GitDelta.values, git_delta_t.values);
    });
    test('GitDiffFlag', () {
      compareEnums(GitDiffFlag.values, git_diff_flag_t.values);
    });
    test('GitDiffStats', () {
      compareEnums(GitDiffStats.values, git_diff_stats_format_t.values);
    });
    test('GitDiffFind', () {
      compareEnums(GitDiffFind.values, git_diff_find_t.values);
    });
    test('GitDiffLine', () {
      compareEnums(GitDiffLine.values, git_diff_line_t.values);
    });
    test('GitApplyLocation', () {
      compareEnums(GitApplyLocation.values, git_apply_location_t.values);
    });
    test('GitConfigLevel', () {
      compareEnums(GitConfigLevel.values, git_config_level_t.values);
    });
    test('GitStash', () {
      compareEnums(GitStash.values, git_stash_flags.values);
    });
    test('GitStashApply', () {
      compareEnums(GitStashApply.values, git_stash_apply_flags.values);
    });
    test('GitDirection', () {
      compareEnums(GitDirection.values, git_direction.values);
    });
    test('GitFetchPrune', () {
      compareEnums(GitFetchPrune.values, git_fetch_prune_t.values);
    });
    test('GitRepositoryInit', () {
      compareEnums(GitRepositoryInit.values, git_repository_init_flag_t.values);
    });
    test('GitCredential', () {
      compareEnums(GitCredential.values, git_credential_t.values);
    });
    test('GitFeature', () {
      compareEnums(GitFeature.values, git_feature_t.values);
    });
    test('GitAttributeCheck', () {
      compareEnums(GitAttributeCheck.values, git_attr_value_t.values);
    });
    test('GitBlameFlag', () {
      compareEnums(GitBlameFlag.values, git_blame_flag_t.values);
    });
    test('GitRebaseOperation', () {
      compareEnums(GitRebaseOperation.values, git_rebase_operation_t.values);
    });
    test('GitDescribeStrategy', () {
      compareEnums(GitDescribeStrategy.values, git_describe_strategy_t.values);
    });
    test('GitSubmoduleIgnore', () {
      compareEnums(GitSubmoduleIgnore.values, git_submodule_ignore_t.values);
    });
    test('GitSubmoduleUpdate', () {
      compareEnums(GitSubmoduleUpdate.values, git_submodule_update_t.values);
    });
    test('GitSubmoduleStatus', () {
      compareEnums(GitSubmoduleStatus.values, git_submodule_status_t.values);
    });
    test('GitIndexCapability', () {
      compareEnums(GitIndexCapability.values, git_index_capability_t.values);
    });
    test('GitBlobFilter', () {
      compareEnums(GitBlobFilter.values, git_blob_filter_flag_t.values);
    });
    test('GitIndexAddOption', () {
      compareEnums(GitIndexAddOption.values, git_index_add_option_t.values);
    });
    test('GitWorktree', () {
      compareEnums(GitWorktree.values, git_worktree_prune_t.values);
    });
  });
}
