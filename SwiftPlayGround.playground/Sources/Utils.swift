import Foundation



/// Generate documents in the form ["foo":"bar", "number": x] where x is generated.
///
/// - Parameter count: The number of documents to generate
/// - Returns: Generated documents.
public func generateDocuments(count: Int) -> [[String:Any]] {
    var documents:[[String:Any]] = []
    
    for  i in 0...count {
        documents.append(["foo": "bar", "number": i])
    }
    
    return documents
}
