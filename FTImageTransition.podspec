
Pod::Spec.new do |s|

  s.name         = "FTImageTransition"
  s.version      = "0.2.1"
  s.summary      = "Customize the present animation"
  s.description  = <<-DESC
    	FTImageTransition. Customize the present animation with simple api.
                   DESC
  s.homepage     = "https://github.com/liufengting/FTImageTransition"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author		 = { "liufengting" => "wo157121900@me.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/liufengting/FTImageTransition.git", :tag => "#{s.version}" }
  s.source_files = ["FTImageTransition/*.{h,m,swift}"]
  s.framework    = "UIKit"
  s.swift_version = '4.0'

end
