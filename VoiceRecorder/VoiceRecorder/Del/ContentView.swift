//
//  ContentView.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/19.
//

import SwiftUI
import AVFoundation




struct ContentView: View {

	@State var isRecording:Bool = false
	@State var isPlaying:Bool = false
	@State var isSpeechRecognizer:Bool = false

	@State var fileURL:URL? = nil
	@State var audioPlayer:AVAudioPlayer!

	@State var note:String = "Test Note"
	let bgColor = Color(#colorLiteral(red: 0.98, green: 0.9, blue: 0.2, alpha: 1))


	var playerHandle = Player()
	var recorder = Recorder()
	var speechRecognizer = SpeechRecognizer()

//	let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//	let currentLocale =  Locale(identifier: "ko-KR")



    var body: some View {

		VStack(spacing: 20){


			TextEditor(text: $note)
				.background(bgColor)
				.onAppear{
					UITextView.appearance().backgroundColor = .clear
				}

			HStack {

				Button {

					isRecording.toggle()

					if isRecording {
						fileURL = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "YYYYMMdd-HHmmssSSS")).wav" )
						recorder.startRecording(url: fileURL!)
					}else {
						recorder.stopRecording()
						speechRecognizer.speechToText(To: $note, isRecordingToFile: false, isRecognizeFromFile: true, URL:  fileURL!, Locale: currentLocale)
					}

				} label: {
					Image(systemName: isRecording ? "mic.slash.circle": "mic.circle")
				}

				Button {

					isPlaying.toggle()

					if isPlaying {
						playerHandle.preparePlaying(url: fileURL!, binding: $audioPlayer)
						playerHandle.startPlaying()
					} else {
						playerHandle.pausePlaying()
					}

				} label: {
					Image(systemName: isPlaying ? "pause.circle": "play.circle")

				}


				Button {

					isSpeechRecognizer.toggle()

					if isSpeechRecognizer {
						fileURL = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "YYYYMMdd-HHmmssSSS")).wav" )
						speechRecognizer.speechToText(To: $note, isRecordingToFile: true, isRecognizeFromFile: false, URL:  fileURL!, Locale: currentLocale)
					} else {
						speechRecognizer.stopSpeechToText()
					}

				} label: {
					Image(systemName: isSpeechRecognizer ? "mic.slash.circle": "mic.circle")
				}


			}
			.scaleEffect(2)

		}
		.tint(.yellow)
		.padding()
		.onAppear{
			AudioSessionController.audioSessionSet()
		}


    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

