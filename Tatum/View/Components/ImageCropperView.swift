//
//  ImageCropperView.swift
//  Tatum
//
//  Created by Demir Cücü on 24.01.2026.
//

import SwiftUI

struct ImageCropperView: View {
    let image: UIImage
    let onCrop: (UIImage) -> Void
    let onCancel: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let cropCircleSize: CGFloat = 280
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("BackgroundDark").ignoresSafeArea()
                
                // Image layer - Aspect ratio korunarak
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)  // ✅ Sıkıştırma yok
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                scale *= delta
                                scale = max(0.5, min(scale, 5.0))
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                            }
                    )
                
                // Overlay with circle cutout
                ZStack {
                    // Dark overlay
                    Rectangle()
                        .fill(Color.black.opacity(0.75))
                        .ignoresSafeArea()
                    
                    // Transparent circle in center
                    Circle()
                        .frame(width: cropCircleSize, height: cropCircleSize)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                .allowsHitTesting(false)
                
                // White border circle
                Circle()
                    .strokeBorder(Color.white, lineWidth: 3)
                    .frame(width: cropCircleSize, height: cropCircleSize)
                    .allowsHitTesting(false)
                
                // UI Layer on top
                VStack(spacing: 0) {
                    customNavBar
                    
                    Spacer()
                    
                    // Instructions
                    Text("Drag to reposition • Pinch to zoom")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("BackgroundDark"))
                        .cornerRadius(20)
                        .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    private var customNavBar: some View {
        ZStack {
            Text("Adjust Photo")
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(.white)
            
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .font(.custom("Poppins-Bold", size: 16))
                .padding(12)
                .background(Color("CardDark"))
                .cornerRadius(20)
                .foregroundColor(.white)
                
                Spacer()
                
                Button("Confirm") {
                    cropImage()
                }
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(Color("BrandPurple"))
                .padding(12)
                .background(Color("CardDark"))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(Color("BackgroundDark"))
    }
    
    private func cropImage() {
        // Screen dimensions
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Calculate displayed image size (aspect fit)
        let imageAspect = image.size.width / image.size.height
        let screenAspect = screenWidth / screenHeight
        
        var displayedWidth: CGFloat
        var displayedHeight: CGFloat
        
        if imageAspect > screenAspect {
            // Image is wider - fit to width
            displayedWidth = screenWidth
            displayedHeight = screenWidth / imageAspect
        } else {
            // Image is taller - fit to height
            displayedHeight = screenHeight
            displayedWidth = screenHeight * imageAspect
        }
        
        // Apply scale
        let scaledWidth = displayedWidth * scale
        let scaledHeight = displayedHeight * scale
        
        // Image center on screen (with offset)
        let imageCenterX = (screenWidth / 2) + offset.width
        let imageCenterY = (screenHeight / 2) + offset.height
        
        // Crop circle center
        let cropCenterX = screenWidth / 2
        let cropCenterY = screenHeight / 2
        
        // Delta between crop center and image center
        let deltaX = cropCenterX - imageCenterX
        let deltaY = cropCenterY - imageCenterY
        
        // Create renderer
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: cropCircleSize, height: cropCircleSize))
        
        let croppedImage = renderer.image { context in
            // Circular clipping path
            let circlePath = UIBezierPath(
                ovalIn: CGRect(x: 0, y: 0, width: cropCircleSize, height: cropCircleSize)
            )
            circlePath.addClip()
            
            // Calculate draw position
            let drawX = (cropCircleSize / 2) - deltaX - (scaledWidth / 2)
            let drawY = (cropCircleSize / 2) - deltaY - (scaledHeight / 2)
            
            // Draw image
            image.draw(in: CGRect(
                x: drawX,
                y: drawY,
                width: scaledWidth,
                height: scaledHeight
            ))
        }
        
        onCrop(croppedImage)
    }
}

// MARK: - Custom Overlay with Circular Cutout

struct OverlayWithCircleCutout: View {
    let circleSize: CGFloat
    let screenSize: CGSize
    
    var body: some View {
        Path { path in
            // Full screen rectangle
            path.addRect(CGRect(origin: .zero, size: screenSize))
            
            // Circle to cut out - EXACTLY CENTERED
            let circleRect = CGRect(
                x: (screenSize.width - circleSize) / 2,
                y: (screenSize.height - circleSize) / 2,
                width: circleSize,
                height: circleSize
            )
            path.addEllipse(in: circleRect)
        }
        .fill(Color.black.opacity(0.75), style: FillStyle(eoFill: true))
    }
}
