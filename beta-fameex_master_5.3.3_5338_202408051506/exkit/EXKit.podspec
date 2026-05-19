#
# Be sure to run `pod lib lint EXKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EXKit'
  s.version          = '1.4.1'
  s.summary          = 'A short description of EXKit.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://www.baidu.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'uso' => 'appagent@xiaolian.link' }
  # s.source           = { :git => 'https://stash.dw2nn.com:7999/app/exkit.git', :tag => s.version.to_s }
  s.source           = { :git => 'ssh://git@stash.dw2nn.com:7999/app/exkit.git', :tag => s.version.to_s }
  #  s.source           = { :path => '' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'

  s.source_files = 'EXKit/Classes/**/*'
 
  s.subspec 'Images' do |ss|
    ss.resource_bundles = {
      'EXKitResource' => ['EXKit/Assets/EKUIResources/**/*'],
      'FiveSvg'       => ['EXKit/Assets/FiveSvg/**/*']
    }
  end

  s.subspec 'UI' do |ss|
    ss.source_files = 'EXKit/Classes/UI/**/*'
    ss.dependency 'EXKit/Foundation', "#{s.version}"
    ss.dependency 'DZNEmptyDataSet', '>= 1.8.1'
    ss.dependency 'MJRefresh', '3.1.15.7'
    ss.dependency 'JXSegmentedView','>= 1.3.0'
    ss.dependency 'Blueprints','>= 0.13.1'
    ss.dependency 'SkeletonView', '~> 1.30.4'
    ss.dependency 'lottie-ios', '~> 4.2.0'
  end
  
  s.subspec 'Theme' do |ss|
    ss.subspec 'Core' do |sss|
      sss.source_files = 'EXKit/Classes/Theme/Core/*.{swift}'
      sss.resource_bundle = { 'EXTheme' => 'EXKit/Assets/Theme/*' }
      sss.dependency 'SwiftDraw', ">= 0.14.0"
    end
    ss.subspec 'Deprecated' do |sss|
      sss.dependency 'EXKit/Theme/Core', "#{s.version}"
      sss.source_files = 'EXKit/Classes/Theme/Deprecated/*.{swift}'
    end
  end
  
  s.subspec 'Foundation' do |ss|
    ss.source_files = 'EXKit/Classes/Foundation/**/*'
    ss.dependency 'EXKit/Theme', "#{s.version}"
    ss.dependency 'YYWebImage', '>= 1.0.5'
    ss.dependency 'MJExtension', '3.0.15.1'
    ss.dependency 'SwiftEventBus','>= 5.0.0'
    ss.dependency 'YYText', '>= 1.0.7'
    ss.dependency 'SnapKit','>= 5.6.0'
    ss.dependency 'RxSwift','>= 6.5.0'
    ss.dependency 'RxCocoa', '>= 6.5.0'
    ss.dependency 'SwiftEntryKit','>= 2.0.0'
    ss.dependency 'SKPhotoBrowser', '>= 7.0.0'
    ss.dependency 'IQKeyboardManagerSwift', '>= 6.5.0'
  end
  
  s.subspec 'Analytics' do |ss|
    ss.source_files = 'EXKit/Classes/Analytics/**/*'
    ss.dependency 'EXKit/Foundation', "#{s.version}"
    ss.dependency 'Reachability', '>= 3.2'
  end
  
  s.subspec 'Logger' do |ss|
    ss.source_files = 'EXKit/Classes/Logger/**/*'
    ss.dependency 'EXKit/Foundation', "#{s.version}"
  end
  
end
