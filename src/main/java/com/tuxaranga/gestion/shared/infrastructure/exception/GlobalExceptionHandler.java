package com.tuxaranga.gestion.shared.infrastructure.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import java.net.URI;
import java.time.OffsetDateTime;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(com.tuxaranga.gestion.shared.domain.exception.NotFoundException.class)
    public ProblemDetail handleNotFound(com.tuxaranga.gestion.shared.domain.exception.NotFoundException ex, WebRequest request) {
        ProblemDetail pd = ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, ex.getMessage());
        pd.setType(URI.create("https://api.tuxaranga.gestion/errors/not-found"));
        pd.setTitle("Not Found");
        pd.setProperty("timestamp", OffsetDateTime.now());
        pd.setInstance(URI.create(request.getDescription(false).replace("uri=", "")));
        return pd;
    }

    @ExceptionHandler(com.tuxaranga.gestion.shared.domain.exception.DomainException.class)
    public ProblemDetail handleDomain(com.tuxaranga.gestion.shared.domain.exception.DomainException ex, WebRequest request) {
        ProblemDetail pd = ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, ex.getMessage());
        pd.setType(URI.create("https://api.tuxaranga.gestion/errors/domain"));
        pd.setTitle("Business Error");
        pd.setProperty("timestamp", OffsetDateTime.now());
        pd.setInstance(URI.create(request.getDescription(false).replace("uri=", "")));
        return pd;
    }

    @ExceptionHandler(Exception.class)
    public ProblemDetail handleGeneric(Exception ex, WebRequest request) {
        ProblemDetail pd = ProblemDetail.forStatusAndDetail(HttpStatus.INTERNAL_SERVER_ERROR, "Internal server error");
        pd.setType(URI.create("https://api.tuxaranga.gestion/errors/internal"));
        pd.setTitle("Internal Server Error");
        pd.setProperty("timestamp", OffsetDateTime.now());
        pd.setInstance(URI.create(request.getDescription(false).replace("uri=", "")));
        return pd;
    }
}
