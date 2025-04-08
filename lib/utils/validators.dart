class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // More precise regex for email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    bool hasDigit = value.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    int strengthCount = 0;
    if (hasUppercase) strengthCount++;
    if (hasLowercase) strengthCount++;
    if (hasDigit) strengthCount++;
    if (hasSpecialChar) strengthCount++;
    
    if (strengthCount < 3) {
      String missingElements = '';
      
      if (!hasUppercase) missingElements += (missingElements.isNotEmpty ? ', ' : '') + 'uppercase letter';
      if (!hasLowercase) missingElements += (missingElements.isNotEmpty ? ', ' : '') + 'lowercase letter';
      if (!hasDigit) missingElements += (missingElements.isNotEmpty ? ', ' : '') + 'number';
      if (!hasSpecialChar) missingElements += (missingElements.isNotEmpty ? ', ' : '') + 'special character';
      
      return 'Password is too weak. Please include at least 3 of the following: $missingElements';
    }
    
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscore';
    }
    
    if (value.contains('__')) {
      return 'Username cannot contain consecutive underscores';
    }
    
    if (value.startsWith('_') || value.endsWith('_')) {
      return 'Username cannot start or end with an underscore';
    }
    
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    
    if (value.length < 2) {
      return 'Full name must be at least 2 characters long';
    }
    
    final parts = value.trim().split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length < 2) {
      return 'Please enter your full name (first and last name)';
    }
    
    return null;
  }

  static String? validateThoughtTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    
    if (value.length < 3) {
      return 'Title must be at least 3 characters long';
    }
    
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    
    return null;
  }

  static String? validateThoughtContent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Content is required';
    }
    
    if (value.length < 10) {
      return 'Content must be at least 10 characters long';
    }
    
    return null;
  }
} 