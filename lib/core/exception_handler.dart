class ExceptionHandler {
  
  static String getMessage(
    dynamic error,
  ) {
    final errorText =
        error.toString();

    if (errorText.contains(
      'SocketException',
    )) {
      return 'No internet connection';
    }

    if (errorText.contains(
      'TimeoutException',
    )) {
      return 'Request timed out';
    }

    if (errorText.contains(
      '404',
    )) {
      return 'Data not found';
    }

    if (errorText.contains(
      '500',
    )) {
      return 'Server error occurred';
    }

    return 'Something went wrong';
  }
}