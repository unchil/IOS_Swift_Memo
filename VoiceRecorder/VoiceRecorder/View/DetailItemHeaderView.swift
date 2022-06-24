//
//  DetailItemHeaderView.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/05/13.
//

import SwiftUI

struct DetailItemHeaderView: View {

	@StateObject var detailModel: DetailData

	var body: some View {

		VStack( alignment: .leading) {
			Text("Attach : Snapshot:\(detailModel.detailHeaderData.snapshotCnt)  Record:\(detailModel.detailHeaderData.recordCnt)  Photo:\(detailModel.detailHeaderData.photoCnt)")
			Text("Tag : \(detailModel.detailHeaderData.snippets)")
		}
		.background(.clear)
	}
}


struct DetailItemHeaderView_Previews: PreviewProvider {

	static var controller =  PersistenceController.preview

	static var previews: some View {
		DetailItemHeaderView(detailModel: DetailData())
	}
}
