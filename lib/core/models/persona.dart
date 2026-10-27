enum PersonaTier { easy, medium, hard }

enum PersonaGender { girl, boy }

class Persona {
  const Persona({
    required this.id,
    required this.name,
    required this.gender,
    required this.tier,
    required this.description,
    required this.assetPath,
  });

  final String id;
  final String name;
  final PersonaGender gender;
  final PersonaTier tier;
  final String description;
  final String assetPath;

  bool get isEasy => tier == PersonaTier.easy;
}
