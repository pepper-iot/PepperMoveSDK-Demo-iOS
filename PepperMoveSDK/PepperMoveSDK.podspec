Pod::Spec.new do |s|
  s.name = "PepperMoveSDK"
  s.version = "2.0.2"
  s.summary = "iOS library for realtime video streaming from wifi cameras"
  s.license = "Proprietary"
  s.authors = {"Pepper"=>"dev@pepper.me"}
  s.homepage = "https://pepper.me"
  s.description = "iOS library for realtime video streaming from wifi cameras"
  s.frameworks = ["UIKit", "AVFoundation"]
  s.requires_arc = true
  s.source = { :path => '.' }

  s.ios.deployment_target    = '10.0'
  s.ios.vendored_framework   = 'ios/PepperMoveSDK.framework'
  s.dependency 'PromisesObjC', '~> 1.2'
  s.dependency 'GoogleWebRTC', '~> 1.1'
  s.dependency 'SocketRocket', '~> 0.5'
end
