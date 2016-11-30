//: [Previous](@previous)

import Foundation


/*:
 
The client manages operation
concurrency, connection pools, authentication and retrying when `429` responses are reccieved.

### Connection Pooling

Connection pools are handled by `Foundation.URLSession`, currently this is not configurable via the client and the default values
are used for the platform. See [URLSession documentation]() for information on the defaults.

### 429 Too Many Requests

When using Cloudant via BlueMix it is possible to get a `429 Too Many Requests` response from the server. The client is able to transparently
retry these requests using a doubling back off, however this is not enabled by default. To enable retries, the additional `configuration`
parameter is required. There are some caveats, the number of retries is user configable but is limited to 10.

*/

var str = "Hello, playground"

//: [Next](@next)
