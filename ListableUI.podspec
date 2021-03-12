
Pod::Spec.new do |s|
  s.name         = 'ListableUI'
  s.version      = '0.18.0'
  s.summary      = 'Declarative list views for iOS apps that deploy back to iOS 11.0.'
  s.homepage     = 'https://github.com/kyleve/Listable'
  s.license      = 'Apache License, Version 2.0'
  s.author       = { 'Kyle' => 'k@squareup.com' }
  s.source       = { git: 'https://github.com/kyleve/Listable.git', tag: "#{s.version}" }

  s.ios.deployment_target = '11.0'

  s.swift_versions = ['5.0']

  s.source_files = 'ListableUI/Sources/**/*.{swift,h,m}'

  s.weak_framework = 'SwiftUI'

  unless ENV['LISTABLE_PUBLISHING']

    # These tests can only be run locally, because they depend on local pods.

    s.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'ListableUI/Tests/**/*.{swift}'
      test_spec.ios.resource_bundle = { 'ListableUITestsResources' => 'ListableUI/Tests/Resources/**/*.*' }

      test_spec.framework = 'XCTest'

      test_spec.requires_app_host = true

      test_spec.dependency 'EnglishDictionary'
      test_spec.dependency 'Snapshot'
    end
  end
end
