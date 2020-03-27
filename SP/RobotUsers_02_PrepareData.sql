
ALTER PROCEDURE [dbo].[RobotUsers_02_PrepareData]
		@SportTypeId			INT = 1
	,	@BettypeId				INT = 1
	,	@IsLive					BIT = 1
	,	@NumOfDatePlacedBet		INT = 10
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
		
				
	-- START
	TRUNCATE TABLE dbo.[RobotUsers_StagingDailyData];
	TRUNCATE TABLE dbo.[RobotUsers_CumulativeMarginByDate];
	TRUNCATE TABLE dbo.[RobotUsers_CumulativeInfo];
					
	DECLARE   @AVG				FLOAT
			, @MEDIAN			FLOAT
			, @STD				FLOAT
			, @NORM				FLOAT
			, @Settings_MinBet	MONEY;

	IF	OBJECT_ID('tempdb..#tmpCalculation') IS NOT NULL
		DROP TABLE	#tmpCalculation;

	CREATE TABLE	#tmpCalculation (
			CustId			INT
		,	AVGStake		MONEY
		,   BetCount		INT
	);

	INSERT INTO #tmpCalculation(CustId, AVGStake, BetCount)
	SELECT w.CustId, w.IBCTurnover/w.BetCount, w.BetCount
	FROM dbo.RobotUsers_FilteredDailyData AS w WITH(NOLOCK)
	WHERE w.SporttypeId = @SportTypeId
		AND w.BettypeId = @BettypeId
		AND w.IsLive = @IsLive;
	
	SELECT @AVG= AVG(AVGStake), @STD = STDEVP(AVGStake) 
	FROM #tmpCalculation;
	
	SELECT  @MEDIAN= (
			   (SELECT MAX(AVGStake) FROM
				 (SELECT TOP 50 PERCENT AVGStake 
				  FROM #tmpCalculation ORDER BY AVGStake) AS t)
			 + (SELECT MIN(AVGStake) FROM
				 (SELECT TOP 50 PERCENT AVGStake 
				  FROM #tmpCalculation ORDER BY AVGStake DESC) AS b)
			) / 2.0;

	IF @MEDIAN < @AVG
		BEGIN
			SET @Settings_MinBet = @MEDIAN;
		END
	ELSE
		BEGIN
			SET @NORM = @AVG - (2 * @STD);
			SET @Settings_MinBet = CASE WHEN @NORM > 0 THEN  @NORM ELSE @AVG END;
		END	
	
	
	INSERT INTO dbo.RobotUsers_StagingDailyData(ReportDate, CustId, IBCTurnover, IBCWinloss, BetCount, DateOrder)
	SELECT	w.ReportDate
		,	w.CustId
		,	w.IBCTurnover
		,	-w.IBCWinloss	
		,	w.BetCount	
		,	ROW_NUMBER() OVER(PARTITION BY w.CustId ORDER BY w.ReportDate ASC)
	FROM dbo.RobotUsers_FilteredDailyData AS w WITH(NOLOCK)
	WHERE w.SporttypeId = @SportTypeId
		AND w.BettypeId = @BettypeId
		AND w.IsLive = @IsLive
		AND (w.IBCTurnover/w.BetCount) > @Settings_MinBet;


	INSERT INTO dbo.RobotUsers_CumulativeMarginByDate(CustId, DateOrder, Margin)
	SELECT t1.CustId, t1.DateOrder, CAST(ROUND(SUM(t2.IBCWinloss) / SUM(t2.IBCTurnover), 2) AS NUMERIC(3,2))
	FROM dbo.RobotUsers_StagingDailyData AS t1 WITH(NOLOCK)
		LEFT JOIN dbo.RobotUsers_StagingDailyData AS t2 WITH(NOLOCK)
				ON t1.DateOrder >= (t2.DateOrder) AND t1.CustId = t2.CustId	
	GROUP BY t1.CustId, t1.DateOrder;
		
	UPDATE dbo.RobotUsers_CumulativeMarginByDate WITH(ROWLOCK, UPDLOCK)
	SET Margin = 0.1
	WHERE Margin > 0.1;

	UPDATE dbo.RobotUsers_CumulativeMarginByDate WITH(ROWLOCK, UPDLOCK)
	SET Margin = -0.1
	WHERE Margin < -0.1;

	;WITH cte AS
	(
	   SELECT CustId, DateOrder, Margin,
			 ROW_NUMBER() OVER (PARTITION BY CustId ORDER BY DateOrder DESC) AS RowNumber
	   FROM dbo.RobotUsers_CumulativeMarginByDate WITH(NOLOCK)
	)
	INSERT INTO dbo.RobotUsers_CumulativeInfo(CustId, Margin, NumOfDateBet)
	SELECT CustId, Margin, DateOrder
	FROM cte
	WHERE RowNumber = 1 AND DateOrder > @NumOfDatePlacedBet ;
END;
