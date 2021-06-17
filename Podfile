project 'Ohmicity Backend.xcodeproj/'
platform :macos, '10.15'

target 'Ohmicity Backend' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'DWARF with dSYM File'
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '11.0'
        end
    end
  end

  # Pods for Ohmicity Backend
	pod 'FirebaseCore'
	pod 'FirebaseDatabase'
	pod 'FirebaseStorage'
	pod 'FirebaseFirestoreSwift'
	pod 'FirebaseFirestore'

end
