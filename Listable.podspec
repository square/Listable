# frozen_string_literal: true

require 'sq/ios_default_xcconfig'

Pod::Spec.new do |s|
  s.name         = 'Listable'
  s.version      = '1.0.0.LOCAL'
  s.summary      = 'See the README.'
  s.homepage     = 'https://stash.corp.squareup.com/projects/IOS/repos/register/browse/Frameworks/Listable'
  s.license      = { type: 'Proprietary', text: "© #{Date.today.year} Square, Inc." }
  s.author       = { 'iOS Team' => 'seller-ios@squareup.com' }
  s.source       = { git: 'Not Published', tag: "podify/#{s.version}" }

  s.ios.deployment_target = '9.3'
  s.pod_target_xcconfig = DefaultSquareXCConfig('9.4')

  s.swift_versions = ['5.0']

  s.source_files = 'Sources/**/*.{swift}'
  s.private_header_files = 'Sources/**/Internal/**/*.h'
  s.resource_bundle = { 'ListableResources' => ['Resources/*'] }

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{swift}'

    test_spec.resources = 'Tests/Resources/**/*'

    test_spec.framework = 'XCTest'
    # TODO: Add the appropriate test dependencies. This dependency below is listed as an example.
    # test_spec.dependency 'SquareCoreTesting', '~> 1.0'
  end

  s.app_spec 'DemoApp' do |app_spec|
    app_spec.source_files = 'Demo/**/*.swift'
    app_spec.resource_bundle = { 'ListableDemoResources' => ['Demo/Resources/**/*'] }

    app_spec.dependency 'Blueprint'
    app_spec.dependency 'BlueprintLayout'
    app_spec.dependency 'BlueprintCommonControls'
  end
end
