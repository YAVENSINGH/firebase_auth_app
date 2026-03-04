import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // ─── Current User ───
  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Pehle initialize karna zaroori hai
      await _googleSignIn.initialize();

      // 2. v7+ mein signIn() ki jagah authenticate() use karein
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
      if (googleUser == null) return null;

      // 3. Auth details lein (Note: v7+ mein structure thoda alag ho sakta hai)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Google Sign-In fail ho gaya: $e';
    }
  }

  // ─── Sign Up with Email & Password ───
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Display name update karna agar diya ho
      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
        await credential.user?.reload();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async{
    await _firebaseAuth.signOut();

    try{
      await _googleSignIn.signOut();
    }catch(_){

    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Is email se koi account nahi mila.';
      case 'wrong-password':
        return 'Password galat hai.';
      case 'email-already-in-use':
        return 'Ye email pehle se register hai.';
      case 'invalid-email':
        return 'Email address sahi nahi hai.';
      case 'weak-password':
        return 'Password kam se kam 6 characters ka hona chahiye.';
      case 'too-many-requests':
        return 'Bahut saari koshishon ke baad block kar diya gaya hai.';
      case 'invalid-credential':
        return 'Login details sahi nahi hain.';
      case 'account-exists-with-different-credential':
        return 'Ye email kisi dusre login method ke saath juda hai.';
      default:
        return e.message ?? 'Ek anjan error aayi hai.';
    }
  }

}
