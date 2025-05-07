-- Création des rôles applicatifs
CREATE ROLE role_consultation;
CREATE ROLE role_modification;
CREATE ROLE role_plein_acces;

-- Création des rôles usagers
CREATE ROLE role_dossier_etudiant;
CREATE ROLE role_evaluation_pedagogique;
CREATE ROLE role_dossier_professoral;
CREATE ROLE role_affectation_professorale;
CREATE ROLE role_offre_service;

-- Attribution des privilèges aux rôles applicatifs
-- Pour le rôle de consultation (SELECT uniquement)
GRANT USAGE ON SCHEMA etudiant, professeur, offre_service, commun TO role_consultation;
GRANT SELECT ON ALL TABLES IN SCHEMA etudiant, professeur, offre_service, commun TO role_consultation;
ALTER DEFAULT PRIVILEGES IN SCHEMA etudiant, professeur, offre_service, commun GRANT SELECT ON TABLES TO role_consultation;

-- Pour le rôle de modification (SELECT, UPDATE)
GRANT USAGE ON SCHEMA etudiant, professeur, offre_service, commun TO role_modification;
GRANT SELECT, UPDATE ON ALL TABLES IN SCHEMA etudiant, professeur, offre_service, commun TO role_modification;
ALTER DEFAULT PRIVILEGES IN SCHEMA etudiant, professeur, offre_service, commun GRANT SELECT, UPDATE ON TABLES TO role_modification;

-- Pour le rôle de plein accès (SELECT, INSERT, UPDATE, DELETE)
GRANT USAGE ON SCHEMA etudiant, professeur, offre_service, commun TO role_plein_acces;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA etudiant, professeur, offre_service, commun TO role_plein_acces;
ALTER DEFAULT PRIVILEGES IN SCHEMA etudiant, professeur, offre_service, commun GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO role_plein_acces;

-- Attribution des privilèges aux rôles usagers (à adapter selon les besoins spécifiques)
-- Rôle dossier étudiant
GRANT USAGE ON SCHEMA etudiant TO role_dossier_etudiant;
GRANT SELECT ON ALL TABLES IN SCHEMA etudiant TO role_dossier_etudiant;

-- Rôle évaluation pédagogique
GRANT USAGE ON SCHEMA etudiant, offre_service TO role_evaluation_pedagogique;
GRANT SELECT ON etudiant.evaluation, etudiant.note, offre_service.cours TO role_evaluation_pedagogique;

-- Rôle dossier professoral
GRANT USAGE ON SCHEMA professeur TO role_dossier_professoral;
GRANT SELECT ON ALL TABLES IN SCHEMA professeur TO role_dossier_professoral;

-- Rôle affectation professorale
GRANT USAGE ON SCHEMA professeur, offre_service TO role_affectation_professorale;
GRANT SELECT ON professeur.professeur, professeur.affectation, offre_service.cours TO role_affectation_professorale;

-- Rôle offre de service
GRANT USAGE ON SCHEMA offre_service TO role_offre_service;
GRANT SELECT ON ALL TABLES IN SCHEMA offre_service TO role_offre_service;

-- Combinaison des rôles pour créer des utilisateurs applicatifs
-- Exemple: Un administrateur étudiant avec plein accès
CREATE USER admin_etudiant WITH PASSWORD 'secure_password';
GRANT role_plein_acces, role_dossier_etudiant, role_evaluation_pedagogique TO admin_etudiant;

-- Exemple: Un professeur avec accès en modification
CREATE USER prof_standard WITH PASSWORD 'secure_password';
GRANT role_modification, role_dossier_professoral, role_affectation_professorale TO prof_standard;

-- Exemple: Un étudiant avec accès en consultation
CREATE USER etudiant_standard WITH PASSWORD 'secure_password';
GRANT role_consultation, role_dossier_etudiant TO etudiant_standard;

