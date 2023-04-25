platform :ios, '14.0'

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


target 'Test Targets' do
	# XCTest-Referencing Pods
	pod 'Snapshot', :path => 'Internal Pods/Snapshot/Snapshot.podspec', :testspecs => ['Tests']
end

