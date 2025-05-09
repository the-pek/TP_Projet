package fr.siggeac.app_siggeac.etudiants.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

/**
 * Entité représentant une inscription d'un étudiant à un groupe de cours
 */
@Entity
@Table(name = "inscription", schema = "etudiants")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Inscription {

    /**
     * Clé primaire composite pour l'inscription
     */
    @EmbeddedId
    private InscriptionId id;

    /**
     * Relation avec l'étudiant inscrit
     */
    @ManyToOne
    @MapsId("matriculeE")
    @JoinColumn(name = "matriculeE")
    private Etudiant etudiant;

    /**
     * Classe interne représentant la clé primaire composite
     */
    @Embeddable
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class InscriptionId implements Serializable {
        
        private static final long serialVersionUID = 1L;
        
        @Column(name = "matriculeE")
        private String matriculeE;
        
        @Column(name = "sigle")
        private String sigle;
        
        @Column(name = "trimestre")
        private String trimestre;
        
        @Column(name = "noGroupe")
        private String noGroupe;
    }

    /**
     * Crée une nouvelle inscription
     * 
     * @param etudiant L'étudiant à inscrire
     * @param sigle Le sigle du cours
     * @param trimestre Le trimestre
     * @param noGroupe Le numéro du groupe
     * @return Une nouvelle instance d'inscription
     */
    public static Inscription of(Etudiant etudiant, String sigle, String trimestre, String noGroupe) {
        Inscription inscription = new Inscription();
        InscriptionId id = new InscriptionId(etudiant.getMatriculeE(), sigle, trimestre, noGroupe);
        inscription.setId(id);
        inscription.setEtudiant(etudiant);
        return inscription;
    }
}