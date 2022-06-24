//
//  RecordView.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/21.
//

import SwiftUI
import AVFAudio

struct RecordView: View {

	var id:UUID = UUID()
	var fileURL:URL

	@ObservedObject var recordText:TextFieldData
	@State var audioPlayer:AVAudioPlayer!
	@State var playProgress: Double = 0.0
	@State var isEditing = false
	@State var isPlayState:Bool = false
	@State var isPlayStateBefore:Bool = false

	let bgColor = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))

	var body: some View {
		VStack(spacing:0){
			HStack(alignment: .center, spacing: 20){
				Button {

					if !audioPlayer.isPlaying {
						isPlayState = false
					}

					isPlayState.toggle()

					if isPlayState {
						audioPlayer.play()
						updateProgress()
					} else {
						audioPlayer.pause()
					}

				} label: {
					if let _ = audioPlayer {
						if ( !isPlayState || !audioPlayer.isPlaying){
							Image(systemName:"play.rectangle")
						} else {
							Image(systemName:"pause.rectangle")
						}
					} else { Image(systemName:"play.rectangle") }
				}
				.scaleEffect(ScaleEffectValue.pageViewIcon.rawValue, anchor: .center)


				if let _ = audioPlayer {
					Slider(value: $playProgress, in: 0...audioPlayer.duration) {
					} minimumValueLabel: {
						Text( audioPlayer.currentTime.formatmmss() + " / " + audioPlayer.duration.formatmmss() )
					} maximumValueLabel: { Text("")
					}onEditingChanged: { editting in
						isEditing = editting
						if isEditing {
							updateAudioSeek()
						}
					}
				} else {Text("00:00 / 00:00")}


			}
			.tint( iconColor)
			.padding(.vertical, 12)
			.padding(.horizontal, 12)

			TextEditor(text: $recordText.data)
			.onAppear{
				UITextView.appearance().backgroundColor = .clear
			}
			.multilineTextAlignment(.center)
			.clipShape( RoundedRectangle(cornerRadius: 6))
			.background(bgColor)
		}
		.tint(.secondary)
		.onAppear{
			prepareToPlay()
		}
		.onDisappear{
			AudioSessionController.audioSessionDeactivate()
		}
	}
}

extension RecordView {

	private func stopPlayer() {
		if audioPlayer.isPlaying {
			audioPlayer.stop()
			audioPlayer = nil
		}
		AudioSessionController.audioSessionDeactivate()
	}

	private func prepareToPlay() {

		playProgress = 0
		AudioSessionController.audioSessionActivate()
		DispatchQueue.global(qos: .background).async {
			do {
				audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
				audioPlayer.prepareToPlay()
			} catch {
				AudioSessionController.audioSessionDeactivate()
				print(error.localizedDescription)
			}
		}

	}

	private func updateProgress(){

		DispatchQueue.global(qos: .background).async {
			while audioPlayer.isPlaying {
				playProgress = ( audioPlayer.currentTime / audioPlayer.duration ) *  audioPlayer.duration
			}
		}
	}


	private func updateAudioSeek() {
		isPlayStateBefore = audioPlayer.isPlaying
		if isPlayStateBefore { audioPlayer.pause() }

		DispatchQueue.global(qos: .userInitiated).async {
			while isEditing { audioPlayer.currentTime  = playProgress }
			if isPlayStateBefore { audioPlayer.play() }
		}
	}

}

struct RecordView_Previews: PreviewProvider {

	
	static var url:URL =  Bundle.main.url(forResource: "test2", withExtension: "wav")!

    static var previews: some View {
		RecordView(fileURL: url, recordText:TextFieldData())
    }
}


