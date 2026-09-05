import Foundation
import UIKit

public final class LocalPhotoStore {
    public static let shared = LocalPhotoStore()
    
    private let fileManager = FileManager.default
    private let imageCache = NSCache<NSString, UIImage>()
    
    private var photosDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = appSupport.appendingPathComponent("TAROBOOTH", isDirectory: true).appendingPathComponent("Photos", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        }
        return dir
    }
    
    private init() {
        imageCache.countLimit = 16 // Bounded thumbnail/preview cache
        imageCache.totalCostLimit = 60 * 1024 * 1024 // 60MB maximum memory ceiling
    }
    
    /// Detects file extension based on data magic bytes or preferred hint
    private func detectFileExtension(for data: Data, preferred: String? = nil) -> String {
        if let preferred = preferred, !preferred.isEmpty {
            return preferred.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "."))
        }
        
        // Sniff image magic bytes
        if data.count >= 3 {
            // JPEG: FF D8 FF
            if data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF {
                return "jpg"
            }
        }
        if data.count >= 8 {
            // PNG: 89 50 4E 47 0D 0A 1A 0A
            if data[0] == 0x89 && data[1] == 0x50 && data[2] == 0x4E && data[3] == 0x47 {
                return "png"
            }
        }
        if data.count >= 12 {
            // HEIF / HEIC: bytes 4..7 == "ftyp", bytes 8..11 contains brand
            if let ftypString = String(data: data[4..<8], encoding: .ascii), ftypString == "ftyp" {
                if let brand = String(data: data[8..<12], encoding: .ascii)?.lowercased() {
                    if brand.contains("heic") || brand.contains("heix") || brand.contains("mif1") || brand.contains("msf1") || brand.contains("hevc") {
                        return "heic"
                    }
                }
            }
        }
        if data.count >= 3 {
            // GIF: "GIF"
            if let gifString = String(data: data[0..<3], encoding: .ascii), gifString == "GIF" {
                return "gif"
            }
        }
        
        // Neutral fallback for unrecognized binary image data
        return "img"
    }
    
    /// Saves raw photo data and returns a durable relative assetKey (e.g. "Photos/uuid.heic")
    @discardableResult
    public func savePhoto(data: Data, preferredExtension: String? = nil) throws -> String {
        let ext = detectFileExtension(for: data, preferred: preferredExtension)
        let filename = "\(UUID().uuidString).\(ext)"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        try data.write(to: fileURL, options: .atomic)
        
        let assetKey = "Photos/\(filename)"
        
        // Cache decoded image for responsive UI
        if let image = UIImage(data: data) {
            imageCache.setObject(image, forKey: assetKey as NSString, cost: data.count)
        }
        
        return assetKey
    }
    
    /// Non-throwing convenience method for saving photo data
    public func savePhotoSafely(data: Data, preferredExtension: String? = nil) -> String? {
        try? savePhoto(data: data, preferredExtension: preferredExtension)
    }
    
    /// Loads raw photo data from relative assetKey
    public func loadPhotoData(assetKey: String) -> Data? {
        let filename = URL(fileURLWithPath: assetKey).lastPathComponent
        let fileURL = photosDirectory.appendingPathComponent(filename)
        return try? Data(contentsOf: fileURL)
    }
    
    /// Synchronous memory cache query for immediate UI response
    public func cachedImage(assetKey: String) -> UIImage? {
        imageCache.object(forKey: assetKey as NSString)
    }
    
    /// Loads a decoded UIImage from relative assetKey (with in-memory cache)
    public func loadImage(assetKey: String) -> UIImage? {
        if let cached = imageCache.object(forKey: assetKey as NSString) {
            return cached
        }
        guard let data = loadPhotoData(assetKey: assetKey),
              let image = UIImage(data: data) else {
            return nil
        }
        imageCache.setObject(image, forKey: assetKey as NSString, cost: data.count)
        return image
    }
    
    /// Safely deletes a photo file by assetKey
    public func deletePhoto(assetKey: String) throws {
        let filename = URL(fileURLWithPath: assetKey).lastPathComponent
        let fileURL = photosDirectory.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
        imageCache.removeObject(forKey: assetKey as NSString)
    }
}
