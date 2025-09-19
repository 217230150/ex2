-- 1. 核心业务表创建（按外键依赖顺序）
-- 患者表
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(50) NOT NULL,
    age INT NOT NULL CHECK (age > 0) -- 确保年龄为正数
);

-- 医生表
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(50) NOT NULL -- 存储医生专科领域，如'Cardiology'
);

-- 护士表
CREATE TABLE nurses (
    nurse_id INT PRIMARY KEY,
    nurse_name VARCHAR(50) NOT NULL,
    shift VARCHAR(20) NOT NULL -- 存储护士值班班次，如'morning'（早班）
);

-- 治疗表（关联患者、医生、护士）
CREATE TABLE treatments (
    treatment_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    nurse_id INT NOT NULL,
    treatment_type VARCHAR(50) NOT NULL, -- 存储治疗类型，如'Medication Administration'
    treatment_date DATE NOT NULL,
    -- 外键约束，确保关联数据合法性，删除主表数据时自动删除子表关联数据
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    FOREIGN KEY (nurse_id) REFERENCES nurses(nurse_id) ON DELETE CASCADE
);

-- 药品库存表（按题目要求创建）
CREATE TABLE medication_stock (
    medication_id INT PRIMARY KEY,
    medication_name VARCHAR(50) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0) -- 确保库存数量非负
);

-- 2. 测试数据插入（覆盖所有业务查询场景）
-- 插入患者数据（含80岁以上患者）
INSERT INTO patients (patient_id, patient_name, age) VALUES
(1, 'John Smith', 78),
(2, 'Mary Johnson', 85),
(3, 'Robert Williams', 72),
(4, 'Patricia Brown', 90),
(5, 'Michael Davis', 68),
(6, 'Emily Wilson', 82),
(7, 'David Martinez', 75),
(8, 'Linda Anderson', 65);

-- 插入医生数据（含心脏科医生）
INSERT INTO doctors (doctor_id, doctor_name, specialization) VALUES
(1, 'Dr. Sarah Lee', 'Cardiology'),
(2, 'Dr. James Taylor', 'Neurology'),
(3, 'Dr. Lisa Garcia', 'Cardiology'),
(4, 'Dr. Robert Martinez', 'Geriatrics'),
(5, 'Dr. Jennifer White', 'Orthopedics');

-- 插入护士数据（含早班护士）
INSERT INTO nurses (nurse_id, nurse_name, shift) VALUES
(1, 'Nurse Amy Clark', 'morning'),
(2, 'Nurse Brian Lewis', 'afternoon'),
(3, 'Nurse Jennifer Hall', 'morning'),
(4, 'Nurse David Allen', 'night');

-- 插入治疗数据（关联患者、医生、护士，含多种治疗类型）
INSERT INTO treatments (treatment_id, patient_id, doctor_id, nurse_id, treatment_type, treatment_date) VALUES
(1, 1, 1, 1, 'Medication Administration', '2024-01-10'),
(2, 2, 3, 3, 'Physical Therapy', '2024-01-12'),
(3, 3, 2, 2, 'Neurological Check', '2024-01-15'),
(4, 4, 4, 1, 'Medication Administration', '2024-01-18'),
(5, 5, 5, 4, 'Orthopedic Therapy', '2024-01-20'),
(6, 6, 1, 3, 'Cardiac Monitoring', '2024-01-22'),
(7, 1, 1, 1, 'Follow-up Consultation', '2024-01-25'),
(8, 7, 4, 2, 'Geriatric Assessment', '2024-01-28'),
(9, 8, 5, 4, 'Pain Management', '2024-02-01'),
(10, 2, 3, 3, 'Medication Adjustment', '2024-02-05'),
(11, 4, 4, 1, 'Nutritional Counseling', '2024-02-08'),
(12, 6, 1, 3, 'Cardiac Rehab', '2024-02-10');

-- 插入药品库存数据（用于库存相关查询）
INSERT INTO medication_stock (medication_id, medication_name, quantity) VALUES
(1, 'Aspirin', 150),
(2, 'Lisinopril', 80),
(3, 'Metformin', 120),
(4, 'Atorvastatin', 90),
(5, 'Ibuprofen', 200),
(6, 'Warfarin', 60),
(7, 'Omeprazole', 110);

-- 3. 业务查询（Q1-Q20，适配PostgreSQL语法）
-- Q1: 列出所有患者的姓名和年龄
SELECT patient_name, age 
FROM patients;

-- Q2: 列出所有心脏科（Cardiology）的医生
SELECT doctor_name 
FROM doctors 
WHERE specialization = 'Cardiology';

-- Q3: 查找所有年龄超过80岁的患者
SELECT patient_name, age 
FROM patients 
WHERE age > 80;

-- Q4: 列出所有患者，按年龄升序排列（ youngest first）
SELECT patient_name, age 
FROM patients 
ORDER BY age ASC;

-- Q5: 按专科统计医生数量
SELECT specialization, COUNT(doctor_id) AS doctor_count 
FROM doctors 
GROUP BY specialization;

