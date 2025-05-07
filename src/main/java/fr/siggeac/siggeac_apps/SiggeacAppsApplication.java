package fr.siggeac.siggeac_apps;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication (scanBasePackages = {
		"fr.siggeac.siggeac_apps",
		"fr.siggeac.siggeac_apps.etudiants",
		"fr.siggeac.siggeac_apps.professeurs",
		"fr.siggeac.siggeac_apps.offres_services"
	}
)
public class SiggeacAppsApplication {

	public static void main(String[] args) {
		SpringApplication.run(SiggeacAppsApplication.class, args);
	}

}
