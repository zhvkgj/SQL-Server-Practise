CREATE PROCEDURE proc_TRANSFER(@ac_idFst int, @ac_idSnd int, @count int, @TR_date date = Null)
AS
BEGIN
	DECLARE @ac_stgFst varchar(3), @ac_stgSnd varchar(3), 
			@countCvt int, @cur_date date,
			@ac_closeDateFst date, @ac_closeDateSnd date
	/**/
	SELECT @ac_stgFst = Accounts.ISO_Symbol
	FROM Accounts
	WHERE Accounts.AccountID = @ac_idFst
	SELECT @ac_stgSnd = Accounts.ISO_Symbol
	FROM Accounts
	WHERE Accounts.AccountID = @ac_idSnd
	/**/
	SELECT @ac_closeDateFst = Accounts.Close_Date
	FROM Accounts
	WHERE AccountID = @ac_idFst
	SELECT @ac_closeDateSnd = Accounts.Close_Date
	FROM Accounts
	WHERE AccountID = @ac_idSnd
	/**/
	IF @TR_date is Null
		SELECT @cur_date = GETDATE()
	ELSE
		SELECT @cur_date = @TR_date
	/**/
	IF (@ac_closeDateFst is Null) AND (@ac_closeDateSnd is Null)
		BEGIN
		INSERT INTO List_Transaction VALUES(@ac_idFst, N'Debit', @count, @ac_stgFst, @cur_date)
		/**/
		IF @ac_stgFst <> @ac_stgSnd
			BEGIN
			IF @ac_stgFst = 'RUB' AND @ac_stgSnd = 'USD'
				SELECT @countCvt = @count / 60
			IF @ac_stgFst = 'RUB' AND @ac_stgSnd = 'EUR'
				SELECT @countCvt = @count / 70
			IF @ac_stgFst = 'USD' AND @ac_stgSnd = 'RUB'
				SELECT @countCvt = @count * 60
			IF @ac_stgFst = 'USD' AND @ac_stgSnd = 'EUR'
				SELECT @countCvt = (@count / 60) * 70
			IF @ac_stgFst = 'EUR' AND @ac_stgSnd = 'USD'
				SELECT @countCvt = (@count / 70) * 60
			IF @ac_stgFst = 'EUR' AND @ac_stgSnd = 'RUB'
				SELECT @countCvt = @count * 70
			END
		ELSE
			SELECT @countCvt = @count
		/**/
		INSERT INTO List_Transaction VALUES(@ac_idSnd, N'Add', @countCvt, @ac_stgSnd, @cur_date)
		END
	ELSE
		BEGIN
		RAISERROR('One of the accounts is closed.', 16, 2)
		END
END