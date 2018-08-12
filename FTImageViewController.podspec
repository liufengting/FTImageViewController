#
#  Be sure to run `pod spec lint FTImageViewController.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
	
  s.name         = "FTImageViewController"
  s.version      = "0.0.1"
  s.summary      = "A short summary of FTImageViewController."
  s.description  = <<-DESC
  A short description of FTImageViewController.
                   DESC
  s.homepage     = "https://github.com/liufengting/FTImageViewController"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "liufengting" => "wo157121900@me.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/liufengting/FTImageViewController.git", :tag => "#{s.version}" }
  s.source_files  = "FTImageViewController", "FTImageViewController/*.{h,m,swift}"

  s.dependency "Kingfisher", "~> 4.0"
  # s.dependency "FTZoomTransition", "~> 0.2.1"
  
  s.swift_version = '4.0'

end
