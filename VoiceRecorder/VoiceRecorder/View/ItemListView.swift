//
//  ItemListView.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/05/11.
//

import SwiftUI
import CoreLocation
import GoogleMaps
import AVFoundation

struct ItemListView: View {

	@Environment(\.managedObjectContext) private var viewContext

	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo.writetime, ascending: false)],
		animation: .default)
	private var entity_memo: FetchedResults<Entity_Memo>

	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo_File.writetime, ascending: false)],
		animation: .default)
	private var entity_memo_files: FetchedResults<Entity_Memo_File>

	@FetchRequest(
	sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo_Tag.writetime, ascending: false)],
	animation: .default)
	private var entity_memo_tags: FetchedResults<Entity_Memo_Tag>

	@FetchRequest(
	sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo_Weather.writetime, ascending: false)],
	animation: .default)
	private var memo_weather: FetchedResults<Entity_Memo_Weather>

	var locationCtl = LocationController()
	@StateObject var markerModel = GMSMarkerModel()
	@StateObject var weatherModel = WeatherModel()
	@State var memoItems: [MemoHeaderData] = []
	@State var tags:[TagItem] = TagItem.makeDefaultValue()
	@State var isSearch:Bool = false
	@State var showDelConfirmDialog = false
	@State var currentItem:Double = 0
	@State var resultSet:[Double] = []

	@State var orientation:UIDeviceOrientation = .portrait

	
	var body: some View {

		NavigationView{

			HStack(spacing:0){

				if orientation.isLandscape {
					WeatherView(model: weatherModel)
				}
				VStack {

					if !orientation.isLandscape{
						WeatherView(model: weatherModel)
					}

					List {
						ForEach(memoItems) { item in
							ItemHeaderView(writetime: item.id)
							.font(.system(size: 12, weight: .light, design: .default))
							.swipeActions(edge: .trailing, allowsFullSwipe: false) {
								Button{
									currentItem = item.id
									showDelConfirmDialog.toggle()
								} label: {
									Label("delete", systemImage: "trash.circle")
								}.tint(.red)

								Button{
									shareItem(id: item.id)
								} label: {
									Label("share", systemImage: "square.and.arrow.up")
								}.tint(.indigo)
							}



							NavigationLink{
								 DetailItemView(writetime: item.id)
								 .navigationBarBackButtonHidden(true)
								 .navigationBarHidden(true)
							}label: {
								ImageView(url:documentPath.appendingPathComponent(item.snapshotFileName))
								.aspectRatio(3/2 , contentMode: .fill)
								.previewContextMenu(
									preview: ImageView(url:documentPath.appendingPathComponent(item.snapshotFileName)),
									destination: DetailItemView(writetime: item.id)
												 .navigationBarBackButtonHidden(true)
												 .navigationBarHidden(true),
									presentAsSheet: false
								)
							}

						} //ForEach
					}//List
					.refreshable(action: {
						self.setMemoItems()
					})
					.listStyle(.plain)
				}
			} // HStack
			/*
			.onRotate( perform: { newOrientation in
				self.orientation = newOrientation
			})
			*/
			.onAppear{
		//		AppDelegate.orientationLock = .all
				self.setMemoItems()
				self.weatherModel.setListWeather(context: self.viewContext)
				self.setCurrentMarker()
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading){
					NavigationLink{
						MapContainerView(markerModel: self.markerModel)
							.edgesIgnoringSafeArea(.vertical)
							.onAppear{ self.setMarkers() }
							.onDisappear { self.markerModel.markers.removeAll() }
					}label: { Label("지도", systemImage: "map") }
				}

				ToolbarItemGroup(placement: .navigationBarTrailing) {
					HStack(spacing:0){
						Button {
							isSearch.toggle()
						}label: { Label("검색", systemImage: "magnifyingglass") }

						NavigationLink{
						WriteMemoView()
						.environment(\.managedObjectContext, viewContext)
							.navigationBarBackButtonHidden(true)
							.navigationBarHidden(true)
						}label: { Label("New", systemImage: "note.text.badge.plus") }
					}
				}

			}
			.sheet(isPresented: $isSearch,onDismiss: searchItems) {
				ItemTagsView(items: $tags)
			}
			.navigationBarTitle("GIS Memo", displayMode: .inline)
			.confirmationDialog(self.itemDelMsg, isPresented: $showDelConfirmDialog ,titleVisibility: .visible) {
				 Button("Delete Memo", role: .destructive) {
					 deleteMemo(id: self.currentItem)
				 }
			 }
			 .statusBar(hidden: false)

		 }
	}
}

extension ItemListView {
	var itemDelMsg: String { return "Are you sure you want to clear the Memo?" }
}

extension ItemListView {




	func setMemoItems(){
		self.memoItems = self.entity_memo.map { entity_Memo in
			entity_Memo.toMemoHeaderData()
		}
	}

