class User {
  final String firstName;
  final String lastName;
  final String email;

  /// Either a network URL or an `assets/...` path you can feed to Image.asset
  final String image;

  const User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.image,
  });

  String get fullName => '$firstName $lastName';
}
