package com.employee_management.encryption;


import lombok.*;

@Getter
@Setter
@ToString
public class EncryptionDetail {
    private byte[] plaintextKey;
    private byte[] encryptedKey;   // DEK encrypted using AWS KMS
    private byte[] iv;

    public EncryptionDetail(byte[] plaintextKey, byte[] encryptedKey, byte[] iv) {
        this.plaintextKey = plaintextKey;
        this.encryptedKey = encryptedKey;
        this.iv = iv;
    }
}
