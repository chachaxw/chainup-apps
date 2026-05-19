#
# Be sure to run `pod lib lint Swap.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Swap'
  s.version          = '0.2.0'
  s.summary          = '合约SDK Swap.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description = <<-DESC
                  Computes the meaning of life.
                  Features:
                  1. Is self aware
                DESC

  s.homepage         = 'https:/www.baidu.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '柴伟东' => 'cwd888@163.com' }
  s.source           = { :git => 'ssh://git@stash.dw2nn.com:7999/app/excontractsdk-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }
  s.source_files = 'Swap/Classes/**/*'
  #将xib和图片都放入resources
  s.resource_bundles = {
    'Swap' => ['Swap/Assets/**/*.{xcassets,bundle}']
    #'Swap' => ['Swap/{Assets,Classes}/**/*.{xcassets,png,xib,storyboard}']
  }
  #s.public_header_files = 'Swap/Classes/*.h'
  #如果加入了framework文件，就在podspec里写上下面这句话
  #s.vendored_frameworks = 'SDK/Classes/*.framework'
  #如果加入了.a文件
#  s.vendored_libraries = 'Swap/Classes/*.a'
    s.dependency 'EXKit', '>=1.3.4'
    s.dependency 'JXPagingView/Paging', '2.1.2'
    s.dependency 'Moya/RxSwift', '15.0.0'
    s.dependency 'HandyJSON', '5.0.2'
    s.dependency 'Starscream' , '~>3.1.1'
    s.dependency 'Reachability', '3.2'
    s.dependency 'Reusable', '4.1.2'
    s.dependency 'DeepDiff', '2.3.1'
#    s.dependency 'MJExtension', '3.0.15.1'
    s.dependency 'YYModel', '1.0.4'
    s.dependency 'EXFlutterKLineKit'
end
