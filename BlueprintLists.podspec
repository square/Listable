
Pod::Spec.new do |s|
  s.name         = 'BlueprintLists'
  s.version      = '0.8.0'
  s.summary      = 'Declarative list views for iOS apps that deploy back to iOS 10.0.'
  s.homepage     = 'https://github.com/kyleve/Listable'
  s.license      = { type: 'Proprietary', text: "© 2020 Square, Inc." }
  s.author       = { 'iOS Team' => 'seller-ios@squareup.com' }
  s.source       = { git: 'Not Published', tag: "podify/#{s.version}" }

  s.ios.deployment_target = '10.0'

  s.swift_versions = ['5.0']

  s.dependency 'Listable'
  s.dependency 'BlueprintUI'

  s.source_files = 'BlueprintLists/Sources/**/*.{swift}'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'BlueprintLists/Tests/**/*.{swift}'
    test_spec.resources = 'BlueprintLists/Tests/Resources/**/*'

    test_spec.framework = 'XCTest'
    
    test_spec.libraries = 'swiftsimd', 'swiftCoreGraphics', 'swiftFoundation', 'swiftUIKit'

    test_spec.requires_app_host = true
  end
end
