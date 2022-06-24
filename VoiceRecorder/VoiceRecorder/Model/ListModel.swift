//
//  ListModel.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/05/17.
//

import Foundation

class ListModel:ObservableObject {
	//@Published var listItemHeader:MemoHeaderData = MemoHeaderData.default
	@Published var listItemHeader:MemoHeaderData = MemoHeaderData.makeDefaultValue()
}
