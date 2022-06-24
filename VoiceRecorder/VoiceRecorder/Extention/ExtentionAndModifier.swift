//
//  ViewBuilders.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/21.
//

import Foundation
import SwiftUI
import CoreLocation

import LocalAuthentication

extension LABiometryType {

	var description:String {
		switch self {
			case .none:
				return "보안설정된 메모를 열람하기 위해서 비밀번호로 인증 합니다."
			case .touchID:
				return "보안설정된 메모를 열람하기 위해서 TouchID로 인증 합니다."
			case .faceID:
				return "보안설정된 메모를 열람하기 위해서 FaceID로 인증 합니다."
			@unknown default:
				return ""
		}
	}

}

extension CLAuthorizationStatus {
	var name:String {
		switch self {
			case .notDetermined:
				return "notDetermined"
			case .restricted:
				return "restricted"
			case .denied:
				return "denied"
			case .authorizedAlways:
				return "authorizedAlways"
			case .authorizedWhenInUse:
				return "authorizedWhenInUse"
			@unknown default:
				return "unknown"
		}
	}
}

struct PageViewModifier: ViewModifier {
	//let bgColor:UIColor
	func body(content: Content) -> some View {
		content
			.tabViewStyle(.page)
			.indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
	}
}



extension Double {
	func formatmmss() -> String {
		let date = Date(timeIntervalSince1970: self)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "mm:ss"
		return dateFormatter.string(from: date)
	}
}



struct DeviceRotationViewModifier: ViewModifier {
	let action: (UIDeviceOrientation) -> Void

	func body(content: Content) -> some View {
		content
			.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
				action(UIDevice.current.orientation)
			}
	}
}



extension View {

	func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void)  -> some View {
		self.modifier(DeviceRotationViewModifier(action: action))
	}


}


extension Date
{
	func toString( dateFormat format  : String ) -> String
	{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: self)
	}
}


extension UIView {
  func asImage() -> UIImage {
		let renderer = UIGraphicsImageRenderer(bounds: bounds)
		return renderer.image { rendererContext in
			layer.render(in: rendererContext.cgContext)
		}
	}
}


extension String {

	func getIconImage() -> Image {
		switch (self) {
			case "01d" :  return Image("ic_openweather_01d")
			case "01n" : return Image("ic_openweather_01n") 
			case "02d" : return Image("ic_openweather_02d")
			case "02n" : return Image("ic_openweather_02n")
			case "03d" : return Image("ic_openweather_03d")
			case "03n" : return Image("ic_openweather_03n")
			case "04d" : return Image("ic_openweather_04d")
			case "04n" : return Image("ic_openweather_04n")
			case "09d" : return Image("ic_openweather_09n")
			case "09n" : return Image("ic_openweather_09n")
			case "10d" : return Image("ic_openweather_10d")
			case "10n" : return Image("ic_openweather_10n")
			case "11d" : return Image("ic_openweather_11d")
			case "11n" : return Image("ic_openweather_11n")
			case "13d" : return Image("ic_openweather_13d")
			case "13n" : return Image("ic_openweather_13n")
			case "50d" : return Image("ic_openweather_50d")
			case "50n" : return Image("ic_openweather_50n")
			default: return Image("ic_openweather_unknown")
		}
	}
}

extension CLong {
	func formatHHmmss() -> String {
		let time = Double(self * CLong(1.000000) )
		let date = Date(timeIntervalSince1970: time)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm:ss"
		return dateFormatter.string(from: date)
	}

		func formatHHmm() -> String {
		let time = Double(self * CLong(1.000000) )
		let date = Date(timeIntervalSince1970: time)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		return dateFormatter.string(from: date)
	}

	func formatCollectTime() -> String {
		let collectTime = Double(self * CLong(1.000000) )
		let date = Date(timeIntervalSince1970: collectTime)
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "kr_KR")
		dateFormatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
		return dateFormatter.string(from: date)
	}

	func formatYYYYMMdd_HHmmssSSS() -> String {
		let collectTime = Double(self * CLong(1.000000) )
		let date = Date(timeIntervalSince1970: collectTime)
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "kr_KR")
		dateFormatter.dateFormat = "YYYYMMdd-HHmmssSSS"
		return dateFormatter.string(from: date)
	}
}


extension View {

	func previewContextMenu<Preview:View, Destination:View> (
        preview: Preview,
        destination: Destination,
        preferredContentSize: CGSize? = nil,
        presentAsSheet: Bool = false,
        @ButtonBuilder actions: () -> [PreviewContextAction] = { [] }
    ) -> some View {
        modifier(
            PreviewContextViewModifier(
                destination: destination,
                preview: preview,
                preferredContentSize: preferredContentSize,
                presentAsSheet: presentAsSheet,
                actions: actions
            )
        )
    }

    func previewContextMenu<Preview: View>(
        preview: Preview,
        preferredContentSize: CGSize? = nil,
        presentAsSheet: Bool = false,
        @ButtonBuilder actions: () -> [PreviewContextAction] = { [] }
    ) -> some View {
        modifier(
            PreviewContextViewModifier<Preview, EmptyView>(
                preview: preview,
                preferredContentSize: preferredContentSize,
                presentAsSheet: presentAsSheet,
                actions: actions
            )
        )
    }

 func previewContextMenu<Destination: View>(
        destination: Destination,
        preferredContentSize: CGSize? = nil,
        presentAsSheet: Bool = false,
        @ButtonBuilder actions: () -> [PreviewContextAction] = { [] }
    ) -> some View {
        modifier(
            PreviewContextViewModifier<EmptyView, Destination>(
                destination: destination,
                preferredContentSize: preferredContentSize,
                presentAsSheet: presentAsSheet,
                actions: actions
            )
        )
    }

	@ViewBuilder
    func `if`<Content: View>(
        _ conditional: Bool,
        @ViewBuilder content: (Self) -> Content
    ) -> some View {
        if conditional {
            content(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ conditional: Bool,
        @ViewBuilder if ifContent: (Self) -> TrueContent,
        @ViewBuilder else elseContent: (Self) -> FalseContent
    ) -> some View {
        if conditional {
            ifContent(self)
        } else {
            elseContent(self)
        }
    }

    @ViewBuilder
    func ifLet<Value, Content: View>(
        _ value: Value?,
        @ViewBuilder content: (Self, Value) -> Content
    ) -> some View {
        if let value = value {
            content(self, value)
        } else {
            self
        }
    }

}
