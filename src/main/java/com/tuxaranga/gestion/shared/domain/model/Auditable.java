package com.tuxaranga.gestion.shared.domain.model;

import java.time.OffsetDateTime;

public abstract class Auditable {
    private OffsetDateTime createdAt;
    private String createdBy;
    private OffsetDateTime updatedAt;
    private String updatedBy;
}
