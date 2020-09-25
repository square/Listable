
Pod::Spec.new do |s|
  s.name         = 'BlueprintUILists'
  s.version      = '0.9.0'
  s.summary      = 'Declarative list views for iOS apps that deploy back to iOS 11.0.'
  s.homepage     = 'https://github.com/kyleve/Listable'
  s.license      = { type: 'Proprietary', text: "© 2020 Square, Inc." }
  s.author       = { 'iOS Team' => 'seller-ios@squareup.com' }
  s.source       = { git: 'Not Published', tag: "podify/#{s.version}" }

  s.ios.deployment_target = '11.0'

  s.swift_versions = ['5.0']

  s.dependency 'ListableUI'
  s.dependency 'BlueprintUI'

  s.source_files = 'BlueprintUILists/Sources/**/*.{swift}'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'BlueprintUILists/Tests/**/*.{swift}'
    test_spec.ios.resource_bundle = { 'BlueprintUIListsResources' => 'BlueprintUILists/Tests/Resources/**/*.*' }

    test_spec.framework = 'XCTest'
    
    test_spec.libraries = 'swiftsimd', 'swiftCoreGraphics', 'swiftFoundation', 'swiftUIKit'

    test_spec.requires_app_host = true
  end
end
