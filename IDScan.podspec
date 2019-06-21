Pod::Spec.new do |spec|
  spec.platform              = :ios, "10.0"
  spec.ios.deployment_target = "10.0"
  spec.name                  = "IDScan"
  spec.version               = "1.0.0"
  spec.summary               = "Very basic image capture for IDs and passports."
  spec.homepage              = "https://github.com/Stakenborg/IDScan"
  spec.license               = { :type => "MIT", :file => "LICENSE" }
  spec.author                = { "Stakenborg" => "b.stakenborg@gmail.com" }
  spec.source                = { :git => "https://github.com/Stakenborg/IDScan.git", :tag => "#{spec.version}" }
  spec.source_files          = "IDScan/*.{swift}"
  spec.resources             = "IDScan/*.{xcassets}"

  spec.swift_version         = "5.0"
end
