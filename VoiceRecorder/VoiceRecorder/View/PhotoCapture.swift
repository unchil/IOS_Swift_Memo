//
//  PhotoCapture.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/22.
//

import SwiftUI
import AVFoundation



struct PhotoCapture: View {
	@Environment(\.dismiss) var dismiss

	@StateObject var writeData:WriteData
	@StateObject var model = Camera()
	@State var currentZoomFactor: CGFloat = 1.0
	@State var orientation:AVCaptureVideoOrientation = .portrait
	@State var degrees:Double = 0
	@State var photoIndex = 0


	var body: some View {


		NavigationView {
			GeometryReader { reader in
				ZStack(alignment: .topLeading) {
					Color.black.edgesIgnoringSafeArea(.all)

					CameraPreview(orientation: $orientation, session: model.session)
						.onRotate( perform: { newOrientation in
							self.setOrientation(orientation:newOrientation)
						})


						.gesture(
							DragGesture().onChanged({ value in
								//  Get the percentage of vertical screen space covered by drag
								let percentage: CGFloat = -(value.translation.height / reader.size.height)
								//  Calculate new zoom factor
								let calc = currentZoomFactor + percentage
								//  Limit zoom factor to a maximum of 5x and a minimum of 1x
								let zoomFactor: CGFloat = min(max(calc, 1), 5)
								//  Store the newly calculated zoom factor
								currentZoomFactor = zoomFactor
								//  Sets the zoom factor to the capture device session
								model.zoom(with: zoomFactor)
							})
						)
						.alert(model.alertError.title, isPresented: $model.showAlertError) {
							Button(model.alertError.primaryButtonTitle , role: .destructive) {
								model.alertError.primaryAction?()
							}
						} message: { Text(model.alertError.message) }
						.edgesIgnoringSafeArea(.all)



					VStack {
/*
						HStack{
							Button{
								dismiss.callAsFunction()
							 }label: { Label("이전", systemImage: "chevron.backward")}
							.rotationEffect(.degrees(self.degrees))
							.animation(.default, value: self.degrees)
							.scaleEffect(2)
							.tint(.white)

							Spacer()
						}.padding()
*/
						Button {
							model.switchFlash()
						} label: {
							Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
						}
						.rotationEffect(.degrees(self.degrees))
						.animation(.default, value: self.degrees)
							.accentColor(model.isFlashOn ? .orange : .white)
							.scaleEffect(1.5)


						Spacer()

						HStack(alignment:.center) {

							if model.getPhotos().isEmpty {
								RoundedRectangle(cornerRadius: 10)
								.stroke(Color.white.opacity(0.8), lineWidth: 2)
								.frame(width: 90, height: 90)
								.foregroundColor(.secondary)
							} else {
								NavigationLink {
									ImagePageView(selected: $photoIndex, controllers: model.getPhotos(), displayMode: .full)
									.edgesIgnoringSafeArea(.all)
								} label: {
									RoundedRectangle(cornerRadius: 10)
									.stroke(Color.white.opacity(0.8), lineWidth: 2)
									.frame(width: 90, height: 90)
									.foregroundColor(.secondary)
									.overlay {
									//	model.getPhoto()
										Image(uiImage: model.photo.image)
										.resizable( resizingMode: .stretch)
										.cornerRadius(10)
										.rotationEffect(.degrees(self.degrees))
										.animation(.default, value: self.degrees)
									}
								}
							}

							Spacer()

							Button(action: {
								model.capturePhoto()
							}, label: {
								Circle()
								.foregroundColor(.white)
								.frame(width: 80, height: 80, alignment: .center)
								.overlay(
									Circle()
									.stroke(Color.black.opacity(0.8), lineWidth: 2)
									.frame(width: 65, height: 65, alignment: .center)
								)
							})


							Spacer()

							Button{
								model.flipCamera()
							} label: { Label("Camera Rotate", systemImage: "camera.rotate") }
							.rotationEffect(.degrees(self.degrees))
							.animation(.default, value: self.degrees)
							.scaleEffect(2)
							.tint(.white)

							Spacer()

							Button {

								model.getPhotos().forEach { imageView in
									writeData.photos.append(imageView)
								}
								dismiss.callAsFunction()
								
								/*
								let imageViewArray = model.getPhotos()
								for (index, imageView) in imageViewArray.enumerated() {
									writeData.photos.append(imageView)
									if index == ( imageViewArray.count - 1) {
										dismiss.callAsFunction()
									}
								}
								*/
							} label: { Label("Save", systemImage: "tray.and.arrow.down")}
							.rotationEffect(.degrees(self.degrees))
							.animation(.default, value: self.degrees)
							.scaleEffect(2)
							.tint(.white)
						}
						.padding()
					}
				}
				.labelStyle(.iconOnly)
				.navigationBarTitleDisplayMode(.inline)
			}
		}
		.onAppear {
			// Forcing the rotation to portrait
			UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
			// And making sure it stays that way
			AppDelegate.orientationLock = .portrait

		}
		.onDisappear {
			AppDelegate.orientationLock = .all
		}



	} // body
}

extension PhotoCapture {
	func setOrientation(orientation: UIDeviceOrientation) {

		switch orientation {
			case .portrait :
				self.orientation = .portrait
				self.degrees = 0
				model.setOrientation(orientatiion: AVCaptureVideoOrientation.portrait)
			case .portraitUpsideDown:
				self.orientation = .portraitUpsideDown
				self.degrees = 180
				model.setOrientation(orientatiion: AVCaptureVideoOrientation.portraitUpsideDown)
			case .landscapeLeft:
				self.orientation = .landscapeLeft
				self.degrees = 90
				model.setOrientation(orientatiion: AVCaptureVideoOrientation.landscapeRight)
			case .landscapeRight:
				self.orientation = .landscapeRight
				self.degrees = -90
				model.setOrientation(orientatiion: AVCaptureVideoOrientation.landscapeLeft)
			case .unknown:
				self.orientation = .portrait
				self.degrees = 0
				model.setOrientation(orientatiion: AVCaptureVideoOrientation.portrait)
			case .faceUp:
				self.orientation = .portrait
				self.degrees = 0
				model.setOrientation(orientatiion: AVCaptureVideoOrientation.portrait)
			case .faceDown:
				self.orientation = .portrait
				self.degrees = 0
				model.setOrientation(orientatiion: AVCaptureVideoOrientation.portrait)
			@unknown default:
				self.orientation = .portrait
				self.degrees = 0
				model.setOrientation(orientatiion: AVCaptureVideoOrientation.portrait)
		}
	}

}

struct PhotoCapture_Previews: PreviewProvider {
	static var writeData:WriteData = WriteData(id: 0)
	static var  model = Camera()
	static var previews: some View {
		PhotoCapture(writeData: writeData)
	}
}
