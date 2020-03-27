
ALTER PROCEDURE [dbo].[RobotUsers_05_ComputeDangerLevel]
		@FromDate				DATE = '20200101'
	,	@ToDate					DATE = '20200202'
	,	@SportTypeId			INT = 1
	,	@BettypeId				INT = 1
	,	@IsLive					BIT = 1
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
		
	INSERT INTO dbo.RobotUsers_PercentageOfWin(
			[CustId]
		,	[SporttypeId]
		,	[BettypeId]
		,	[IsLive]
		,	[CurrentMargin]	
		,	[NumberOfDatePlacedBet]
		,	[PercentageOfWin]
		,	[CreatedDate]
		,	[FromDate]
		,	[ToDate]
		)
	SELECT	c.CustId
		,	@SportTypeId
		,	@BettypeId
		,	@IsLive
		,	c.Margin
		,	c.NumOfDateBet
		,   d.PercentageOfWin
		,	GETDATE()
		,   @FromDate
		,	@ToDate
	FROM dbo.RobotUsers_CumulativeInfo AS c WITH(NOLOCK)
		INNER JOIN dbo.RobotUsers_RawChanceOfDanger AS d WITH(NOLOCK) 
			ON c.Margin = d.MarginRange AND (c.NumOfDateBet + 1) = d.DateOrder;
		
END;