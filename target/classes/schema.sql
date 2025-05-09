/*
==============================================================================
universite_ind.sql
------------------------------------------------------------------------------
Produit     : Université
Résumé      : Script de création de la base, des schémas et des tables
Projet      : UCAC-ICAM - Gestion Universitaire
Etudiants : 
    Atouga II Emmanuel Désiré
    Kengne Kengne Pierre-Edwin
    Missamou Siefou Joevinio
    Dohicou Kopse Jonathan
Version     : 2025-05-07
Statut      : Développement
Encodage    : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme  : PostgreSQL 14+
==============================================================================
*/

/*Avant de run ce script il faut créer la base de donnée Université de manière graphique*/

-- Suppression des schémas s’ils existent
drop schema if exists etudiants cascade;
drop schema if exists professeurs cascade;
drop schema if exists offres cascade;

/*
==============================================================================
Création des schémas
==============================================================================
*/
create schema etudiants;
set search_path to 'etudiants';
create domain Bureau
  Text
  check (value similar to '[A-Z][0-9]{1,2}-[0-9]{4}(-[0-9]{2})?') ;
create domain Cause
  Text ;
create domain CDC
  SmallInt
  check (value between 1 and 90) ;
create domain MatriculeE
  Text
  check (value similar to '[a-z]{4}[0-9]{4}') ;
create domain MatriculeP
  Text
  check (value similar to '[a-z]{4}[0-9]{4}') ;
create domain NoGroupe
  Text
  check (value similar to '[0-9]{2}') ;
create domain Nom
  Text
  check (length(value) <= 120 and value similar to '[[:alpha:]]+([-’ [:alpha:]])*[[:alpha:]]+') ;
create domain Note
  SmallInt
  check (value between 1 and 90) ;
create domain Sigle
  Text check (value similar to '[A-Z]{3}[0-9]{3}') ;
create domain Titre
  Text ;
create domain Trimestre
  Text
  check (value similar to '[0-9]{4}-[1-3]') ;

create schema professeurs;
set search_path to 'professeurs';
create domain Bureau
  Text
  check (value similar to '[A-Z][0-9]{1,2}-[0-9]{4}(-[0-9]{2})?') ;
create domain Cause
  Text ;
create domain CDC
  SmallInt
  check (value between 1 and 90) ;
create domain MatriculeE
  Text
  check (value similar to '[a-z]{4}[0-9]{4}') ;
create domain MatriculeP
  Text
  check (value similar to '[a-z]{4}[0-9]{4}') ;
create domain NoGroupe
  Text
  check (value similar to '[0-9]{2}') ;
create domain Nom
  Text
  check (length(value) <= 120 and value similar to '[[:alpha:]]+([-’ [:alpha:]])*[[:alpha:]]+') ;
create domain Note
  SmallInt
  check (value between 1 and 90) ;
create domain Sigle
  Text check (value similar to '[A-Z]{3}[0-9]{3}') ;
create domain Titre
  Text ;
create domain Trimestre
  Text
  check (value similar to '[0-9]{4}-[1-3]') ;

create schema offres;
set search_path to 'offres';
create domain Bureau
  Text
  check (value similar to '[A-Z][0-9]{1,2}-[0-9]{4}(-[0-9]{2})?') ;
create domain Cause
  Text ;
create domain CDC
  SmallInt
  check (value between 1 and 90) ;
create domain MatriculeE
  Text
  check (value similar to '[a-z]{4}[0-9]{4}') ;
create domain MatriculeP
  Text
  check (value similar to '[a-z]{4}[0-9]{4}') ;
create domain NoGroupe
  Text
  check (value similar to '[0-9]{2}') ;
create domain Nom
  Text
  check (length(value) <= 120 and value similar to '[[:alpha:]]+([-’ [:alpha:]])*[[:alpha:]]+') ;
create domain Note
  SmallInt
  check (value between 1 and 90) ;
create domain Sigle
  Text check (value similar to '[A-Z]{3}[0-9]{3}') ;
create domain Titre
  Text ;
create domain Trimestre
  Text
  check (value similar to '[0-9]{4}-[1-3]') ;
--
--  Définir la portée.
--
set search_path to 'offres' ;
--
--
create table Cours
(
  sigle Sigle not null,
  titre Titre not null,
  credit CDC not null,
  --  df sigle -> titre
  --  df sigle -> crédit
  constraint Cours_cc0 primary key (sigle)
) ;
comment on table Cours is
  'Le cours (identifié par le sigle "sigle") est défini dans le répertoire des cours offerts par l’Université. '
  'Il a pour titre "titre". '
  'Il comporte "credit" crédit(s). '
