//
//  DetailItemView.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/05/13.
//

import SwiftUI
import CoreData
import LocalAuthentication


struct DetailItemView: View {

	var writetime:Double

	@Environment(\.managedObjectContext) private var viewContext
	@Environment(\.dismiss) var dismiss

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

	@StateObject var weatherModel = WeatherModel()
	@StateObject var detailModel = DetailData()

    @State  var isPrefrences = false
    @State var isTag: Bool = false
	@State var snapshotIndex:Int = 0
	@State var recordIndex:Int = 0
	@State var photoIndex:Int = 0
	@State var tags:[TagItem] = []
	@State var prefrences:[MemoPrefrences] = MemoPrefrences.makeDefaultValue()
	@State var showDelConfirmDialog = false
	@State var showAlertDialog = false
	@State var delItemType:WriteDataType = .snapshot
	@State var isLock = true

	var isSecret:Bool {
		if let result = entity_memo.first(where: { row in
			row.writetime == self.writetime })
		{ return result.isSecret } else { return false }
	}

//	@State private var orientation:UIDeviceOrientation = .portrait

	var body: some View {

		ZStack{
		
			if isLock {

				LockView()

			} else {

				NavigationView {

					HStack{

		//				if orientation.isLandscape {
		//					WeatherView(model: weatherModel)
		//				}
						VStack(spacing:0){
						/*
							if orientation.isLandscape {
								Divider()
								DetailItemHeaderView(detailModel: detailModel)
								.font(.subheadline)
								.padding()
								Divider()
							}
						*/
							ScrollView {

							//	if !orientation.isLandscape {
									WeatherView(model: weatherModel)
									Divider()
									DetailItemHeaderView(detailModel: detailModel)
									.font(.subheadline)
									.padding()
									Divider()
						//		}

								GroupBox(label:Label(WriteDataType.snapshot.name, systemImage: WriteDataType.snapshot.systemImage)){
									if detailModel.snapshots.isEmpty { EmptyView().aspectRatio(3 / 2, contentMode: .fit) } else {

										NavigationLink {
											ImagePageView(selected:$snapshotIndex, controllers: detailModel.snapshots, displayMode: .full)
										//	.navigationBarHidden(true)
											.edgesIgnoringSafeArea(.all)
										} label: {
											ImagePageView(selected:$snapshotIndex, controllers: detailModel.snapshots, displayMode: .frame)
											.aspectRatio(3 / 2, contentMode: .fit)
											.onAppear{
												snapshotIndex = detailModel.snapshots.count - 1
											}
										}
									}
								}.groupBoxStyle(MemoItemGroupBoxStyle(deleteAction: {
									delItemType = .snapshot
									if ( detailModel.snapshots.count > 1 && snapshotIndex != 0 ){
										showDelConfirmDialog.toggle()
									}else { showAlertDialog.toggle() }
								}))

								Divider()

								GroupBox(label: Label(WriteDataType.record.name, systemImage: WriteDataType.record.systemImage)){
									if detailModel.records.isEmpty { EmptyView().aspectRatio(3 / 2, contentMode: .fit) } else {
										RecordPageView(selected:$recordIndex, controllers: detailModel.records)
										.aspectRatio(3 / 2, contentMode: .fit)
										.onAppear{
											recordIndex = detailModel.records.count - 1
										}
									}
								}.groupBoxStyle(MemoItemGroupBoxStyle(deleteAction: {
									if !detailModel.records.isEmpty {
										delItemType = .record
										showDelConfirmDialog.toggle()
									}
								}))

								Divider()

								GroupBox(label:Label(WriteDataType.photo.name, systemImage: WriteDataType.photo.systemImage)){
									if detailModel.photos.isEmpty { EmptyView().aspectRatio(3 / 2, contentMode: .fit) } else {
										NavigationLink {
											ImagePageView(selected:$photoIndex, controllers: detailModel.photos, displayMode: .full)
									//		.navigationBarHidden(true)
											.edgesIgnoringSafeArea(.all)
										} label: {
											ImagePageView(selected:$photoIndex, controllers: detailModel.photos, displayMode: .frame)
											.aspectRatio(3 / 2, contentMode: .fit)
											.onAppear{
												photoIndex = detailModel.photos.count - 1
											}

										}
									}
								}.groupBoxStyle(MemoItemGroupBoxStyle(deleteAction: {
									if !detailModel.photos.isEmpty {
										delItemType = .photo
										showDelConfirmDialog.toggle()
									}
								}))

								Divider()
							}
						}
					}
					.confirmationDialog(delItemType.deleteMessage, isPresented: $showDelConfirmDialog ,titleVisibility: .visible) {
						Button(delItemType.deleteTitle, role: .destructive) {
							deleteItem()
						}
					}
					.alert(delItemType.deleteTitle, isPresented: $showAlertDialog, actions: {
						Button("Dismiss", role: .cancel) {} }, message: {  Text(delItemType.alertMessage) })
					.background(Color.clear)
					.toolbar {
						ToolbarItem(placement: .navigationBarLeading){
							Button {
								updateRecordText()
								dismiss.callAsFunction()
							} label: { Label("이전", systemImage: "chevron.backward") }
						}

						ToolbarItemGroup(placement: .navigationBarTrailing) {
							Button{
								isTag.toggle()
							}label: { Label("태그", systemImage: "tag") }

							Button{
								isPrefrences.toggle()
							}label: { Label("설정", systemImage: "gearshape") }
						}
					}
					.sheet(isPresented: $isTag, onDismiss: updateTag) {
						ItemTagsView(items: $tags)
					}
					.sheet(isPresented: $isPrefrences, onDismiss: updatePrefrences) {
						ItemPrefrencesView(items: $prefrences)
					}
					.onAppear{
						refreshWeatherData()
						refreshMemoData()
					}
					.navigationBarTitle("Detail Memo", displayMode: .inline)

				}

			} // if else

		} // ZStack
		.onAppear {
			AppDelegate.orientationLock = .all
			if isSecret {
				checkAuthentication()
			} else {
				isLock = false
			}
		}
/*
		.onRotate( perform: { newOrientation in
			self.orientation = newOrientation
		})
*/
		.statusBar(hidden: false)


	} //body
}

