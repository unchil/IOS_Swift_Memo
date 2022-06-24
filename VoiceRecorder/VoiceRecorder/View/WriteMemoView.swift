//
//  WriteMemoView.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/22.
//

import SwiftUI
import GoogleMaps

struct WriteMemoView: View {

	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject var cameraService: CameraService
	@Environment(\.dismiss) var dismiss


	@StateObject var writeData = WriteData(id: Date().timeIntervalSince1970 )

	@State var selectedType: WriteDataType = .snapshot
	@State  var expandList: Bool = false
	@State var isSave:Bool = false
	@State  var isPrefrences = false
	@State var isTag = false
	@State var isCamera:Bool = false
	@State var isOpenDrawMenu = false
	@State  var isDraw = false
	@State var isSnapshot = false
	@State var isEraser = false
	@State  var isRecord = false
	@State var fileURL:URL? = nil
	@State var note:String = "Test Note"
	@State private var selectedMapType: MapType = .normal

	var path = GMSMutablePath()
	var speechRecognizer = SpeechRecognizer()
	var locationCtl = LocationController()

	@StateObject var markerModel = GMSMarkerModel()
	@StateObject var weatherModel = WeatherModel()


///	let safeAreaHeight:CGFloat = 0
///	let snapshotHeight =  UIScreen.main.bounds.height + 240
///	let snapshotWidth = UIScreen.main.bounds.width
///	let scrollViewHeight: CGFloat = 40
///	@State var yDragTranslation: CGFloat = 0
///	@State var xDragTranslation: CGFloat = 0

	var body: some View {
		NavigationView {
			GeometryReader { geometry in
				ZStack(alignment:.topLeading) {
//					Color.clear
					MapContainerView(markerModel: self.markerModel)

					Picker( "MapType", selection: $selectedMapType) {
						ForEach(MapType.allCases) { mapType in
							Text(mapType.rawValue.capitalized)
						}
					}
					.onChange(of: selectedMapType) { _ in
						mapTypeProcess()
					}
					.pickerStyle(.segmented)

					HStack{
						Spacer()
						Button{
							self.setCurrentMarker()
						} label: { Label("", systemImage:"location.circle.fill") }
						.scaleEffect(2)
						.padding(.trailing, 30)
					}
					.padding(.vertical, 90)

/*
					WriteContainerView(writeData: writeData, selectedType: $selectedType, expandList: $expandList)
						.background(Color.white)
						.clipShape( RoundedRectangle(cornerRadius: 6))
						.offset( x: 0, y: geometry.size.height - (expandList ? geometry.size.height - safeAreaHeight : scrollViewHeight) )
						.offset( x: 0, y: self.yDragTranslation )
						.animation( .spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0),value:self.yDragTranslation )
						.gesture( DragGesture()
							.onChanged { value in
								self.yDragTranslation = value.translation.height
							}
							.onEnded { value in
								if (value.translation.height < -100  ) {
									self.expandList = true
								} else if (value.translation.height > 100  ) {
									self.expandList = false
								}
								self.yDragTranslation = 0
							 } )
*/
				}
				.sheet(isPresented: $expandList, content: {
					WriteContainerView(writeData: writeData, selectedType: $selectedType)
				})
				.sheet(isPresented: $isTag, onDismiss: setTag) {
					ItemTagsView(items: $writeData.tags)
				}
				.sheet(isPresented: $isPrefrences, onDismiss: setPrefrences) {
					ItemPrefrencesView(items: $writeData.prefrences)
				}

				.sheet(isPresented: $isCamera, onDismiss: photoProcess){
				
					PhotoCapture(writeData: writeData)
					.navigationBarBackButtonHidden(true)
				}

				.toolbar{

					ToolbarItemGroup(placement:.navigationBarLeading){
						HStack(spacing:0){
							Button{
							//	writeData.clear()
								dismiss.callAsFunction()
							 }label: { Label("이전", systemImage: "chevron.backward")}

							 Button{
									isTag.toggle()
							}label: { Label("태그", systemImage: "tag") }

							Button{
								isPrefrences.toggle()
							}label: { Label("설정", systemImage: "gearshape") }

							Button{
								expandList.toggle()
							 }label: { Label("Data", systemImage: "tray") }

						}
					}

					ToolbarItemGroup(placement: .navigationBarTrailing) {
						HStack(spacing:0){
							Button {

							} label: { Label("DrawMenu", systemImage: "scribble") }
							.contextMenu{
								Button {
									isDraw.toggle()
								} label: { Label("draw",  systemImage: "hand.draw") }

								 Button {
									isEraser.toggle()
									eraserProcess()
								} label: { Label("eraser", systemImage: "hand.tap" ) }

								 Button {
									isSnapshot.toggle()
									snapShotProcess()
								} label: {Label("snapshot", systemImage: "camera.viewfinder" ) }
							}

							Button {
								isRecord.toggle()
								recordProcess()
							} label: { Label("Record", systemImage:  isRecord ? "waveform.and.mic" : "mic" ) }



							Button {
								isCamera.toggle()
							} label: { Label("Camera", systemImage:"camera") }

/*
							NavigationLink {
								PhotoCapture(writeData: writeData)
							//	.navigationBarHidden(true)
							} label:{ Label("Camera", systemImage:"camera") }
*/
							Button{
								isSave.toggle()
								saveMemo()
							}label: { Label("저장", systemImage: "externaldrive.badge.plus") }
						}
					}

				}
				.overlay {

					if isSave {
						ProgressView()
						.scaleEffect(1.5, anchor: .center)
					}

					if isRecord {
						Label("", systemImage: "mic")
							.foregroundColor(micColor)
							.labelStyle(.iconOnly)

						Label("", systemImage: "circle")
							.foregroundColor(micColor)
							.scaleEffect(1.5, anchor: .center)
							.labelStyle(.iconOnly)
							.shadow(radius: 6)

						ProgressView()
							.scaleEffect(3, anchor: .center)
							.progressViewStyle(CircularProgressViewStyle(tint: micColor))
					}

					if isDraw {
						Color.secondary
							.gesture(
								DragGesture()
								.onChanged({ value in

									let firstCoordinate:CLLocationCoordinate2D =
										(self.markerModel.currentMarker?.map?.projection.coordinate(for: value.startLocation))!

									path.insert(firstCoordinate, at: 0)

									let coordinate:CLLocationCoordinate2D =
										(self.markerModel.currentMarker?.map?.projection.coordinate(for: value.location))!

									path.add(coordinate)

									drawPolylineToMap()
								})
								.onEnded({ value in
									path.removeAllCoordinates()
								})
							)
					}
				}
				.onAppear{


					self.setCurrentMarker()
					UIToolbar.appearance().backgroundColor = UIColor(toolBarBgColor)
					AudioSessionController.audioSessionSet()
					AudioSessionController.audioSessionActivate()
					writeData.tags = TagItem.makeDefaultValue()
					writeData.prefrences = MemoPrefrences.makeDefaultValue()
				}
				.onDisappear{
					AudioSessionController.audioSessionDeactivate()

				}
				.navigationBarTitle("New", displayMode: .inline)
				.statusBar(hidden: false)
			}
		}
	}
}

