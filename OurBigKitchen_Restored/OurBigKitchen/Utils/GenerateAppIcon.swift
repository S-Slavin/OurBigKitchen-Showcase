import SwiftUI
import UIKit

struct AppIconGenerator {
    static func generateAppIcon() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1024, height: 1024))
        let image = renderer.image { context in
            let hostingController = UIHostingController(rootView: IconGenerator())
            hostingController.view.frame = CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024))
            hostingController.view.backgroundColor = .clear
            
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
        
        if let data = image.pngData() {
            let fileManager = FileManager.default
            let currentDirectory = fileManager.currentDirectoryPath
            let iconPath = (currentDirectory as NSString).appendingPathComponent("AppIcon1024.png")
            
            do {
                try data.write(to: URL(fileURLWithPath: iconPath))
                print("App icon generated successfully at: \(iconPath)")
            } catch {
                print("Error saving app icon: \(error)")
            }
        }
    }
} 