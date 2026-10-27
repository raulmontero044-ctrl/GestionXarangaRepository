package com.tuxaranga.gestion;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@EnableJpaAuditing(auditorAwareRef = "auditorAwareImpl")
@SpringBootApplication
public class GestionXarangaApplication {
    public static void main(String[] args) {
        SpringApplication.run(GestionXarangaApplication.class, args);
    }
}
