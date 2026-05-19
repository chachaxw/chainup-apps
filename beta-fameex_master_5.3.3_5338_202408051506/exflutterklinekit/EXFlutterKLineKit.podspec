

Pod::Spec.new do |spec|

  spec.name         = "EXFlutterKLineKit"
  spec.version      = "0.0.5"
  spec.summary      = "A flutter version candle library."

  spec.description  = <<-DESC
    A flutter version of the candle library to improve development efficiency.  
                   DESC
  spec.homepage     = "https://gitee.com/BradBin"
  spec.author           = { 'bradjohn' => 'bradjohn20210401@gmail.com' }
  spec.license          = { :type => 'MIT' }
  spec.source           = {:git => 'ssh://git@stash.dw2nn.com:7999/app/exflutterklinekit.git', :tag => spec.version.to_s}
  spec.ios.deployment_target = '12.0'
  spec.static_framework = true
  spec.source_files = 'EXFlutterKLineKit/Classes/**/*'
#  spec.vendored_frameworks = 'Frameworks/*.xcframework'
  spec.vendored_frameworks = 'Frameworks/*.framework'

  spec.pod_target_xcconfig = {'VALID_ARCHS' => 'x86_64 armv7 arm64'}
  
end
