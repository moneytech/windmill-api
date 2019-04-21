package io.windmill.windmill.services;

import static io.windmill.windmill.persistence.QueryConfiguration.identitifier;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.persistence.NoResultException;
import javax.persistence.Query;
import javax.validation.constraints.NotNull;

import io.windmill.windmill.persistence.Export;
import io.windmill.windmill.persistence.QueryConfiguration;
import io.windmill.windmill.persistence.WindmillEntityManager;
import io.windmill.windmill.persistence.sns.Endpoint;
import io.windmill.windmill.services.Notification.Messages;
import io.windmill.windmill.services.exceptions.ExportGoneException;
import io.windmill.windmill.services.exceptions.StorageServiceException;

@ApplicationScoped
public class ExportService {

    @Inject
    private AuthenticationService authenticationService;    

    @Inject 
    private NotificationService notificationService; 

	@Inject
    private WindmillEntityManager entityManager;

    @Inject 
    private StorageService storageService;

	@PostConstruct
    private void init() {
    	entityManager = WindmillEntityManager.unwrapEJBExceptions(this.entityManager);        
    }

	public Export get(UUID export_identifier) throws ExportGoneException {		
				
		try {
			return this.entityManager.getSingleResult("export.find_by_identifier", identitifier(export_identifier));	
		} catch (NoResultException e) {
			throw new ExportGoneException(ExportGoneException.EXPORT_NOT_FOUND, e);
		}		
	}

	public Export belongs(UUID account_identifier, UUID export_identifier) throws ExportGoneException {
		try {
			
			Export export = this.entityManager.getSingleResult("export.belongs_to_account_identifier", new QueryConfiguration<Export>() {
		
				@Override
				public @NotNull Query apply(Query query) {
					query.setParameter("identifier", export_identifier);
					query.setParameter("account_identifier", account_identifier);
					
					return query;
				}
			});
			
			return export;
		} catch (NoResultException e) {
			throw new ExportGoneException(ExportGoneException.EXPORT_NOT_FOUND, e);
		}
	}    
	
	public void notify(Export export) 
	{
		String notification = Messages.of("New build", String.format("%s %s is now available to install.", export.getTitle(), export.getVersion()));
		
		List<Endpoint> endpoints = 
				this.entityManager.getResultList("endpoint.find_by_account_identifier", 
						query -> query.setParameter("account_identifier", export.getAccount().getIdentifier())); 
		
		this.notificationService.notify(notification, endpoints);
	}

	public void delete(Export export) throws StorageServiceException {

		this.entityManager.delete(export);
		
		Instant fiveMinutesFromNow = Instant.now().plus(Duration.ofMinutes(5));

		this.storageService.delete(this.authenticationService.export(export, fiveMinutesFromNow));
		this.storageService.delete(this.authenticationService.manifest(export, fiveMinutesFromNow));
		
	}
}
