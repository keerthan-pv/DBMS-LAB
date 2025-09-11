-- ============================================
-- File: SRN1_SRN2_schema_and_data.sql
-- Relational schema + sample data
-- Engine: MySQL (InnoDB)
-- ============================================

-- 0) Create database and use it
DROP DATABASE IF EXISTS NutritionDB;
CREATE DATABASE NutritionDB;
USE NutritionDB;

-- 1) Clean up (drop in child->parent order)
DROP TABLE IF EXISTS MealPlan_Recipe;
DROP TABLE IF EXISTS Feedback;
DROP TABLE IF EXISTS User_Diet_Log;
DROP TABLE IF EXISTS Recipe_Ingredient;
DROP TABLE IF EXISTS Nutrition;
DROP TABLE IF EXISTS Ingredient;
DROP TABLE IF EXISTS Recipe;
DROP TABLE IF EXISTS Meal_Plan;
DROP TABLE IF EXISTS User;

-- 2) User table
CREATE TABLE User (
  User_ID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(100) NOT NULL,
  Email VARCHAR(255) NOT NULL UNIQUE,
  Password VARCHAR(255) NOT NULL,
  Age TINYINT UNSIGNED CHECK (Age BETWEEN 1 AND 120),
  Gender ENUM('Male','Female','Other') DEFAULT 'Other',
  Height_cm SMALLINT UNSIGNED CHECK (Height_cm > 0),
  Weight_kg DECIMAL(5,2) CHECK (Weight_kg > 0),
  Activity_Level ENUM('Sedentary','Light','Moderate','Active','Very Active') DEFAULT 'Moderate',
  Dietary_Preferences VARCHAR(100),
  Allergies VARCHAR(255),
  Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3) Recipe table
CREATE TABLE Recipe (
  Recipe_ID INT AUTO_INCREMENT PRIMARY KEY,
  Recipe_Name VARCHAR(200) NOT NULL,
  Description TEXT,
  Cuisine_Type VARCHAR(100),
  Preparation_Time_minutes SMALLINT UNSIGNED CHECK (Preparation_Time_minutes >= 0) DEFAULT 0,
  Cooking_Time_minutes SMALLINT UNSIGNED CHECK (Cooking_Time_minutes >= 0) DEFAULT 0,
  Serving_Size DECIMAL(4,2) NOT NULL DEFAULT 1,
  Difficulty_Level ENUM('Easy','Medium','Hard') DEFAULT 'Easy',
  Instructions TEXT,
  Creator_User_ID INT,
  Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_recipe_creator FOREIGN KEY (Creator_User_ID)
    REFERENCES User(User_ID)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4) Ingredient table
CREATE TABLE Ingredient (
  Ingredient_ID INT AUTO_INCREMENT PRIMARY KEY,
  Ingredient_Name VARCHAR(150) NOT NULL UNIQUE,
  Unit_Of_Measure VARCHAR(50) NOT NULL,
  Category VARCHAR(50) NOT NULL,
  Notes VARCHAR(255)
) ENGINE=InnoDB;

