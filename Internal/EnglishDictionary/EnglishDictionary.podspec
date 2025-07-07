require_relative '../../version'

Pod::Spec.new do |s|
  s.name         = 'EnglishDictionary'
  s.version      = '1.0.0.LOCAL'
  s.summary      = 'English Dictionary class for testing.'
  s.homepage     = 'https://github.com/kyleve/Listable'
  s.license      = { type: 'Proprietary', text: "© 2020 Square, Inc." }
  s.author       = { 'iOS Team' => 'seller-ios@squareup.com' }
  s.source       = { git: 'Not Published', tag: "podify/#{s.version}" }

  s.ios.deployment_target = LISTABLE_IOS_DEPLOYMENT_TARGET

  s.swift_versions = [LISTABLE_SWIFT_VERSION]

  s.source_files = 'Sources/**/*.{swift}'
  s.ios.resource_bundle = { 'EnglishDictionaryResources' => 'Resources/**/*.*' }
end
