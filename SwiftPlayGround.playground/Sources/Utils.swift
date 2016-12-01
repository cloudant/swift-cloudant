import Foundation



public func generateDocuments(count: Int) -> [[String:Any]] {
    var documents:[[String:Any]] = []
    
    for  i in 0...count {
        documents.append(["foo": "bar", "number": i])
    }
    
    return documents
}