-- Q6: 列出患者及其主治医生的姓名（通过治疗记录关联，去重避免重复）
SELECT DISTINCT p.patient_name, d.doctor_name 
FROM patients p
JOIN treatments t ON p.patient_id = t.patient_id
JOIN doctors d ON t.doctor_id = d.doctor_id;

-- Q7: 显示治疗详情及对应的患者姓名、医生姓名
SELECT 
    t.treatment_id,
    t.treatment_type,
    t.treatment_date,
    p.patient_name,
    d.doctor_name
FROM treatments t
JOIN patients p ON t.patient_id = p.patient_id
JOIN doctors d ON t.doctor_id = d.doctor_id;

-- Q8: 统计每个医生监管的患者数量（去重，避免同一患者多次治疗重复计数）
SELECT 
    d.doctor_name,
    COUNT(DISTINCT t.patient_id) AS supervised_patients_count
FROM doctors d
LEFT JOIN treatments t ON d.doctor_id = t.doctor_id
GROUP BY d.doctor_id, d.doctor_name;

-- Q9: 计算患者的平均年龄，别名设为average_age
SELECT AVG(age) AS average_age 
FROM patients;

-- Q10: 查找最常见的治疗类型（仅显示该类型）
SELECT treatment_type AS most_common_treatment
FROM treatments
GROUP BY treatment_type
ORDER BY COUNT(*) DESC
LIMIT 1;

-- Q11: 列出年龄超过所有患者平均年龄的患者
SELECT patient_name, age 
FROM patients 
WHERE age > (SELECT AVG(age) FROM patients);

-- Q12: 列出监管患者数量超过5人的医生
SELECT 
    d.doctor_name,
    COUNT(DISTINCT t.patient_id) AS patient_count
FROM doctors d
JOIN treatments t ON d.doctor_id = t.doctor_id
GROUP BY d.doctor_id, d.doctor_name
HAVING COUNT(DISTINCT t.patient_id) > 5;

-- Q13: 列出早班（morning shift）护士提供的治疗及对应患者姓名
SELECT 
    p.patient_name,
    t.treatment_type,
    t.treatment_date,
    n.nurse_name
FROM treatments t
JOIN nurses n ON t.nurse_id = n.nurse_id
JOIN patients p ON t.patient_id = p.patient_id
WHERE n.shift = 'morning';

-- Q14: 查找每个患者的最新治疗记录（按治疗日期倒序取第一条）
WITH patient_latest_treatment AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY treatment_date DESC) AS rn
    FROM treatments
)
SELECT 
    p.patient_name,
    plt.treatment_type,
    plt.treatment_date
FROM patient_latest_treatment plt
JOIN patients p ON plt.patient_id = p.patient_id
WHERE plt.rn = 1;

-- Q15: 列出每个医生及其患者的平均年龄（保留1位小数，提升可读性）
SELECT 
    d.doctor_name,
    ROUND(AVG(p.age), 1) AS average_patient_age
FROM doctors d
LEFT JOIN treatments t ON d.doctor_id = t.doctor_id
LEFT JOIN patients p ON t.patient_id = p.patient_id
GROUP BY d.doctor_id, d.doctor_name;

-- Q16: 列出监管患者数量超过3人的医生姓名
SELECT d.doctor_name
FROM doctors d
JOIN treatments t ON d.doctor_id = t.doctor_id
GROUP BY d.doctor_id, d.doctor_name
HAVING COUNT(DISTINCT t.patient_id) > 3;

-- Q17: 列出未接受过任何治疗的患者（使用NOT IN）
SELECT patient_name 
FROM patients 
WHERE patient_id NOT IN (SELECT DISTINCT patient_id FROM treatments);

-- Q18: 列出库存数量低于平均库存的药品
SELECT medication_name, quantity 
FROM medication_stock 
WHERE quantity < (SELECT AVG(quantity) FROM medication_stock);

-- Q19: 按医生分组，对其患者按年龄排名（升序，同年龄并列排名）
SELECT 
    d.doctor_name,
    p.patient_name,
    p.age,
    RANK() OVER (PARTITION BY d.doctor_id ORDER BY p.age ASC) AS patient_age_rank
FROM doctors d
JOIN treatments t ON d.doctor_id = t.doctor_id
JOIN patients p ON t.patient_id = p.patient_id;

-- Q20: 按专科分组，查找拥有最年长患者的医生
WITH specialist_patient_age AS (
    SELECT 
        d.specialization,
        d.doctor_name,
        p.patient_name,
        p.age AS patient_age,
        ROW_NUMBER() OVER (PARTITION BY d.specialization ORDER BY p.age DESC) AS rn
    FROM doctors d
    JOIN treatments t ON d.doctor_id = t.doctor_id
    JOIN patients p ON t.patient_id = p.patient_id
)
SELECT 
    specialization,
    doctor_name,
    patient_name AS oldest_patient_name,
    patient_age
FROM specialist_patient_age
WHERE rn = 1;







