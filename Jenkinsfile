#!groovy

/*
 * Copyright © 2017 IBM Corp. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */

def buildAndTest(nodeLabel) {
  def buildAndTestScript = {

  }
  node(nodeLabel) {
    checkout scm
    withCredentials([usernamePassword(credentialsId: 'clientlibs-test', usernameVariable: 'TEST_COUCH_USERNAME', passwordVariable: 'TEST_COUCH_PASSWORD')]) {
      withEnv(["TEST_COUCH_URL=https://clientlibs-test.cloudant.com"]) {
        def swiftPath=''
        if (nodeLabel == null) {
          sh 'sudo apt-get update'
          sh 'sudo apt-get install -y build-essential git libcurl3 libblocksruntime-dev clang libicu-dev uuid-dev'
          sh 'wget https://swift.org/builds/swift-5.0-release/ubuntu1404/swift-5.0-RELEASE/swift-5.0-RELEASE-ubuntu14.04.tar.gz'
          sh 'gunzip swift-5.0-RELEASE-ubuntu14.04.tar.gz'
          sh 'tar -xvf swift-5.0-RELEASE-ubuntu14.04.tar'
          swiftPath = './swift-5.0-RELEASE-ubuntu14.04/usr/bin/'
        }
        sh "${swiftPath}swift build"
        sh "${swiftPath}swift test"
      }
    }
  }
}


stage('QA') {
  parallel(
    Mac:
    {
      buildAndTest("macos")
    },
    Linux:
    {
      buildAndTest(null)
    }
  )
}
