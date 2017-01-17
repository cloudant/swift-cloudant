# Architecture

SwiftCloudant follows a layered layout for classes. The foundation being HTTP
classes, which the operations build on.

## HTTP

The main class for HTTP is `InterceptableSession`. `InterceptableSession` initially
provided support for the interceptor API that can be found in the other Cloudant
Client libs. However the Interceptor API was removed in favour of building
in support for Cookie Authentication and `429 - Too Many Requests` built in
directly. Most of the classes such as `OperationRequestBuilder` effectively
do a small amount of work and the classes are well documented.

### InterceptableSession

#### 429 support

429 Support is built in using `Dispatch` (libdispatch in objc). It uses a custom
extension on `DispatchTimeInterval` to provide calculations for the time delay.
The queue on which the retry tasks are dispatched is the `delegate` queue. Unlike
403 Forbidden responses retries occur when the initial response is received from
the server. This is because it is possible to stop loading the response from
the server if we know the request has already failed.

#### Quirks

There are some quirks with the implementation, since it is not possible to use `self`
as a parameter to another `init` method while in the init for `self` because the underlying
`Foundation.URLSession` (`NSURLSession` in objc) is created in a `lazy` property.
This means care has to be taken when the `InterceptableSession` is being deallocated.

### URLSessionTask

`URLSessionTask` provides a slimmed down, `Foundation.URLSessionTask` like interface,
it is mostly a state store for the inflight request that it encapsulates for
the `URLSession`

## Operations

All SwiftCloudant API calls are operations, and each operation class provides
information to the underlying machinery with a well defined set of APIs. The
`Operation` class is a custom implementation of `Foundation.Operation`, it makes
it possible to run a `CouchOperation` on an `Foundation.OperationQueue`. `Operation`
transforms the API exposed to  each of the operations to the API expected by the HTTP classes.
Such as converting an `[String:String]` of parameters to `[URLQueryItems]`.

### CouchOperation

`CouchOperation` lays out the API for classes to define an API to call on the server,
however it only provides basic functionality to provide the maximum flexibility
to conforming classes. However this makes it more difficult to implement new APIs
when there is not much work to be performed. For these cases the `JSONOperation`
and `DataOperation` come in.

`JSONOperation` makes it easier to deserialise JSON responses from the server.
It defaults the method `processResponse(data:httpInfo:error:)` to correctly
process the response data into a deserialised JSON structure. The structure type
(eg `[String:Any]` or `[Any]`) is defined by the conforming class to match expected
type when the API returns **correctly**. The response will be cast to this type
using the `as?` so if a 403 is returned from `_all_dbs` the response **will** be
`nil` this is expected. The response object is only guaranteed to be present when
the request was successful.

`DataOperation` makes it possible to interact with Attachments, and any other
operation which does not return JSON as the response. The default implementation
of `processResponse(data:httpInfo:error:)` calls the completion handler
with the expected error semantics.

Anyone implementing a new API for SwiftCloudant **should** conform to either
`JSONOperation` or `DataOperation`.

### Operation API Call Order
Classes which implement `CouchOperation`, `JSONOperation` or `DataOperation` have
a guaranteed order in which the  APIs **will** be called to make it possible
to do processing of Data into the expected form for the CouchDB endpoint.
That order is:

1. `validate()`
  - `callCompletionHandler` (if validation fails)
1. `serialise`
  - `callCompletionHandler` (if serialise throws)
1. `endpoint`
1. `parameters`
1. `method`
1. `data`
1. `httpContentType` (if `data` is not `nil`)
1. `processResponse(data:httpInfo:error)`
1. `callCompletionHandler`
  - should then be called by the operation during processing.


## Testing

There are two types of testing for the client, Full End to End testing, and simulated execution.

### Full End to End

Full End to End testing goes through the entire machinery of the library, making
real requests to the server. If there is not a CouchDB server that can be contacted
the tests tend to fail with a crash due to set-up methods forcibly unwrapping
test methods.

### Simulated Execution
The `TestHelpers.swift` file contains an extension to `XCTestCase` which adds
`simulateXXXXResponse` which will simulate the API calls required to make an
operation and will trigger a canned response without hitting the network. This
is useful for running tests to make sure the `processResponse(data:httpInfo:error)`
method processes responses correctly.

There is a slight quirk that it does not call the properties used to create the `HTTP`
request, only the method:

- validate
- serialise
- processResponse
- callCompletionHandler

are called when using the simulation.

The simulated operations are executed on the Main queue asynchronously so it is
possible to use expectations as if it was an End to End Test.

Since the tests do not hit the network, any test of operations that would
ordinarily hit the network must check the expected request payloads and HTTP
properties. The Query tests provide an example that performs these required checks.
