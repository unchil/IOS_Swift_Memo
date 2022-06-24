//
//  MemoPrefrences.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/22.
//

import Foundation

class MemoPrefrences: ObservableObject, Identifiable {


	enum Prefrences: Int {

		case secret
		case pin

		var name: String {
			switch self {
			case .secret :   return "보안 설정"
			case .pin: return "위치 등록"
			}
		}

		var systemImage: String {
			switch self {
			case .secret :   return "lock"
			case .pin: return "mappin.and.ellipse"
			}
		}

	}

	var id: String = UUID().uuidString

	@Published var prefrence: Prefrences
	@Published var isSelected: Bool


	init(prefrence:Prefrences, isSelected: Bool) {
		self.prefrence = prefrence
		self.isSelected = isSelected
	}

	static func makeDefaultValue() ->[MemoPrefrences] {
		return  [ MemoPrefrences(prefrence: Prefrences.secret, isSelected: false), MemoPrefrences(prefrence: Prefrences.pin, isSelected: false)]
	}


	static let prefrences: [MemoPrefrences] = [ MemoPrefrences(prefrence: Prefrences.secret, isSelected: false), MemoPrefrences(prefrence: Prefrences.pin, isSelected: false)]



}
