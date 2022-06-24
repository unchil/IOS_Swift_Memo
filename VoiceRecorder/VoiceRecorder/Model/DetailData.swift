//
//  DetailData.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/05/17.
//

import Foundation


class DetailData: ObservableObject {

	@Published var memoData = MemoData.makeDefaultValue()
	@Published var detailHeaderData = DetailHeaderData.makeDefaultValue()
	@Published var recordTexts:[TextFieldData] = []
	@Published var snapshots:[ImageView] = []
	@Published var records:[RecordView] = []
	@Published var photos:[ImageView] = []
}
