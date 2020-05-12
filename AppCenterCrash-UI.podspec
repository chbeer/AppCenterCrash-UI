Pod::Spec.new do |s|
  s.name             = 'AppCenterCrash-UI'
  s.version          = '0.1.2'
  s.summary          = 'A UI for reporting crashes adding a comment.'

  s.description      = <<-DESC
This framework provides a UI for the user to add some more info to a crash that happened.
                       DESC

  s.homepage         = 'https://github.com/chbeer/AppCenterCrash-UI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Christian Beer' => 'christian.beer@chbeer.de' }
  s.source           = { :git => 'https://github.com/chbeer/AppCenterCrash-UI.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/christian_beer'

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  
  s.static_framework = true
  s.swift_version = '4.0'

  s.ios.source_files   = 'AppCenterCrash-UI/*.{h,m,swift}','AppCenterCrash-UI/iOS/*'
  s.osx.source_files   = 'AppCenterCrash-UI/*.{h,m,swift}','AppCenterCrash-UI/macOS/*'
  
  s.ios.resource = 'AppCenterCrash-UI/Assets/*','AppCenterCrash-UI/iOS/Assets/*'
  s.osx.resource = 'AppCenterCrash-UI/Assets/*','AppCenterCrash-UI/macOS/Assets/*'

  s.dependency 'AppCenter/Crashes'
end
