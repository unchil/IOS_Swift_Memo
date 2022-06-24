//
//  AudioSessionController.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/19.
//

import Foundation
import AVFoundation
import Speech
import SwiftUI
import CoreMedia

class AudioSessionController {

	var audioEngine:AVAudioEngine?
	var speechRecognizer:SFSpeechRecognizer?
	var audioRecorder:AVAudioRecorder?
	var audioPlayer:AVAudioPlayer?

	var fileRecognitionRequest: SFSpeechURLRecognitionRequest?
	var bufferRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
	var recognitionTask: SFSpeechRecognitionTask?

	deinit {
		reset()
	}


	private func reset() {
		speechRecognizerReset()
		audioRecorderReset()
		audioPlayerReset()
	}

	func speechRecognizerReset(){
		recognitionTask?.cancel()
		audioEngine?.stop()
		audioEngine = nil
		recognitionTask = nil

	}

	func audioRecorderReset(){
		if (audioRecorder?.isRecording ?? false) == true {
			audioRecorder?.stop()
		}
		audioRecorder = nil
		AudioSessionController.audioSessionDeactivate()
	}

	func audioPlayerReset(){
		if (audioPlayer?.isPlaying ?? false) == true {
			audioPlayer?.stop()
		}
		audioPlayer = nil
		AudioSessionController.audioSessionDeactivate()
	}


	static func audioSessionSet() {
		do {
			try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
		} catch {
			print("Failed to audioSessionSet")
		}
	}


	static func audioSessionActivate() {
		do {
			try AVAudioSession.sharedInstance().setActive(true)
		} catch {
			print("Failed to audioSessionActivate")
		}
	}

	static func audioSessionDeactivate() {
		do{
			try AVAudioSession.sharedInstance().setActive(false)
		}catch{
			print("Failed to  audioSessionDeactivate")
		}
	}

	static func canAccess(withHandler handler: @escaping (Bool) -> Void) {
		SFSpeechRecognizer.requestAuthorization { status in
			if status == .authorized {
				AVAudioSession.sharedInstance().requestRecordPermission { authorized in
					handler(authorized)
				}
			} else {
				handler(false)
			}
		}
	}

}



struct SpeechRecognizer {

	let assistant:AudioSessionController = AudioSessionController()

	private func relay(_ binding: Binding<String>, message: String) {
		DispatchQueue.main.async {
			binding.wrappedValue = message
		}
	}

	func stopSpeechToText() {
		 assistant.speechRecognizerReset()
	}

	func speechToText(To speech: Binding<String>, isRecordingToFile: Bool = false, isRecognizeFromFile:Bool = false,  URL fileUrl: URL,  Locale locale :Locale ) {

		AudioSessionController.canAccess { authorized in

			guard authorized else { return }

			assistant.speechRecognizer = SFSpeechRecognizer(locale: locale )

			assistant.audioEngine = AVAudioEngine()

			guard let audioEngine = assistant.audioEngine else {
				fatalError("Unable to create audio engine")
			}

			if isRecognizeFromFile {
				assistant.fileRecognitionRequest = SFSpeechURLRecognitionRequest(url: fileUrl)
			} else {
				assistant.bufferRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
			}

			guard let recognitionRequest = isRecognizeFromFile ? assistant.fileRecognitionRequest : assistant.bufferRecognitionRequest
			else {
				fatalError("Unable to create request")
			}


			recognitionRequest.shouldReportPartialResults = true

			AudioSessionController.audioSessionActivate()

			let inputNode = audioEngine.inputNode

			let outputFormat = inputNode.outputFormat(forBus: 0)
		

			if !isRecognizeFromFile {

				do {

					let settings: [String: Any] = [
						AVFormatIDKey: outputFormat.settings[AVFormatIDKey] ?? kAudioFormatLinearPCM,
						AVNumberOfChannelsKey: outputFormat.settings[AVNumberOfChannelsKey] ?? 2,
						AVSampleRateKey: outputFormat.settings[AVSampleRateKey] ?? 44100,
						AVLinearPCMBitDepthKey: outputFormat.settings[AVLinearPCMBitDepthKey] ?? 16
					]

					let audioFile = try AVAudioFile(forWriting: fileUrl, settings: settings)

					inputNode.installTap(onBus: 0, bufferSize: 1024, format: outputFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
						(recognitionRequest as! SFSpeechAudioBufferRecognitionRequest).append(buffer)

						if isRecordingToFile {
							try! audioFile.write(from: buffer)
						}
					}

				} catch {
					print("Error recording to File: " + error.localizedDescription)
					assistant.speechRecognizerReset()
					return
				}

			}

			audioEngine.prepare()

			do {
				try audioEngine.start()
			} catch {
				print("Error audioEngine.start(): " + error.localizedDescription)
				assistant.speechRecognizerReset()
				return
			}

			assistant.recognitionTask = assistant.speechRecognizer?.recognitionTask(with: recognitionRequest) { (result, error) in

				var isFinal = false

				if let result = result {
					relay(speech, message: result.bestTranscription.formattedString)
					isFinal = result.isFinal
				}

				if error != nil || isFinal {
					audioEngine.stop()
					inputNode.removeTap(onBus: 0)
					assistant.fileRecognitionRequest = nil
					assistant.bufferRecognitionRequest = nil
					AudioSessionController.audioSessionDeactivate()
				}
			}

		}

	}

}


struct Recorder {
	let assistant:AudioSessionController = AudioSessionController()
	let settings = [
		AVFormatIDKey: Int(kAudioFormatLinearPCM),
		AVSampleRateKey: 44100,
		AVNumberOfChannelsKey: 2,
	//	AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
		AVLinearPCMBitDepthKey: 16
	]


	func startRecording(url:URL){

		AudioSessionController.canAccess { authorized in

			guard authorized else { return }

			AudioSessionController.audioSessionActivate()

			do { assistant.audioRecorder = try AVAudioRecorder(url: url, settings: settings) } catch {
				 print("Could not start recording")
				AudioSessionController.audioSessionDeactivate()
				return
			 }
			assistant.audioRecorder?.record()
		}
	}

	
	func stopRecording() {
		assistant.audioRecorder?.stop()
		AudioSessionController.audioSessionDeactivate()
	}

}



struct Player {
	
	let assistant:AudioSessionController = AudioSessionController()

	func preparePlaying(url:URL, binding: Binding<AVAudioPlayer?>){

		guard url.isFileURL  else { return }

		AudioSessionController.audioSessionActivate()

		do {
			assistant.audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: "wav")
		} catch {
			print("Could not start playing")
			AudioSessionController.audioSessionDeactivate()
			return
		}
		assistant.audioPlayer?.prepareToPlay()

		binding.wrappedValue = assistant.audioPlayer!
		
	}

	func startPlaying(){
		AudioSessionController.audioSessionActivate()
		assistant.audioPlayer?.play()

	}

	func pausePlaying() {
		assistant.audioPlayer?.pause()
		AudioSessionController.audioSessionDeactivate()

	}

	func stopPlaying(){
		assistant.audioPlayerReset()
	}

}
