package com.employee_management.encryption;

import com.amazonaws.services.kms.AWSKMS;
import com.amazonaws.services.kms.model.DecryptRequest;
import com.amazonaws.services.kms.model.GenerateDataKeyRequest;
import com.amazonaws.services.kms.model.GenerateDataKeyResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.util.Base64;

/*
I have an spring boot application which is connected to aws dynamodb, I want to use bouncy castle for the encryption and decryption of data while saving it in the dynamodb, can you please help me design this in best possible way where hackers can not hack system, also give me ondemind and rotational key rotation. I am using terraform and dont want manually creation of aws resources

 */
@Configuration
public class EncryptionUtil {

    @Autowired
    private AWSKMS kmsClient;


    public EncryptionDetail getEncryptionDetail(String kmsKeyId) throws Exception {
        // Step 1: Generate Data Encryption Key (DEK)
        GenerateDataKeyRequest dataKeyRequest = new GenerateDataKeyRequest().withKeyId(kmsKeyId).withKeySpec("AES_256");
        GenerateDataKeyResult dataKeyResult = kmsClient.generateDataKey(dataKeyRequest);

        byte[] plaintextKey = dataKeyResult.getPlaintext().array();
        byte[] encryptedKey = dataKeyResult.getCiphertextBlob().array();

        // Step 2: Encrypt the data using the plaintext key and AES (Bouncy Castle)
        byte[] iv = new byte[16];
        SecureRandom random = new SecureRandom();
        random.nextBytes(iv);

        // Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding", "BC");
        //  cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(plaintextKey, "AES"), new IvParameterSpec(iv));
        // byte[] encryptedData = cipher.doFinal(plainData.getBytes(StandardCharsets.UTF_8));

        // Return encrypted data and encrypted DEK
        // return new EncryptedPayload(Base64.getEncoder().encodeToString(encryptedData), Base64.getEncoder().encodeToString(encryptedKey), Base64.getEncoder().encodeToString(iv));
        return new EncryptionDetail(plaintextKey, encryptedKey, iv);
    }

    public Cipher decrypt(EncryptionDetail encryptionDetail) throws IllegalBlockSizeException, BadPaddingException, NoSuchPaddingException, NoSuchAlgorithmException, NoSuchProviderException, InvalidAlgorithmParameterException, InvalidKeyException, NoSuchProviderException, InvalidAlgorithmParameterException, InvalidKeyException {
        // Step 1: Decrypt the DEK using KMS
        DecryptRequest decryptRequest = new DecryptRequest().withCiphertextBlob(ByteBuffer.wrap(Base64.getDecoder().decode(encryptionDetail.getEncryptedKey())));
        ByteBuffer decryptedKey = kmsClient.decrypt(decryptRequest).getPlaintext();

        // Step 2: Decrypt data using AES
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding", "BC");
        cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(decryptedKey.array(), "AES"), new IvParameterSpec(Base64.getDecoder().decode(encryptionDetail.getIv())));
        //   byte[] decryptedData = cipher.doFinal(Base64.getDecoder().decode(encryptionDetail.getCiphertext()));
        //   return new String(decryptedData, StandardCharsets.UTF_8);
        return cipher;
    }
}