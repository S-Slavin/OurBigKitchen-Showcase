import Foundation

enum ValidationError: LocalizedError {
    case invalidEmail
    case invalidPassword
    case passwordMismatch
    case invalidCompanyEmail
    case emptyField(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .invalidPassword:
            return "Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character"
        case .passwordMismatch:
            return "Passwords do not match"
        case .invalidCompanyEmail:
            return "Please enter a valid company email address"
        case .emptyField(let field):
            return "\(field) cannot be empty"
        }
    }
}

struct ValidationUtils {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character
        let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[@#$%^&+=!])(?=.*[^\\s]).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    static func validateCompanyEmail(_ email: String, companyName: String) -> Bool {
        guard isValidEmail(email) else { return false }
        
        // Convert both to lowercase for comparison
        let emailLower = email.lowercased()
        let companyLower = companyName.lowercased()
        
        // Extract domain from email
        guard let domain = emailLower.split(separator: "@").last else { return false }
        
        // Check if domain contains company name
        return String(domain).contains(companyLower)
    }
    
    static func validateSignUpForm(
        firstName: String,
        lastName: String,
        email: String,
        companyName: String,
        companyPosition: String,
        companyEmail: String,
        password: String,
        confirmPassword: String
    ) throws {
        // Check empty fields
        if firstName.isEmpty { throw ValidationError.emptyField("First name") }
        if lastName.isEmpty { throw ValidationError.emptyField("Last name") }
        if email.isEmpty { throw ValidationError.emptyField("Email") }
        if companyName.isEmpty { throw ValidationError.emptyField("Company name") }
        if companyPosition.isEmpty { throw ValidationError.emptyField("Position") }
        if companyEmail.isEmpty { throw ValidationError.emptyField("Company email") }
        if password.isEmpty { throw ValidationError.emptyField("Password") }
        
        // Validate email
        guard isValidEmail(email) else {
            throw ValidationError.invalidEmail
        }
        
        // Validate company email
        guard validateCompanyEmail(companyEmail, companyName: companyName) else {
            throw ValidationError.invalidCompanyEmail
        }
        
        // Validate password
        guard isValidPassword(password) else {
            throw ValidationError.invalidPassword
        }
        
        // Check password match
        guard password == confirmPassword else {
            throw ValidationError.passwordMismatch
        }
    }
} 