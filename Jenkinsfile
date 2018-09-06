#!groovy

/*
 * Copyright © 2017, 2019 IBM Corp. All rights reserved.
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
 def getEnvForServer(server) {
  // Define the matrix environments
    def testEnvVars = ['DOCKER_HOST=']
    if (server == 'cloudant-service') {
      testEnvVars.add("SERVER_URL=https://${SERVER_USER}.cloudant.com")
    }
    return testEnvVars
}

def buildAndTest(nodeLabel, server) {
  node(nodeLabel == 'linux' ? null : nodeLabel) {
    checkout scm
    withCredentials([usernamePassword(credentialsId: 'clientlibs-test', usernameVariable: 'SERVER_USER', passwordVariable: 'SERVER_PASSWORD')]) {
      withEnv(getEnvForServer(server)) {
        if (nodeLabel == 'linux') {
          try {
            sh "docker-compose -f ${server}.yml -f swift.yml up --abort-on-container-exit"
          } finally {
            sh "docker-compose -f ${server}.yml -f swift.yml down -v --rmi local"
          }
        } else {
          sh "swift build"
          sh "swift test"
        }
      }
    }
  }
}


stage('QA') {
  axes = [:]
  services = ['couchdb', 'cloudant-service']
  oses = ['linux']
  services.each { server ->
    oses.each { os ->
      axes.put("${os}-${server}", {buildAndTest(os, server)})
    }
  }
  axes.put("macos-cloudant-service", {buildAndTest('macos', 'cloudant-service')})
  parallel(axes)
}
