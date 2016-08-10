use_frameworks!

target 'IMeditated' do
    pod 'RxSwift', :git => 'git@github.com:ReactiveX/RxSwift.git'
    pod 'RxCocoa', :git => 'git@github.com:ReactiveX/RxSwift.git'
    pod 'Result', :git => 'git@github.com:antitypical/Result.git'
end

# RxTests and RxBlocking make the most sense in the context of unit/integration tests
target 'IMeditatedTests' do
    pod 'RxSwift', :git => 'git@github.com:ReactiveX/RxSwift.git'
    pod 'RxCocoa', :git => 'git@github.com:ReactiveX/RxSwift.git'
    pod 'RxBlocking', :git => 'git@github.com:ReactiveX/RxSwift.git'
    pod 'RxTests', :git => 'git@github.com:ReactiveX/RxSwift.git'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['SWIFT_VERSION'] = "3.0"
    end
  end
end