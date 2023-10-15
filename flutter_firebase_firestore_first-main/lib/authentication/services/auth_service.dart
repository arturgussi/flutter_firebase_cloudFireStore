import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> entrarUsuario({
    required String email,
    required String senha,
  }) async {
    try {
      // UserCredential userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // userCredential.user!.
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          return "O e-mail não está cadastrado";
        case "wrong-password":
          return "Senha incorreta";
        case "invalid-login-credentials":
          return "Usuário ou senha incorretos";
      }
      return e.code;
    }

    return null;
  }

  Future<String?> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
  }) async {
    try {
      UserCredential userCredencial =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await userCredencial.user!.updateDisplayName(
        nome,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "O e-mail já está em uso";
      }
      return e.code;
    }

    return null;
  }

  Future<String?> redefinicaoSenha({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "E-mail não cadastrado";
      }
      return e.code;
    }

    return null;
  }

  Future<String?> deslogar() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }

  Future<String?> removerConta({required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: _firebaseAuth.currentUser!.email!, password: senha);

      await _firebaseAuth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }
}
