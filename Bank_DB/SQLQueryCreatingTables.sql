CREATE DATABASE BankDB;
GO
USE BankDB;
CREATE TABLE Cities(
	City_Name varchar(255) NOT NULL PRIMARY KEY,
	Population int NOT NULL
);

CREATE TABLE Persons(
	PersonID int IDENTITY(1,1) PRIMARY KEY,
	LastName varchar(255) NOT NULL,
	FirstName varchar(255) NOT NULL,
	Address varchar(255) NOT NULL,
	City varchar(255) NOT NULL FOREIGN KEY REFERENCES Cities(City_Name),
	Passport varchar(10) NOT NULL UNIQUE
);

CREATE TABLE Sterlings(
	ISO_Symbol varchar(3) NOT NULL PRIMARY KEY,
	Sterling_Name varchar(255) NOT NULL,
	ISO_Key varchar(3) NOT NULL
);

CREATE TABLE Accounts(
	AccountID int IDENTITY(1001,1) PRIMARY KEY,
	ISO_Symbol varchar(3) NOT NULL FOREIGN KEY REFERENCES Sterlings(ISO_Symbol),
	Opening_Date date NOT NULL,
	Close_Date date,
	Bankroll int NOT NULL DEFAULT 0,
	PersonID int NOT NULL FOREIGN KEY REFERENCES Persons(PersonID)
);

CREATE TABLE Transactions(
	Name varchar(255) NOT NULL PRIMARY KEY,
	Symbol char NOT NULL
);

CREATE TABLE List_Transaction(
	AccountID int NOT NULL FOREIGN KEY REFERENCES Accounts(AccountID),
	Name varchar(255) NOT NULL FOREIGN KEY REFERENCES Transactions(Name),
	Amount int,
	ISO_Symbol varchar(3) NOT NULL FOREIGN KEY REFERENCES Sterlings(ISO_Symbol),
	Transaction_Date date NOT NULL
);