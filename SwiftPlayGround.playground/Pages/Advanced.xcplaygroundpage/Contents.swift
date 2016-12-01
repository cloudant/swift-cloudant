//: [Previous](@previous)

import Foundation


/*:
 
 # Advanced
 
 
 ## CouchDBClient.
The client manages operation concurrency, connection pools, authentication and retrying when `429` responses are reccieved.

### Connection Pooling

Connection pools are handled by `Foundation.URLSession`. This is the number of hosts currently this is not configurable via the client and the default values
are used for the platform. See [URLSession documentation]() for information on the defaults.

### 429 Too Many Requests

When using Cloudant via BlueMix it is possible to get a `429 Too Many Requests` response from the server. The client is able to transparently
retry these requests using a doubling back off, however this is not enabled by default. To enable retries, the additional `configuration`
parameter is required. There are some caveats, the number of retries is user configable but is limited to 10. 
 
 - example: Configuration for a client to back-off when 429 responses are encountered using the default back off time seed and max retries.
 ` let config = ClientConfiguration(shouldBackOff: true)`
 
 
 - example: Configuration for a client to back off whn 429 responses with custom max retries and inital back off time seed.
 `let config = ClientConfiguration(shouldBackOff: true, backOffAttempts: 4, initialBackOff: .seconds(1)`
 
*/


//: [Next](@next)
