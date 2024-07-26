
WITH DepartmentStats AS (
    SELECT Department,
           STDEV(Salary) AS Standard_Deviation,
           AVG(Salary) AS Average
    FROM Employee_Salaries 
    WHERE Salary >= 10000 
    GROUP BY Department
),
DepartmentOutliers AS (
    SELECT emp.Department,
           emp.Salary,
           ds.Standard_Deviation,
           ds.Average,
           (emp.Salary - ds.Average) / ds.Standard_Deviation AS Zscore
    FROM Employee_Salaries emp
    JOIN DepartmentStats ds ON emp.Department = ds.Department
    WHERE emp.Salary >= 10000
),
AboveBelowAverageCounts AS (
    SELECT 
        emp.Department,
        SUM(CASE WHEN emp.Salary > ds.Average THEN 1 ELSE 0 END) AS Above_Average_Count,
        SUM(CASE WHEN emp.Salary <= ds.Average THEN 1 ELSE 0 END) AS Below_Average_Count
    FROM 
        Employee_Salaries emp
    JOIN 
        DepartmentStats ds ON emp.Department = ds.Department
    WHERE 
        emp.Salary >= 10000
    GROUP BY 
        emp.Department
)
SELECT 
    ds.Department,
    ROUND(ds.Standard_Deviation, 2) AS Standard_Deviation,    
    ROUND(ds.Average, 2) AS Average,
    ROUND((ds.Standard_Deviation / ds.Average) * 100, 2) AS Coefficient_of_variation,
    SUM(CASE WHEN d_out.Zscore > 1.96 OR d_out.Zscore < -1.96 THEN 1 ELSE 0 END) AS Outliers_Count,
    abac.Above_Average_Count,
    abac.Below_Average_Count
INTO 
    DepartmentStatistics
FROM 
    DepartmentStats ds
LEFT JOIN 
    DepartmentOutliers d_out ON ds.Department = d_out.Department
LEFT JOIN 
    AboveBelowAverageCounts abac ON ds.Department = abac.Department
GROUP BY 
    ds.Department, ds.Standard_Deviation, ds.Average, abac.Above_Average_Count, abac.Below_Average_Count
ORDER BY 
    ds.Department;

select* from DepartmentStatistics