#
# Be sure to run `pod lib lint LUX.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LUX'
    s.version          = '0.2.19'
    s.summary          = 'LUX contains everything you need to create a simple app.'
    s.swift_versions   = ['4.0', '4.1', '4.2', '5.0', '5.1', '5.2', '5.3']
    s.description      = <<-DESC
  There's a bunch of really cool stuff in this pod, all targeted at letting you build the things that are *different* about your app, not the reproducing the same things over and over. Customizable, extendable, bare bones implementations of common UX components like splash, login, creds creation, commenting, and view/edit profile screens, an app delegate implementation that sets up fabric and crashlytics for you, a simple framework for handling user sessions, a material design based controller for table views... and more coming!
                         DESC

    s.homepage         = 'https://github.com/ThryvInc/LUX'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Elliot' => '' }
  s.source           = { :git => 'https://github.com/ThryvInc/LUX.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/elliot_schrock'

  s.ios.deployment_target = '11.0'
  
  s.source_files = 'LUX/Classes/**/*.swift'
  s.resources = 'LUX/**/*.xib'
  s.dependency 'LithoUtils'
  
  s.subspec 'Base' do |sp|
    sp.source_files = 'LUX/Classes/Base/**/*.swift'
    sp.resources = 'LUX/Classes/Base/**/*.xib'
    sp.dependency 'Prelude', '~> 3.0'
    sp.dependency 'FlexDataSource'
    sp.dependency 'LithoOperators'
    sp.dependency 'FunNet/Core'
    sp.dependency 'fuikit/Core'
    sp.dependency 'Slippers'
    sp.dependency 'SDWebImage'
  end
  
  s.subspec 'Utilities' do |sp|
    sp.source_files = 'LUX/Classes/Utilities/**/*.swift'
    sp.resources = 'LUX/Classes/Utilities/**/*.xib'
    sp.dependency 'Prelude', '~> 3.0'
  end
  
  s.subspec 'Auth' do |sp|
    sp.source_files = 'LUX/Classes/Auth/**/*.swift'
    sp.resources = 'LUX/Classes/Auth/**/*.xib'
  end
  
  s.subspec 'BaseFunctional' do |sp|
    sp.source_files = 'LUX/Classes/Base/Functional/**/*.swift'
    sp.resources = 'LUX/Classes/Base/Functional/**/*.xib'
  end
  
  s.subspec 'Networking' do |sp|
    sp.source_files = 'LUX/Classes/Networking/**/*.swift'
    sp.resources = 'LUX/Classes/Networking/**/*.xib'
    sp.ios.deployment_target = '13.0'
    sp.dependency 'FunNet/Combine'
    sp.dependency 'LUX/BaseNetworking'
  end
  
  s.subspec 'BaseNetworking' do |sp|
    sp.source_files = 'LUX/Classes/Base/Networking/**/*.swift'
    sp.resources = 'LUX/Classes/Base/Networking/**/*.xib'
    
    sp.dependency 'LUX/Auth'
    sp.dependency 'FunNet/Core'
    sp.dependency 'Slippers'
  end
  
  s.subspec 'TableViews' do |sp|
    sp.source_files = 'LUX/Classes/TableViews/**/*.swift'
    sp.resources = 'LUX/Classes/TableViews/**/*.xib'
    sp.ios.deployment_target = '13.0'
    sp.dependency 'LUX/BaseTableViews'
  end
  
  s.subspec 'CollectionViews' do |sp|
    sp.source_files = 'LUX/Classes/CollectionViews/**/*.swift'
    sp.resources = 'LUX/Classes/CollectionViews/**/*.xib'
    sp.ios.deployment_target = '13.0'
    sp.dependency 'LUX/BaseCollectionViews'
  end
  
  s.subspec 'BaseTableViews' do |sp|
    sp.source_files = 'LUX/Classes/Base/TableViews/**/*.swift'
    sp.resources = 'LUX/Classes/Base/TableViews/**/*.xib'
    
    sp.dependency 'LUX/BaseFunctional'
    sp.dependency 'FlexDataSource'
  end
  
  s.subspec 'BaseCollectionViews' do |sp|
    sp.source_files = 'LUX/Classes/Base/CollectionViews/**/*.swift'
    sp.resources = 'LUX/Classes/Base/CollectionViews/**/*.xib'
    
    sp.dependency 'LUX/BaseFunctional'
    sp.dependency 'FlexDataSource'
  end
  
  s.subspec 'AppOpenFlow' do |sp|
    sp.source_files = 'LUX/Classes/AppOpenFlow/**/*.swift'
    sp.resources = 'LUX/Classes/AppOpenFlow/**/*.xib'
    sp.ios.deployment_target = '13.0'
    sp.dependency 'LUX/Auth'
    sp.dependency 'LUX/Networking'
  end
  
  s.subspec 'BaseAppOpenFlow' do |sp|
    sp.source_files = 'LUX/Classes/Base/AppOpen/**/*.swift'
    sp.resources = 'LUX/Classes/Base/AppOpen/**/*.xib'
    
    sp.dependency 'LUX/BaseFunctional'
  end
  
  s.subspec 'BaseSearch' do |sp|
    sp.source_files = 'LUX/Classes/Base/Search/**/*.swift'
    sp.resources = 'LUX/Classes/Base/Search/**/*.xib'
    
    sp.dependency 'LUX/BaseFunctional'
  end
  
  s.subspec 'Search' do |sp|
    sp.source_files = 'LUX/Classes/Search/**/*.swift'
    sp.resources = 'LUX/Classes/Search/**/*.xib'
    sp.ios.deployment_target = '13.0'
    sp.dependency 'LUX/TableViews'
    sp.dependency 'LUX/BaseSearch'
  end
  
end
