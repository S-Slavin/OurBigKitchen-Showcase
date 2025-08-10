import SwiftUI
import Foundation

// Directly reference ButtonStyles since it's in the project module
struct OnboardingSlide {
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

struct OnboardingView: View {
    @AppStorage("com.ourbigkitchen.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    @State private var animateBackground = false
    @State private var animateIcon = false
    @State private var showRegistrationFlow = false
    
    private let slides = [
        OnboardingSlide(
            title: "Together, We Are Building a Kinder World",
            description: "Join our powerful movement for positive change through food and community service.",
            imageName: "heart.circle.fill",
            color: ThemeManager.Colors.primary
        ),
        OnboardingSlide(
            title: "Track Your Impact",
            description: "Log your volunteer hours and meals prepared to see your contribution grow.",
            imageName: "chart.bar.fill",
            color: ThemeManager.Colors.mealsServed
        ),
        OnboardingSlide(
            title: "Share Your Journey",
            description: "Inspire others by sharing your impact on social media.",
            imageName: "square.and.arrow.up",
            color: ThemeManager.Colors.donations
        ),
        OnboardingSlide(
            title: "Join Events",
            description: "Participate in community cooking events and meet fellow volunteers.",
            imageName: "calendar",
            color: ThemeManager.Colors.wasteReduced
        )
    ]
    
    // Consistent theme colors from ThemeManager
    private let primaryColor = ThemeManager.Colors.primary
    private let accentColor = ThemeManager.Colors.accent
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94) // Cream
    
