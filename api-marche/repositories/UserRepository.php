<?php
class UserRepository {
    private PDO $db;
    public function __construct() { $this->db = Database::getInstance()->getConnection(); }

    public function findById(int $id): ?User {
        $s = $this->db->prepare("SELECT * FROM users WHERE id = ?");
        $s->execute([$id]); $r = $s->fetch();
        return $r ? new User($r) : null;
    }
    public function findByEmail(string $email): ?User {
        $s = $this->db->prepare("SELECT * FROM users WHERE email = ?");
        $s->execute([$email]); $r = $s->fetch();
        return $r ? new User($r) : null;
    }
    public function existsByEmail(string $email): bool {
        $s = $this->db->prepare("SELECT COUNT(*) FROM users WHERE email = ?");
        $s->execute([$email]); return (int)$s->fetchColumn() > 0;
    }
    public function save(User $u): User {
        if ($u->id !== null) {
            $s = $this->db->prepare("UPDATE users SET
                nom=?, email=?, telephone=?, ville=?, user_image=?, bio=?, role=?,
                nom_magasin=?, adresse_entreprise=?, categorie_entreprise=?, description_entreprise=?
                WHERE id=?");
            $s->execute([
                $u->nom,$u->email,$u->telephone,$u->ville,$u->userImage,$u->bio,$u->role,
                $u->nomMagasin,$u->adresseEntreprise,$u->categorieEntreprise,$u->descriptionEntreprise,
                $u->id
            ]);
            return $this->findById($u->id);
        }
        $s = $this->db->prepare("INSERT INTO users
            (nom,email,password,telephone,ville,user_image,bio,role,
             nom_magasin,adresse_entreprise,categorie_entreprise,description_entreprise)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?)");
        $s->execute([
            $u->nom,$u->email,$u->password,$u->telephone,$u->ville,$u->userImage,$u->bio,$u->role,
            $u->nomMagasin,$u->adresseEntreprise,$u->categorieEntreprise,$u->descriptionEntreprise
        ]);
        return $this->findById((int)$this->db->lastInsertId());
    }
}