;

create table Groupe
(
  sigle Sigle not null,
  trimestre Trimestre not null,
  noGroupe NoGroupe not null,
  constraint Groupe_cc0 primary key (sigle, trimestre, noGroupe),
  constraint Groupe_cr0 foreign key (sigle) references Cours
) ;
comment on table Groupe is
  'Le groupe (identifié par le sigle "sigle", le numéro "noGroupe" et le trimestre "trimestre") est constitué. '
;

create table Offre
  -- Correspond à l’offre planifiée.
(
  sigle Sigle not null,
  trimestre Trimestre not null,
  constraint Offre_cc0 primary key (sigle, trimestre),
  constraint Offre_cr0 foreign key (sigle) references Cours
) ;
comment on table Offre is
  'l’Université s’engage à offrir le cours "sigle" au trimestre "trimestre". '
;

--
--  Définir la portée.
--
set search_path to 'etudiants';
--
--
create table Etudiant
(
  matriculeE MatriculeE not null,
  nom Nom not null,
  ddn Date not null,
  --  df matriculeE -> nom
  --  df matriculeE -> ddn
  constraint Etudiant_cc0 primary key (matriculeE)
) ;
comment on table Etudiant is
  'La personne étudiante (identifiée par le matricule "matriculeE") possède un dossier à l’Université. '
  'Son nom est "nom". '
  'Sa date de naissance est "ddn". '
;

create table Inscription
(
  matriculeE MatriculeE not null,
  sigle Sigle not null,
  trimestre Trimestre not null,
  noGroupe NoGroupe not null,
  constraint Inscription_cc0 primary key (matriculeE, sigle, trimestre, noGroupe),
  constraint Inscription_cr0 foreign key (sigle, trimestre, noGroupe) references offres.Groupe
) ;
comment on table Inscription is
  'La personne étudiante (identifiée par "matriculeE") est inscrite au '
  'groupe identifié par le sigle "sigle", le numéro "noGroupe" et le trimestre "trimestre".'
;

create table Evaluation
(
  matriculeE MatriculeE not null,
  sigle Sigle not null,
  trimestre Trimestre not null,
  noGroupe NoGroupe not null,
  note Note not null,
  --  df sigle, trimestre, noGroupe, matriculeE -> note
  constraint Evaluation_cc0 primary key (matriculeE, sigle, trimestre, noGroupe),
  constraint Evaluation_cr0 foreign key (sigle, trimestre, noGroupe, matriculeE) references Inscription
) ;
comment on table Evaluation is
  'La personne étudiante (identifiée par "matriculeE") inscrite au '
  'groupe identifié par sigle "sigle", le numéro "noGroupe" et le trimestre "trimestre" '
  'a obtenu la note "note". '
;

--
--  Définir la portée.
--
set search_path to 'professeurs' ;
--
--
create table Professeur
(
  matriculeP MatriculeP not null,
  nom Nom not null,
  --  df matriculeP -> nom
  constraint Professeur_cc0 primary key (matriculeP)
) ;
comment on table Professeur is
  'La personne enseignante (identifiée par le matricule "matriculeP") possède un dossier à l’Université. '
  'Une personne enseignante est une professeure, un professeur, une chargée de cours ou un chargé de cours. '
  'Son nom est "nom". '
;

create table Competence
(
  sigle Sigle not null,
  matriculeP MatriculeP not null,
  constraint Competence_cc0 primary key (sigle, matriculeP),
  constraint Competence_cr0 foreign key (sigle) references offres.Cours,
  constraint Competence_cr1 foreign key (matriculeP) references Professeur
) ;
comment on table Competence is
  'La personne enseignante (identifiée par "matriculeP") a la compétence requise '
  'pour assure le cours (identifié par le sigle "sigle"). '
;

create table Disponibilite
(
  trimestre Trimestre,
  matriculeP MatriculeP,
  constraint Disponibilite_cc0 primary key (trimestre, matriculeP),
  constraint Disponibilite_cr0 foreign key (trimestre) references offres.Cours,
  constraint Disponibilite_cr1 foreign key (matriculeP) references Professeur
) ;
comment on table Disponibilite is
  'La personne enseignante (identifiée par "matriculeP") est disponible '
  'pour enseigner durant le trimestre "trimestre". '
