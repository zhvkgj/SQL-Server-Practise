CREATE FUNCTION get_Clients()
RETURNS @result_table 
TABLE(PersonID int, Name varchar(255), AccountsInfo varchar(1000)) 
AS 
BEGIN
	DECLARE @cur_id INT;
	/**/
	DECLARE Cur CURSOR 
	FOR SELECT Persons.PersonID, AccountID 
	FROM Persons JOIN Accounts
	ON  Accounts.PersonID = Persons.PersonID 
	AND (SELECT MIN(Bankroll) FROM Accounts 
	WHERE Accounts.PersonID = Persons.PersonID) < 0 
	ORDER BY Persons.PersonID
	/**/
	DECLARE @info_cur varchar(1000) = '',  
			@name_cur varchar(255), 
			@accountID_cur int
	/**/
	OPEN Cur FETCH FROM Cur INTO @cur_id, @accountID_cur
	/**/
	WHILE(@@FETCH_STATUS =  0)
	BEGIN
		/**/
		SET @info_cur = N'¹ ' + 
			(CONVERT(varchar(1000), @accountID_cur)) + N'(' + 
			(SELECT ISO_Symbol FROM Accounts 
			 WHERE Accounts.AccountID = @accountID_cur) + N'): ' + 
			CONVERT(varchar(1000), 
			(SELECT Bankroll FROM Accounts 
			 WHERE Accounts.AccountID = @accountID_cur)) + N'; '
		/**/
		SET @name_cur = 
		(SELECT LastName FROM Persons
		 WHERE Persons.PersonID = @cur_id) + ' ' + 
		 (SELECT FirstName FROM Persons
		  WHERE Persons.PersonID = @cur_id) + N' '
		/**/
		IF(SELECT Count(*) FROM @result_table WHERE PersonID = @cur_id) = 0
		BEGIN
			INSERT @result_table ([PersonID], [Name], [AccountsInfo]) 
			VALUES (@cur_id, @name_cur, @info_cur)
		END
		ELSE
		BEGIN
			UPDATE @result_table 
			SET AccountsInfo = AccountsInfo + @info_cur 
			WHERE PersonID = @cur_id
		END
		FETCH FROM Cur INTO @cur_id, @accountID_cur
	END
	CLOSE Cur
	DEALLOCATE Cur
	RETURN
END