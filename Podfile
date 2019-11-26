platform :ios, '9.3'

project 'Demo/Demo.xcodeproj'
workspace 'Demo/Demo.xcworkspace'

target 'Demo' do
	# Local Pods
	pod 'Listable', :path => 'Listable.podspec', :testspecs => ['Tests']
	pod 'BlueprintLists', :path => 'BlueprintLists.podspec', :testspecs => ['Tests']

	# External Pods
	pod 'BlueprintUI'
	pod 'BlueprintUICommonControls'

	# Internal Pods
	pod 'EnglishDictionary', :path => 'Internal Pods/EnglishDictionary/EnglishDictionary.podspec'
end