;

create table Professeur_Bureau_PRE
(
  matriculeP MatriculeP not null,
  bureau Bureau not null,
  --  df matriculeP -> bureau
  constraint Professeur_Bureau_PRE_cc0 primary key (matriculeP),
  constraint Professeur_Bureau_PRE_cr0 foreign key (matriculeP) references Professeur
);
comment on table Professeur_Bureau_PRE is
  'La personne enseignante (identifiée par le matricule "matriculeP") a un bureau '
  'et ce bureau est le "bureau". '
;

create table Professeur_Bureau_ABS
(
  matriculeP MatriculeP not null,
  cause Cause not null,
  --  df matriculeP -> cause
  constraint Professeur_Bureau_ABS_cc0 primary key (matriculeP),
  constraint Professeur_Bureau_ABS_cr1 foreign key (matriculeP) references Professeur
) ;
comment on table Professeur_Bureau_ABS is
  'La personne enseignante (identifiée par le matricule "matriculeP") n’a pas de bureau '
  'pour la raison "cause". '
;

create table Affectation
  -- Correspond à l’offre effective.
(
  sigle Sigle,
  trimestre Trimestre not null,
  noGroupe NoGroupe not null,
  matriculeP MatriculeP not null,
  -- Pour permettre à un groupe de professeur d’assurer la formation, il faudrait
  -- ajouter matriculeP à la clé candidate.
  constraint Affectation_cc0 primary key (sigle, trimestre, noGroupe),
  constraint Affectation_cr0 foreign key (sigle, trimestre, noGroupe) references offres.Groupe,
  constraint Affectation_cr1 foreign key (matriculeP) references Professeur
) ;
comment on table Affectation is
  'La personne enseignante (identifiée par "matriculeP") assure la formation du '
  'groupe identifié par les  sigle "sigle", le numéro "noGroupe" et le trimestre "trimestre". '
;

/*
==============================================================================
universite_ind.sql
------------------------------------------------------------------------------
Contributeurs : 
    Atouga II Emmanuel Désiré
    Kengne Kengne Pierre-Edwin
    Missamou Siefou Joevinio
    Dohicou Kopse Jonathan
Licence : Projet académique UCAC-ICAM, reproduction autorisée à usage pédagogique.
==============================================================================
*/

/*
==============================================================================
universite_imm.sql
------------------------------------------------------------------------------
Produit     : Université
Résumé      : Script de création de la base, des schémas et des tables
Projet      : UCAC-ICAM - Gestion Universitaire
Etudiants : 
    Atouga II Emmanuel Désiré
    Kengne Kengne Pierre-Edwin
    Missamou Siefou Joevinio
    Dohicou Kopse Jonathan
Version     : 2025-05-07
Statut      : Développement
Encodage    : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme  : PostgreSQL 14+
==============================================================================
*/
--
--  Ouvrir la portée de l’interface précédemment créée.
--
set search_path to 'etudiants','professeurs','offres' ;

--
--  Déterminer si l’offre effective est en accord avec l’offre planifiée.
--

create or replace function Offre_plan_non_couverte ()
  returns table
    (
      sigle Sigle,
      trimestre Trimestre
    )
begin atomic
  select sigle, trimestre from Offre
  except
  select distinct sigle, trimestre from Affectation ;
end ;
comment on function Offre_plan_non_couverte () is
  'Détermine les cours de l’offre (planifiée) non couverts par l’affection (offre effective).'
;

create or replace function Offre_eff_conforme () returns boolean

return
  (select not exists(select * from Offre_plan_non_couverte())) ;

comment on function Offre_eff_conforme () is
  'Détermine si l’affection (offre effective) est conforme à l’offre (planifiée).'
;

