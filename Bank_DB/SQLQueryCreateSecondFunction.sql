CREATE FUNCTION dbo.get_Percent (@id int)
RETURNS dec(4, 2)
AS
BEGIN
	DECLARE @default_percent dec(4, 2) = 13
	DECLARE @open_date date = (SELECT MIN(Accounts.Opening_Date) FROM Accounts WHERE PersonID = @id)
	DECLARE @last_twoYears date = DATEADD(YEAR, -2, GETDATE())
	DECLARE @limitation int = DATEDIFF(YEAR, @open_date, GETDATE())
	DECLARE @month_dif int = DATEPART(MONTH, GETDATE()) - DATEPART(MONTH, @open_date)
	DECLARE @days_dif int =  DATEPART(DAY, GETDATE()) - DATEPART(DAY, @open_date)
	DECLARE @income int, @costs int, @ic_ratio dec(4,2)
	/**/
	IF @limitation <> 0
		IF @month_dif < 0 OR (@month_dif = 0 AND @days_dif < 0)
			SET @limitation -= 1
	/**/
	SET @default_percent -= (CONVERT(dec(4,1), @limitation) * 0.1)
	IF @default_percent <= 4
		RETURN 4
	/**/
	SET @income = (
		SELECT SUM(List_Transaction.Amount)
		FROM ((List_Transaction
		INNER JOIN Accounts
		ON List_Transaction.AccountID = Accounts.AccountID)
		INNER JOIN Persons
		ON Persons.PersonID = Accounts.PersonID)
		WHERE List_Transaction.Name = 'Add' AND Persons.PersonID = @id)
	/**/
	SET @costs = (
		SELECT SUM(List_Transaction.Amount)
		FROM ((List_Transaction
		INNER JOIN Accounts
		ON List_Transaction.AccountID = Accounts.AccountID)
		INNER JOIN Persons
		ON Persons.PersonID = Accounts.PersonID)
		WHERE List_Transaction.Name = 'Debit' AND Persons.PersonID = @id)
	/**/
	SET @ic_ratio = CONVERT(dec(4,2), @income) / CONVERT(dec(4,2), @costs)
	SET @default_percent -= (@ic_ratio * 0.1)
	IF @default_percent <= 4
		RETURN 4
	RETURN @default_percent
END