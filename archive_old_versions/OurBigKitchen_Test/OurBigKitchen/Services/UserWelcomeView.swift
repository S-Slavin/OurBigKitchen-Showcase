//
//  UserWelcomeView.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import SwiftUI

struct UserWelcomeView: View {
    var onComplete: () -> Void
    @State private var currentPage = 0
    @State private var animateBackground = false
    @State private var animateContent = false
    
    // Colors
    private let primaryColor = Color(red: 0.93, green: 0.46, blue: 0.12) // Orange
    private let accentColor = Color(red: 0.85, green: 0.33, blue: 0.10) // Dark Orange
    private let backgroundColor = Color(red: 1.0, green: 0.98, blue: 0.94) // Cream
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background content
                backgroundView
                
                VStack(spacing: 0) {
                    // Content area with enhanced visuals
                    contentArea(geometry: geometry)
                    
                    // Bottom navigation with improved styling
                    navigationArea(geometry: geometry)
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                // Animate elements in with improved timing
                withAnimation(.easeOut(duration: 1.0)) {
                    animateBackground = true
                }
                withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                    animateContent = true
                }
            }
        }
    }
    
    // Extracted background view to simplify body
    private var backgroundView: some View {
        ZStack {
            Color.white
            
            // Lighter gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    backgroundColor.opacity(0.5),
                    Color(red: 1.0, green: 0.95, blue: 0.9).opacity(0.5),
                    backgroundColor.opacity(0.5)
                ]),
                startPoint: animateBackground ? .topLeading : .bottomTrailing,
                endPoint: animateBackground ? .bottomTrailing : .topLeading
            )
            .animation(.easeInOut(duration: 12).repeatForever(autoreverses: true), value: animateBackground)
            
            // Softer animated background patterns with reduced opacity
            ZStack {
                // Abstract shapes in the background for depth
                ForEach(0..<6) { i in
                    RoundedRectangle(cornerRadius: 40)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    primaryColor.opacity(0.02 + Double(i) * 0.002),
                                    accentColor.opacity(0.01 + Double(i) * 0.001)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(
                            width: CGFloat.random(in: 180...300),
                            height: CGFloat.random(in: 180...300)
                        )
                        .rotationEffect(.degrees(Double.random(in: 0...360)))
                        .offset(
                            x: CGFloat.random(in: -180...180),
                            y: CGFloat.random(in: -300...300)
                        )
                        .animation(
                            Animation.easeInOut(duration: Double(10 + i))
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.5),
                            value: animateBackground
                        )
                        .blur(radius: 2)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // Content area with TabView - enhanced transitions
    private func contentArea(geometry: GeometryProxy) -> some View {
        TabView(selection: $currentPage) {
            // First page with enhanced animation
            welcomeSlide
                .tag(0)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            
            // Second page with enhanced animation
            feedSlide
                .tag(1)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            
            // Third page with enhanced animation
            shareSlide
                .tag(2)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            
            // Fourth page with enhanced animation
            impactSlide
                .tag(3)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: geometry.size.height * 0.75) // Slightly larger content area
        .animation(.easeInOut(duration: 0.5), value: currentPage)
    }
    
    // Enhanced page indicators
    private func pageIndicators() -> some View {
        HStack(spacing: 12) {
            ForEach(0..<4) { index in
                pageIndicator(for: index)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.3))
        .cornerRadius(20)
    }
    
    // Individual page indicator with enhanced design
    @ViewBuilder
    private func pageIndicator(for index: Int) -> some View {
        let isSelected = currentPage == index
        
        Group {
            if isSelected {
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [primaryColor.opacity(0.8), accentColor.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 28, height: 8)
                    .shadow(color: primaryColor.opacity(0.3), radius: 2, x: 0, y: 1)
            } else {
                Capsule()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: 8, height: 8)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                currentPage = index
            }
        }
    }
    
    // Navigation buttons with enhanced styling
    private func navigationButtons() -> some View {
        HStack(spacing: 24) {
            backButton()
            
            Spacer()
            
            nextOrStartButton()
        }
    }
    
    // Navigation area that combines page indicators and navigation buttons
    private func navigationArea(geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            pageIndicators()
            
            Spacer().frame(height: 10)
            
            navigationButtons()
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .frame(height: geometry.size.height * 0.25)
        .background(
            Color.white
                .opacity(0.2)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blur(radius: 0.5)
        )
    }
    
    // Back button with improved styling
    private func backButton() -> some View {
        Group {
            if currentPage > 0 {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        currentPage -= 1
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(width: 100)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                }
                .buttonStyle(ButtonStyles.scale)
            } else {
                Spacer()
                    .frame(width: 100)
            }
        }
    }
    
    // Next or Get Started button with improved styling
    private func nextOrStartButton() -> some View {
        Group {
            if currentPage < 3 {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        currentPage += 1
                    }
                }) {
                    HStack {
                        Text("Next")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 100)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [primaryColor, accentColor]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                }
                .buttonStyle(ButtonStyles.scale)
            } else {
                Button(action: {
                    // Add a slight delay for visual feedback
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        animateContent = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        onComplete()
                    }
                }) {
                    HStack {
                        Text("Get Started")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 120)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [primaryColor, accentColor]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                }
                .buttonStyle(ButtonStyles.scale)
            }
        }
    }
    
    // Enhanced welcome slide
    private var welcomeSlide: some View {
        VStack(spacing: 50) {
            Spacer()
            
            // Enhanced logo with improved shadow and animation
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 160)
                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
                .scaleEffect(animateContent ? 1.0 : 0.9)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: animateContent)
            
            VStack(spacing: 20) {
                Text("Together, We Build a Kinder World")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .shadow(color: Color.white.opacity(0.7), radius: 2, x: 0, y: 1)
                    .offset(y: animateContent ? 0 : 10)
                    .animation(.easeOut(duration: 0.8).delay(0.3), value: animateContent)
                
                Text("Join a powerful movement where every action creates positive change. Through food and community, we're building a more compassionate world.")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 25)
                    .shadow(color: Color.white.opacity(0.7), radius: 1, x: 0, y: 1)
                    .offset(y: animateContent ? 0 : 10)
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: animateContent)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity)
        .background(
            Color.white.opacity(0.5)
        )
    }
    
    private var feedSlide: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Enhanced icon with animations
            ZStack {
                // Subtle background glow
                Circle()
                    .fill(primaryColor.opacity(0.1))
                    .frame(width: 130, height: 130)
                    .blur(radius: 15)
                
                Image(systemName: "fork.knife")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 90)
                    .foregroundColor(primaryColor.opacity(0.9))
                    .scaleEffect(animateContent ? 1.0 : 0.9)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: animateContent)
            }
            
            VStack(spacing: 16) {
                Text("Feed Those in Need")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .shadow(color: Color.white.opacity(0.5), radius: 1, x: 0, y: 1)
                    .offset(y: animateContent ? 0 : 10)
                    .animation(.easeOut(duration: 0.7).delay(0.2), value: animateContent)
                
                Text("Cook nutritious meals for the vulnerable and make a direct impact in your community. Every meal prepared is a step toward ending hunger.")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 25)
                    .shadow(color: Color.white.opacity(0.5), radius: 1, x: 0, y: 1)
                    .offset(y: animateContent ? 0 : 10)
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.7).delay(0.3), value: animateContent)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.top, 20)
        .background(Color.white.opacity(0.5))
    }
    
    private var shareSlide: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Enhanced icon with animations
            ZStack {
                // Subtle background glow
                Circle()
                    .fill(primaryColor.opacity(0.1))
                    .frame(width: 130, height: 130)
                    .blur(radius: 15)
                
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 90)
                    .foregroundColor(primaryColor.opacity(0.9))
                    .scaleEffect(animateContent ? 1.0 : 0.9)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: animateContent)
            }
            
            VStack(spacing: 16) {
                Text("Share Your Journey")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .shadow(color: Color.white.opacity(0.5), radius: 1, x: 0, y: 1)
                    .offset(y: animateContent ? 0 : 10)
                    .animation(.easeOut(duration: 0.7).delay(0.2), value: animateContent)
                
                Text("Inspire others by sharing your achievements on social media. Every meal and hour you contribute creates a powerful story of positive change worth sharing.")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 25)
                    .shadow(color: Color.white.opacity(0.5), radius: 1, x: 0, y: 1)
                    .offset(y: animateContent ? 0 : 10)
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.7).delay(0.3), value: animateContent)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.top, 20)
        .background(Color.white.opacity(0.5))
    }
    
    private var impactSlide: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Enhanced icon with animations
            ZStack {
                // Subtle background glow
                Circle()
                    .fill(primaryColor.opacity(0.1))
                    .frame(width: 130, height: 130)
                    .blur(radius: 15)
                
                Image(systemName: "chart.bar.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 90)
                    .foregroundColor(primaryColor.opacity(0.9))
                    .scaleEffect(animateContent ? 1.0 : 0.9)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: animateContent)
            }
            
            VStack(spacing: 16) {
                Text("Track Your Impact")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .shadow(color: Color.white.opacity(0.5), radius: 1, x: 0, y: 1)
                    .offset(y: animateContent ? 0 : 10)
                    .animation(.easeOut(duration: 0.7).delay(0.2), value: animateContent)
                
                Text("See how your contributions create positive change. Every volunteer hour and meal prepared adds to our collective mission of kindness.")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 25)
                    .shadow(color: Color.white.opacity(0.5), radius: 1, x: 0, y: 1)
                    .offset(y: animateContent ? 0 : 10)
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.7).delay(0.3), value: animateContent)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.top, 20)
        .background(Color.white.opacity(0.5))
    }
}

#Preview {
    UserWelcomeView(onComplete: {})
}