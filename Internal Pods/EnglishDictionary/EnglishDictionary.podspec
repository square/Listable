
Pod::Spec.new do |s|
  s.name         = 'EnglishDictionary'
  s.version      = '1.0.0.LOCAL'
  s.summary      = 'English Dictionary class for testing.'
  s.homepage     = 'https://github.com/kyleve/Listable'
  s.license      = { type: 'Proprietary', text: "© #{Date.today.year} Square, Inc." }
  s.author       = { 'iOS Team' => 'seller-ios@squareup.com' }
  s.source       = { git: 'Not Published', tag: "podify/#{s.version}" }

  s.ios.deployment_target = '9.3'

  s.swift_versions = ['5.0']

  s.source_files = 'Sources/**/*.{swift}'
  s.ios.resource_bundle = { 'EnglishDictionaryResources' => 'Resources/**/*.*' }
end
