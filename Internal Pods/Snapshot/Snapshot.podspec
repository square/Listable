
Pod::Spec.new do |s|
  s.name         = 'Snapshot'
  s.version      = '1.0.0.LOCAL'
  s.summary      = 'Snapshot testing for images, text hierarchies, etc.'
  s.homepage     = 'https://github.com/kyleve/Listable'
  s.license      = { type: 'Proprietary', text: "© 2020 Square, Inc." }
  s.author       = { 'iOS Team' => 'seller-ios@squareup.com' }
  s.source       = { git: 'Not Published', tag: "podify/#{s.version}" }

  s.ios.deployment_target = '9.3'

  s.swift_versions = ['5.0']

  s.source_files = 'Sources/**/*.{swift}'

  s.framework = 'XCTest'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{swift}'

    test_spec.framework = 'XCTest'

    test_spec.requires_app_host = true
  end  
end