extension WriteMemoView {

	func setCurrentMarker(){
		if let location = self.locationCtl.cLLocationManager.location {
			self.markerModel.currentMarker = GMSMarker(position: location.coordinate)
		}
	}

	func makeDefaultSnapshot() {
		if let map = self.markerModel.currentMarker?.map {
			let snapshot = UIGraphicsImageRenderer(size: map.bounds.size).image { _ in
				map.drawHierarchy(in: map.bounds, afterScreenUpdates: true)
			}
			self.writeData.snapshots.append(ImageView( image: snapshot))
		}
	}

	func saveMemo(){

		weatherModel.setMemoWeather(context: self.viewContext, writetime: writeData.id) { weatherData in
			writeData.makeWeatherDesc(weatherInfo: weatherData)
		}

		if let location = locationCtl.cLLocationManager.location {
			writeData.setCurrentLocation(location: location)
		}

		if writeData.snapshots.isEmpty {
			makeDefaultSnapshot()
		}

		writeData.saveImageToFile()
		writeData.setPrefrences()
		writeData.toEntity_Memo(context: viewContext)

		dismiss.callAsFunction()
	}


	func eraserProcess(){
		if let map = self.markerModel.currentMarker?.map {
			if isDraw {
				isDraw.toggle()
			}
			path.removeAllCoordinates()
			map.clear()
		}
	}

	func drawPolylineToMap (){
		if let map = markerModel.currentMarker?.map {
			let polyline = GMSPolyline(path: path)
			polyline.strokeWidth = 5
			polyline.strokeColor = UIColor(Color.blue)
			polyline.geodesic = true
			polyline.map = map
		}
	}

	func mapTypeProcess(){
		var mapType: GMSMapViewType = .normal
		switch selectedMapType {
			case .normal: do { mapType = GMSMapViewType.normal}
			case .hybrid : do { mapType = GMSMapViewType.hybrid }
			case .terrain : do { mapType = GMSMapViewType.terrain }
		}
		self.markerModel.currentMarker?.map?.mapType = mapType
	}

	func snapShotProcess() {
		if let map = self.markerModel.currentMarker?.map {
			let snapshot = UIGraphicsImageRenderer(size: map.bounds.size).image { _ in
				map.drawHierarchy(in: map.bounds, afterScreenUpdates: true)
			}
			self.writeData.snapshots.append(ImageView( image: snapshot))
			selectedType = .snapshot
			expandList = true
			map.clear()
			path.removeAllCoordinates()
		}
		isSnapshot.toggle()

		if isDraw {
			isDraw.toggle()
		}
	}

	func recordProcess() {
		if isRecord {
			expandList = false
			fileURL = documentPath.appendingPathComponent("\(Date().toString(dateFormat: fileNameFormat)).\(recordingFileExe)" )
			guard let url = fileURL else { return }
			speechRecognizer.speechToText(To: $note, isRecordingToFile: true, isRecognizeFromFile: false, URL:  url, Locale: currentLocale)
		} else {
			speechRecognizer.stopSpeechToText()
			guard let url = fileURL else { return }

			if FileManager.default.fileExists(atPath: url.path) {
				let textFieldData = TextFieldData(data: note)
				writeData.recordTexts.append(textFieldData)
				self.writeData.records.append( RecordView( fileURL: url, recordText: textFieldData) )
				selectedType = .record
				expandList = true
			}
		}
	}

	func photoProcess(){
		if !writeData.photos.isEmpty {
			selectedType = .photo
			expandList = true
		}
	}

	func setTag() {

	}

	func setPrefrences() {

	}
}

struct WriteMemoView_Previews: PreviewProvider {

	static let context = PersistenceController.preview.container.viewContext

    static var previews: some View {
		WriteMemoView()
		.environment(\.managedObjectContext, context)
    }
}
