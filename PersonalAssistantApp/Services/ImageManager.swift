//
//  ImageManager.swift
//  PersonalAssistantApp
//
//  Created by Ayşe Fulya on 24.10.2025.
//


//
//  ImageManager.swift
//  PersonalAssistant
//
//  Services klasörüne ekle

import UIKit

class ImageManager {
    static let shared = ImageManager()
    
    private init() {}
    
    func saveImage(_ image: UIImage) -> String? {
        guard let resizedImage = resizeImage(image: image, maxSize: 1000),
              let imageData = resizedImage.jpegData(compressionQuality: 0.6) else {
            return nil
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = paths[0].appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            print("✅ Resim kaydedildi: \(fileName)")
            return fileName
        } catch {
            print("❌ Hata: \(error)")
            return nil
        }
    }
    
    func loadImage(from path: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = paths[0].appendingPathComponent(path)
        
        guard let imageData = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
    func deleteImage(at path: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = paths[0].appendingPathComponent(path)
        
        try? FileManager.default.removeItem(at: fileURL)
        print("🗑️ Resim silindi: \(path)")
    }
    
    private func resizeImage(image: UIImage, maxSize: CGFloat) -> UIImage? {
        let size = image.size
        let ratio = min(maxSize / size.width, maxSize / size.height)
        
        guard ratio < 1 else { return image }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}