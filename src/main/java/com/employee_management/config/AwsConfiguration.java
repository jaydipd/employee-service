package com.employee_management.config;

import com.amazonaws.auth.DefaultAWSCredentialsProviderChain;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.kms.AWSKMS;
import com.amazonaws.services.kms.AWSKMSClient;
import com.amazonaws.services.kms.AWSKMSClientBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AwsConfiguration {

    @Value("${aws.region}")
    String region;


    @Bean
    public AmazonDynamoDB amazonDynamoDB() {
        return AmazonDynamoDBClientBuilder.standard().withCredentials(DefaultAWSCredentialsProviderChain.getInstance()).withRegion(region).build();

    }

    @Bean
    public AWSKMS kms() {
        return AWSKMSClientBuilder.standard().withCredentials(DefaultAWSCredentialsProviderChain.getInstance()).withRegion(region).build();
    }
}