-- 5) Nutrition table (1-to-1 with Ingredient)
CREATE TABLE Nutrition (
  Nutrition_ID INT AUTO_INCREMENT PRIMARY KEY,
  Ingredient_ID INT NOT NULL UNIQUE,
  Calories DECIMAL(6,2) CHECK (Calories >= 0),
  Carbohydrates_g DECIMAL(6,2) DEFAULT 0 CHECK (Carbohydrates_g >= 0),
  Protein_g DECIMAL(6,2) DEFAULT 0 CHECK (Protein_g >= 0),
  Fat_g DECIMAL(6,2) DEFAULT 0 CHECK (Fat_g >= 0),
  Fiber_g DECIMAL(6,2) DEFAULT 0 CHECK (Fiber_g >= 0),
  Vitamins VARCHAR(255),
  Minerals VARCHAR(255),
  Other_Nutrients TEXT,
  CONSTRAINT fk_nutrition_ingredient FOREIGN KEY (Ingredient_ID)
    REFERENCES Ingredient(Ingredient_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6) Recipe_Ingredient (many-to-many)
CREATE TABLE Recipe_Ingredient (
  RecipeIngredient_ID INT AUTO_INCREMENT PRIMARY KEY,
  Recipe_ID INT NOT NULL,
  Ingredient_ID INT NOT NULL,
  Quantity DECIMAL(8,3) NOT NULL CHECK (Quantity > 0),
  Unit VARCHAR(50) NOT NULL,
  CONSTRAINT fk_ri_recipe FOREIGN KEY (Recipe_ID)
    REFERENCES Recipe(Recipe_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_ri_ingredient FOREIGN KEY (Ingredient_ID)
    REFERENCES Ingredient(Ingredient_ID)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  UNIQUE (Recipe_ID, Ingredient_ID)
) ENGINE=InnoDB;

-- 7) User_Diet_Log
CREATE TABLE User_Diet_Log (
  Log_ID INT AUTO_INCREMENT PRIMARY KEY,
  User_ID INT,
  Recipe_ID INT,
  Date DATE NOT NULL,
  Time TIME,
  Portion_Size DECIMAL(5,2) DEFAULT 1 CHECK (Portion_Size > 0),
  Notes VARCHAR(255),
  Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_log_user FOREIGN KEY (User_ID)
    REFERENCES User(User_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_log_recipe FOREIGN KEY (Recipe_ID)
    REFERENCES Recipe(Recipe_ID)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 8) Meal_Plan
CREATE TABLE Meal_Plan (
  MealPlan_ID INT AUTO_INCREMENT PRIMARY KEY,
  User_ID INT,
  Plan_Name VARCHAR(150) NOT NULL,
  Start_Date DATE,
  End_Date DATE,
  Notes TEXT,
  Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_mealplan_user FOREIGN KEY (User_ID)
    REFERENCES User(User_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 8b) MealPlan_Recipe
CREATE TABLE MealPlan_Recipe (
  id INT AUTO_INCREMENT PRIMARY KEY,
  MealPlan_ID INT NOT NULL,
  Recipe_ID INT NOT NULL,
  Day_of_Plan DATE,
  Meal_Type ENUM('Breakfast','Lunch','Dinner','Snack') DEFAULT 'Lunch',
  CONSTRAINT fk_mpr_mealplan FOREIGN KEY (MealPlan_ID)
    REFERENCES Meal_Plan(MealPlan_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_mpr_recipe FOREIGN KEY (Recipe_ID)
    REFERENCES Recipe(Recipe_ID)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 9) Feedback
CREATE TABLE Feedback (
  Feedback_ID INT AUTO_INCREMENT PRIMARY KEY,
  User_ID INT NOT NULL,
  Recipe_ID INT NOT NULL,
  Rating TINYINT UNSIGNED NOT NULL CHECK (Rating BETWEEN 1 AND 5),
  Comments TEXT,
  Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_feedback_user FOREIGN KEY (User_ID)
    REFERENCES User(User_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_feedback_recipe FOREIGN KEY (Recipe_ID)
    REFERENCES Recipe(Recipe_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- Sample Data Inserts
-- ============================================

-- Users
INSERT INTO User (Name, Email, Password, Age, Gender, Height_cm, Weight_kg, Activity_Level, Dietary_Preferences, Allergies)
VALUES
('Asha Kumar','asha.kumar@example.com','$2b$12$examplehash1',25,'Female',158,53.5,'Moderate','Vegetarian','Peanuts'),
('Rohan Verma','rohan.verma@example.com','$2b$12$examplehash2',28,'Male',172,70.2,'Active','Non-Vegetarian',''),
('Meera Nair','meera.nair@example.com','$2b$12$examplehash3',34,'Female',165,62.0,'Light','Vegan','Gluten'),
('Arjun Das','arjun.das@example.com','$2b$12$examplehash4',22,'Male',178,75.0,'Very Active','Non-Vegetarian','Shellfish'),
('Priya Sen','priya.sen@example.com','$2b$12$examplehash5',30,'Female',160,58.0,'Moderate','Vegetarian','Lactose');

-- Ingredients
INSERT INTO Ingredient (Ingredient_Name, Unit_Of_Measure, Category, Notes) VALUES
('Brown Rice','grams','Grain','Whole grain option'),
('Chicken Breast','grams','Meat','Skinless'),
('Spinach','grams','Vegetable','Fresh leaves'),
('Olive Oil','ml','Fat','Extra virgin'),
('Chickpeas (canned)','grams','Legume','Rinsed'),
('Tomato','grams','Vegetable','Ripe'),
('Almonds','grams','Nuts','Raw, unsalted');

-- Nutrition
INSERT INTO Nutrition (Ingredient_ID, Calories, Carbohydrates_g, Protein_g, Fat_g, Fiber_g, Vitamins, Minerals)
VALUES
(1,111,23.0,2.6,0.9,1.8,'B-vitamins','Magnesium'),
(2,165,0,31.0,3.6,0,'B6','Phosphorus, Selenium'),
(3,23,3.6,2.9,0.4,2.2,'A,C,K','Iron, Calcium'),
(4,884,0,0,100,0,'E','None significant'),
(5,164,27.4,8.9,2.6,7.6,'B-vitamins','Iron'),
(6,18,3.9,0.9,0.2,1.2,'C','Potassium'),
(7,579,21.6,21.2,49.9,12.5,'E','Magnesium, Calcium');

-- Recipes
INSERT INTO Recipe (Recipe_Name, Description, Cuisine_Type, Preparation_Time_minutes, Cooking_Time_minutes, Serving_Size, Difficulty_Level, Instructions, Creator_User_ID)
VALUES
('Grilled Chicken & Brown Rice Bowl','Protein-rich bowl with veggies','Fusion',15,20,1,'Medium','Grill chicken, cook rice, steam spinach, combine.',2),
('Chickpea & Spinach Salad','Vegan salad, quick and nutritious','Mediterranean',10,0,2,'Easy','Mix chickpeas, spinach, tomato; dress with olive oil.',3),
('Tomato Almond Chutney','Tangy chutney with almonds','Indian',10,0,4,'Easy','Blend tomato, roasted almonds and spices.',1),
('Simple Brown Rice','Plain whole grain rice','Asian',5,30,3,'Easy','Rinse rice and boil in 2:1 water ratio.',4),
('Almond Snack','Roasted almonds with a pinch of salt','Snack',5,10,1,'Easy','Lightly roast almonds.',5);

-- Recipe_Ingredient
INSERT INTO Recipe_Ingredient (Recipe_ID, Ingredient_ID, Quantity, Unit) VALUES
(1,2,150,'grams'),
(1,1,120,'grams'),
(1,3,50,'grams'),
(2,5,200,'grams'),
(2,3,80,'grams'),
(2,6,100,'grams'),
(3,7,30,'grams'),
(3,6,150,'grams'),
(4,1,200,'grams'),
(5,7,40,'grams');

-- Meal Plans
INSERT INTO Meal_Plan (User_ID, Plan_Name, Start_Date, End_Date, Notes) VALUES
(1,'Weekly Veg Boost','2025-09-15','2025-09-21','Focus on iron-rich veggies'),
(2,'High Protein Plan','2025-09-10','2025-09-24','Athlete style protein intake'),
(3,'Vegan Reset','2025-09-20','2025-09-27','No animal products');

-- MealPlan_Recipe
INSERT INTO MealPlan_Recipe (MealPlan_ID, Recipe_ID, Day_of_Plan, Meal_Type) VALUES
(1,2,'2025-09-15','Lunch'),
(1,3,'2025-09-15','Dinner'),
(2,1,'2025-09-10','Dinner'),
(2,4,'2025-09-11','Lunch'),
(3,2,'2025-09-20','Lunch');

-- User_Diet_Log
INSERT INTO User_Diet_Log (User_ID, Recipe_ID, Date, Time, Portion_Size, Notes) VALUES
(1,3,'2025-09-01','08:30:00',1,'Breakfast chutney on toast'),
(2,1,'2025-09-02','13:00:00',1.5,'Post workout meal'),
(3,2,'2025-09-03','12:30:00',1,'Light lunch'),
(4,4,'2025-09-04','19:00:00',2,'Family dinner'),
(5,5,'2025-09-05','17:00:00',0.5,'Snack');

-- Feedback
INSERT INTO Feedback (User_ID, Recipe_ID, Rating, Comments) VALUES
(1,3,5,'Loved the chutney with dosa!'),
(2,1,4,'Good protein balance, a bit dry'),
(3,2,5,'Perfect for a quick vegan lunch'),
(4,4,4,'Rice cooked well'),
(5,5,5,'Excellent snack for travel'),
(1,2,4,'Fresh and filling');

-- ============================================
-- SHOW OUTPUTS (for Workbench)
-- ============================================

-- See all tables
SHOW TABLES;

-- Show schema of each table
SHOW CREATE TABLE User;
SHOW CREATE TABLE Recipe;
SHOW CREATE TABLE Ingredient;
SHOW CREATE TABLE Nutrition;
SHOW CREATE TABLE Recipe_Ingredient;
SHOW CREATE TABLE User_Diet_Log;
SHOW CREATE TABLE Meal_Plan;
SHOW CREATE TABLE MealPlan_Recipe;
SHOW CREATE TABLE Feedback;

-- Preview data
SELECT * FROM User;
SELECT * FROM Ingredient;
SELECT * FROM Nutrition;
SELECT * FROM Recipe;
SELECT * FROM Recipe_Ingredient;
SELECT * FROM Meal_Plan;
SELECT * FROM MealPlan_Recipe;
SELECT * FROM User_Diet_Log;
SELECT * FROM Feedback;

