class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi boş olamaz';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    
    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş olamaz';
    }
    
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    
    if (value.length > 20) {
      return 'Şifre en fazla 20 karakter olabilir';
    }
    
    // Check for at least one letter and one number
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'Şifre en az bir harf ve bir rakam içermelidir';
    }
    
    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı boş olamaz';
    }
    
    if (value != originalPassword) {
      return 'Şifreler eşleşmiyor';
    }
    
    return null;
  }

  // Name validation
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'İsim boş olamaz';
    }
    
    if (value.length < 2) {
      return 'İsim en az 2 karakter olmalıdır';
    }
    
    if (value.length > 50) {
      return 'İsim en fazla 50 karakter olabilir';
    }
    
    // Check for valid characters (letters, spaces, Turkish characters)
    if (!RegExp(r'^[a-zA-ZçğıöşüÇĞIİÖŞÜ\s]+$').hasMatch(value)) {
      return 'İsim sadece harf ve boşluk içerebilir';
    }
    
    return null;
  }

  // Amount validation for expenses
  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tutar boş olamaz';
    }
    
    // Remove currency symbol and spaces
    final cleanValue = value.replaceAll('₺', '').replaceAll(',', '.').trim();
    
    final amount = double.tryParse(cleanValue);
    if (amount == null) {
      return 'Geçerli bir tutar girin';
    }
    
    if (amount <= 0) {
      return 'Tutar 0\'dan büyük olmalıdır';
    }
    
    if (amount > 1000000) {
      return 'Tutar çok yüksek';
    }
    
    // Check decimal places (max 2)
    if (cleanValue.contains('.')) {
      final decimalPart = cleanValue.split('.')[1];
      if (decimalPart.length > 2) {
        return 'En fazla 2 ondalık basamak girilebilir';
      }
    }
    
    return null;
  }

  // Description validation
  static String? description(String? value) {
    if (value == null || value.isEmpty) {
      return 'Açıklama boş olamaz';
    }
    
    if (value.length < 2) {
      return 'Açıklama en az 2 karakter olmalıdır';
    }
    
    if (value.length > 100) {
      return 'Açıklama en fazla 100 karakter olabilir';
    }
    
    return null;
  }

  // Category name validation
  static String? categoryName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kategori adı boş olamaz';
    }
    
    if (value.length < 2) {
      return 'Kategori adı en az 2 karakter olmalıdır';
    }
    
    if (value.length > 30) {
      return 'Kategori adı en fazla 30 karakter olabilir';
    }
    
    return null;
  }

  // Phone number validation (Turkish format)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    // Remove spaces, dashes, parentheses
    final cleanValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Turkish phone number format: +90 or 0 followed by 10 digits
    if (!RegExp(r'^(\+90|0)?5\d{9}$').hasMatch(cleanValue)) {
      return 'Geçerli bir telefon numarası girin (05XXXXXXXXX)';
    }
    
    return null;
  }

  // Required field validation
  static String? required(String? value, {String fieldName = 'Bu alan'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName boş olamaz';
    }
    return null;
  }

  // URL validation
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Geçerli bir URL girin (http:// veya https://)';
      }
      return null;
    } catch (e) {
      return 'Geçerli bir URL girin';
    }
  }

  // Budget validation
  static String? budget(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Budget is optional
    }
    
    final cleanValue = value.replaceAll('₺', '').replaceAll(',', '.').trim();
    final amount = double.tryParse(cleanValue);
    
    if (amount == null) {
      return 'Geçerli bir bütçe tutarı girin';
    }
    
    if (amount < 0) {
      return 'Bütçe negatif olamaz';
    }
    
    if (amount > 10000000) {
      return 'Bütçe tutarı çok yüksek';
    }
    
    return null;
  }

  // Date validation
  static String? date(DateTime? value) {
    if (value == null) {
      return 'Tarih seçiniz';
    }
    
    final now = DateTime.now();
    final maxFutureDate = now.add(const Duration(days: 365 * 5)); // 5 years in future
    final minPastDate = now.subtract(const Duration(days: 365 * 10)); // 10 years in past
    
    if (value.isAfter(maxFutureDate)) {
      return 'Tarih çok ileri bir tarih olamaz';
    }
    
    if (value.isBefore(minPastDate)) {
      return 'Tarih çok eski bir tarih olamaz';
    }
    
    return null;
  }

  // Notes validation
  static String? notes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Notes are optional
    }
    
    if (value.length > 500) {
      return 'Notlar en fazla 500 karakter olabilir';
    }
    
    return null;
  }

  // Tax number validation (Turkish)
  static String? taxNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Tax number is optional
    }
    
    // Remove spaces and dashes
    final cleanValue = value.replaceAll(RegExp(r'[\s\-]'), '');
    
    // Turkish tax number should be 10 or 11 digits
    if (!RegExp(r'^\d{10,11}$').hasMatch(cleanValue)) {
      return 'Vergi numarası 10 veya 11 haneli olmalıdır';
    }
    
    return null;
  }

  // Combine multiple validators
  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}