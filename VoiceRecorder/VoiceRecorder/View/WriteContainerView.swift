//
//  WriteContainerView.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/21.
//

import SwiftUI

struct WriteContainerView: View {

	@ObservedObject var writeData:WriteData
	@Binding var selectedType: WriteDataType

	@State var snapshotIndex:Int = 0
	@State var recordIndex:Int = 0
	@State var photoIndex:Int = 0
	@State var showDelConfirmDialog = false
	@State var delItemType:WriteDataType = .snapshot

	var body: some View {

		NavigationView{

			VStack{

				//Image(systemName: expandList ? "chevron.down" : "chevron.up").padding(.vertical)
				Text("Write Data Container")
				.font(.headline)
				.padding()

				Picker( "WriteDataType", selection: $selectedType) {
				  ForEach(WriteDataType.allCases) { dataType in
					  Text(dataType.rawValue.capitalized)
				  }
				}
				.pickerStyle(.segmented)

				switch selectedType {
					case .snapshot: do {
						GroupBox(label:Label(WriteDataType.snapshot.name, systemImage: WriteDataType.snapshot.systemImage)){
							if writeData.snapshots.isEmpty { NoDataView() } else {
								NavigationLink {
									ImagePageView(selected:$snapshotIndex, controllers: writeData.snapshots, displayMode: .full)
								//	.navigationBarHidden(true)
									.edgesIgnoringSafeArea(.all)
								} label: {
									ImagePageView(selected:$snapshotIndex, controllers: writeData.snapshots, displayMode: .frame)
									.onAppear{
										snapshotIndex = writeData.snapshots.count - 1
									}
								}
							}
						}.groupBoxStyle(MemoItemGroupBoxStyle(deleteAction: {
							delItemType = .snapshot
							if !writeData.snapshots.isEmpty {
								delItemType = .snapshot
								showDelConfirmDialog.toggle()
							}
						}))
					}
					case .record: do {
						GroupBox(label: Label(WriteDataType.record.name, systemImage: WriteDataType.record.systemImage)){
							if writeData.records.isEmpty { NoDataView() } else {
								RecordPageView(selected:$recordIndex, controllers: writeData.records)
								.onAppear{
									recordIndex = writeData.records.count - 1
								}
							}
						}.groupBoxStyle(MemoItemGroupBoxStyle(deleteAction: {
							if !writeData.records.isEmpty {
								delItemType = .record
								showDelConfirmDialog.toggle()
							}
						}))
					}
					case .photo: do {
						GroupBox(label:Label(WriteDataType.photo.name, systemImage: WriteDataType.photo.systemImage)){
							if writeData.photos.isEmpty { NoDataView() } else {
								NavigationLink {
									ImagePageView(selected:$photoIndex, controllers: writeData.photos, displayMode: .full)
								//	.navigationBarHidden(true)
									.edgesIgnoringSafeArea(.all)
								} label: {
									ImagePageView(selected:$photoIndex, controllers: writeData.photos, displayMode: .frame)
									.onAppear{
										photoIndex = writeData.photos.count - 1
									}
								}
							}
						}
						.groupBoxStyle(MemoItemGroupBoxStyle(deleteAction: {
							if !writeData.photos.isEmpty {
								delItemType = .photo
								showDelConfirmDialog.toggle()
							}
						}))
					}
				}
			}
			.confirmationDialog(delItemType.deleteMessage, isPresented: $showDelConfirmDialog ,titleVisibility: .visible) {
				Button(delItemType.deleteTitle, role: .destructive) {
					deleteItem()
				}
			}
			.navigationBarHidden(true)
		} // NavigationView
	} // body
}

extension WriteContainerView {

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


	func deleteSnapshot() {
		writeData.snapshots.remove(at: snapshotIndex)
	}

	func deleteRecord() {
		writeData.records.remove(at: recordIndex)
		writeData.recordTexts.remove(at: recordIndex)
	}

	func deletePhoto() {
		writeData.photos.remove(at: photoIndex)
	}
}

struct WriteContainerView_Previews: PreviewProvider {
	static var writeData:WriteData = WriteData(id: 0)

    static var previews: some View {
		WriteContainerView(writeData:writeData, selectedType: .constant(WriteDataType.snapshot))
	//	WriteContainerView()
    }
}
