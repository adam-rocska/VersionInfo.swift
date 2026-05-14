# Contributing

VersionInfo.swift aims to stay small, native to Swift Package Manager, and
boring at runtime.

## Ground Rules

- Keep each issue or pull request about one change.
- Preserve public API unless the change explicitly requires a SemVer-breaking
  release.
- Prefer Swift language and SwiftPM-native mechanisms over ad hoc scripts.
- Do not add third-party dependencies unless the value is obvious and the cost
  is small.
- Keep generated Git information a build-time concern, not a runtime concern.
- Use SemVer tags without a `v` prefix.

## Before Opening an Issue

Choose the issue template that matches the work:

- bug report for observable incorrect behavior
- feature request for one new capability
- documentation issue for unclear or missing docs

Security reports do not belong in public issues. Use the private reporting path
in `SECURITY.md`.

## Pull Requests

A good pull request should include:

- a clear summary of the behavior change
- tests for new or changed behavior
- README or DocC updates when usage changes
- explicit notes about public API and release impact

For plugin behavior, prefer consumer-package acceptance tests. The important
question is whether a real package can attach the plugin and use the generated
`versions` value.

## Verification

Run the relevant checks before asking for review:

```sh
swift test
swift test -c release
swift package generate-documentation --target VersionInfo
```

If the change affects platform support, also verify the relevant target platform
or explain exactly why it could not be verified.

## Documentation

Documentation is part of the product. If a behavior is public enough for users
to depend on, it should be described in the README, DocC, or both.
