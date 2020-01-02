
Pod::Spec.new do |s|
  s.name         = 'BlueprintLists'
  s.version      = '0.1.1'
  s.summary      = 'Declarative list views for iOS apps that deploy back to iOS 9.3.'
  s.homepage     = 'https://github.com/kyleve/Listable'
  s.license      = { type: 'Proprietary', text: "© 2020 Square, Inc." }
  s.author       = { 'iOS Team' => 'seller-ios@squareup.com' }
  s.source       = { git: 'Not Published', tag: "podify/#{s.version}" }

  s.ios.deployment_target = '9.3'

  s.swift_versions = ['5.0']

  s.dependency 'Listable'
  s.dependency 'BlueprintUI'

  s.source_files = 'BlueprintLists/Sources/**/*.{swift}'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'BlueprintLists/Tests/**/*.{swift}'
    test_spec.resources = 'BlueprintLists/Tests/Resources/**/*'

    test_spec.framework = 'XCTest'

    test_spec.requires_app_host = true
  end
end
