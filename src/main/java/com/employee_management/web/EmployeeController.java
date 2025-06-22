package com.employee_management.web;

import com.employee_management.data.Employee;
import com.employee_management.encryption.EncryptionDetail;
import com.employee_management.encryption.EncryptionUtil;
import com.employee_management.repository.EmployeeRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.util.Base64;
import java.util.Optional;

@RestController
@RequestMapping("/api")
public class EmployeeController {

    @Autowired
    private EmployeeRepository employeeRepository;

    @Value("${employee-encryption.kms-key-id}")
    private String employeeEncryptionKmsKeyId;

    @Autowired
    private EncryptionUtil encryptionUtil;

    Logger logger = LoggerFactory.getLogger(EmployeeController.class);

    @GetMapping(value = "/getEmployees")
    public ResponseEntity<String> getEmployees() {
        logger.info("GET_EMPLOYEES X-Correlation-ID: {}", MDC.get("X-Correlation-ID"));
        return ResponseEntity.ok("[satish, vikas, pradeep, manoj]");
    }

    @GetMapping(value = "/getEmployee/{id}")
    //   @Cacheable(value = "employeecache1", keyGenerator = "employeeIdKeyGenerator", unless = "#result==null")
    public String getEmployee(@PathVariable(name = "id") String id) throws Exception {
        logger.info("GET_EMPLOYEE X-Correlation-ID: {}", MDC.get("X-Correlation-ID"));
        Optional<Employee> opt = employeeRepository.findById(id);
        if (!opt.isPresent()) {
            throw new Exception("id not present:" + id);
        }
        return opt.get().toString();
    }

    @PostMapping(value = "/employee")
    public ResponseEntity<Employee> createEmployee(@RequestBody Employee employee) throws InvalidAlgorithmParameterException, IllegalBlockSizeException, NoSuchPaddingException, BadPaddingException, NoSuchAlgorithmException, NoSuchProviderException, InvalidKeyException {
        EncryptionDetail encryptionDetail = getEncryptionDetail();
        Cipher cipher = getDecryptionDetail(encryptionDetail);
        Employee employee1 = Employee.builder().id(employee.getId()).salary(employee.getSalary()).name(employee.getName()).adharCard(getEncryptData(encryptionDetail, employee.getAdharCard())).encryptedKey(encryptionDetail.getEncryptedKey()).iv(encryptionDetail.getIv()).build();
        Employee savedEmployee = employeeRepository.save(employee1);
        savedEmployee.setAdharCard(getDecryptData(cipher, savedEmployee.getAdharCard()));
        return ResponseEntity.ok(savedEmployee);
    }

    public EncryptionDetail getEncryptionDetail() {
        EncryptionDetail encryptionDetail = null;
        try {
            encryptionDetail = encryptionUtil.getEncryptionDetail(employeeEncryptionKmsKeyId);

        } catch (Exception exception) {
            exception.printStackTrace();
        }
        return encryptionDetail;
    }

    public Cipher getDecryptionDetail(EncryptionDetail encryptionDetail) {
        Cipher cipher = null;
        try {
            cipher = encryptionUtil.decrypt(encryptionDetail);
        } catch (Exception exception) {
            exception.printStackTrace();
        }
        return cipher;
    }

    public String getEncryptData(EncryptionDetail encryptionDetail, String plainData) throws IllegalBlockSizeException, BadPaddingException, NoSuchPaddingException, NoSuchAlgorithmException, NoSuchProviderException, InvalidAlgorithmParameterException, InvalidKeyException {
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding", "BC");
        cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(encryptionDetail.getPlaintextKey(), "AES"), new IvParameterSpec(encryptionDetail.getIv()));
        byte[] encryptedData = cipher.doFinal(plainData.getBytes(StandardCharsets.UTF_8));
        return Base64.getEncoder().encodeToString(encryptedData);
    }

    public String getDecryptData(Cipher cipher, String data) throws IllegalBlockSizeException, BadPaddingException {
        byte[] decryptedData = cipher.doFinal(Base64.getDecoder().decode(data));
        return new String(decryptedData, StandardCharsets.UTF_8);
    }
}
