SELECT company.Company_code,founder,COUNT(DISTINCT lead_manager_code),COUNT(DISTINCT senior_manager_code) ,COUNT(DISTINCT manager_code),COUNT(DISTINCT employee_code) 
FROM Employee
JOIN company On company.company_code=employee.company_code
GROUP BY 1,2
ORDER BY 1
