class User {
  final int? id;
  final String? nom;
  final String? email;
  final String? telephone;
  final String? ville;
  final String? userImage;
  final String? bio;
  final String? role;
  final String? nomMagasin;
  final String? adresseEntreprise;
  final String? categorieEntreprise;
  final String? descriptionEntreprise;
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id, this.nom, this.email, this.telephone, this.ville,
    this.userImage, this.bio, this.role, this.nomMagasin,
    this.adresseEntreprise, this.categorieEntreprise,
    this.descriptionEntreprise, this.createdAt, this.updatedAt,
  });

  bool get isVendeur => role == 'vendeur';

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}'),
    nom: j['nom'],
    email: j['email'],
    telephone: j['telephone'],
    ville: j['ville'],
    userImage: j['userImage'],
    bio: j['bio'],
    role: j['role'],
    nomMagasin: j['nomMagasin'],
    adresseEntreprise: j['adresseEntreprise'],
    categorieEntreprise: j['categorieEntreprise'],
    descriptionEntreprise: j['descriptionEntreprise'],
    createdAt: j['createdAt'],
    updatedAt: j['updatedAt'],
  );
}

class SellerInfo {
  final int? id;
  final String? nom;
  final String? userImage;
  final String? nomMagasin;
  final String? ville;
  final String? telephone;
  final String? membreDepuis;

  SellerInfo({
    this.id, this.nom, this.userImage, this.nomMagasin,
    this.ville, this.telephone, this.membreDepuis,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> j) => SellerInfo(
    id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}'),
    nom: j['nom'],
    userImage: j['userImage'],
    nomMagasin: j['nomMagasin'],
    ville: j['ville'],
    telephone: j['telephone'],
    membreDepuis: j['membreDepuis'],
  );
}