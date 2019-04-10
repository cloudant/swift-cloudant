# Contributing

## Issues

Please [read these guidelines](http://ibm.biz/cdt-issue-guide) before opening an issue.
If you still need to open an issue then we ask that you complete the template as
fully as possible.

## Pull requests

We welcome pull requests, but ask contributors to keep in mind the following:

* Only PRs with the template completed will be accepted
* We will not accept PRs for user specific functionality

### Developer Certificate of Origin

In order for us to accept pull-requests, the contributor must sign-off a
[Developer Certificate of Origin (DCO)](DCO1.1.txt). This clarifies the
intellectual property license granted with any contribution. It is for your
protection as a Contributor as well as the protection of IBM and its customers;
it does not change your rights to use your own Contributions for any other purpose.

Please read the agreement and acknowledge it by ticking the appropriate box in the PR
 text, for example:

- [x] Tick to sign-off your agreement to the Developer Certificate of Origin (DCO) 1.1

## General information

### Adding files

Production source files are stored in the `Source` tree with tests stored in the
`Tests` tree.

`Tests/SwiftCloudantTests` contains all the tests for the `SwiftCloudant` module.

## Requirements

Starting from scratch you'll need:

* Xcode
* Xcode command line tools
* [Swift 3 or 4](https://swift.org/getting-started/#installing-swift)

First, download Xcode from the app store or [ADC][adc].

When this is installed, install the command line tools. The simplest way is:

```sh
xcode-select --install
```

### Getting started with the project

The Swift Package Manager is the default build tool for SwiftCloudant. In order
to use Xcode as a development envrionment run the command:

```sh
$ swift package generate-xcodeproj
```

## Building

```sh
swift build
```

## Testing

### Test Configuration

By default, the tests will attempt to use CouchDB located at `http://localhost:5984`,
these can be configured using the Test Bundle's `TestSettings.plist` file. The properties
are as follows:

| Property Name | Purpose | Default |
|---------------|---------|---------|
| SERVER_URL | The URL to connect to | http://localhost:5984 |
| SERVER_USER | The username to use when accessing the server | `nil` |
| SERVER_PASSWORD | The password to use when accessing the server | `nil`|


Note: Since the move to using the SwiftPackageManager test configuration options
currently do not work. For now tests will only connect to `http://localhost:5984`

### Running the tests

Run:
```bash
export TOOLCHAINS=swift
swift build
swift test
```

or if you have a generated xcode project you can use:
```bash
export TOOLCHAINS=swift
xcodebuild -project SwiftCloudant.xcproj -scheme SwiftCloudant test
```

Currently only OS X / macOS is supported for testing.

__NOTE__: You should also check that any changes made compile using the Swift Package Manager,
use the command `swift build` in the root of the checkout to compile using the Swift Package Manager.
