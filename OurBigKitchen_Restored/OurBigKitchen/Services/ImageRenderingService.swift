import SwiftUI
import UIKit

@MainActor
class ImageRenderingService {
    @MainActor static let shared = ImageRenderingService()
    
    private init() {}
    
    func renderView<Content: View>(_ content: Content) -> UIImage? {
        let controller = UIHostingController(rootView: content)
        guard let view = controller.view else { return nil }
        
        let targetSize = controller.view.intrinsicContentSize
        view.bounds = CGRect(origin: .zero, size: targetSize)
        view.backgroundColor = .clear
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        return renderer.image { _ in
            view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    // Added to support the filter functionality previously in ImpactFilterViewModel
    func renderView<T: View>(_ view: T, size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        
        // Set preferred size
        controller.view.frame = CGRect(origin: .zero, size: size)
        
        // Render the view to an image
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    // Added filter functionality from the removed implementation
    func applyFilter(to image: UIImage, filter: String) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        var filteredImage: CIImage?
        
        switch filter {
        case "Vibrant":
            // Apply vibrance filter
            let vibranceFilter = CIFilter(name: "CIVibrance")
            vibranceFilter?.setValue(ciImage, forKey: kCIInputImageKey)
            vibranceFilter?.setValue(0.5, forKey: kCIInputAmountKey)
            filteredImage = vibranceFilter?.outputImage
            
        case "Monochrome":
            // Apply monochrome filter
            let monochromeFilter = CIFilter(name: "CIColorMonochrome")
            monochromeFilter?.setValue(ciImage, forKey: kCIInputImageKey)
            monochromeFilter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: kCIInputColorKey)
            monochromeFilter?.setValue(1.0, forKey: kCIInputIntensityKey)
            filteredImage = monochromeFilter?.outputImage
            
        default:
            filteredImage = ciImage
        }
        
        guard let outputImage = filteredImage else { return nil }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    func renderImpactImage(impact: Impact) -> UIImage? {
        let content = ImpactShareCard(impact: impact)
        return renderView(content)
    }
    
    func renderImpactImage(impact: Impact, with image: UIImage?) -> UIImage? {
        let content = ImpactShareCard(impact: impact, backgroundImage: image)
        return renderView(content)
    }
}

// Custom sharing card view
struct ImpactShareCard: View {
    let impact: Impact
    var backgroundImage: UIImage?
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Our Big Kitchen Impact")
                .font(.title2)
                .bold()
                .padding(.top)
            
            if let image = backgroundImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 300, maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            HStack(spacing: 20) {
                ImpactStatDisplay(
                    value: "\(impact.mealsProvided)",
                    label: "Meals",
                    icon: "fork.knife",
                    color: .blue
                )
                
                ImpactStatDisplay(
                    value: "\(impact.hoursContributed)",
                    label: "Hours",
                    icon: "clock",
                    color: .orange
                )
                
                ImpactStatDisplay(
                    value: "\(impact.peopleHelped)",
                    label: "People",
                    icon: "person.2",
                    color: .green
                )
            }
            
            if let _ = impact.mealsMade, let _ = impact.timeSpent {
                HStack(spacing: 20) {
                    ImpactStatDisplay(
                        value: "\(String(format: "%.1f", impact.foodWasteSaved))",
                        label: "Food Saved",
                        icon: "leaf",
                        color: .green
                    )
                    
                    ImpactStatDisplay(
                        value: "\(String(format: "%.1f", impact.carbonSaved))",
                        label: "Carbon Saved",
                        icon: "cloud",
                        color: .blue
                    )
                }
            }
            
            Text("Join me in making a difference!")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text("#OurBigKitchen #Community")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .padding(.horizontal)
        .frame(width: 350)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

struct ImpactStatDisplay: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(8)
                .background(Circle().fill(color))
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ImpactShareCard(
        impact: Impact(
            mealsProvided: 125,
            hoursContributed: 12,
            peopleHelped: 200,
            eventsAttended: 3,
            mealsMade: 60,
            timeSpent: 12
        )
    )
    .padding()
} 