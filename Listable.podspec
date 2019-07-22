
Pod::Spec.new do |s|
  s.name         = 'Listable'
  s.version      = '1.0.0.LOCAL'
  s.summary      = 'Declarative list views for iOS apps that deploy back to iOS 9.3.'
  s.homepage     = 'https://stash.corp.squareup.com/projects/IOS/repos/register/browse/Frameworks/Listable'
  s.license      = { type: 'Proprietary', text: "© #{Date.today.year} Square, Inc." }
  s.author       = { 'iOS Team' => 'seller-ios@squareup.com' }
  s.source       = { git: 'Not Published', tag: "podify/#{s.version}" }

  s.ios.deployment_target = '9.3'

  s.swift_versions = ['5.0']

  s.source_files = 'Sources/**/*.{swift}'
  s.private_header_files = 'Sources/**/Internal/**/*.h'
  s.resource_bundle = { 'ListableResources' => ['Resources/*'] }

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{swift}'
    test_spec.resources = 'Tests/Resources/**/*'

    test_spec.framework = 'XCTest'
  end

  s.app_spec 'DemoApp' do |app_spec|
    app_spec.source_files = 'Demo/**/*.swift'
    app_spec.resource_bundle = { 'ListableDemoResources' => ['Demo/Resources/**/*'] }

    app_spec.dependency 'BlueprintUI'
    app_spec.dependency 'BlueprintUICommonControls'
  end
end
