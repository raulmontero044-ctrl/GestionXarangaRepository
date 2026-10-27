package com.tuxaranga.gestion.shared.domain.vo;

import java.math.BigDecimal;

public record Money(BigDecimal amount, String currency) implements com.tuxaranga.gestion.shared.domain.model.ValueObject {
    public Money {
        if (amount == null) {
            throw new IllegalArgumentException("Amount cannot be null");
        }
        if (currency == null || currency.isBlank()) {
            throw new IllegalArgumentException("Currency cannot be blank");
        }
    }
}
