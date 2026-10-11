import SwiftUI

/// Simplified, minimalist Login screen strictly following the Stitch Obsidian Orbit DESIGN.md specifications.
/// - Minimalist constraint: No top navigation bar, no widgets, only Pomolo logo + "Welcome back" header.
/// - Colors: Canvas #F8F4EE, Primary text Charcoal #2A2A2A, Primary CTA #FF7A1A.
/// - Dark Mode: Seamlessly inverts Charcoal and Off-White tokens.
/// - Dynamic Type: Powered by @ScaledMetric for all paddings, heights, and radii.
@MainActor
public struct LoginView: View {
    @StateObject private var viewModel: AuthViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Scaled Metrics for Dynamic Type & Responsive Layout
    @ScaledMetric(relativeTo: .body) private var horizontalPadding: CGFloat = 24
    @ScaledMetric(relativeTo: .body) private var inputHeight: CGFloat = 52
    @ScaledMetric(relativeTo: .body) private var buttonHeight: CGFloat = 52
    @ScaledMetric(relativeTo: .title) private var logoContainerSize: CGFloat = 64
    @ScaledMetric(relativeTo: .title) private var logoImageSize: CGFloat = 44
    @ScaledMetric(relativeTo: .caption) private var cornerRadius: CGFloat = 16
    
    // Callbacks for optional external orchestration
    public var onLoginSuccess: (() -> Void)?
    public var onNavigateToSignUp: (() -> Void)?
    
