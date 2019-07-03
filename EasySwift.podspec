#
# Be sure to run `pod lib lint WMReactNative.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EasySwift'
  s.version          = '0.1.0'
  s.summary          = 'a basic functiosn collection of swift.'
  s.homepage         = 'https://github.com/ws00801526/EasySwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Fraker.XM' => '3057600441@qq.com' }
  s.source           = { :git => 'https://github.com/ws00801526/EasySwift.git', :tag => s.version.to_s }
  s.swift_versions = '5.0'
  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/**/*'
end
