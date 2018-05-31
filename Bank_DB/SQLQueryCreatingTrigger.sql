USE BankDB
GO
CREATE TRIGGER tr_INSERT
ON List_Transaction
AFTER INSERT
AS
BEGIN
/**/
DECLARE @tr_name varchar(255), @tr_idFst int, @tr_idSnd int, @tr_amount int, @tr_stgFstCur varchar(3),
		@tr_date date, @tr_bankroll int, @tr_countAc int, @tr_bankrollCvt int, 
		@tr_pid int, @tr_stgFst varchar(3), @tr_stgSnd varchar(3), @tr_closeDate date
/**/
SELECT @tr_name = Name, @tr_idFst = AccountID, @tr_date = Transaction_Date, 
	   @tr_amount = Amount, @tr_stgFstCur = ISO_Symbol
FROM INSERTED
/**/
SELECT @tr_pid = Accounts.PersonID
FROM Accounts
WHERE Accounts.AccountID = @tr_idFst
/**/
SELECT @tr_bankroll = Accounts.Bankroll
FROM Accounts
WHERE Accounts.AccountID = @tr_idFst
/**/
SELECT @tr_countAc = COUNT(AccountID)
FROM Accounts 
INNER JOIN Persons
ON Accounts.PersonID = Persons.PersonID 
WHERE Accounts.PersonID = @tr_pid
/**/
SELECT @tr_stgFst = Accounts.ISO_Symbol
FROM Accounts
WHERE Accounts.AccountID = @tr_idFst
/**/
SELECT @tr_closeDate = Accounts.Close_Date
FROM Accounts
WHERE AccountID = @tr_idFst
/**/
IF not(@tr_closeDate is NULL)
	BEGIN
	ROLLBACK
	RAISERROR('This account is closed.', 16, 2)
	END
/**/
ELSE
BEGIN
IF @tr_name = 'Close'
	BEGIN
	IF @tr_bankroll = 0
		BEGIN
		UPDATE Accounts SET Close_Date = @tr_date
		WHERE Accounts.AccountID = @tr_idFst
		END
	ELSE
		BEGIN
		IF @tr_bankroll < 0
			BEGIN
			ROLLBACK
			RAISERROR('Negative bankroll.', 16, 2)
			END
		ELSE
			BEGIN
			IF @tr_countAc = 1
				BEGIN
				ROLLBACK
				RAISERROR('Account is not empty.', 16, 2)
				END
			ELSE
				BEGIN
				IF @tr_countAc > 1
					BEGIN
					/**/
					SELECT TOP 1 @tr_idSnd = Accounts.AccountID
					FROM Accounts
					WHERE (Accounts.PersonID = @tr_pid) AND (Accounts.AccountID <> @tr_idFst) AND (not (Accounts.Close_Date is Null))
					/**/
					IF (@tr_idSnd is Null)
						BEGIN
						ROLLBACK
						RAISERROR('Negative bankroll, other accounts are closed', 16, 2)
						END
					ELSE
						BEGIN
						/**/
						SELECT @tr_stgSnd = Accounts.ISO_Symbol
						FROM Accounts
						WHERE Accounts.AccountID = @tr_idSnd
						/**/
						UPDATE Accounts SET Close_Date = @tr_date
						WHERE Accounts.AccountID = @tr_idFst
						INSERT INTO List_Transaction VALUES (@tr_idFst, N'Debit', @tr_bankroll, @tr_stgFst, @tr_date)
						/**/
						UPDATE Accounts SET Bankroll = 0
						WHERE Accounts.AccountID = @tr_idFst
						/**/
						IF @tr_stgFst <> @tr_stgSnd
							BEGIN
							IF @tr_stgFst = 'RUB' AND @tr_stgSnd = 'USD'
								SELECT @tr_bankrollCvt = @tr_bankroll / 60
							IF @tr_stgFst = 'RUB' AND @tr_stgSnd = 'EUR'
								SELECT @tr_bankrollCvt = @tr_bankroll / 70
							IF @tr_stgFst = 'USD' AND @tr_stgSnd = 'RUB'
								SELECT @tr_bankrollCvt = @tr_bankroll * 60
							IF @tr_stgFst = 'USD' AND @tr_stgSnd = 'EUR'
								SELECT @tr_bankrollCvt = (@tr_bankroll / 60) * 70
							IF @tr_stgFst = 'EUR' AND @tr_stgSnd = 'USD'
								SELECT @tr_bankrollCvt = (@tr_bankroll / 70) * 60
							IF @tr_stgFst = 'EUR' AND @tr_stgSnd = 'RUB'
								SELECT @tr_bankrollCvt = @tr_bankroll * 70
							END
						ELSE
							SELECT @tr_bankrollCvt = @tr_bankroll
						/**/
						INSERT INTO List_Transaction VALUES (@tr_idSnd, N'Add', @tr_bankrollCvt, @tr_stgSnd, @tr_date)
						UPDATE Accounts SET Bankroll = (SELECT Bankroll FROM Accounts WHERE AccountID = @tr_idSnd) + @tr_bankrollCvt
						WHERE Accounts.AccountID = @tr_idSnd
						END
					END
				END
			END
		END
	END
END
/**/
IF @tr_name = 'Add'
	BEGIN
		UPDATE Accounts SET Bankroll = (SELECT Bankroll FROM Accounts WHERE AccountID = @tr_idFst) + @tr_amount
		WHERE Accounts.AccountID = @tr_idFst	
	END
/**/
IF @tr_name = 'Debit'
	BEGIN
		UPDATE Accounts SET Bankroll = (SELECT Bankroll FROM Accounts WHERE AccountID = @tr_idFst) - @tr_amount
		WHERE Accounts.AccountID = @tr_idFst
	END
/**/
IF @tr_name = 'Balance'
	BEGIN
		IF @tr_stgFst = @tr_stgFstCur
		BEGIN
			UPDATE List_Transaction SET Amount = @tr_bankroll
			WHERE AccountID = @tr_idFst AND Name = 'Balance' AND Transaction_Date = @tr_date
		END
		ELSE
			BEGIN
			IF @tr_stgFst = 'RUB' AND @tr_stgFstCur = 'USD'
				SELECT @tr_bankroll = @tr_bankroll / 60
			IF @tr_stgFst = 'RUB' AND @tr_stgFstCur = 'EUR'
				SELECT @tr_bankroll = @tr_bankroll / 70
			IF @tr_stgFst = 'USD' AND @tr_stgFstCur = 'RUB'
				SELECT @tr_bankroll = @tr_bankroll * 60
			IF @tr_stgFst = 'USD' AND @tr_stgFstCur = 'EUR'
				SELECT @tr_bankroll = (@tr_bankroll / 60) * 70
			IF @tr_stgFst = 'EUR' AND @tr_stgFstCur = 'USD'
				SELECT @tr_bankroll = (@tr_bankroll / 70) * 60
			IF @tr_stgFst = 'EUR' AND @tr_stgFstCur = 'RUB'
				SELECT @tr_bankroll = @tr_bankroll * 70
			UPDATE List_Transaction SET Amount = @tr_bankroll
			WHERE AccountID = @tr_idFst AND Name = 'Balance' AND Transaction_Date = @tr_date AND ISO_Symbol = @tr_stgFstCur
		END
	END
END
