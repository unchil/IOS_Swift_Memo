//
//  Photo.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/22.
//

import Foundation
import UIKit

public struct Photo: Identifiable, Equatable {
	public var id: String
	public var originalData: Data
	public var image: UIImage

	public init(id: String = UUID().uuidString, originalData: Data) {
		self.id = id
		self.originalData = originalData
		self.image = UIImage(data: originalData)!
	}

}

