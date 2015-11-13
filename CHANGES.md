# 0.2.1 (2015-11-13)

- [FIX] Fixed issue where the document id would be null
  when calling `putDocumentCompletionBlock`
- [FIX] Fixed issue where the status code passed to `putDocumentCompletionBlock`
  would always be equal to `kCDTNoHTTPStatusCode` even when a HTTP request was
  made successfully made to the server.

# 0.2 (2015-11-9)

Initial Release
