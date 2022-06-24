//
//  ItemHeaderView.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/05/11.
//

import SwiftUI

struct ItemHeaderView: View {

	@Environment(\.managedObjectContext) private var viewContext

	var writetime:Double


	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo.writetime, ascending: false)],
		animation: .default)
	private var entity_memo: FetchedResults<Entity_Memo>

	@StateObject var listModel = ListModel()

	var body: some View {

		HStack{

			Label("secret", systemImage: listModel.listItemHeader.isSecret ? "lock" : "lock.open")
			.scaleEffect(1.5, anchor: .center)
			.padding(.horizontal)

			VStack( alignment: .leading) {
				Text("\(listModel.listItemHeader.title)\n\(listModel.listItemHeader.desc)")
				Text("snapshot:\(listModel.listItemHeader.snapshotCnt)  record:\(listModel.listItemHeader.recordCnt)  photo:\(listModel.listItemHeader.photoCnt)")
				Text(listModel.listItemHeader.snippets)
			}

			Label("pin", systemImage: listModel.listItemHeader.isPin ? "mappin.and.ellipse" : "mappin.slash")
			.scaleEffect(1.5, anchor: .center)
			.padding(.horizontal)

		}
		.onAppear{
			if let result = entity_memo.first(where: { row in
				row.writetime == self.writetime }) {
				listModel.listItemHeader = result.toMemoHeaderData()
			}
		}
		.labelStyle(.iconOnly)
	}
}

struct ItemHeader_Previews: PreviewProvider {

	static var previews: some View {
		ItemHeaderView(writetime: 0)
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
	}
}
