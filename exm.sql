USE [wdb]
GO

DECLARE	@return_value int,
		@totalCount int

EXEC	@return_value = [dbo].[PROC_getTerminalList]
		@terminalId = NULL,
		@pageNo = 1,
		@length = 5,
		@totalCount = @totalCount OUTPUT

SELECT	@totalCount as N'@totalCount'

SELECT	'Return Value' = @return_value

GO
