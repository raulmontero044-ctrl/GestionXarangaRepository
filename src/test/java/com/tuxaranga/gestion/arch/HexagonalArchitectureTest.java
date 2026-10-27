package com.tuxaranga.gestion.arch;

import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;
import com.tngtech.archunit.library.Architectures;

@AnalyzeClasses(packages = "com.tuxaranga.gestion")
public class HexagonalArchitectureTest {
    @ArchTest
    static final ArchRule hexagonal_architecture_is_respected = Architectures.onionArchitecture()
            .domainModels("..domain..")
            .domainServices("..domain..")
            .applicationServices("..application..")
            .adapter("persistence", "..infrastructure.adapter.out.persistence..")
            .adapter("rest", "..infrastructure.adapter.in.web.rest..")
            .withOptionalLayers(true)
            .ensureAllClassesAreContainedInArchitectureIgnoringDependencies(
                    "..shared.infrastructure.exception..",
                    "..shared.infrastructure.config..",
                    "..GestionXarangaApplication"
            );

    @ArchTest
    static final ArchRule domain_should_not_depend_on_spring = com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses()
            .that().resideInAPackage("..domain..")
            .should().dependOnClassesThat().resideInAPackage("org.springframework..")
            .because("Domain must be pure without Spring dependencies");
}
