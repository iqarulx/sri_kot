enum UserType { accountHolder, admin, staff }

enum ProfileType { staff, admin }

enum ModalType { danger, info, call }

enum ImagePickerMode { galary, camera }

enum BillType { enquiry, estimate, invoice }

enum SaveType { create, edit, delete }

enum FileProviderType { excel, image, all }

enum PdfType { estimate, enquiry }

enum LocalData {
  all,
  login,
  loginEmail,
  userName,
  uid,
  companyid,
  companyUniqueId,
  companyName,
  companyAddress,
  isAdmin
}

enum PasswordError {
  upperCase('Must contain at least one uppercase'),
  lowerCase('Must contain at least one lowercase'),
  digit('Must contain at least one digit'),
  eigthCharacter('Must be at least 8 characters in length'),
  specialCharacter('Contain at least one special character: !@#\\\$&*~');

  final String message;

  const PasswordError(this.message);
}

enum PaymentType { company, staff, user }

enum PlanTypes { free, premium, enterprise }

enum DataTypes { local, cloud }

enum ProductType { discounted, netRated }
