package fr.siggeac.app_siggeac.etudiants.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Entité représentant un étudiant dans le système
 */
@Entity
@Table(name = "etudiant", schema = "etudiants")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Etudiant {

    @Id
    @Column(name = "matriculeE", nullable = false)
    private String matriculeE;

    @Column(name = "nom", nullable = false)
    private String nom;

    @Column(name = "ddn", nullable = false)
    private LocalDate ddn;

    /**
     * Crée un nouvel étudiant avec le matricule, le nom et la date de naissance spécifiés
     * 
     * @param matriculeE Le matricule de l'étudiant
     * @param nom Le nom de l'étudiant
     * @param ddn La date de naissance de l'étudiant
     * @return Une nouvelle instance d'étudiant
     */
    public static Etudiant of(String matriculeE, String nom, LocalDate ddn) {
        Etudiant etudiant = new Etudiant();
        etudiant.setMatriculeE(matriculeE);
        etudiant.setNom(nom);
        etudiant.setDdn(ddn);
        return etudiant;
    }
}