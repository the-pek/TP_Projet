package fr.siggeac.app_siggeac;

import org.jooq.DSLContext;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;



@Controller
@RequestMapping("/home")
public class SiggeacController {

    private final DSLContext dsl;
    public SiggeacController(DSLContext dsl) {
        this.dsl = dsl;
    }

    /**
     * Page de liste des services.
     *
     * @return le nom de la vue associ e
     */
    @GetMapping
    public String list() {
        return "HomePage/index";
    }
}