import Foundation



public func generateDocuments(count: Int) -> [[String:Any]] {
    var documents:[[String:Any]] = []
    
    for  i in 0...count {
        if i % 2 == 0 {
        documents.append(["hello": "world", "number": i])
        } else {
            documents.append(["foo": "bar", "number": i])
        }
    }
    
    return documents
}