--
--  Déterminer si un étudiant remplit les conditions préalables à un cours.
--
--  DONE 2021-03-19 (LL01) : Déterminer si un étudiant remplit les conditions préalables à un cours.

    create or replace function Etud_prealable_manquant (me MatriculeE, s Sigle)
      returns table (sigle_pre Sigle)
    as $$
    begin
      return query
        select p.siglePrealable as sigle_pre
        from Prealable p
        where p.sigle = s
          and not exists (
            select 1
            from Inscription i
            join Evaluation e on i.matriculeE = e.matriculeE
                             and i.sigle = e.sigle
                             and i.trimestre = e.trimestre
                             and i.noGroupe = e.noGroupe
            join Groupe g on i.sigle = g.sigle
                         and i.trimestre = g.trimestre
                         and i.noGroupe = g.noGroupe
            where i.matriculeE = me
              and g.sigle = p.siglePrealable
              and e.note >= 60
          );
    end;
    $$ language plpgsql;

    create or replace function Etud_prealable_satisfait (me MatriculeE, s Sigle)
    returns boolean as $$
    begin
      return not exists(select * from Etud_prealable_manquant(me, s));
    end;
    $$ language plpgsql;


--
--  Ajouter, retirer, modifier : un professeur, un étudiant, un cours, une offre, un groupe.
--

--  Professeur
--  DONE 2021-03-19 (LL01) : Ajouter, retirer, modifier un professeur

    create or replace function Prof_ajouter(n Nom, b Bureau, out mp MatriculeP)
    as $$
    begin
      insert into Professeur (nom) values (n) returning matriculeP into mp;
      insert into Professeur_Bureau_PRE (matriculeP, bureau) values (mp, b);
    end;
    $$ language plpgsql;

    create or replace procedure Prof_modifier_nom(mp MatriculeP, n Nom)
    as $$
    begin
      update Professeur set nom = n where matriculeP = mp;
    end;
    $$ language plpgsql;

    create or replace procedure Prof_retirer(mp MatriculeP)
    as $$
    begin
      delete from Professeur where matriculeP = mp;
    end;
    $$ language plpgsql;

--  Étudiant
--  DONE 2021-03-19 (LL01) : Ajouter, retirer, modifier un étudiant

    create or replace function Etud_ajouter(n Nom, d Date, out me MatriculeE)
    as $$
    begin
      insert into Etudiant (nom, ddn) values (n, d) returning matriculeE into me;
    end;
    $$ language plpgsql;

    create or replace procedure Etud_modifier_nom(me MatriculeE, n Nom)
    as $$
    begin
      update Etudiant set nom = n where matriculeE = me;
    end;
    $$ language plpgsql;

    create or replace procedure Etud_modifier_ddn(me MatriculeE, d Date)
    as $$
    begin
      update Etudiant set ddn = d where matriculeE = me;
    end;
    $$ language plpgsql;

    create or replace procedure Etud_retirer(me MatriculeE)
    as $$
    begin
      delete from Etudiant where matriculeE = me;
    end;
    $$ language plpgsql;

--  Cours
--  DONE 2021-03-19 (LL01) : Ajouter, retirer, modifier un cours

    create or replace function Cours_ajouter(t Titre, c CDC, out s Sigle)
    as $$
    begin
      insert into Cours (titre, credit) values (t, c) returning sigle into s;
    end;
    $$ language plpgsql;

    create or replace procedure Cours_modifier_titre(s Sigle, t Titre)
    as $$
    begin
      update Cours set titre = t where sigle = s;
    end;
    $$ language plpgsql;

    create or replace procedure Cours_modifier_credit(s Sigle, c CDC)
    as $$
    begin
      update Cours set credit = c where sigle = s;
    end;
    $$ language plpgsql;

    create or replace procedure Cours_retirer(s Sigle)
    as $$
    begin
      delete from Cours where sigle = s;
    end;
    $$ language plpgsql;

--  Offre
--  DONE 2021-03-19 (LL01) : Ajouter, retirer, modifier une offre

    create or replace procedure Offre_ajouter(s Sigle, t Trimestre)
    as $$
    begin
      insert into Offre (sigle, trimestre) values (s, t);
    end;
    $$ language plpgsql;

    create or replace procedure Offre_retirer(s Sigle, t Trimestre)
    as $$
    begin
      delete from Offre where sigle = s and trimestre = t;
    end;
    $$ language plpgsql;

--  Groupe
--  DONE 2021-03-19 (LL01) : Ajouter, retirer, modifier un groupe

    create or replace function Groupe_ajouter(s Sigle, t Trimestre, p MatriculeP, out ng NoGroupe)
    as $$
    begin
      insert into Groupe (sigle, trimestre, noGroupe)
      values (s, t, (select coalesce(max(noGroupe::integer), 0) + 1 from Groupe where sigle = s and trimestre = t)::NoGroupe)
      returning noGroupe into ng;

      insert into Affectation (sigle, trimestre, noGroupe, matriculeP)
      values (s, t, ng, p);
    end;
    $$ language plpgsql;

    create or replace procedure Groupe_retirer(s Sigle, t Trimestre, ng NoGroupe)
    as $$
    begin
      delete from Groupe where sigle = s and trimestre = t and noGroupe = ng;
    end;
    $$ language plpgsql;


