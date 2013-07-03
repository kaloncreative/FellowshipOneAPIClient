
Pod::Spec.new do |s|
  s.name         = "FellowshipOne"
  s.version      = "1.2.0"
  s.summary      = "A Cocoa Touch library for consuming the Fellowship One API"
  s.homepage     = "https://github.com/kaloncreative/FellowshipOneAPIClient"

  # Specify the license type. CocoaPods detects automatically the license file if it is named
  # 'LICENCE*.*' or 'LICENSE*.*', however if the name is different, specify it.
  # s.license      = 'MIT (example)'
  # s.license      = { :type => 'MIT (example)', :file => 'FILE_LICENSE' }

  s.authors      = { "Chad Meyer" => "chadmeyer@me.com", "Austin Grigg" => "austin@kaloncreative.com" }

  s.source       = { :git => "https://github.com/kaloncreative/FellowshipOneAPIClient.git", :tag => "1.2.0" }

  s.platform     = :ios, '5.0'

  s.source_files = 'Classes', 'FellowshipOneAPIClient/**/*.{h,m,c}'

  s.public_header_files = 'FellowshipOneAPIClient/**/*.h'

  s.requires_arc = false
end
