//
//  TagItem.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/22.
//

import Foundation
import SwiftUI


class TagItem: ObservableObject, Identifiable {



	var id: String = UUID().uuidString

	@Published var tag: Tag
	@Published var isSelected: Bool


	init(tag:Tag, isSelected: Bool) {
		self.tag = tag
		self.isSelected = isSelected
	}


	static let tags: [TagItem] = [ TagItem(tag: Tag.travel, isSelected: false), TagItem(tag: Tag.shopping, isSelected: false), TagItem(tag: Tag.tracking, isSelected: false)]

	static func makeDefaultValue() ->[TagItem] {
			return [ TagItem(tag: Tag.travel, isSelected: false), TagItem(tag: Tag.shopping, isSelected: false), TagItem(tag: Tag.tracking, isSelected: false)]
	}



}


