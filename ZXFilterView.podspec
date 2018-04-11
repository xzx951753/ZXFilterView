#
# Be sure to run `pod lib lint ZXFilterView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZXFilterView'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ZXFilterView.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/xzx951753/ZXFilterView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xzx951753' => '285644797@qq.com' }
  s.source           = { :git => 'https://github.com/xzx951753/ZXFilterView.git' }


  s.ios.deployment_target = '8.0'
  s.source_files = 'ZXFilterView/Classes/**/*'
  s.public_header_files = 'ZXFilterView/Classes/**/*.h'
  s.dependency 'Masonry', '~> 1.1.0'
end
