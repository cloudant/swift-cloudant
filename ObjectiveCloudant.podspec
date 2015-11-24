Pod::Spec.new do |s|

  s.name         = "ObjectiveCloudant"
  s.version      = "0.2.2"
  s.summary      = "Objective-cloudant is a client library for  Apache CouchDB / IBM Cloudant"

  s.description  = <<-DESC

                   Objective-cloudant is a client library for interacting with
                   Apache CouchDB / IBM Cloudant.

                   It provides an operation based API for performing actions
                   with the Apache CouchDB HTTP API.

                   DESC

  s.homepage = "https://github.com/cloudant/objective-cloudant"

  s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }

  s.author = { "IBM Cloudant" => "support@cloudant.com" }

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"

  s.source = { :git => "https://github.com/cloudant/objective-cloudant.git", :tag => s.version.to_s}
  s.source_files  = "Classes", "ObjectiveCloudant/**/*.{h,m}"

  s.public_header_files = "ObjectiveCloudant/**/*.h"
  s.private_header_files = "ObjectiveCloudant/**/*+Internal.h"


end
