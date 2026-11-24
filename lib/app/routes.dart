/// Nama rute terpusat (PRD §3).
abstract final class Routes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const forgotPassword = '/forgot-password';

  static const home = '/home';
  static const tracking = '/tracking';
  static const notifications = '/notifications';
  static const profile = '/profile';

  static const activation = '/activation';
  static const changePassword = '/profile/password';
  static const deleteAccount = '/profile/delete';
  static const pdfViewer = '/pdf-viewer';
  static String order(String id) => '/order/$id';

  static const debug = '/debug';

  static const authRoutes = {
    welcome,
    login,
    register,
    verifyEmail,
    forgotPassword,
  };
}
