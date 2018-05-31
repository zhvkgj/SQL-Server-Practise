GO
INSERT [dbo].[Accounts] ([ISO_Symbol], [Opening_Date], [Bankroll], [PersonID]) VALUES (N'RUB', '2012-10-25', 0, 7)
GO
INSERT INTO List_Transaction VALUES (1008, N'Add', 10000, N'RUB', '2018-01-01')
GO
INSERT INTO List_Transaction VALUES (1008, N'Debit', 10000, N'RUB', '2018-01-02')
GO
INSERT INTO List_Transaction VALUES (1008, N'Balance', 0, N'RUB', '2018-01-03')
GO
INSERT INTO List_Transaction VALUES (1008, N'Close', 0, N'RUB', '2018-01-03')
GO
INSERT INTO List_Transaction VALUES (1002, N'Close', 0, N'RUB', '2018-01-01');