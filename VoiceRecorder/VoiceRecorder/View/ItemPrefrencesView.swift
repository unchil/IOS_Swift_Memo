//
//  ItemPrefrencesView.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/22.
//

import SwiftUI

struct ItemPrefrencesView: View {
	@Binding var items:[MemoPrefrences]

	var body: some View {
		VStack{
			Text("Setting Prefrences")
			.font(.headline)
			.padding()

			ScrollView {
				ForEach( items ) {  element in
					let index = items.firstIndex { item in
						item.id == element.id
					} ?? 0

					Toggle(isOn: self.$items[index].isSelected) {
						Label(self.items[index].prefrence.name, systemImage: self.items[index].prefrence.systemImage)
					}
					.toggleStyle(.switch)
					.padding(.horizontal)
				}
			}
		}

	}
}

struct ItemPrefrencesView_Previews: PreviewProvider {


	static var items:[MemoPrefrences] = MemoPrefrences.prefrences

	static var previews: some View {
		ItemPrefrencesView(items: .constant(items))
	}
}