extension DetailItemView {

	func checkAuthentication() {
		let authContext = LAContext()
		authContext.localizedCancelTitle = "Cancel"
		var error: NSError?
		if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: authContext.biometryType.description) { success, err in
				DispatchQueue.main.async {
					if success {
						self.isLock = false
					} else {
						self.isLock = true
					}
				}
			}
		} else {
			print(#function,  error?.localizedDescription ?? "")
			self.isLock = true
		}
	}

	func deleteItem(){
		switch self.delItemType {
			case .snapshot:
				deleteSnapshot()
			case .record:
				deleteRecord()
			case .photo:
				deletePhoto()
		}
	}


	func deleteSnapshot(){
		let fileName = detailModel.snapshots[snapshotIndex].url?.lastPathComponent
		if let entityMemo = entity_memo.first(where: { row in
			row.writetime == self.writetime}) {

			if let entityMemoFile = entity_memo_files.first(where: { row in
				row.writetime == self.writetime &&
				row.fileName == fileName
			}) {
				self.viewContext.delete(entityMemoFile)
			}

			entityMemo.snapshotCnt = entityMemo.snapshotCnt - 1
			commitTrans(context: self.viewContext)

			refreshSnapshotData()
			refreshHeaderData()

			deleteFile(fileName: fileName!)
		}
	}


	func deleteRecord() {
		updateRecordText()
		let fileName = detailModel.records[recordIndex].fileURL.lastPathComponent
		if let entityMemo = entity_memo.first(where: { row in
			row.writetime == self.writetime
		}) {
			if let entityMemoFile = entity_memo_files.first(where: { row in
				row.writetime == self.writetime &&
				row.fileName == fileName
			}) {
				self.viewContext.delete(entityMemoFile)
			}
			entityMemo.recordCnt = entityMemo.recordCnt - 1
			commitTrans(context: self.viewContext)
			refreshRecordData()
			deleteFile(fileName: fileName)
			refreshHeaderData()
		}
	}

	func deletePhoto() {
		let fileName = detailModel.photos[photoIndex].url?.lastPathComponent
		if let entityMemo = entity_memo.first(where: { row in
			row.writetime == self.writetime
		}) {
			if let entityMemoFile = entity_memo_files.first(where: { row in
				row.writetime == self.writetime &&
				row.fileName == fileName
			}) {
				self.viewContext.delete(entityMemoFile)
			}
			entityMemo.photoCnt = entityMemo.photoCnt - 1
			commitTrans(context: self.viewContext)
			refreshPhotoData()
			deleteFile(fileName: fileName!)
			refreshHeaderData()
		}
	}

	func refreshWeatherData() {
		if let result = memo_weather.first(where: { row in
			row.writetime == Int64(self.writetime) }) {
			weatherModel.weatherData = result.toWeatherData
		}
	}

	func refreshRecordData(){
		detailModel.recordTexts.removeAll()
		detailModel.records.removeAll()

		self.entity_memo_files.filter { row in
			row.writetime == self.writetime &&
			row.type == WriteDataType.record.rawValue
		}.forEach { item in
			let fieldData = TextFieldData(data: item.text ?? "")
			detailModel.recordTexts.append(fieldData)
			detailModel.records.append(
				RecordView(	fileURL: documentPath.appendingPathComponent(item.fileName!),
							recordText: fieldData))
		}
	}


	func refreshSnapshotData(){
		detailModel.snapshots.removeAll()
		self.entity_memo_files.filter { row in
			row.writetime == self.writetime  &&
			row.type == WriteDataType.snapshot.rawValue
		}.forEach { item in
			detailModel.snapshots.append(
				ImageView( url: documentPath.appendingPathComponent(item.fileName!) ) )
		}
	}

	func refreshPhotoData(){
		detailModel.photos.removeAll()
		self.entity_memo_files.filter { row in
			row.writetime == self.writetime &&
			row.type == WriteDataType.photo.rawValue
		}.forEach { item in
			detailModel.photos.append(
				ImageView( url: documentPath.appendingPathComponent(item.fileName!) ) )
		}
	}

	func refreshMemoData(){
		if let result = entity_memo.first(where: { row in
			row.writetime == self.writetime }) {
			self.detailModel.memoData = result.toMemoData()
			self.detailModel.detailHeaderData = result.toDetailHeaderData()
			self.prefrences.forEach { memoPrefrences in
				switch memoPrefrences.prefrence {
					case .secret: memoPrefrences.isSelected = detailModel.memoData.isSecret
					case .pin: memoPrefrences.isSelected = detailModel.memoData.isPin
				}
			}
			if let tagInfo = entity_memo_tags.first(where: {row in
				row.writetime == self.writetime }) {
				self.tags.removeAll()
				TagItem.tags.forEach { tagItem in
					switch tagItem.tag {
						case .shopping: self.tags.append(TagItem(tag: Tag.shopping, isSelected: tagInfo.shopping))
						case .tracking: self.tags.append(TagItem(tag: Tag.tracking, isSelected: tagInfo.tracking))
						case .travel : self.tags.append(TagItem(tag: Tag.travel, isSelected: tagInfo.travel))
					}
				}
			}
			refreshSnapshotData()
			refreshRecordData()
			refreshPhotoData()
		}
	}

	func refreshHeaderData() {
		if let result = entity_memo.first(where: { row in
			row.writetime == self.writetime }) {
			detailModel.detailHeaderData = result.toDetailHeaderData()
		}
	}

	func  updateRecordText()  {
		let memoFiles = entity_memo_files.filter { entity_Memo_File in
			entity_Memo_File.writetime == self.writetime &&
			entity_Memo_File.type == WriteDataType.record.rawValue
		}
		for (index, entity_memo_file) in memoFiles.enumerated() {
			entity_memo_file.text = detailModel.recordTexts[index].data
			commitTrans(context: viewContext)
		}
	}

	func updateTag() {
		if let entity = entity_memo_tags.first(where: { row in
					row.writetime == self.writetime }) {

			var  snippet = ""

			tags.forEach { item in
				let value:Bool = item.isSelected
				if value {
					snippet +=  " \(item.tag.name)"
				}
				switch item.tag {
					case .shopping : entity.shopping = value
					case .tracking : entity.tracking = value
					case .travel : entity.travel = value
				}
			}
			commitTrans(context: viewContext)

			if let entityMemo = entity_memo.first(where: { row in
				row.writetime == self.writetime
			}) { entityMemo.snippets = snippet }
			commitTrans(context: viewContext)

			refreshHeaderData()
		}
	}

	func updatePrefrences(){
		if let entity = entity_memo.first(where: { row in
					row.writetime == self.writetime }) {
			prefrences.forEach { item in
				switch item.prefrence {
					case .secret:  entity.isSecret = item.isSelected
					case .pin: entity.isPin = item.isSelected
				}
			}
			commitTrans(context: viewContext)
		}
	}
}


struct DetailItemView_Previews: PreviewProvider {

    static var previews: some View {
        DetailItemView(writetime: 0)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
