import SwiftUI
import Photos

/// Sharable Screen with Native View-to-Image Rendering via iOS 16+ ImageRenderer API
/// Replicates the Stitch "Milestone Share - 7-Day Focus Streak" Screen.
public struct SharableScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.displayScale) private var displayScale
    
    // Dynamic parameters linked to Core Data / User Stats
    @Binding public var streakDays: Int
    public var focusTierText: String
    public var proofStatText: String
    
    // State for rendering and sharing
    @State private var renderedCardImage: UIImage? = nil
    @State private var isShowingShareSheet: Bool = false
    @State private var toastMessage: String? = nil
    @State private var showToast: Bool = false
    
    public init(
        streakDays: Binding<Int>,
        focusTierText: String = "Top 1% Focus Tier",
        proofStatText: String = "Crushed 35 hours of uninterrupted deep work."
    ) {
        self._streakDays = streakDays
        self.focusTierText = focusTierText
        self.proofStatText = proofStatText
    }
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Top Story Preview Frame
                        cardPreviewFrame
                            .padding(.top, 8)
                        
                        // Bottom Distribution & Share Action Controls
                        exportControlsSection
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
                
                // Floating Toast Banner
                if showToast, let msg = toastMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.pomoloOrange)
                        Text(msg)
                            .font(PomoloTypography.bodyMedium(12))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.pomoloCharcoal)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 24)
                }
            }
            .background(Color.pomoloCanvas.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.pomoloTextPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.pomoloCard)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.pomoloBorder, lineWidth: 1))
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("Story Preview")
                            .font(PomoloTypography.headlineSmall(15))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.pomoloTextPrimary)
                        Text("Ready to Share")
                            .font(PomoloTypography.labelCaps(10))
                            .foregroundColor(Color.pomoloTextSecondary.opacity(0.7))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        shareGeneratedCard()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.pomoloTextPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.pomoloCard)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.pomoloBorder, lineWidth: 1))
                    }
                }
            }
            .sheet(isPresented: $isShowingShareSheet) {
                if let image = renderedCardImage {
                    CardActivityShareSheet(image: image)
                }
            }
        }
    }
    
    // MARK: - Standalone Card Preview Frame
    private var cardPreviewFrame: some View {
        MilestoneCardView(
            streakDays: streakDays,
            focusTierText: focusTierText,
            wrappedYearText: "Wrapped '25",
            proofStatText: proofStatText
        )
    }
    
    // MARK: - Bottom Export & Distribution Bar
    private var exportControlsSection: some View {
        VStack(spacing: 10) {
            // Primary Instagram Stories CTA
            Button {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                shareToInstagramStories()
            } label: {
                HStack(spacing: 10) {
                    // Instagram Camera / Glyph Icon
                    instagramIcon
                        .frame(width: 20, height: 20)
                    
                    Text("Share to Instagram Stories")
                        .font(PomoloTypography.headlineSmall(15))
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.pomoloOrange)
                .clipShape(Capsule())
                .shadow(color: Color.pomoloOrange.opacity(0.35), radius: 12, x: 0, y: 5)
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Secondary Quick Actions Row (Post to X, Save Card, Copy Link)
            HStack(spacing: 8) {
                // Share to X Button
                actionButton(title: "Post to X", icon: "xmark") {
                    shareToX()
                }
                
                // Save Card to Photos
                actionButton(title: "Save Card", icon: "arrow.down") {
                    saveCardToPhotos()
                }
                
                // Copy Link
                actionButton(title: "Copy Link", icon: "link") {
                    copyShareLink()
                }
            }
        }
    }
    
    // MARK: - Action Buttons
    private func actionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(PomoloTypography.labelCaps(11))
                    .fontWeight(.semibold)
            }
            .foregroundColor(Color.pomoloTextPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.pomoloCard)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.pomoloBorder, lineWidth: 1))
            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Native View-To-Image Rendering (iOS 16+ ImageRenderer)
    @MainActor
    private func generateMilestoneUIImage() -> UIImage? {
        let cardToRender = MilestoneCardView(
            streakDays: streakDays,
            focusTierText: focusTierText,
            wrappedYearText: "Wrapped '25",
            proofStatText: proofStatText
        )
        
        let renderer = ImageRenderer(content: cardToRender)
        // High-resolution export scale (3x for crisp retina display)
        renderer.scale = max(displayScale, 3.0)
        renderer.isOpaque = false
        return renderer.uiImage
    }
    
    // MARK: - Share Actions
    private func shareGeneratedCard() {
        if let image = generateMilestoneUIImage() {
            self.renderedCardImage = image
            self.isShowingShareSheet = true
        }
    }
    
    private func shareToInstagramStories() {
        guard let image = generateMilestoneUIImage() else { return }
        self.renderedCardImage = image
        
        // Check if Instagram Stories custom pasteboard URL scheme is available
        guard let instagramURL = URL(string: "instagram-stories://share?source_application=pomolo") else {
            self.isShowingShareSheet = true
            return
        }
        
        if UIApplication.shared.canOpenURL(instagramURL) {
            guard let pngData = image.pngData() else { return }
            let pasteboardItems: [String: Any] = [
                "com.instagram.sharedSticker.stickerImage": pngData,
                "com.instagram.sharedSticker.backgroundTopColor": "#F8F4EE",
                "com.instagram.sharedSticker.backgroundBottomColor": "#FFD7B0"
            ]
            let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
                .expirationDate: Date().addingTimeInterval(300)
            ]
            UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
            UIApplication.shared.open(instagramURL)
            displayToast("Launching Instagram Stories...")
        } else {
            // Fallback to Native Share Sheet
            self.isShowingShareSheet = true
        }
    }
    
    private func shareToX() {
        let text = "I'm on a \(streakDays)-day flow state streak on @PomoloApp! 35 hours of deep focus crushed. 🔥 #DeepWork #Pomodoro"
        if let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let twitterURL = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)"),
           UIApplication.shared.canOpenURL(twitterURL) {
            UIApplication.shared.open(twitterURL)
            displayToast("Drafting milestone post on X...")
        } else {
            shareGeneratedCard()
        }
    }
    
    private func saveCardToPhotos() {
        guard let image = generateMilestoneUIImage() else { return }
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    displayToast("Saved high-res card to Photos!")
                } else {
                    displayToast("Please allow Photos access in Settings.")
                }
            }
        }
    }
    
    private func copyShareLink() {
        UIPasteboard.general.string = "https://pomolo.app/share/streak/\(streakDays)-day-zone"
        displayToast("Streak link copied to clipboard!")
    }
    
    private func displayToast(_ message: String) {
        toastMessage = message
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showToast = false
            }
        }
    }
    
    // MARK: - Instagram Glyph SVG / Path
    private var instagramIcon: some View {
        Image(systemName: "camera.fill")
            .font(.system(size: 15, weight: .bold))
    }
}

// MARK: - UIActivityViewController Sheet for Generated UIImage
public struct CardActivityShareSheet: UIViewControllerRepresentable {
    public let image: UIImage
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let text = "🔥 Check out my 7-Day Focus Streak milestone on Pomolo!"
        let controller = UIActivityViewController(activityItems: [image, text], applicationActivities: nil)
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
