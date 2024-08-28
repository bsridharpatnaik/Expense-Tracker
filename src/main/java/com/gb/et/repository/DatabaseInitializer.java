package com.gb.et.repository;

import com.gb.et.models.Organization;
import com.gb.et.models.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class DatabaseInitializer implements CommandLineRunner {

    @Autowired
    private OrganizationRepository organizationRepository;

    @Autowired
    private UserRepository userRepository;

    @Override
    public void run(String... args) throws Exception {
        // Ensure 'egcity' organization exists
        Optional<Organization> egcityOptional = organizationRepository.findByName("egcity");
        Organization egcity;
        if (!egcityOptional.isPresent()) {
            egcity = new Organization();
            egcity.setName("egcity");
            egcity = organizationRepository.save(egcity);
        } else {
            egcity = egcityOptional.get();
        }

        // Ensure 'anonymous' organization exists
        Optional<Organization> anonymousOptional = organizationRepository.findByName("anonymous");
        if (!anonymousOptional.isPresent()) {
            Organization anonymous = new Organization();
            anonymous.setName("anonymous");
            organizationRepository.save(anonymous);
        }

        // Ensure 'raja' user exists with 'egcity' organization
        Optional<User> rajaOptional = userRepository.findByUsername("raja");
        if (!rajaOptional.isPresent()) {
            User raja = new User();
            raja.setUsername("raja");
            raja.setPassword("$2a$04$dzz91QUINWlllzzX7cK/TudKCZb5ZMlvCHdxEkx/nHUaX7d/dbFIa"); // Remember to hash this password in real use
            raja.setOrganization(egcity);
            userRepository.save(raja);
        }
    }
}