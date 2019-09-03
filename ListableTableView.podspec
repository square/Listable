
Pod::Spec.new do |s|
  s.name         = 'ListableTableView'
  s.version      = '1.0.0.LOCAL'
  s.summary      = 'Declarative list views for iOS apps that deploy back to iOS 9.3.'
  s.homepage     = 'https://github.com/kyleve/Listable'
  s.license      = { type: 'Proprietary', text: "© #{Date.today.year} Square, Inc." }
  s.author       = { 'iOS Team' => 'seller-ios@squareup.com' }
  s.source       = { git: 'Not Published', tag: "podify/#{s.version}" }

  s.ios.deployment_target = '9.3'

  s.swift_versions = ['5.0']

  s.dependency 'ListableCore'

  s.source_files = 'ListableTableView/Sources/**/*.{swift}'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'ListableTableView/Tests/**/*.{swift}'
    test_spec.resources = 'ListableTableView/Tests/Resources/**/*'

    test_spec.framework = 'XCTest'
  end
end
