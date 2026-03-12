//
//  CameraPermission.swift
//  FindYourWall
//
//  Created by Max Wayne on 3/11/26.
//
// Referenced Stewart Lynch's Youtube series: https://www.youtube.com/watch?v=1ZYE5FcUN4Y

import UIKit
import AVFoundation

enum CameraPermission {
    static func checkPermissions() -> CameraError? {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authStatus {
            case .notDetermined:
                return nil
            case .restricted:
                return nil
            case .denied:
                return .unauthorized
            case .authorized:
                return nil
            @unknown default:
                return nil
            }
        }
        return .unavailable
    }
    
    enum CameraError: Error, LocalizedError {
        case unauthorized
        case unavailable
        
        var errorDescription: String? {
            switch self {
            case .unauthorized:
                return NSLocalizedString("Camera use unauthorized", comment: "")
            case .unavailable:
                return NSLocalizedString("Camera is not available", comment: "")
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .unauthorized:
                return "Open Settings > Privacy and Security > Camera then enable for this app."
            case .unavailable:
                return "Use the photo album instead."
            }
        }
    }
}