--
--  Ajouter, retirer : une compétence, une disponibilité ou une affectation à un professeur.
--
--  DONE 2021-03-19 (LL01) : Ajouter, retirer : une compétence, une disponibilité ou une affectation à un professeur.

        create or replace procedure Competence_ajouter(mp MatriculeP, s Sigle)
        as $$
        begin
          insert into Competence (matriculeP, sigle) values (mp, s);
        end;
        $$ language plpgsql;

        create or replace procedure Competence_retirer(mp MatriculeP, s Sigle)
        as $$
        begin
          delete from Competence where matriculeP = mp and sigle = s;
        end;
        $$ language plpgsql;

        create or replace procedure Dispo_ajouter(mp MatriculeP, t Trimestre)
        as $$
        begin
          insert into Disponibilite (matriculeP, trimestre) values (mp, t);
        end;
        $$ language plpgsql;

        create or replace procedure Dispo_retirer(mp MatriculeP, t Trimestre)
        as $$
        begin
          delete from Disponibilite where matriculeP = mp and trimestre = t;
        end;
        $$ language plpgsql;

        create or replace procedure Affectation_ajouter(s Sigle, t Trimestre, ng NoGroupe, mp MatriculeP)
        as $$
        begin
          insert into Affectation (sigle, trimestre, noGroupe, matriculeP)
          values (s, t, ng, mp);
        end;
        $$ language plpgsql;

        create or replace procedure Affectation_retirer(s Sigle, t Trimestre, ng NoGroupe)
        as $$
        begin
          delete from Affectation where sigle = s and trimestre = t and noGroupe = ng;
        end;
        $$ language plpgsql;
--
--  Ajouter, retirer : une inscription d’un étudiant à un groupe.
--
--  DONE 2021-03-19 (LL01) : Ajouter, retirer : une inscription d’un étudiant à un groupe.

    create or replace procedure Inscription_ajouter(me MatriculeE, s Sigle, t Trimestre, ng NoGroupe)
    as $$
    begin
      insert into Inscription (matriculeE, sigle, trimestre, noGroupe)
      values (me, s, t, ng);
    end;
    $$ language plpgsql;

    create or replace procedure Inscription_retirer(me MatriculeE, s Sigle, t Trimestre, ng NoGroupe)
    as $$
    begin
      delete from Inscription
      where matriculeE = me and sigle = s and trimestre = t and noGroupe = ng;
    end;
    $$ language plpgsql;
--
--  Ajouter, retirer : un préalable à un cours.
--
--  DONE 2021-03-19 (LL01) : Ajouter, retirer : un préalable à un cours.

    create or replace procedure Prealable_ajouter(s Sigle, sp Sigle)
    as $$
    begin
      insert into Prealable (sigle, siglePrealable) values (s, sp);
    end;
    $$ language plpgsql;

    create or replace procedure Prealable_retirer(s Sigle, sp Sigle)
    as $$
    begin
      delete from Prealable where sigle = s and siglePrealable = sp;
    end;
    $$ language plpgsql;
--
--  Attribuer, modifier : une note à un étudiant en regard d’une inscription à un groupe.
--
--  DONE 2021-03-19 (LL01) : Attribuer, modifier : une note à un étudiant en regard d’une inscription à un groupe.

    create or replace procedure Note_attribuer(me MatriculeE, s Sigle, t Trimestre, ng NoGroupe, n Note)
    as $$
    begin
      insert into Evaluation (matriculeE, sigle, trimestre, noGroupe, note)
      values (me, s, t, ng, n)
      on conflict (matriculeE, sigle, trimestre, noGroupe)
      do update set note = n;
    end;
    $$ language plpgsql;
/*
==============================================================================
universite_imm.sql
------------------------------------------------------------------------------
Contributeurs : 
    Atouga II Emmanuel Désiré
    Kengne Kengne Pierre-Edwin
    Missamou Siefou Joevinio
    Dohicou Kopse Jonathan
Licence : Projet académique UCAC-ICAM, reproduction autorisée à usage pédagogique.
==============================================================================
*/