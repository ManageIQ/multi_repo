# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/ManageIQ/more_core_extensions/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/ManageIQ/more_core_extensions/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/ManageIQ/more_core_extensions/compare/v0.3.0...v0.3.1
