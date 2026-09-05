import Foundation
import AVFoundation
import UIKit

public final class CameraService: NSObject, ObservableObject, CameraServiceProtocol {
    public let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    @Published public var isRunning: Bool = false
    
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    
    private var currentPosition: CameraPosition = .back
    private var currentFlashMode: FlashMode = .off
    
    private var photoCaptureCompletion: ((Result<CameraCaptureResult, Error>) -> Void)?
    
    public var isSessionConfigured = false
    
    public override init() {
        super.init()
    }
    
    // MARK: - Hardware Check & Authorization
    
    public var hasCameraHardware: Bool {
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        return !discovery.devices.isEmpty
    }
    
    public var authorizationStatus: AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    public func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    // MARK: - Session Configuration
    
    public func configureSessionIfNeeded() async throws {
        guard !isSessionConfigured else { return }
        
        let authorized = await checkAuthorization()
        guard authorized else {
            throw TAROCoreError.permissionDenied
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: TAROCoreError.unknown)
                    return
                }
                
                self.session.beginConfiguration()
                self.session.sessionPreset = .photo
                
                // Video Input
                do {
                    let camera = self.discoverCamera(for: self.currentPosition)
                    guard let camera = camera else {
                        self.session.commitConfiguration()
                        continuation.resume(throwing: TAROCoreError.unavailable)
                        return
                    }
                    
                    let videoInput = try AVCaptureDeviceInput(device: camera)
                    if self.session.canAddInput(videoInput) {
                        self.session.addInput(videoInput)
                        self.videoDeviceInput = videoInput
                    } else {
                        self.session.commitConfiguration()
                        continuation.resume(throwing: TAROCoreError.invalidState)
                        return
                    }
                } catch {
                    self.session.commitConfiguration()
                    continuation.resume(throwing: error)
                    return
                }
                
                // Photo Output
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                    self.photoOutput.isHighResolutionCaptureEnabled = true
                    if #available(iOS 16.0, *) {
                        self.photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 3840, height: 2160)
                    }
                } else {
                    self.session.commitConfiguration()
                    continuation.resume(throwing: TAROCoreError.invalidState)
                    return
                }
                
                self.session.commitConfiguration()
                self.isSessionConfigured = true
                continuation.resume(returning: ())
            }
        }
    }
    
    // MARK: - Lifecycle
    
    public func startSession() async throws {
        try await configureSessionIfNeeded()
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }
                if !self.session.isRunning {
                    self.session.startRunning()
                    DispatchQueue.main.async { [weak self] in
                        self?.isRunning = true
                    }
                }
                continuation.resume()
            }
        }
    }
    
    public func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async { [weak self] in
                    self?.isRunning = false
                }
            }
        }
    }
    
    // MARK: - Camera Switching
    
    public func switchCamera(to position: CameraPosition) async throws {
        guard position != currentPosition else { return }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: TAROCoreError.unknown)
                    return
                }
                
                self.session.beginConfiguration()
                
                if let currentInput = self.videoDeviceInput {
                    self.session.removeInput(currentInput)
                }
                
                guard let newCamera = self.discoverCamera(for: position) else {
                    self.session.commitConfiguration()
                    continuation.resume(throwing: TAROCoreError.unavailable)
                    return
                }
                
                do {
                    let newInput = try AVCaptureDeviceInput(device: newCamera)
                    if self.session.canAddInput(newInput) {
                        self.session.addInput(newInput)
                        self.videoDeviceInput = newInput
                        self.currentPosition = position
                        self.session.commitConfiguration()
                        continuation.resume(returning: ())
                    } else {
                        self.session.commitConfiguration()
                        continuation.resume(throwing: TAROCoreError.invalidState)
                    }
                } catch {
                    self.session.commitConfiguration()
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Flash Mode
    
    public func setFlashMode(_ mode: FlashMode) {
        self.currentFlashMode = mode
    }
    
    // MARK: - Photo Capture
    
    public func capturePhoto() async throws -> CameraCaptureResult {
        guard isSessionConfigured && session.isRunning else {
            throw TAROCoreError.invalidState
        }
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CameraCaptureResult, Error>) in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: TAROCoreError.unknown)
                    return
                }
                
                let photoSettings = AVCapturePhotoSettings()
                
                // Configure flash if supported on current device
                if let device = self.videoDeviceInput?.device, device.hasFlash {
                    switch self.currentFlashMode {
                    case .on:
                        if self.photoOutput.supportedFlashModes.contains(.on) {
                            photoSettings.flashMode = .on
                        }
                    case .off:
                        if self.photoOutput.supportedFlashModes.contains(.off) {
                            photoSettings.flashMode = .off
                        }
                    case .auto:
                        if self.photoOutput.supportedFlashModes.contains(.auto) {
                            photoSettings.flashMode = .auto
                        }
                    }
                }
                
                self.photoCaptureCompletion = { result in
                    continuation.resume(with: result)
                }
                
                self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
            }
        }
    }
    
    // MARK: - Helper Discovery
    
    private func discoverCamera(for position: CameraPosition) -> AVCaptureDevice? {
        let deviceType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera
        let avPosition: AVCaptureDevice.Position = (position == .front) ? .front : .back
        
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [deviceType],
            mediaType: .video,
            position: avPosition
        )
        return discovery.devices.first ?? AVCaptureDevice.default(for: .video)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraService: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            photoCaptureCompletion?(.failure(error))
            photoCaptureCompletion = nil
            return
        }
        
        guard let data = photo.fileDataRepresentation() else {
            photoCaptureCompletion?(.failure(TAROCoreError.captureFailed))
            photoCaptureCompletion = nil
            return
        }
        
        do {
            // Save original bytes unfiltered into LocalPhotoStore
            let assetKey = try LocalPhotoStore.shared.savePhoto(data: data)
            let result = CameraCaptureResult(
                assetKey: assetKey,
                localIdentifier: "cam_\(UUID().uuidString.prefix(6))"
            )
            photoCaptureCompletion?(.success(result))
        } catch {
            photoCaptureCompletion?(.failure(error))
        }
        photoCaptureCompletion = nil
    }
}
