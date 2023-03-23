//login exceptions
class UserNotFoundAuthException implements Exception {}

class WrongPassWordAuthException implements Exception {}

//register exception

class WeakPassWordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

//generic exceptions

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
