Pod::Spec.new do |s|
  s.name             = 'KenBurns'
  s.version          = '0.2.8'
  s.summary          = 'A little Swift tool that performs a nice Ken Burns effect on an image'
  s.description      = 'A little Swift tool that performs a nice Ken Burns effect on an image. Powering Calm since 2016'
  s.homepage         = 'https://github.com/calmcom/KenBurns'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'calmcom' => 'support@calm.com' }
  s.source           = { :git => 'https://github.com/calmcom/KenBurns.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.source_files = 'KenBurns/Classes/**/*'
  s.frameworks = 'UIKit'
  s.dependency 'CalmParametricAnimations', '~> 1.0.1'
  s.dependency 'SDWebImage', :'~> 3.8.2'
end
