# 🎬 DVD Rental Store Analysis (Sakila Database)

![Project Banner](https://github.com/yourusername/DVD_Rental_SQL_Analysis/assets/banner-image.png)

---

## 📊 Project Overview
SQL-based analysis of the **Sakila DVD Rental Database** to uncover trends in rentals, revenue, customer behavior, and store performance.  
The project demonstrates the use of **SQL for business analytics** and **data-driven insights** to improve store efficiency and profitability.

---

## 🧰 Tools & Techniques
- **Tool:** MySQL  
- **Techniques Used:** CTEs, Joins, Aggregations, Window Functions  
- **Dataset:** Sakila Database  
  - 1,000 Films  
  - 599 Customers  
  - 16 Categories  
  - 16,000+ Rental Transactions  

---

## 🎯 Objectives
1. Identify the most rented films and popular categories  
2. Find top customers by rental frequency and total payments  
3. Analyze monthly rental trends and peak activity periods  
4. Determine the most profitable film categories  
5. Evaluate staff and store performance based on revenue  

---

## 🧩 Data Understanding
Key tables explored:  
- **Actor:** 200 actors (basic reference data)  
- **Category:** 16 film categories  
- **Customer:** 599 customers, 584 active  
- **Film:** 1,000 films with rental details  
- **Rental:** 16,000+ transactions (main analysis table)  
- **Staff & Store:** 2 staff and 2 store locations  

**Data Validation:**  
✔ No null values  
✔ No duplicate records  
✔ Film and film_text tables perfectly synchronized  

---

## 🧼 Data Cleaning and Preparation
- Used `ROW_NUMBER()` to check for duplicates (none found).  
- Verified record consistency between key tables.  
- Ensured each customer has at least one rental record.  

---

## 💻 SQL Analysis & Results

### 1️⃣ Most Rented Films
Top 10 most rented films show evenly distributed rental counts (31–34 each), indicating **balanced audience preference**.

| Rank | Film Title | Rental Count |
|------|-------------|---------------|
| 1 | BUCKET BROTHERHOOD | 34 |
| 2 | ROCKETEER MOTHER | 33 |
| ... | ... | ... |

**Insight:** No single film dominates rentals — audience preferences are diverse.

---

### 2️⃣ Rentals by Genre
| Category | Rental Count | Rental % |
|-----------|---------------|----------|
| Sports | 1179 | 7.3 |
| Animation | 1166 | 7.3 |
| Action | 1112 | 6.9 |
| Drama | 1060 | 6.6 |
| Music | 830 | 5.2 |

**Insight:**  
Sports, Sci-Fi, and Animation lead with around **7%** of total rentals each.  
Top five genres capture **35%+** of overall demand.

<img width="617" height="267" alt="image" src="https://github.com/user-attachments/assets/421217e3-4e14-46a8-a49e-0d892572c26e" />


---

### 3️⃣ Customer Spending Behavior
| Spending Category | Count | Percentage |
|--------------------|--------|-------------|
| High | 2 | 0.33% |
| Medium | 393 | 65.61% |
| Low | 204 | 34.06% |

**Insight:**  
- Medium spenders (66%) dominate overall.  
- High spenders are few but contribute significant revenue.  
- Target low and medium segments for retention.

---

### 4️⃣ Rental Trends Over Time
Rental activity peaked during **July–August 2005** with the highest rentals and payments.  
Activity dropped by **February 2006**, indicating an **off-season trend**.

![Monthly Rental Trend](https://github.com/yourusername/DVD_Rental_SQL_Analysis/assets/rental-trend.png)

---

### 5️⃣ Most Profitable Film Categories
| Category | Total Revenue | Revenue % |
|-----------|----------------|-------------|
| Sports | 5314.21 | 7.88 |
| Sci-Fi | 4756.98 | 7.06 |
| Animation | 4656.30 | 6.91 |
| Drama | 4587.39 | 6.81 |
| Music | 3417.72 | 5.07 |

**Insight:**  
Sports, Sci-Fi, and Animation contribute over **21%** of total revenue — indicating high audience engagement.

---

### 6️⃣ Staff Performance
| Staff ID | Staff Name | Total Revenue | Rank |
|-----------|-------------|----------------|-------|
| 2 | Jon Stephens | 33,881.94 | 1 |
| 1 | Mike Hillyer | 33,524.62 | 2 |

**Insight:**  
Both staff members show **strong and nearly equal performance**, with Jon slightly leading in revenue.

---

### 7️⃣ Store Performance
| Store ID | Total Revenue | Rank |
|-----------|----------------|-------|
| 2 | 33,881.94 | 1 |
| 1 | 33,524.62 | 2 |

**Insight:**  
Store 2 slightly outperforms Store 1, showing consistent business across branches.

---

## 📈 Key Findings Summary
- Sports, Sci-Fi, and Animation generate **21%+** of total revenue.  
- Rentals peak in **July–August**, lowest in **February**.  
- Medium spenders (66%) dominate; high spenders are few but valuable.  
- Staff and store performance are **balanced and efficient**.  
- Data is clean and consistent, supporting reliable analysis.  

---

## 💡 Recommendations
1. Promote top-performing genres for higher returns.  
2. Offer loyalty programs to convert medium spenders to high spenders.  
3. Launch seasonal offers to increase off-season rentals.  
4. Maintain consistency across staff and stores with equal incentives.

---