	func setCurrentMarker(){
		if let location = self.locationCtl.cLLocationManager.location {
			self.markerModel.currentMarker = GMSMarker(position: location.coordinate)
		}
	}

	func setMarkers(){
		entity_memo.filter { row in
			row.isPin == true
		}.forEach { item in
			let headerInfo = item.toMemoHeaderData()
			let location = CLLocationCoordinate2D(latitude: headerInfo.latitude ,longitude: headerInfo.longitude )
			let marker = GMSMarker(position:location)
			marker.snippet = headerInfo.snippets
			marker.title = headerInfo.title
//			marker.userData = item.writetime
			marker.userData = GMSMarkerUserData(id: item.writetime, snapshotFileName: item.snapshotFileName!)


			self.markerModel.markers.append(marker)
		}
	}

	private func searchItems(){

		tags.forEach { item in
			if item.isSelected {
				switch item.tag {
					case .shopping : searchTag(tag: .shopping)
					case .tracking : searchTag(tag: .tracking)
					case .travel : searchTag(tag: .travel)
				}
			}
		}

		if self.resultSet.isEmpty {
			self.memoItems = []
		} else {
			self.memoItems = entity_memo.filter { entity_memo in
				self.resultSet.contains(entity_memo.writetime) == true
			}.map { Entity_Memo in
				Entity_Memo.toMemoHeaderData()
			}
		}
		self.resultSet = []
		self.tags = TagItem.makeDefaultValue()
	}

	private func searchTag(tag:Tag) {
		let _ = entity_memo_tags.filter { memo_tag in
			switch tag {
				case .travel:
					return ( memo_tag.travel == true ) ? true : false
				case .shopping:
					return ( memo_tag.shopping == true ) ? true : false
				case .tracking:
					return ( memo_tag.tracking == true ) ? true : false
			}
		}.map { Entity_Memo_Tag in
			if !self.resultSet.contains( Entity_Memo_Tag.writetime) {
				self.resultSet.append(Entity_Memo_Tag.writetime)
			}
		}
	}


	func deleteMemo(id:Double){

		if let index = memoItems.firstIndex(where: { row in
			row.id == id
		}){

			let writetime = memoItems[index].id

			if let entityMemo = entity_memo.first(where: { row in
				row.writetime == writetime
			}) {
				self.viewContext.delete(entityMemo)
			}

			entity_memo_files.filter { entity_Memo_File in
				entity_Memo_File.writetime == writetime
			}.forEach { entity_Memo_File in
				deleteFile(fileName:entity_Memo_File.fileName!)
				self.viewContext.delete(entity_Memo_File)
			}

			entity_memo_tags.filter { entity_Memo_Tag in
				entity_Memo_Tag.writetime == writetime
			}.forEach { entity_Memo_Tag in
				self.viewContext.delete(entity_Memo_Tag)
			}

			if let entityWeather = memo_weather.first(where: { row in
				row.writetime == Int64(writetime)
			}) {
				self.viewContext.delete(entityWeather)
			}

			commitTrans(context: self.viewContext)
			memoItems.remove(at: index)
		}
	}


	 func shareItem(id:Double){

		var shareObject = [Any]()

		var shareText = "\n Share Memo \n"

		if let entityMemo = entity_memo.first(where: { row in
			row.writetime == id
		}) {
			let headerInfo = entityMemo.toMemoHeaderData()
			shareText += "\n [DATE  :] \(headerInfo.title)"
			shareText += "\n [DESC  :] \(headerInfo.desc)"
			shareText += "\n [TAG   :] \(headerInfo.snippets)"
			shareText += "\n [ATTACH:]  Snapshot:\(headerInfo.snapshotCnt)  Record:\(headerInfo.recordCnt)  Photo:\(headerInfo.photoCnt)"

			shareText += "\n"

			entity_memo_files.filter { entity_Memo_File in
				entity_Memo_File.writetime == id &&
				entity_Memo_File.type == WriteDataType.record.rawValue
			}.forEach { entity_Memo_File in
				shareText += " [MEMO  :] \( entity_Memo_File.text ?? "")\n"
			}

		}

		shareObject.append(shareText)

		entity_memo_files.filter { entity_Memo_File in
			entity_Memo_File.writetime == id
		}.forEach { entity_Memo_File in
			shareObject.append(documentPath.appendingPathComponent(entity_Memo_File.fileName!))
		}

		shareObject.append(shareText)

		let viewController = UIActivityViewController(activityItems: shareObject, applicationActivities: nil)
		let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
		if let window = windowScene?.windows.first {
			window.rootViewController?.present(viewController, animated: true, completion: nil)
		}
	}

}

struct ItemListView_Previews: PreviewProvider {

    static var previews: some View {
			ItemListView()
			.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
