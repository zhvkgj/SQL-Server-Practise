USE BankDB
GO
INSERT [dbo].[Transactions] ([Name], [Symbol]) VALUES (N'Add', N'+')
GO
INSERT [dbo].[Transactions] ([Name], [Symbol]) VALUES (N'Debit', N'-')
GO
INSERT [dbo].[Transactions] ([Name], [Symbol]) VALUES (N'Balance', N'?')
GO
INSERT [dbo].[Transactions] ([Name], [Symbol]) VALUES (N'Close', N'!');
