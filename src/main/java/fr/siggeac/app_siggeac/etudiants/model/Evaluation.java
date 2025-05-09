package fr.siggeac.app_siggeac.etudiants.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entité représentant l'évaluation d'un étudiant pour un cours
 */
@Entity
@Table(name = "evaluation", schema = "etudiants")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Evaluation {

    /**
     * La clé primaire est la même que celle de l'inscription associée
     */
    @EmbeddedId
    private Inscription.InscriptionId id;

    /**
     * La note obtenue par l'étudiant
     */
    @Column(name = "note", nullable = false)
    private Short note;

    /**
     * Relation avec l'inscription associée
     */
    @OneToOne
    @MapsId
    @JoinColumns({
        @JoinColumn(name = "matriculeE", referencedColumnName = "matriculeE"),
        @JoinColumn(name = "sigle", referencedColumnName = "sigle"),
        @JoinColumn(name = "trimestre", referencedColumnName = "trimestre"),
        @JoinColumn(name = "noGroupe", referencedColumnName = "noGroupe")
    })
    private Inscription inscription;

    /**
     * Crée une nouvelle évaluation
     * 
     * @param inscription L'inscription associée
     * @param note La note obtenue
     * @return Une nouvelle instance d'évaluation
     */
    public static Evaluation of(Inscription inscription, Short note) {
        Evaluation evaluation = new Evaluation();
        evaluation.setId(inscription.getId());
        evaluation.setInscription(inscription);
        evaluation.setNote(note);
        return evaluation;
    }
}