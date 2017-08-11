# Contributing

## Developer Certificate of Origin

In order for us to accept pull-requests, the contributor must sign-off a
[Developer Certificate of Origin (DCO)](DCO1.1.txt). This clarifies the
intellectual property license granted with any contribution. It is for your
protection as a Contributor as well as the protection of IBM and its customers;
it does not change your rights to use your own Contributions for any other purpose.

Please read the agreement and acknowledge it by ticking the appropriate box in the PR
 text, for example:

- [x] Tick to sign-off your agreement to the Developer Certificate of Origin (DCO) 1.1

## Setting up your environment

You have probably got most of these set up already, but starting from scratch
you'll need:

* Xcode
* Xcode command line tools
* Latest Swift 3 development snapshot
* Homebrew (optional, but useful)

First, download Xcode from the app store or [ADC][adc].

When this is installed, install the command line tools. The simplest way is:

```bash
xcode-select --install
```

Install homebrew using the [guide on the homebrew site][homebrew].


Install Swift 3 development snapshot from [swift.org][swiftorg].
[adc]: http://developer.apple.com/
[homebrew]: http://brew.sh
[swiftorg]: https://swift.org/download/#snapshots

## Getting started with the project

The Swift Package Manager is the default build tool for SwiftCloudant. In order
to use Xcode as a development envrionment run the command:

```bash
$ swift package generate-xcodeproj
```

## Adding files

Production source files are stored in the `Source` tree with tests stored in the
`Tests` tree.

`Tests/SwiftCloudantTests` contains all the tests for the `SwiftCloudant` module.

### Test Configuration

By default, the tests will attempt to use CouchDB located at `http://localhost:5984`,
these can be configured using the Test Bundle's `TestSettings.plist` file. The properties
are as follows:

| Property Name | Purpose | Default |
|---------------|---------|---------|
| TEST_COUCH_URL | The URL to connect to | http://localhost:5984 |
| TEST_COUCH_USERNAME | The username to use when accessing the server | `nil` |
| TEST_COUCH_PASSWORD | The password to use when accessing the server | `nil`|


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

## Contributing your changes

We follow a fairly standard procedure:

* Fork the swift-cloudant repo into your own account, clone to your machine.
    * Create a branch with your changes on (git checkout -b my-new-feature)
    * Make sure to update the CHANGELOG and CONTRIBUTORS before sending a PR.
    * All contributions must include tests.
* Try to follow the style of the code around the code you are adding -- the project contains source code from a few places with slightly differing styles.
* Commit your changes (git commit -am 'Add some feature')
* Push to the branch (git push origin my-new-feature)
* Issue a PR for this to our repo.
