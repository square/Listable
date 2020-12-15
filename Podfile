source 'https://cdn.cocoapods.org/'

platform :ios, '11.0'

project 'Demo/Demo.xcodeproj'
workspace 'Demo/Demo.xcworkspace'

use_frameworks!

target 'Demo' do
	# Local Pods
	pod 'ListableUI', :path => 'ListableUI.podspec', :testspecs => ['Tests']
	pod 'BlueprintUILists', :path => 'BlueprintUILists.podspec', :testspecs => ['Tests']

	# External Pods
	pod 'BlueprintUI'
	pod 'BlueprintUICommonControls'

	# Internal Pods
	pod 'EnglishDictionary', :path => 'Internal Pods/EnglishDictionary/EnglishDictionary.podspec'
end