    public init(
        viewModel: AuthViewModel? = nil,
        onLoginSuccess: (() -> Void)? = nil,
        onNavigateToSignUp: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel ?? AuthViewModel.shared)
        self.onLoginSuccess = onLoginSuccess
        self.onNavigateToSignUp = onNavigateToSignUp
    }
    
    public var body: some View {
        ZStack {
            // Screen Background Canvas (#F8F4EE Light / #131315 Dark)
            Color.pomoloCanvas
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 32)
                    
                    // MARK: - 1. Brand Identification & Clean Header
                    brandHeaderSection
                        .padding(.bottom, 32)
                    
                    // MARK: - 2. Credentials Form
                    credentialsFormSection
                        .padding(.bottom, 24)
                    
                    // MARK: - 3. Tactile Divider
                    tactileDividerSection
                        .padding(.bottom, 24)
                    
                    // MARK: - 4. SSO Authentication Stubs (Apple & Google)
                    socialAuthSection
                        .padding(.bottom, 32)
                    
                    Spacer(minLength: 20)
                    
                    // MARK: - 5. Footer Sign-Up Link
                    footerSection
                        .padding(.bottom, 16)
                }
                .padding(.horizontal, horizontalPadding)
                .frame(maxWidth: 520) // Optimal centered layout for iPad and larger screens
            }
        }
        // Minimalist constraint: Strict suppression of top navigation bar
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: viewModel.isAuthenticated) { _, authenticated in
            if authenticated {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onLoginSuccess?()
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Brand Hero: Isolated 64x64 rounded logo and "Welcome back" headline
    private var brandHeaderSection: some View {
        VStack(spacing: 16) {
            // Pomolo Logo Container
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.pomoloCard)
                    .frame(width: logoContainerSize, height: logoContainerSize)
                    .shadow(
                        color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.06),
                        radius: 10,
                        x: 0,
                        y: 4
                    )
                
                // Embedded Logo Asset with Vector Fallback
                if UIImage(named: "PomoloLogo") != nil {
                    Image("PomoloLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoImageSize, height: logoImageSize)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                } else {
                    // Precision Brand Glyph Fallback (Tomato / Pomodoro Timer)
                    ZStack {
                        Circle()
                            .fill(Color.pomoloOrange)
                            .frame(width: logoImageSize, height: logoImageSize)
                        Image(systemName: "timer")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Clean "Welcome back" Title
            Text("Welcome back")
                .font(PomoloTypography.headlineLarge(28))
                .foregroundColor(Color.pomoloTextPrimary)
                .multilineTextAlignment(.center)
                .tracking(-0.5)
        }
    }
    
    /// Credentials Form: Email, Password, Forgot Link, and Vibrant Orange CTA
    private var credentialsFormSection: some View {
        VStack(spacing: 14) {
            // Email Input Field
            HStack(spacing: 12) {
                TextField("Email", text: $viewModel.email)
                    .font(PomoloTypography.bodyLarge(15))
                    .foregroundColor(Color.pomoloTextPrimary)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            .padding(.horizontal, 16)
            .frame(height: inputHeight)
            .background(Color.pomoloCard)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.pomoloBorder, lineWidth: 0.5)
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.04),
                radius: 6,
                x: 0,
                y: 2
            )
            
            // Password Input Field with Visibility Toggle
            HStack(spacing: 10) {
                if viewModel.isPasswordVisible {
                    TextField("Password", text: $viewModel.password)
                        .font(PomoloTypography.bodyLarge(15))
                        .foregroundColor(Color.pomoloTextPrimary)
                        .textContentType(.password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                } else {
                    SecureField("Password", text: $viewModel.password)
                        .font(PomoloTypography.bodyLarge(15))
                        .foregroundColor(Color.pomoloTextPrimary)
                        .textContentType(.password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.isPasswordVisible.toggle()
                } label: {
                    Image(systemName: viewModel.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.pomoloTextSecondary.opacity(0.8))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .frame(height: inputHeight)
            .background(Color.pomoloCard)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.pomoloBorder, lineWidth: 0.5)
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.04),
                radius: 6,
                x: 0,
                y: 2
            )
            
            // Trailing "Forgot password?" Action
            HStack {
                Spacer()
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.forgotPassword()
                } label: {
                    Text("Forgot password?")
                        .font(PomoloTypography.caption(13))
                        .foregroundColor(Color.pomoloTextSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 2)
            
            // Hardcoded Credentials Helper Badge
            HStack(spacing: 6) {
                Image(systemName: "key.fill")
                    .font(.system(size: 11))
                    .foregroundColor(Color.pomoloOrange)
                Text("Credentials:")
                    .font(PomoloTypography.caption(11))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.pomoloTextSecondary)
                Text("lk.gcm29@gmail.com")
                    .font(PomoloTypography.caption(11))
                    .foregroundColor(Color.pomoloTextPrimary)
                Text("•")
                    .foregroundColor(Color.pomoloTextSecondary)
                Text("248430")
                    .font(PomoloTypography.caption(11))
                    .fontWeight(.bold)
                    .foregroundColor(Color.pomoloTextPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.pomoloOrange.opacity(0.10))
            .clipShape(Capsule())
            
            // Inline Error / Status Banner (If Present)
            if let error = viewModel.errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color.red)
                    Text(error)
                        .font(PomoloTypography.caption(12))
                        .foregroundColor(Color.red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Primary "Log in" CTA Button (Exclusive #FF7A1A Color Token)
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                viewModel.loginWithEmail()
            } label: {
                ZStack {
                    if viewModel.isLoading && viewModel.currentProvider == .email {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Log in")
                            .font(PomoloTypography.headlineSmall(17))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(Color.pomoloOrange)
                .clipShape(Capsule())
                .shadow(
                    color: Color.pomoloOrange.opacity(0.28),
                    radius: 12,
                    x: 0,
                    y: 6
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(viewModel.isLoading)
            .padding(.top, 6)
        }
    }
    
    /// Tactile Divider with Centered "OR CONTINUE WITH" Label
    private var tactileDividerSection: some View {
        ZStack {
            Rectangle()
                .fill(Color.pomoloBorder)
                .frame(height: 1)
            
            Text("OR CONTINUE WITH")
                .font(PomoloTypography.caption(11))
                .fontWeight(.semibold)
                .tracking(1.2)
                .foregroundColor(Color.pomoloTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 4)
                .background(Color.pomoloCanvas)
        }
    }
    
    /// SSO Authentication Stubs: "Sign in with Apple" and "Continue with Google"
    private var socialAuthSection: some View {
        VStack(spacing: 12) {
            // Sign in with Apple Button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                viewModel.signInWithApple()
            } label: {
                HStack(spacing: 10) {
                    if viewModel.isLoading && viewModel.currentProvider == .apple {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.pomoloAppleForeground))
                    } else {
                        Image(systemName: "applelogo")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(Color.pomoloAppleForeground)
                        
                        Text("Sign in with Apple")
                            .font(PomoloTypography.bodyLarge(16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.pomoloAppleForeground)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(Color.pomoloAppleBackground)
                .clipShape(Capsule())
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.15 : 0.08),
                    radius: 4,
                    x: 0,
                    y: 2
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(viewModel.isLoading)
            
            // Continue with Google Button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                viewModel.signInWithGoogle()
            } label: {
                HStack(spacing: 10) {
                    if viewModel.isLoading && viewModel.currentProvider == .google {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.pomoloTextPrimary))
                    } else {
                        // Multi-color Google "G" Icon
                        GoogleLogoGlyph()
                            .frame(width: 18, height: 18)
                        
                        Text("Continue with Google")
                            .font(PomoloTypography.bodyLarge(16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.pomoloTextPrimary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(Color.pomoloCard)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.pomoloBorder, lineWidth: 0.8)
                )
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.04),
                    radius: 4,
                    x: 0,
                    y: 2
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(viewModel.isLoading)
        }
    }
    
    /// Footer: "Don't have an account? Sign Up"
    private var footerSection: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .font(PomoloTypography.bodyLarge(14))
                .foregroundColor(Color.pomoloTextSecondary)
            
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                if let onNavigateToSignUp = onNavigateToSignUp {
                    onNavigateToSignUp()
                } else {
                    dismiss()
                }
            } label: {
                Text("Sign Up")
                    .font(PomoloTypography.bodyLarge(14))
                    .fontWeight(.bold)
                    .foregroundColor(Color.pomoloOrange)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Native Multi-Color Google "G" Glyph
/// Lightweight vector rendering of the standard Google Quad-Color mark
public struct GoogleLogoGlyph: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background outer ring
            Circle()
                .trim(from: 0.0, to: 0.75)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#EA4335"), // Red
                            Color(hex: "#FBBC05"), // Yellow
                            Color(hex: "#34A853"), // Green
                            Color(hex: "#4285F4"), // Blue
                            Color(hex: "#EA4335")  // Red
                        ]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 3.2, lineCap: .butt)
                )
                .rotationEffect(.degrees(-45))
            
            // Horizontal bar in Google Blue (#4285F4)
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color(hex: "#4285F4"))
                .frame(width: 9, height: 3.2)
                .offset(x: 3, y: 0)
        }
    }
}

#Preview("Login Screen - Light Mode") {
    LoginView()
        .preferredColorScheme(.light)
}

#Preview("Login Screen - Dark Mode") {
    LoginView()
        .preferredColorScheme(.dark)
}
