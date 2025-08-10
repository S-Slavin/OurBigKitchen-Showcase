import SwiftUI
import UIKit

struct ImpactView: View {
    @EnvironmentObject var impactService: ImpactService
    @State private var selectedTags: [String] = ["#Cooking", "#Volunteering"]
    @State private var caption: String = ""
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    
    let allTags = ["#Cooking", "#Serving", "#Volunteering", "#Donations", "#Community", "#Help"]
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 1.0, green: 0.97, blue: 0.92)
                .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HeaderView()
                    
                    // Stats Card
                    StatsCardView()
                    
                    // Track Your Impact
                    TrackImpactView()
                    
                    // Photo & Tag Section
                    PhotoTagSectionView()
                    
                    // Share Button
                    ShareSectionView()
                    
                    Spacer()
                }
            }
            
            // Toast
            if showToast {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(toastMessage)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(Color.black.opacity(0.85))
                            .cornerRadius(16)
                        Spacer()
                    }
                    .padding(.bottom, 48)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: showToast)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    // MARK: - Header View
    private func HeaderView() -> some View {
        ZStack(alignment: .topTrailing) {
            HStack {
                Text("Making An Impact")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 2)
                Spacer()
            }
            .padding(.top, 32)
            .padding(.leading, 28)
            
            // Reset Button
            Button(action: {
                selectedTags = []
                caption = ""
                selectedImage = nil
                showToastWith(message: "Reset complete")
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .clipShape(Circle())
                    .shadow(color: Color.red.opacity(0.18), radius: 6, x: 0, y: 4)
            }
            .padding(.top, 24)
            .padding(.trailing, 28)
        }
        .padding(.bottom, 12)
    }
    
    // MARK: - Stats Card View
    private func StatsCardView() -> some View {
        HStack(spacing: 0) {
            Spacer()
            ImpactStat(icon: "fork.knife", color: .blue, value: "\(impactService.totalMealsServed)", label: "Meals Served")
            Spacer()
            ImpactStat(icon: "flame.fill", color: .orange, value: "\(impactService.familiesHelped)", label: "Families Helped")
            Spacer()
            ImpactStat(icon: "heart.fill", color: .red, value: "\(impactService.livesTouched)", label: "Lives Touched")
            Spacer()
            ImpactStat(icon: "leaf", color: .green, value: String(format: "%.1f", impactService.foodSavedKg), label: "Food Saved (kg)")
            Spacer()
        }
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white)
                .shadow(color: Color.orange.opacity(0.10), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 18)
        .padding(.bottom, 24)
    }
    
    // MARK: - Track Impact View
    private func TrackImpactView() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Track Your Impact")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            HStack(spacing: 32) {
                AnimatedCircleButton(icon: "camera.fill", color: .blue, label: "Capture Photo") {
                    showImagePicker = true
                }
                AnimatedCircleButton(icon: "list.bullet.rectangle", color: .green, label: "Log Activity") {
                    showToastWith(message: "Activity logged!")
                }
                AnimatedCircleButton(icon: "chart.bar.fill", color: .purple, label: "View Insights") {
                    showToastWith(message: "Insights coming soon!")
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.7))
                .blur(radius: 0.5)
        )
        .padding(.bottom, 18)
    }
    
    // MARK: - Photo & Tag Section
    private func PhotoTagSectionView() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Tag & Share Your Photo")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            HStack {
                Button(action: {
                    showImagePicker = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .shadow(color: Color.gray.opacity(0.10), radius: 4, x: 0, y: 2)
                        
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 66, height: 66)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        } else {
                            Image(systemName: "camera")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                TextField("Add a caption to your photo...", text: $caption)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.gray.opacity(0.08), radius: 2, x: 0, y: 1)
            }
            .padding(.bottom, 2)
            
            // Tag selection
            Text("Add tags to your photo")
                .font(.caption)
                .foregroundColor(.gray)
            
            TagSelectionView(allTags: allTags, selectedTags: $selectedTags)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: Color.gray.opacity(0.10), radius: 8, x: 0, y: 4)
        )
        .padding(.bottom, 24)
    }
    
    // MARK: - Share Section
    private func ShareSectionView() -> some View {
        VStack(spacing: 10) {
            Button(action: {
                if selectedImage == nil {
                    showToastWith(message: "No image to share")
                } else {
                    showToastWith(message: "Shared successfully!")
                    // Reset after sharing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        selectedImage = nil
                        caption = ""
                        selectedTags = ["#Cooking", "#Volunteering"]
                    }
                }
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 22, weight: .bold))
                    Text("Share")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(18)
                .shadow(color: Color.blue.opacity(0.18), radius: 8, x: 0, y: 4)
            }
            
            HStack(spacing: 24) {
                SocialCircleIcon(icon: "f.circle.fill", color: .blue)
                SocialCircleIcon(icon: "message.circle.fill", color: .blue)
                SocialCircleIcon(icon: "camera.circle.fill", color: .purple)
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
    }
    
    private func showToastWith(message: String) {
        toastMessage = message
        withAnimation {
            showToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
}

// MARK: - Supporting Views

struct ImpactStat: View {
    let icon: String
    let color: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 70)
    }
}

struct AnimatedCircleButton: View {
    let icon: String
    let color: Color
    let label: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                    action()
                }
            }) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(color)
                            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 80)
    }
}

struct TagSelectionView: View {
    let allTags: [String]
    @Binding var selectedTags: [String]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 100))
        ], spacing: 8) {
            ForEach(allTags, id: \.self) { tag in
                Button(action: {
                    if selectedTags.contains(tag) {
                        selectedTags.removeAll { $0 == tag }
                    } else {
                        selectedTags.append(tag)
                    }
                }) {
                    Text(tag)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedTags.contains(tag) ? .white : .blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedTags.contains(tag) ? Color.blue : Color.blue.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue, lineWidth: selectedTags.contains(tag) ? 0 : 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct SocialCircleIcon: View {
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Handle social sharing
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
