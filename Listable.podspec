
Pod::Spec.new do |s|
  s.name         = 'Listable'
  s.version      = '0.6.0'
  s.summary      = 'Declarative list views for iOS apps that deploy back to iOS 10.0.'
  s.homepage     = 'https://github.com/kyleve/Listable'
  s.license      = { type: 'Proprietary', text: "© 2020 Square, Inc." }
  s.author       = { 'iOS Team' => 'seller-ios@squareup.com' }
  s.source       = { git: 'Not Published', tag: "podify/#{s.version}" }

  s.ios.deployment_target = '10.0'

  s.swift_versions = ['5.0']

  s.source_files = 'Listable/Sources/**/*.{swift}'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Listable/Tests/**/*.{swift}'
    test_spec.ios.resource_bundle = { 'ListableTestsResources' => 'Listable/Tests/Resources/**/*.*' }

    test_spec.framework = 'XCTest'

    test_spec.requires_app_host = true

    test_spec.dependency 'EnglishDictionary'
    test_spec.dependency 'Snapshot'
  end
end
