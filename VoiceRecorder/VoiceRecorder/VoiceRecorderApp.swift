//
//  VoiceRecorderApp.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/19.
//

import SwiftUI
import GoogleMaps

@main
struct VoiceRecorderApp: App {

	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	let setKey = GMSServices.provideAPIKey(GoogleSDKConstants.apiKey)
	let persistenceController = PersistenceController.shared

	var body: some Scene {
		WindowGroup {
		//	test()
			ItemListView()
	//	PhotoCapture(writeData: WriteData(id: 0))
			.environment(\.managedObjectContext, persistenceController.container.viewContext)
		}
	}
}

class AppDelegate: NSObject, UIApplicationDelegate {

	//By default you want all your views to rotate freely
	static var orientationLock = UIInterfaceOrientationMask.all

	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return AppDelegate.orientationLock
	}
}