    var body: some View {
        ZStack {
            // Enhanced background gradient with animation
            LinearGradient(
                gradient: Gradient(colors: [
                    backgroundColor,
                    backgroundColor.opacity(0.95),
                    Color(red: 1.0, green: 0.95, blue: 0.9),
                    Color(red: 0.98, green: 0.92, blue: 0.84)
                ]),
                startPoint: animateBackground ? .topLeading : .topTrailing,
                endPoint: animateBackground ? .bottomTrailing : .bottomLeading
            )
            .edgesIgnoringSafeArea(.all)
            .animation(
                Animation.easeInOut(duration: 10)
                    .repeatForever(autoreverses: true),
                value: animateBackground
            )
            .onAppear {
                animateBackground = true
            }
            
            // Enhanced background elements
            ZStack {
                // Decorative floating elements
                ForEach(0..<12) { i in
                    let size = CGFloat(30 + i * 12)
                    let opacity = 0.03 + Double(i) * 0.005
                    
                    Circle()
                        .fill(slides[currentPage].color.opacity(opacity))
                        .frame(width: size, height: size)
                        .offset(
                            x: CGFloat.random(in: -180...180),
                            y: CGFloat.random(in: -350...350)
                        )
                        .blur(radius: 3)
                        .animation(
                            Animation.easeInOut(duration: Double(8 + i))
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.1),
                            value: animateBackground
                        )
                }
            }
            
            VStack(spacing: 0) {
                // Skip button at top right with improved styling
                HStack {
                    Spacer()
                    
                    Button("SKIP FOR DEMO") {
                        // Add a graceful exit animation
                        withAnimation(.easeOut(duration: 0.5)) {
                            hasCompletedOnboarding = true
                            dismiss()
                        }
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(12)
                    .padding(.trailing)
                    .padding(.top, 20)
                    .buttonStyle(ButtonStyles.scale)
                }
                
                // Main content
                TabView(selection: $currentPage) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        VStack(spacing: 30) {
                            Spacer(minLength: 40)
                            
                            // Enhanced image with better animation
                            ZStack {
                                // Large outer circle with gradient
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                slides[index].color.opacity(0.2),
                                                slides[index].color.opacity(0.05)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 200, height: 200)
                                    .scaleEffect(animateIcon ? 1.05 : 1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 3)
                                            .repeatForever(autoreverses: true),
                                        value: animateIcon
                                    )
                                
                                // Middle circle with subtle glow
                                Circle()
                                    .fill(slides[index].color.opacity(0.15))
                                    .frame(width: 160, height: 160)
                                    .blur(radius: 1)
                                    .scaleEffect(animateIcon ? 1.08 : 0.95)
                                    .animation(
                                        Animation.easeInOut(duration: 2.5)
                                            .repeatForever(autoreverses: true)
                                            .delay(0.3),
                                        value: animateIcon
                                    )
                                
                                // Icon with enhanced animation
                                Image(systemName: slides[index].imageName)
                                    .font(.system(size: 90))
                                    .foregroundColor(slides[index].color)
                                    .offset(y: animateIcon ? -5 : 0)
                                    .animation(
                                        Animation.easeInOut(duration: 1.5)
                                            .repeatForever(autoreverses: true),
                                        value: animateIcon
                                    )
                            }
                            .shadow(color: slides[index].color.opacity(0.3), radius: 20, x: 0, y: 10)
                            
                            // Text content with improved styling
                            VStack(spacing: 25) {
                                Text(slides[index].title)
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(.darkText),
                                                Color(.darkText).opacity(0.9)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .padding(.horizontal, 20)
                                    .shadow(color: Color.white.opacity(0.5), radius: 1, x: 0, y: 1)
                                
                                Text(slides[index].description)
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Color.black.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 30)
                                    .padding(.top, 8)
                                    .shadow(color: Color.white.opacity(0.5), radius: 1, x: 0, y: 1)
                            }
                            
                            Spacer()
                            
                            // Navigation and Get Started buttons with improved styling
                            VStack(spacing: 20) {
                                if index == slides.count - 1 {
                                    // Enhanced Get Started button on last slide
                                    Button {
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            hasCompletedOnboarding = true
                                            showRegistrationFlow = true
                                        }
                                    } label: {
                                        HStack {
                                            Text("Get Started")
                                                .font(.system(size: 22, weight: .bold))
                                            
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 20))
                                                .offset(x: animateIcon ? 3 : 0)
                                                .animation(
                                                    Animation.easeInOut(duration: 1)
                                                        .repeatForever(autoreverses: true),
                                                    value: animateIcon
                                                )
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 22)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [primaryColor, accentColor.opacity(0.8)]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 30)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                        )
                                        .cornerRadius(30)
                                        .shadow(color: slides[index].color.opacity(0.5), radius: 15, x: 0, y: 8)
                                    }
                                    .padding(.horizontal, 35)
                                    .buttonStyle(ButtonStyles.scale)
                                } else {
                                    // Enhanced Next button on other slides
                                    Button {
                                        withAnimation {
                                            currentPage = index + 1
                                        }
                                    } label: {
                                        HStack {
                                            Text("Next")
                                                .font(.system(size: 22, weight: .bold))
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 20))
                                                .offset(x: animateIcon ? 3 : 0)
                                                .animation(
                                                    Animation.easeInOut(duration: 1)
                                                        .repeatForever(autoreverses: true),
                                                    value: animateIcon
                                                )
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 22)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    slides[index].color,
                                                    slides[index].color.opacity(0.8)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 30)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                        )
                                        .cornerRadius(30)
                                        .shadow(color: slides[index].color.opacity(0.4), radius: 10, x: 0, y: 6)
                                    }
                                    .padding(.horizontal, 35)
                                    .buttonStyle(ButtonStyles.scale)
                                }
                                
                                // Enhanced page indicators
                                HStack(spacing: 12) {
                                    ForEach(0..<slides.count, id: \.self) { i in
                                        Circle()
                                            .fill(i == currentPage ? slides[i].color : Color.gray.opacity(0.4))
                                            .frame(width: i == currentPage ? 14 : 8, height: i == currentPage ? 14 : 8)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(0.5), lineWidth: i == currentPage ? 1 : 0)
                                            )
                                            .scaleEffect(i == currentPage ? 1.2 : 1.0)
                                            .shadow(color: i == currentPage ? slides[i].color.opacity(0.6) : Color.clear, 
                                                   radius: 4, x: 0, y: 2)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                                            .onTapGesture {
                                                withAnimation {
                                                    currentPage = i
                                                }
                                            }
                                    }
                                }
                                .padding(.vertical, 24)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { _ in
                    // Reset animations for the new page
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            animateIcon = true
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showRegistrationFlow) {
            RegistrationFlowView()
        }
        .onAppear {
            // Start animations when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    animateIcon = true
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
} 