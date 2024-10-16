import 'package:email_otp/email_otp.dart';
import 'mail_template.dart';

class MailConfig {
  static final MailConfig _instance = MailConfig._internal();

  MailConfig._internal();

  factory MailConfig() => _instance;

  static Future<void> initialize() async {
    EmailOTP.config(
      appName: 'Sri KOT',
      appEmail: "contact@srisoftwarez.com",
      otpType: OTPType.numeric,
    );

    EmailOTP.setSMTP(
      host: 'smtp.gmail.com',
      emailPort: EmailPort.port587,
      secureType: SecureType.tls,
      username: 'iqarulx@gmail.com',
      password: 'jyllfshbkhthgolt',
    );

    EmailOTP.setTemplate(
      template: template,
    );
  }
}
