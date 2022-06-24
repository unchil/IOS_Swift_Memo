//
//  test.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/05/30.
//

import SwiftUI
import AVFoundation

struct test: View {

@State var orientation:UIDeviceOrientation = .portrait



	let prevLayer = AVCaptureVideoPreviewLayer()
	let model = Camera()

    var body: some View {

		VStack{
			Text("Wonderful, World!")
			.previewContextMenu(
				preview: Text("Preview"),
				destination: Text("Beautiful World"),
				presentAsSheet: true
			) {
				PreviewContextAction(title: "Only Title")
				PreviewContextAction(title: "Title and action") {
					// do something
				}
				PreviewContextAction(title: "Action with image", systemImage: "plus") {
					// do something
				}
				PreviewContextAction(title: "Desctructive action", attributes: .destructive) {
					// do something
				}
			}

		}

    }



}


struct test_Previews: PreviewProvider {
    static var previews: some View {
		test()
			.previewInterfaceOrientation(.portrait)
    }
}
