
Pod::Spec.new do |spec|

  spec.name         = "DYFStoreReceiptVerifier_Swift"
  spec.version      = "1.2.0"
  spec.summary      = "The verification program of receipts for in app purchases within iOS."

  spec.description  = <<-DESC
  TODU:[Swift] The verification program of receipts for in app purchases within iOS.
  DESC

  spec.homepage      = "https://github.com/itenfay/DYFStoreReceiptVerifier_Swift"
  # spec.screenshots = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  spec.license = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Tenfay" => "itenfay@163.com" }
  # Or just: spec.author  = "Tenfay"
  # spec.authors          = { "Tenfay" => "itenfay@163.com" }
  # spec.social_media_url = "https://twitter.com/Tenfay"

  spec.platform     = :ios
  # spec.platform   = :ios, "5.0"
  spec.ios.deployment_target 	 = "8.0"
  # spec.osx.deployment_target 	 = "10.10"
  # spec.watchos.deployment_target = "3.0"
  # spec.tvos.deployment_target    = "9.0"

  spec.source = { :git => "https://github.com/itenfay/DYFStoreReceiptVerifier_Swift.git", :tag => spec.version.to_s }

  spec.source_files    = "Classes/*.swift"
  # spec.exclude_files = "Classes/Exclude"
  # spec.public_header_files = "Classes/**/*.h"

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"
  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # spec.framework    = "Security"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"

  #spec.swift_versions = ['4.2', '5.0']
  spec.swift_version = '5.0'
  spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"
end
