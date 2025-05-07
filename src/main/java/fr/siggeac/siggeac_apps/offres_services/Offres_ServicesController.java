package fr.siggeac.siggeac_apps.offres_services;

import org.jooq.DSLContext;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;



@Controller
@RequestMapping("/offre")
public class Offres_ServicesController {

    private final DSLContext dsl;
    public Offres_ServicesController(DSLContext dsl) {
        this.dsl = dsl;
    }

    /**
     * Page de liste des services.
     *
     * @return le nom de la vue associ e
     */
    @GetMapping
    public String list() {
        return "offre/index";
    }
}