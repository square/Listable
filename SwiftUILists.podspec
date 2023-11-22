require_relative 'version'

Pod::Spec.new do |s|
  s.name         = 'SwiftUILists'
  s.version      = LISTABLE_VERSION
  s.summary      = 'Declarative list views for SwiftUI'
  s.homepage     = 'https://github.com/square/Listable'
  s.license      = 'Apache License, Version 2.0'
  s.author       = { 'UI Systems iOS' => 'ui-systems-ios@squareup.com' }
  s.source       = { git: 'https://github.com/square/Listable.git', tag: "#{s.version}" }

  s.ios.deployment_target = LISTABLE_IOS_DEPLOYMENT_TARGET

  s.swift_versions = [LISTABLE_SWIFT_VERSION]

  s.dependency 'ListableUI'
  
  s.frameworks = 'SwiftUI'

  s.source_files = 'SwiftUILists/Sources/**/*.{swift}'

  s.pod_target_xcconfig = {
    'APPLICATION_EXTENSION_API_ONLY' => 'YES',
  }

  unless ENV['LISTABLE_PUBLISHING']

   # These tests can only be run locally, because they depend on local pods.

    s.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'SwiftUILists/Tests/**/*.{swift}'
      test_spec.ios.resource_bundle = { 'SwiftUIListsResources' => 'SwiftUILists/Tests/Resources/**/*.*' }

      test_spec.frameworks = 'XCTest', 'SwiftUI'

      test_spec.libraries = 'swiftsimd', 'swiftCoreGraphics', 'swiftFoundation', 'swiftUIKit'

      test_spec.requires_app_host = true
    end
  end
end
