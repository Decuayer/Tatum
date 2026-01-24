//
//  ValidationHelper.swift
//  Tatum
//
//  Created by Demir Cücü on 24.01.2026.
//

import Foundation

struct ValidationHelper {
    
    // MARK: - Email Validation
    

    static func validateEmail(_ email: String) -> String? {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedEmail.isEmpty {
            return "The email address cannot be empty."
        }
        
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if !emailPredicate.evaluate(with: trimmedEmail) {
            return "Enter a valid email address."
        }
        
        return nil
    }
    
    // MARK: - Password Validation
    
    static func validatePassword(_ password: String) -> String? {
        if password.isEmpty {
            return "Password cannot be empty."
        }
        
        if password.count < 6 {
            return "The password must be at least 6 characters long."
        }
        
        let uppercaseRegex = ".*[A-Z]+.*"
        let uppercasePredicate = NSPredicate(format: "SELF MATCHES %@", uppercaseRegex)
        if !uppercasePredicate.evaluate(with: password) {
            return "The password must contain at least one uppercase letter."
        }
        
        let lowercaseRegex = ".*[a-z]+.*"
        let lowercasePredicate = NSPredicate(format: "SELF MATCHES %@", lowercaseRegex)
        if !lowercasePredicate.evaluate(with: password) {
            return "The password must contain at least one lowercase letter."
        }
        
        let symbolRegex = ".*[!@#$%^&*()_+\\-=\\[\\]{}|;:,.<>?]+.*"
        let symbolPredicate = NSPredicate(format: "SELF MATCHES %@", symbolRegex)
        if !symbolPredicate.evaluate(with: password) {
            return "The password must contain at least one symbol. (!@#$%^&* etc.)"
        }
        
        return nil
    }
    
    // MARK: - Phone Number Validation
    
    static func validatePhoneNumber(_ phone: String) -> String? {
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Allow empty phone (it's optional)
        if trimmedPhone.isEmpty {
            return nil
        }
        
        // Remove common separators for validation
        let digitsOnly = trimmedPhone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        // Check minimum length (at least 10 digits for most countries)
        if digitsOnly.count < 10 {
            return "Phone number must contain at least 10 digits."
        }
        
        // Check maximum length (15 digits is international max)
        if digitsOnly.count > 15 {
            return "Phone number cannot exceed 15 digits."
        }
        
        // Validate format: allow +, digits, spaces, dashes, parentheses
        let phoneRegex = "^[+]?[0-9][0-9\\s\\-()]*$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        if !phonePredicate.evaluate(with: trimmedPhone) {
            return "Enter a valid phone number format (e.g., +1234567890 or (123) 456-7890)."
        }
        
        return nil
    }
    
    // MARK: - Helper Methods
    
    static func isValidEmail(_ email: String) -> Bool {
        return validateEmail(email) == nil
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        return validatePassword(password) == nil
    }
    
    static func isValidPhoneNumber(_ phone: String) -> Bool {
        return validatePhoneNumber(phone) == nil
    }
}
