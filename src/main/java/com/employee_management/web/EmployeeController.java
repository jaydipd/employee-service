package com.employee_management.web;

import com.employee_management.data.Employee;
import com.employee_management.repository.EmployeeRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api")
public class EmployeeController {

    @Autowired
    private EmployeeRepository employeeRepository;

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
    public ResponseEntity<Employee> createEmployee(@RequestBody Employee employee) {
        return ResponseEntity.ok(employeeRepository.save(employee));

    }
}