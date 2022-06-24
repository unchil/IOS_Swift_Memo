//
//  MarkerInfoView.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/05/24.
//

import SwiftUI
import GoogleMaps

struct MarkerInfoView: View {

	var writetime:Double
	var marker:GMSMarker?

	@Environment(\.managedObjectContext) private var viewContext

	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Entity_Memo.writetime, ascending: false)],
		animation: .default)
	private var entity_memo: FetchedResults<Entity_Memo>

	@StateObject var detailData = DetailData()

	var body: some View {

		if writetime == 0 {
			VStack(alignment: .center, spacing: 10){

				Text("Current Location")
				.font(.title)

				GroupBox(label: Label("Description:", systemImage: "info.circle")){

					VStack(alignment: .leading){
						Text("Latitude: \(marker!.position.latitude)")
						Text("Longitude:\(marker!.position.longitude)")
					}
					.padding(.vertical,6)
				}
			}
		} else {
			VStack(alignment: .center, spacing: 10){

				Text("Marker Infomation")
				.font(.title)

				Text("\(detailData.detailHeaderData.title)")
				.font(.headline)

				Text("\(detailData.detailHeaderData.desc)")
				.font(.headline)

				GroupBox(label: Label("Description:", systemImage: "info.circle")){
					VStack(alignment: .leading){
						Text("Tag: \(detailData.detailHeaderData.snippets)")
						Text("Attach: Snapshot:\(detailData.detailHeaderData.snapshotCnt)  Record:\(detailData.detailHeaderData.recordCnt)  Photo:\(detailData.detailHeaderData.photoCnt)")
						Text("Latitude: \(detailData.detailHeaderData.latitude)")
						Text("Longitude:\(detailData.detailHeaderData.longitude)")
					}.padding(.vertical,6)
				}

				Spacer()

			}
			.onAppear {
				if let result = entity_memo.first(where: { row in
							row.writetime == self.writetime }) {
					detailData.detailHeaderData = result.toDetailHeaderData()
				}
			}

		}
	}
}

struct MarkerInfoView_Previews: PreviewProvider {

	static var previews: some View {
		MarkerInfoView(writetime: 0, marker: GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0)) )
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
	}
}
