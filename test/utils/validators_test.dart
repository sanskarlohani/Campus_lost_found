import 'package:flutter_test/flutter_test.dart';
import 'package:unilink/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('Email validator returns error for invalid emails', () {
      expect(Validators.validateEmail(''), 'Email is required');
      expect(Validators.validateEmail('invalid'), 'Please enter a valid email');
      expect(Validators.validateEmail('test@'), 'Please enter a valid email');
    });

    test('Email validator returns null for valid emails', () {
      expect(Validators.validateEmail('test@university.edu'), null);
      expect(Validators.validateEmail('john.doe@college.ac.in'), null);
    });

    test('Password validator returns error for short passwords', () {
      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters');
    });

    test('Password validator returns null for valid passwords', () {
      expect(Validators.validatePassword('123456'), null);
    });

    test('Confirm password validator returns error for mismatch', () {
      expect(Validators.validateConfirmPassword('pass1', 'pass2'), 'Passwords do not match');
    });

    test('Confirm password validator returns null for match', () {
      expect(Validators.validateConfirmPassword('match', 'match'), null);
    });

    test('Required field validator works correctly', () {
      expect(Validators.validateRequired('', 'Name'), 'Name is required');
      expect(Validators.validateRequired('John', 'Name'), null);
    });
  });
}
