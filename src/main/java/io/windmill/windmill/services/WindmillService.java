package io.windmill.windmill.services;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriBuilderException;

import org.jboss.logging.Logger;

import com.amazonaws.AmazonClientException;
import com.amazonaws.services.s3.model.ObjectMetadata;

import io.windmill.windmill.common.Metadata;
import io.windmill.windmill.persistence.Windmill;
import io.windmill.windmill.persistence.WindmillDAO;
import io.windmill.windmill.services.Notification.Messages;
import io.windmill.windmill.web.common.UriBuilders;

@ApplicationScoped
public class WindmillService {

    private static final Logger LOGGER = Logger.getLogger(WindmillService.class);

    @Inject
    AccountService accountService; 

    @Inject
    NotificationService notificationService; 

    @Inject 
    StorageService storageService;
    
	@Inject
	private WindmillDAO windmillDAO;

	public List<Windmill> get(String account_identifier) {
		
	      List<Windmill> windmills = this.windmillDAO.windmills(account_identifier);
	      
	      LOGGER.debug(String.format("Found: %s", windmills.size()));
	      
	      return windmills;
	}

	/**
	 * 
	 * @param account_identifier
	 * @param metadata
	 * @param ipa
	 * @param plist
	 * @return a URI in the itms format, e.g. "itms-services://?action=download-manifest&url=https://ota.windmill.io/14810686-4690-4900-ADA5-8B0B7338AA39/io.windmill.windmill/1.0/windmill.plist"
	 * @throws FileNotFoundException
	 * @throws URISyntaxException 
	 * @throws UriBuilderException 
	 * @throws IllegalArgumentException 
	 */
	public URI createOrUpdate(String account_identifier, Metadata metadata, File ipa, ByteArrayOutputStream plist) throws FileNotFoundException, IllegalArgumentException, URISyntaxException 
	{
		Windmill windmill = accountService.create(account_identifier, metadata.getIdentifier(), metadata.getTitle(), metadata.getVersion());
	
	    LOGGER.debug(String.format("Created or updated windmill for %s with metadata.bundle-identifier '%s', metadata.bundle-version '%s', metadata.title '%s'", account_identifier, windmill.getIdentifier(), windmill.getVersion(), windmill.getTitle()));

		URI path = UriBuilder.fromPath(account_identifier)
				.path(metadata.getIdentifier())
				.path(String.valueOf(metadata.getVersion()))
				.path(metadata.getTitle())
				.build();		
		
		try {
			ObjectMetadata ipaMetadata = new ObjectMetadata();
			ipaMetadata.setContentLength(ipa.length());
			storageService.upload(new FileInputStream(ipa), String.format("%s.ipa", path), ipaMetadata);
			
			byte[] byteArray = plist.toByteArray();
			ObjectMetadata plistMetadata = new ObjectMetadata();
			plistMetadata.setContentLength(byteArray.length);			
			storageService.upload(new ByteArrayInputStream(byteArray), String.format("%s.plist", path), plistMetadata);			
		}
		catch (AmazonClientException | InterruptedException amazonException) {
			LOGGER.error("Unable to upload file, upload aws aborted.", amazonException);
			throw new StorageServiceException(amazonException);
		}
		
        String notification = Messages.of("New build", String.format("%s %s (455f6a1) is now available to install.", windmill.getTitle(), windmill.getVersion()));
        
		notificationService.notify(notification, notificationService.createPlatform("e14113c658cd67f35a870433f4218d51233eba0cbdc02c88e80adaad1dcc94c6"));

		String itmsURL = UriBuilders.createITMS(String.format("%s.plist", path));

		LOGGER.debug(itmsURL);

        return URI.create(itmsURL); 
	}
}
