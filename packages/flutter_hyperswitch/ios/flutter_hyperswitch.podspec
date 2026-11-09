#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_hyperswitch.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_hyperswitch'
  s.version          = '0.0.1'
  s.summary          = 'Hyperswitch payments SDK for Flutter.'
  s.description      = <<-DESC
Flutter Hyperswitch: Simplifying payment integration for Flutter apps with seamless API interactions and customizable UI.
                       DESC
  s.homepage         = 'https://hyperswitch.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Juspay Technologies' => 'hyperswitch@juspay.in' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'hyperswitch-sdk-ios/sentry', '= 0.4.4.patch4'
  s.platform = :ios, '15.1'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
