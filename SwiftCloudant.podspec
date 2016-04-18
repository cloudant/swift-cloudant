Pod::Spec.new do |s|

  s.name         = "SwiftCloudant"
  s.version      = "0.1.0"
  s.summary      = "SwiftCloudant is a client library for  Apache CouchDB / IBM Cloudant"

  s.description  = <<-DESC

                   SwiftCloudant is a client library for interacting with
                   Apache CouchDB / IBM Cloudant.

                   It provides an operation based API for performing actions
                   with the Apache CouchDB HTTP API.

                   DESC

  s.homepage = "https://github.com/cloudant/swift-cloudant"

  s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }

  s.author = { "IBM Cloudant" => "support@cloudant.com" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"

  s.source = { :git => "https://github.com/cloudant/swift-cloudant.git", :tag => s.version.to_s}
  s.source_files  = "Classes", "Source/**/*.swift"

end
