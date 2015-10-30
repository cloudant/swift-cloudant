# Contributing

## Setting up your environment

You have probably got most of these set up already, but starting from scratch
you'll need:

* Xcode
* Xcode command line tools
* Cocoapods
* Homebrew (optional, but useful)

First, download Xcode from the app store or [ADC][adc].

When this is installed, install the command line tools. The simplest way is:

```bash
xcode-select --install
```

Install homebrew using the [guide on the homebrew site][homebrew].

Install cocoapods using the [guide on their site][cpinstall].

[adc]: http://developer.apple.com/
[homebrew]: http://brew.sh
[cpinstall]: http://guides.cocoapods.org/using/index.html

## Coding guidelines

The house style is [documented](doc/style-guide.md). There's information there on using
`clang-format` to automatically use the right format.

## Getting started with the project

The main workspace is `ObjectiveCloudant.xcworkspace` this is in the root of
the checkout after `pod install` has been run to setup all the dependancies
for the project. All development should be completed via this workspace.

## Adding files

First you should make sure you add them in the correct place in the project
structure.

* `HTTP` for classes which are related to HTTP layer above `NSURLSession`
*  `Operations - Instance` for operations which interact with the sever, such as
creating databases.
* `Operations - Database` for  operations which interact with a Database, which
perform tasks such creating a document.
* `ObjectiveCloudant` for classes that need to be used in order to successfully
interact with the database. Such as CDTCouchDBClient.

### Using Xcode build to run the tests.

Run:
```bash
xcodebuild -project ObjectiveCloudant.xcodeproj/ -scheme ObjectiveCloudantTests -destination 'platform=iOS Simulator,OS=latest,name=iPhone 4S' build test
```

Currently only iOS is supported for testing.

__NOTE__: Currently server information is hard coded to localhost without credentials.

## Contributing your changes

We follow a fairly standard procedure:

* Fork the objective-cloudant repo into your own account, clone to your machine.
    * Create a branch with your changes on (git checkout -b my-new-feature)
    * Make sure to update the CHANGELOG and CONTRIBUTORS before sending a PR.
    * All contributions must include tests.
* Try to follow the style of the code around the code you are adding -- the project contains source code from a few places with slightly differing styles.
* Commit your changes (git commit -am 'Add some feature')
* Push to the branch (git push origin my-new-feature)
* Issue a PR for this to our repo.
