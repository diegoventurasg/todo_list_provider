import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:todo_list_provider/app/exception/auth_exception.dart';

import './user_repository.dart';

class UserRepositoryImpl extends UserRepository {
  final FirebaseAuth _firebaseAuth;

  UserRepositoryImpl({required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth;

  @override
  Future<User?> register(String email, String password) async {
    try {
      final userCredencial = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredencial.user;
    } on FirebaseAuthException catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      if (e.code == 'email-already-in-use') {
        throw AuthException(message: 'E-mail já utilizado');
      } else {
        throw AuthException(message: e.message ?? 'Erro ao registrar usuário');
      }
    }
  }

  @override
  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } on PlatformException catch (e, s) {
      log(e.toString());
      log(s.toString());
      throw AuthException(message: e.message ?? 'Erro ao realizar login');
    } on FirebaseAuthException catch (e, s) {
      log(e.toString());
      log(s.toString());
      if (e.code == 'invalid-credential') {
        throw AuthException(message: 'Login ou senha inválidos');
      }
      throw AuthException(message: e.message ?? 'Erro ao realizar login');
    }
  }
}
