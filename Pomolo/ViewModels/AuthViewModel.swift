import SwiftUI
import Combine

public enum AuthProvider: String, CaseIterable {
    case email
    case apple
    case google
}

/// Authentication ViewModel handling business logic, credential validation, and login state persistence.
@MainActor
public final class AuthViewModel: ObservableObject {
    public static let shared = AuthViewModel()
    
    // MARK: - Hardcoded Credentials
    public static let hardcodedEmail = "lk.gcm29@gmail.com"
    public static let hardcodedPassword = "248430"
    
    // MARK: - Published State
    @Published public var email: String
    @Published public var password: String
    @Published public var isPasswordVisible: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var currentProvider: AuthProvider? = nil
    
    @Published public var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: "isUserAuthenticated")
        }
    }
    
    @Published public var userEmail: String {
        didSet {
            UserDefaults.standard.set(userEmail, forKey: "authenticatedUserEmail")
        }
    }
    
    public init() {
        let storedAuth = UserDefaults.standard.bool(forKey: "isUserAuthenticated")
        let storedEmail = UserDefaults.standard.string(forKey: "authenticatedUserEmail") ?? ""
        
        self.isAuthenticated = storedAuth
        self.userEmail = storedEmail
        
        // Prefill with hardcoded credentials for instant verification and testing
        self.email = storedEmail.isEmpty ? Self.hardcodedEmail : storedEmail
        self.password = Self.hardcodedPassword
    }
    
    /// Computes whether inputs have valid formatting
    public var isFormValid: Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return !cleanEmail.isEmpty && cleanEmail.contains("@") && !password.isEmpty
    }
    
    /// Standard email + password authentication against hardcoded credentials
    public func loginWithEmail() {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanEmail.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }
        guard !cleanPassword.isEmpty else {
            errorMessage = "Please enter your password."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            self.isLoading = false
            
            // Validate against required hardcoded credentials
            if cleanEmail == Self.hardcodedEmail.lowercased() && cleanPassword == Self.hardcodedPassword {
                self.userEmail = Self.hardcodedEmail
                self.currentProvider = .email
                self.errorMessage = nil
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.isAuthenticated = true
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } else {
                self.errorMessage = "Invalid credentials. Use \(Self.hardcodedEmail) and password \(Self.hardcodedPassword)."
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }
        }
    }
    
    /// Apple SSO stub — authorizes user as the hardcoded profile
    public func signInWithApple() {
        performSSOAuth(provider: .apple)
    }
    
    /// Google OAuth stub — authorizes user as the hardcoded profile
    public func signInWithGoogle() {
        performSSOAuth(provider: .google)
    }
    
    /// Forgot password dispatch
    public func forgotPassword() {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanEmail.isEmpty {
            errorMessage = "Enter your email above to receive password reset instructions."
        } else {
            errorMessage = "Reset link dispatched. Credentials: \(Self.hardcodedEmail) / \(Self.hardcodedPassword)"
        }
    }
    
    /// Logout: resets authentication state and clears session
    public func signOut() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            self.isAuthenticated = false
            self.currentProvider = nil
            self.userEmail = ""
            self.password = ""
            self.errorMessage = nil
        }
    }
    
    // MARK: - Private SSO Helper
    private func performSSOAuth(provider: AuthProvider) {
        isLoading = true
        errorMessage = nil
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            self.isLoading = false
            self.userEmail = Self.hardcodedEmail
            self.currentProvider = provider
            self.errorMessage = nil
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.isAuthenticated = true
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}