-- Types personnalisés pour renforcer le typage
CREATE TYPE genre_type AS ENUM ('M', 'F');
CREATE TYPE statut_etudiant AS ENUM ('ACTIF', 'INACTIF', 'DIPLOME', 'CONGE');
CREATE TYPE statut_professeur AS ENUM ('ACTIF', 'CONGE', 'RETRAITE');
CREATE TYPE type_cours AS ENUM ('COURS', 'TD', 'TP', 'PROJET', 'STAGE');
CREATE TYPE semestre_type AS ENUM ('S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10');
CREATE TYPE validation_type AS ENUM ('CC', 'EXAMEN', 'PROJET', 'STAGE');

-- Schéma commun
CREATE TABLE commun.personne (
    id_personne SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    date_naissance DATE NOT NULL,
    genre genre_type NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    telephone VARCHAR(20) CHECK (telephone ~ '^\+?[0-9]{10,15}$'),
    adresse TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE commun.personne IS 'Informations communes à toutes les personnes';

-- Schéma étudiant
CREATE TABLE etudiant.etudiant (
    id_etudiant SERIAL PRIMARY KEY,
    id_personne INTEGER NOT NULL REFERENCES commun.personne(id_personne) ON DELETE CASCADE,
    matricule VARCHAR(20) UNIQUE NOT NULL,
    statut statut_etudiant NOT NULL DEFAULT 'ACTIF',
    date_inscription DATE NOT NULL DEFAULT CURRENT_DATE,
    filiere VARCHAR(100) NOT NULL,
    niveau INTEGER NOT NULL CHECK (niveau BETWEEN 1 AND 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE etudiant.dossier_etudiant (
    id_dossier SERIAL PRIMARY KEY,
    id_etudiant INTEGER NOT NULL REFERENCES etudiant.etudiant(id_etudiant) ON DELETE CASCADE,
    annee_academique VARCHAR(9) NOT NULL CHECK (annee_academique ~ '^[0-9]{4}-[0-9]{4}$'),
    observations TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (id_etudiant, annee_academique)
);

CREATE TABLE etudiant.evaluation (
    id_evaluation SERIAL PRIMARY KEY,
    id_etudiant INTEGER NOT NULL REFERENCES etudiant.etudiant(id_etudiant) ON DELETE CASCADE,
    id_cours INTEGER NOT NULL, -- sera référencé ultérieurement
    type_evaluation validation_type NOT NULL,
    date_evaluation DATE NOT NULL,
    note DECIMAL(5,2) NOT NULL CHECK (note BETWEEN 0 AND 20),
    coefficient DECIMAL(3,1) NOT NULL DEFAULT 1.0 CHECK (coefficient > 0),
    observations TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Schéma professeur
CREATE TABLE professeur.professeur (
    id_professeur SERIAL PRIMARY KEY,
    id_personne INTEGER NOT NULL REFERENCES commun.personne(id_personne) ON DELETE CASCADE,
    matricule VARCHAR(20) UNIQUE NOT NULL,
    statut statut_professeur NOT NULL DEFAULT 'ACTIF',
    specialite VARCHAR(100) NOT NULL,
    date_recrutement DATE NOT NULL DEFAULT CURRENT_DATE,
    grade VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE professeur.affectation (
    id_affectation SERIAL PRIMARY KEY,
    id_professeur INTEGER NOT NULL REFERENCES professeur.professeur(id_professeur) ON DELETE CASCADE,
    id_cours INTEGER NOT NULL, -- sera référencé ultérieurement
    annee_academique VARCHAR(9) NOT NULL CHECK (annee_academique ~ '^[0-9]{4}-[0-9]{4}$'),
    volume_horaire INTEGER NOT NULL CHECK (volume_horaire > 0),
    observations TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (id_professeur, id_cours, annee_academique)
);

-- Schéma offre de service
CREATE TABLE offre_service.departement (
    id_departement SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(10) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE offre_service.filiere (
    id_filiere SERIAL PRIMARY KEY,
    id_departement INTEGER NOT NULL REFERENCES offre_service.departement(id_departement) ON DELETE CASCADE,
    nom VARCHAR(100) NOT NULL,
    code VARCHAR(10) NOT NULL UNIQUE,
    niveau_etude INTEGER NOT NULL CHECK (niveau_etude BETWEEN 1 AND 5),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (id_departement, nom)
);

CREATE TABLE offre_service.module (
    id_module SERIAL PRIMARY KEY,
    id_filiere INTEGER NOT NULL REFERENCES offre_service.filiere(id_filiere) ON DELETE CASCADE,
    nom VARCHAR(100) NOT NULL,
    code VARCHAR(20) NOT NULL UNIQUE,
    credits INTEGER NOT NULL CHECK (credits > 0),
    niveau INTEGER NOT NULL CHECK (niveau BETWEEN 1 AND 5),
    semestre semestre_type NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (id_filiere, code)
);

CREATE TABLE offre_service.cours (
    id_cours SERIAL PRIMARY KEY,
    id_module INTEGER NOT NULL REFERENCES offre_service.module(id_module) ON DELETE CASCADE,
    intitule VARCHAR(100) NOT NULL,
    code VARCHAR(20) NOT NULL UNIQUE,
    type_cours type_cours NOT NULL,
    volume_horaire INTEGER NOT NULL CHECK (volume_horaire > 0),
    coefficent DECIMAL(3,1) NOT NULL DEFAULT 1.0 CHECK (coefficent > 0),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Ajout des clés étrangères manquantes
ALTER TABLE etudiant.evaluation ADD CONSTRAINT fk_cours FOREIGN KEY (id_cours) REFERENCES offre_service.cours(id_cours);
ALTER TABLE professeur.affectation ADD CONSTRAINT fk_cours FOREIGN KEY (id_cours) REFERENCES offre_service.cours(id_cours);

-- Schéma sécurité
CREATE TABLE securite.utilisateur (
    id_utilisateur SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    id_personne INTEGER REFERENCES commun.personne(id_personne) ON DELETE SET NULL,
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    actif BOOLEAN NOT NULL DEFAULT TRUE,
    derniere_connexion TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE securite.role (
    id_role SERIAL PRIMARY KEY,
    nom VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE securite.permission (
    id_permission SERIAL PRIMARY KEY,
    nom VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE securite.role_permission (
    id_role INTEGER NOT NULL REFERENCES securite.role(id_role) ON DELETE CASCADE,
    id_permission INTEGER NOT NULL REFERENCES securite.permission(id_permission) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_role, id_permission)
);

CREATE TABLE securite.utilisateur_role (
    id_utilisateur INTEGER NOT NULL REFERENCES securite.utilisateur(id_utilisateur) ON DELETE CASCADE,
    id_role INTEGER NOT NULL REFERENCES securite.role(id_role) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_utilisateur, id_role)
);

-- Ajout de déclencheurs pour la mise à jour automatique des timestamps
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Création des déclencheurs pour chaque table avec un champ updated_at
CREATE TRIGGER update_commun_personne_modtime BEFORE UPDATE ON commun.personne FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_etudiant_etudiant_modtime BEFORE UPDATE ON etudiant.etudiant FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_etudiant_dossier_etudiant_modtime BEFORE UPDATE ON etudiant.dossier_etudiant FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_etudiant_evaluation_modtime BEFORE UPDATE ON etudiant.evaluation FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_professeur_professeur_modtime BEFORE UPDATE ON professeur.professeur FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_professeur_affectation_modtime BEFORE UPDATE ON professeur.affectation FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_offre_service_departement_modtime BEFORE UPDATE ON offre_service.departement FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_offre_service_filiere_modtime BEFORE UPDATE ON offre_service.filiere FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_offre_service_module_modtime BEFORE UPDATE ON offre_service.module FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_offre_service_cours_modtime BEFORE UPDATE ON offre_service.cours FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_securite_utilisateur_modtime BEFORE UPDATE ON securite.utilisateur FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_securite_role_modtime BEFORE UPDATE ON securite.role FOR EACH ROW EXECUTE FUNCTION update_modified_column();
CREATE TRIGGER update_securite_permission_modtime BEFORE UPDATE ON securite.permission FOR EACH ROW EXECUTE FUNCTION update_modified_column();