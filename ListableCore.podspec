
Pod::Spec.new do |s|
  s.name         = 'ListableCore'
  s.version      = '0.1.1'
  s.summary      = 'Declarative list views for iOS apps that deploy back to iOS 9.3.'
  s.homepage     = 'https://github.com/kyleve/Listable'
  s.license      = { type: 'Proprietary', text: "© #{Date.today.year} Square, Inc." }
  s.author       = { 'iOS Team' => 'seller-ios@squareup.com' }
  s.source       = { git: 'Not Published', tag: "podify/#{s.version}" }

  s.ios.deployment_target = '9.3'

  s.swift_versions = ['5.0']

  s.source_files = 'ListableCore/Sources/**/*.{swift}'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'ListableCore/Tests/**/*.{swift}'
    test_spec.resources = 'ListableCore/Tests/Resources/**/*'

    test_spec.framework = 'XCTest'
  end
end
