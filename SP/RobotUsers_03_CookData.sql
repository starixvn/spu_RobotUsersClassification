
ALTER PROCEDURE [dbo].[RobotUsers_03_CookData]
AS
/*
	Created: 20200326@Long.Luu
	Task : 
	DB: bodb_VR2Model
	Original:

	Revisions:
		- 20200326@Long.Luu: Created [Redmine ID: #128272]

	Param's Explanation:
*/
BEGIN

	SET NOCOUNT ON;

	-- Winner/Loser counter
	TRUNCATE TABLE dbo.[RobotUsers_WinnerByDateCounter];
	TRUNCATE TABLE dbo.[RobotUsers_LoserByDateCounter];

	INSERT INTO dbo.[RobotUsers_WinnerByDateCounter](MarginRange, DateOrder, NumOfWinner)
	SELECT	w.Margin
		,	w.DateOrder
		,	COUNT(DISTINCT w.CustId)
	FROM dbo.[RobotUsers_CumulativeMarginByDate] AS w WITH(NOLOCK)
		INNER JOIN dbo.[RobotUsers_CumulativeInfo] AS c WITH(NOLOCK) ON w.CustId = c.CustId
	WHERE c.Margin > 0
	GROUP BY w.Margin, w.DateOrder;

	INSERT INTO dbo.[RobotUsers_LoserByDateCounter](MarginRange, DateOrder, NumOfLoser)
	SELECT	w.Margin
		,	w.DateOrder
		,	COUNT(DISTINCT w.CustId)
	FROM dbo.[RobotUsers_CumulativeMarginByDate] AS w WITH(NOLOCK)
		INNER JOIN dbo.[RobotUsers_CumulativeInfo] AS c WITH(NOLOCK) ON w.CustId = c.CustId
	GROUP BY w.Margin, w.DateOrder;

END;