# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [1.1.0] - 2025-10-01
### Added
- [show_commit_history] Add pr-changelog display format [[#49](https://github.com/ManageIQ/multi_repo/pull/49)]
- [pull_request_blaster_outer] Prevent git show paging when using --force [[#53](https://github.com/ManageIQ/multi_repo/pull/53)]

### Changed
- Update licensee to at least 9.7.0 [[#54](https://github.com/ManageIQ/multi_repo/pull/54)]
- Separate progress bar options from creation of the progress bar [[#55](https://github.com/ManageIQ/multi_repo/pull/55)]

## [1.0.0] - 2025-04-24
### Added
- Allow blank overrides on the command line [[#46](https://github.com/ManageIQ/multi_repo/pull/46)]

### Removed
- **BREAKING**: Remove travis gem dependency and service helper [[#48](https://github.com/ManageIQ/multi_repo/pull/48)]

## [0.6.0] - 2025-02-27
### Added
- [pull_request_blaster_outer] Option to force creation of the pull request without asking [[#40](https://github.com/ManageIQ/multi_repo/pull/40)]

## [0.5.1] - 2025-02-20
### Added
- Add debugging of octokit request/response if DEBUG env var set [[#38](https://github.com/ManageIQ/multi_repo/pull/38)]

### Fixed
- Pin json gem to 2.9.1 since 2.10.0+ is broken [[#41](https://github.com/ManageIQ/multi_repo/pull/41)]

## [0.5.0] - 2024-11-12
### Added
- [pull_request_labeler] Add ability to also add a comment about why the labels are changing [[#30](https://github.com/ManageIQ/multi_repo/pull/30)]
- [pull_request_labeler] Add normalization of PR formats to org/repo#pr format [[#30](https://github.com/ManageIQ/multi_repo/pull/30)]
- [pull_request_merger] Add URL support to pull_request_merger [[#37](https://github.com/ManageIQ/multi_repo/pull/37)]
- [Git Service, GitHub service] Move helper methods into services [[#31](https://github.com/ManageIQ/multi_repo/pull/31)]
- Add testing with ruby 3.2, 3.3 [[#35](https://github.com/ManageIQ/multi_repo/pull/35)]

### Changed
- [pull_request_labeler] Make add and remove optional [[#30](https://github.com/ManageIQ/multi_repo/pull/30)]

### Fixed
- [pull_request_labeler] Fix cli description of --prs [[#30](https://github.com/ManageIQ/multi_repo/pull/30)]
- [show_commit_history] Handle issue where PR may not be found [[#36](https://github.com/ManageIQ/multi_repo/pull/30)]

## [0.4.0] - 2024-03-29
### Changed
- Allow overriding the path for a repo [[#28](https://github.com/ManageIQ/multi_repo/pull/28)]

### Fixed
- [update_milestone] Fix issue where a due date was required to close a milestone [[#24](https://github.com/ManageIQ/multi_repo/pull/24)]
- [GitHub service] Use newer method for actions-secrets creation [[#27](https://github.com/ManageIQ/multi_repo/pull/27)]

## [0.3.1] - 2024-01-31
### Fixed
- [pull_request_blaster_outer] Various fixes and cleanup output [[#21](https://github.com/ManageIQ/multi_repo/pull/21)]
- [show_commit_history] Prevent missing ranges from failing the entire run [[#20](https://github.com/ManageIQ/multi_repo/pull/20)]
- [pull_request_merger] Fixing issue passing kwargs on Ruby 3 [[#23](https://github.com/ManageIQ/multi_repo/pull/23)]

[Unreleased]: https://github.com/ManageIQ/multi_repo/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/ManageIQ/multi_repo/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/ManageIQ/multi_repo/compare/v0.6.0...v1.0.0
[0.6.0]: https://github.com/ManageIQ/multi_repo/compare/v0.5.1...v0.6.0
[0.5.1]: https://github.com/ManageIQ/multi_repo/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/ManageIQ/multi_repo/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/ManageIQ/multi_repo/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/ManageIQ/multi_repo/compare/v0.3.0...v0.3.1
