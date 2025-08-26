

-- LAB 3: University Fest Management System (DDL)

-- Create Database
CREATE DATABASE IF NOT EXISTS University_fest;
USE University_fest;

-- =========================
-- TASK 1: CREATE TABLES
-- =========================

-- Fest Table
CREATE TABLE Fest (
    FestID INT PRIMARY KEY,
    FestName VARCHAR(100) NOT NULL,
    Year INT NOT NULL,
    HeadTeamID INT
);

-- Team Table
CREATE TABLE Team (
    TeamID INT PRIMARY KEY,
    TeamName VARCHAR(100) NOT NULL,
    NumMembers INT CHECK (NumMembers >= 1),
    TeamType ENUM('ORG','MNG') DEFAULT 'ORG',
    FestID INT,
    FOREIGN KEY (FestID) REFERENCES Fest(FestID) ON DELETE CASCADE
);

-- Member Table
CREATE TABLE Member (
    MemberID INT PRIMARY KEY,
    MemberName VARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Age INT CHECK (Age > 0),
    TeamID INT,
    ReportsTo INT,
    FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE CASCADE,
    FOREIGN KEY (ReportsTo) REFERENCES Member(MemberID)
);

-- Event Table (initial name Event_conduction)
CREATE TABLE Event_conduction (
    EventID INT PRIMARY KEY,
    EventName VARCHAR(100) NOT NULL,
    VenueBlock VARCHAR(50),
    VenueFloor INT,
    VenueRoomNo INT,
    Date_of_conduction DATE NOT NULL,
    Price DECIMAL(10,2) CHECK (Price <= 1500),
    TeamID INT,
    FestID INT,
    FOREIGN KEY (TeamID) REFERENCES Team(TeamID),
    FOREIGN KEY (FestID) REFERENCES Fest(FestID) ON DELETE CASCADE
);

-- Participant Table
CREATE TABLE Participant (
    SRN VARCHAR(20) PRIMARY KEY,
    PName VARCHAR(100) NOT NULL,
    Gender CHAR(1) CHECK (Gender IN ('M','F','O')),
    Department VARCHAR(100) NOT NULL,
    Semester INT CHECK (Semester BETWEEN 1 AND 8)
);

-- Visitor Table
CREATE TABLE Visitor (
    VisitorID INT PRIMARY KEY,
    VName VARCHAR(100) NOT NULL,
    Gender CHAR(1) CHECK (Gender IN ('M','F','O')),
    Age INT CHECK (Age > 0),
    ParticipantSRN VARCHAR(20),
    FOREIGN KEY (ParticipantSRN) REFERENCES Participant(SRN)
);

-- Registration Table
CREATE TABLE Registration (
    RegNo INT,
    EventID INT,
    SRN VARCHAR(20),
    PRIMARY KEY (RegNo, EventID, SRN),
    FOREIGN KEY (EventID) REFERENCES Event_conduction(EventID) ON DELETE CASCADE,
    FOREIGN KEY (SRN) REFERENCES Participant(SRN)
);

-- Stall Table
CREATE TABLE Stall (
    StallID INT PRIMARY KEY,
    StallName VARCHAR(100) NOT NULL
);

-- Item Table
CREATE TABLE Item (
    ItemID INT PRIMARY KEY,
    ItemName VARCHAR(100) NOT NULL,
    ItemType ENUM('Veg','Non-Veg')
);

-- StallItems Table
CREATE TABLE StallItems (
    StallID INT,
    ItemID INT,
    Price DECIMAL(10,2) NOT NULL DEFAULT 50,
    Quantity INT CHECK (Quantity BETWEEN 0 AND 150),
    PRIMARY KEY (StallID, ItemID),
    FOREIGN KEY (StallID) REFERENCES Stall(StallID),
    FOREIGN KEY (ItemID) REFERENCES Item(ItemID)
);

-- Purchase Table
CREATE TABLE Purchase (
    PurchaseID INT PRIMARY KEY,
    SRN VARCHAR(20),
    StallID INT,
    ItemID INT,
    Quantity INT CHECK (Quantity > 0),
    PurchaseDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SRN) REFERENCES Participant(SRN),
    FOREIGN KEY (StallID, ItemID) REFERENCES StallItems(StallID, ItemID)
);

-- =========================
-- TASK 2: ALTERATIONS
-- =========================

-- 1. Modify gender datatype + reposition column
ALTER TABLE Participant MODIFY Gender ENUM('M','F','O') AFTER PName;

-- 2. Default value for price in StallItems
ALTER TABLE StallItems MODIFY Price DECIMAL(10,2) NOT NULL DEFAULT 50;

-- 3. Max stocks condition (<=150)
ALTER TABLE StallItems MODIFY Quantity INT CHECK (Quantity BETWEEN 0 AND 150);

-- 4. Rename Event_conduction → Event_schedule
RENAME TABLE Event_conduction TO Event_schedule;

-- 5. Move Date_of_conduction as first column
ALTER TABLE Event_schedule MODIFY Date_of_conduction DATE FIRST;

