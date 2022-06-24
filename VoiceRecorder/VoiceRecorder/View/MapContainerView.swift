//
//  MapContainerView.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/25.
//


import SwiftUI
import GoogleMaps

struct MapContainerView: View {

	@StateObject var markerModel:GMSMarkerModel
//	@State var zoomInCenter: Bool = false
	@State var isDidTap:Bool = false
	@State var isMarkerInfo = false
	@State var zoomLevel:Float = 12

	var body: some View {


		GeometryReader { geometry in

			ZStack {


			//	let diameter = zoomInCenter ? geometry.size.width : (geometry.size.height * 2)

				GoogleMapControllerBridge( markers: $markerModel.markers,
										   selectedMarker: $markerModel.currentMarker,
										   isDidTap: $isDidTap,
											zoomLevel:self.zoomLevel
										   /*
										   onAnimationEnded: { zoomInCenter = true },
										   mapViewWillMove: { (isGesture) in
												guard isGesture else { return }
												zoomInCenter = false
											}
											*/
											)
				.onAppear{
					self.zoomLevel = markerModel.markers.isEmpty ? 17 : 12
				}
/*
				.clipShape(
						Circle()
						.size(width: diameter, height: diameter)
						.offset( CGPoint( x: (geometry.size.width - diameter) / 2,
										  y: (geometry.size.height - diameter) / 2 ) )
				)
				.animation(.default, value: 10)
*/

				if isDidTap {

					if let marker = markerModel.currentMarker,  let userData = marker.userData as? GMSMarkerUserData  {

						VStack{

							Spacer()

							RoundedRectangle(cornerRadius: 10)
							.stroke(Color.white.opacity(0.8), lineWidth: 2)
							.frame(width: 120, height: 120)
							.foregroundColor(.secondary)
							.background{
								ImageView(url:documentPath.appendingPathComponent(userData.snapshotFileName))
							}
							.onTapGesture(perform: {
								isDidTap.toggle()
							})
							.previewContextMenu(
								preview: ImageView(url:documentPath.appendingPathComponent(userData.snapshotFileName)),
								destination: DetailItemView(writetime: userData.id)
											 .navigationBarBackButtonHidden(true)
											 .navigationBarHidden(true),
								presentAsSheet: true
							){
								PreviewContextAction(title: "Marker Information", systemImage: "doc.plaintext") {
									isMarkerInfo.toggle()
								}

								PreviewContextAction(title: "Close", systemImage: "xmark.circle", attributes: .destructive) {
									isDidTap.toggle()
								}
							}
						}
						.padding(.bottom, 20)

					}

				}


			}
			.sheet(isPresented: $isMarkerInfo,onDismiss: initSelectedMarker){
				if let marker = markerModel.currentMarker,  let userData = marker.userData as? GMSMarkerUserData {
					NavigationView {
						NavigationLink{
							 DetailItemView(writetime: userData.id )
							 .navigationBarBackButtonHidden(true)
							 .navigationBarHidden(true)
						}label: {
							MarkerInfoView(writetime: userData.id )
						}
					}
				}else {
					MarkerInfoView(writetime: 0, marker: markerModel.currentMarker)
				}
			}

			.statusBar(hidden: false)
		}
	}
}


extension MapContainerView {

	func initSelectedMarker () {

	}

}

struct MapContainerView_Previews: PreviewProvider {

	@StateObject static var markerModel = GMSMarkerModel()

	static var previews: some View {
		MapContainerView(markerModel: markerModel)
	}
}

