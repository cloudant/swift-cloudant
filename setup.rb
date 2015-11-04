#!/usr/bin/ruby

success = false
loop_count = 0

while !success and loop_count < 10

    success = system("curl http://127.0.0.1:5984/")
    loop_count = loop_count + 1
    sleep(10) unless success
end

exit success unless success

system("curl -X PUT http://127.0.0.1:5984//_replicator/replication-doc -H 'Content-Type: application/json' -d '{\"source\": \"https://clientlibs-test.cloudant.com/animaldb\",\"target\": \"http://localhost:5984/objectivecouch-test\",\"create_target\": true,\"continuous\": false}'")

exit $?.to_i
