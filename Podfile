# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ZegoExpressExample-iOS-OC' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'ZegoExpressEngine'  #, '~> 1.17.5'
  pod 'Masonry'
  pod 'SVProgressHUD'
  pod 'Bugly', '~> 2.5.5'

end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
            config.build_settings['ENABLE_BITCODE'] = 'NO'
         end
    end
  end
end
