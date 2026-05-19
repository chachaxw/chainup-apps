#
# Be sure to run `pod lib lint EXUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EXLookin'
  s.version          = '1.2.0'
  s.summary          = 'EXLookin made by ChainUp iOS group'
  s.description      = <<-DESC
  EXLookin made by ChainUp iOS groupA, and Lookin is a tiny framework for Lookin app to make colors visualization.
                       DESC
  ##
  s.homepage         = 'https://stash.dw2nn.com/scm/app/EXKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'uso' => 'appagent@xiaolian.link' }
  s.source           = { :git => 'ssh://git@stash.dw2nn.com:7999/app/EXKit.git', :tag => s.version.to_s }
  ##
  s.ios.deployment_target = '12.0'
  s.source_files = 'EXLookin/EXLookin.swift'
  ##
  s.dependency 'LookinServer/Swift', '>= 1.1.4'
  s.dependency 'EXKit/Theme', '>= 1.2.0'
  
end
