//
//  LinuxMain.swift
//  SwiftCloudant
//
//  Created by Rhys Short on 28/06/2016.
//  Copyright © 2016 IBM Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

import XCTest

@testable import SwiftCloudantTests

XCTMain( [
testCase(CreateDatabaseTests.allTests),
testCase(PutAttachmentTests.allTests),
testCase(CreateQueryIndexTests.allTests),
testCase(DeleteAttachmentTests.allTests),
testCase(GetDocumentTests.allTests),
testCase(InterceptorTests.allTests),
testCase(ReadAttachmentTests.allTests),
testCase(QueryViewTests.allTests),
testCase(GetAllDatabasesTest.allTests),
testCase(DeleteDocumentTests.allTests),
testCase(GetAllDocsTest.allTests),
testCase(InterceptableSessionTests.allTests),
testCase(DeleteQueryIndexTests.allTests),
testCase(FindDocumentOperationTests.allTests),
testCase(BulkDocsTests.allTests),
testCase(PutDocumentTests.allTests)])
// XCTMain(tests)
