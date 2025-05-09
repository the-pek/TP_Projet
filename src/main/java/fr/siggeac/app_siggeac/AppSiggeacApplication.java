package fr.siggeac.app_siggeac;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication (scanBasePackages = {
		"fr.siggeac.app_siggeac",
		"fr.siggeac.app_siggeac.etudiants",
		"fr.siggeac.app_siggeac.professeurs",
		"fr.siggeac.app_siggeac.offres_services"
	}
)

public class AppSiggeacApplication {

	public static void main(String[] args) {
		SpringApplication.run(AppSiggeacApplication.class, args);
	}

}
