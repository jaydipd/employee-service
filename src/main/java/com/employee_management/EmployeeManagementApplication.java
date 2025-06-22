package com.employee_management;

import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.socialsignin.spring.data.dynamodb.repository.config.EnableDynamoDBRepositories;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.FilterType;
import org.springframework.stereotype.Repository;

import java.security.Security;

@SpringBootApplication
@EnableDynamoDBRepositories(basePackages = "com.employee_management.repository", includeFilters = @ComponentScan.Filter(type = FilterType.ANNOTATION, classes = Repository.class))
public class EmployeeManagementApplication implements CommandLineRunner {
    public static void main(String[] args) {
        SpringApplication.run(EmployeeManagementApplication.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        Security.addProvider(new BouncyCastleProvider());
    }
}
