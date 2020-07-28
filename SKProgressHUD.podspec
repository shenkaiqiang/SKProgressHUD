#
#  Be sure to run `pod spec lint SKProgressHUD.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.swift_version = "5.2"
  spec.name         = "SKProgressHUD"
  spec.version      = "0.0.1"
  spec.summary      = "网络状态加载框"

  spec.description  = <<-DESC
  一个网络状态加载框
                   DESC

  spec.homepage     = "https://github.com/shenkaiqiang/SKProgressHUD"

  spec.license      = "MIT"

  spec.author             = { "shenkaiqiang" => "1187159671@qq.com" }
  
  spec.platform     = :ios, "11.0"

  spec.source       = { :git => "https://github.com/shenkaiqiang/SKProgressHUD.git", :tag => "#{spec.version}" }

  spec.source_files  = "SKProgressHUD/*.swift"

  spec.requires_arc = true

end
