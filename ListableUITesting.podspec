require_relative 'version'

Pod::Spec.new do |s|
  s.name         = 'ListableUITesting'
  s.version      = '1.0.0.LOCAL'
  s.summary      = 'Testing library for Listable.'
  s.homepage     = 'https://github.com/kyleve/Listable'
  s.license      = 'Apache License, Version 2.0'
  s.author       = { 'Kyle' => 'k@squareup.com' }
  s.source       = { git: 'https://github.com/kyleve/Listable.git', tag: "#{s.version}" }

  s.ios.deployment_target = '12.0'

  s.swift_versions = ['5.4']

  s.source_files = 'ListableUITesting/Sources/**/*.{swift,h,m}'
  
  s.framework = 'XCTest'
  
  s.dependency 'ListableUI'

  unless ENV['LISTABLE_PUBLISHING']

    # These tests can only be run locally, because they depend on local pods.

    s.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'ListableUITesting/Tests/**/*.{swift}'
      test_spec.ios.resource_bundle = { 'ListableUITestingTestsResources' => 'ListableUITesting/Tests/Resources/**/*.*' }

      test_spec.framework = 'XCTest'

      test_spec.requires_app_host = true
    end
  end
end
