//
//  CameraPreview.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/22.
//

import SwiftUI
import AVFoundation


struct CameraPreview: UIViewRepresentable {

	@Binding var orientation: AVCaptureVideoOrientation
	let session: AVCaptureSession


	func makeUIView(context: Context) -> VideoPreview {
		let view = VideoPreview()

		view.videoPreviewLayer.cornerRadius = 0
		view.videoPreviewLayer.session = self.session
		view.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
		view.videoPreviewLayer.connection?.videoOrientation = self.orientation

		return view
	}

	func updateUIView(_ uiView: VideoPreview, context: Context) {
		//uiView.videoPreviewLayer.connection?.videoOrientation = self.orientation
	}


	class VideoPreview: UIView {

		override class var layerClass: AnyClass {
			AVCaptureVideoPreviewLayer.self
		}
		var videoPreviewLayer: AVCaptureVideoPreviewLayer {
			return layer as! AVCaptureVideoPreviewLayer
		}
	}

}

struct CameraPreview_Previews: PreviewProvider {

	static var model = Camera()
	static var orientation:AVCaptureVideoOrientation = .portrait

	static var previews: some View {


		CameraPreview(orientation: .constant(orientation), session: model.session)
			.previewInterfaceOrientation(.portrait)

	}
}
