require_relative 'version'

Pod::Spec.new do |s|
  s.name         = 'BlueprintUILists'
  s.version      = LISTABLE_VERSION
  s.summary      = 'Declarative list views for iOS apps that deploy back to iOS 14.0.'
  s.homepage     = 'https://github.com/kyleve/Listable'
  s.license      = 'Apache License, Version 2.0'
  s.author       = { 'Kyle' => 'k@squareup.com' }
  s.source       = { git: 'https://github.com/kyleve/Listable.git', tag: "#{s.version}" }

  s.ios.deployment_target = LISTABLE_IOS_DEPLOYMENT_TARGET

  s.swift_versions = [LISTABLE_SWIFT_VERSION]

  s.dependency 'ListableUI'
  s.dependency 'BlueprintUI'

  s.source_files = 'BlueprintUILists/Sources/**/*.{swift}'

  unless ENV['LISTABLE_PUBLISHING']

   # These tests can only be run locally, because they depend on local pods.

    s.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'BlueprintUILists/Tests/**/*.{swift}'
      test_spec.ios.resource_bundle = { 'BlueprintUIListsResources' => 'BlueprintUILists/Tests/Resources/**/*.*' }

      test_spec.dependency 'BlueprintUICommonControls'

      test_spec.framework = 'XCTest'

      test_spec.libraries = 'swiftsimd', 'swiftCoreGraphics', 'swiftFoundation', 'swiftUIKit'

      test_spec.requires_app_host = true
    end
  end
end
