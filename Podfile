# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'BluIDSDK_SampleApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_modular_headers!

  # Pods for BluIDSDK_SampleApp
  project "./BluIDSDK_SampleApp.xcodeproj"
  pod "CryptoSwift", "1.4.0"
  pod 'AYPopupPickerView', "1.2"
  pod 'CocoaLumberjack/Swift', "3.7.2"
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
