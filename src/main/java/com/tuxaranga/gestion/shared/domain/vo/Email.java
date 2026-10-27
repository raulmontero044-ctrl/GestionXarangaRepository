package com.tuxaranga.gestion.shared.domain.vo;

public record Email(String value) implements com.tuxaranga.gestion.shared.domain.model.ValueObject {
    public Email {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Email cannot be blank");
        }
    }
}
