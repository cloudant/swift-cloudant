# Contributing

## Contributor License Agreement

In order for us to accept pull-requests, the contributor must first complete
a Contributor License Agreement (CLA). This clarifies the intellectual 
property license granted with any contribution. It is for your protection as a 
Contributor as well as the protection of IBM and its customers; it does not 
change your rights to use your own Contributions for any other purpose.

This is a quick process: one option is signing using Preview on a Mac,
then sending a copy to us via email. Signing this agreement covers a few repos
as mentioned in the appendix of the CLA.

You can download the CLAs here:

 - [Individual](http://cloudant.github.io/cloudant-sync-eap/cla/cla-individual.pdf)
 - [Corporate](http://cloudant.github.io/cloudant-sync-eap/cla/cla-corporate.pdf)

If you are an IBMer, please contact us directly as the contribution process is
slightly different.

## Setting up your environment

You have probably got most of these set up already, but starting from scratch
you'll need:

* Xcode
* Xcode command line tools
* Swift 3 development snapshot
* Cocoapods
* Homebrew (optional, but useful)

First, download Xcode from the app store or [ADC][adc].

When this is installed, install the command line tools. The simplest way is:

```bash
xcode-select --install
```

Install homebrew using the [guide on the homebrew site][homebrew].

Install cocoapods using the [guide on their site][cpinstall].

Install Swift 3 development snapshot from [swift.org][swiftorg].
[adc]: http://developer.apple.com/
[homebrew]: http://brew.sh
[cpinstall]: http://guides.cocoapods.org/using/index.html
[swiftorg]: https://swift.org/download/#snapshots

## Coding guidelines

The house style is [documented](doc/style-guide.md). There's information there on using
`clang-format` to automatically use the right format.

## Getting started with the project

The main workspace is `ObjectiveCloudant.xcworkspace` this is in the root of
the checkout after `pod install` has been run to setup all the dependancies
for the project. All development should be completed via this workspace.

## Adding files

First you should make sure you add them in the correct place in the project
structure. All production code goes into `Source` and test code goes into `Test`.

* `HTTP` for classes which are related to HTTP layer above `NSURLSession`
*  `Operations` for operations perform tasks such creating a document.
* `Source` for classes that need to be used in order to successfully
interact with the database. Such as CDTCouchDBClient.

### Using Xcode build to run the tests.

Run:
```bash
export TOOLCHAINS=swift
pod update
xcodebuild -workspace SwiftCloudant.xcworkspace/ -scheme SwiftCloudantTests -destination 'platform=iOS Simulator,OS=latest,name=iPhone 4S' build test
```

Currently only iOS is supported for testing.

__NOTE__: Currently server information is hard coded to localhost without credentials.

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
