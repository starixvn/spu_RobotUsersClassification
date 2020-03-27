
ALTER PROCEDURE [dbo].[RobotUsers_01_FilterData]
		@FromDate				DATE = '20200101'
	,	@ToDate					DATE = '20200202'
	,	@Settings_MinBetCount	INT	= 0
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
	TRUNCATE TABLE dbo.[RobotUsers_FilteredDailyData]

	IF	OBJECT_ID('tempdb..#tmpFilterFactor') IS NOT NULL
		DROP TABLE	#tmpFilterFactor;

	CREATE TABLE	#tmpFilterFactor (
			CustId				INT
		,	Factor				INT
		,   FactorPercentage	FLOAT
		,	PRIMARY KEY (
				CustId			ASC
			,	Factor			ASC
		)
	);

	INSERT INTO dbo.RobotUsers_FilteredDailyData(ReportDate, CustId, SporttypeId, BettypeId, IsLive, IBCTurnover, IBCWinloss, BetCount)
	SELECT	w.ReportDate
		,	w.CustId
		,	w.SporttypeId
		,	w.BettypeId
		,	w.IsLive
		,	w.IBCTurnover
		,	-w.IBCWinloss	
		,	w.BetCount
	FROM dbo.RobotUsers_DailyData AS w WITH(NOLOCK)
	WHERE w.ReportDate BETWEEN @FromDate AND @ToDate
		AND w.BetCount > @Settings_MinBetCount;

	-- Filter Sporttype with small TO
	INSERT INTO #tmpFilterFactor(CustId, Factor, FactorPercentage)
	SELECT f.CustId, f.SporttypeId, SUM(f.IBCTurnover) / SUM(SUM(f.IBCTurnover)) OVER(PARTITION BY f.CustId)
	FROM dbo.RobotUsers_FilteredDailyData AS f WITH(NOLOCK)
	GROUP BY f.CustId, f.SporttypeId;
		
	DELETE a WITH(ROWLOCK)
	FROM dbo.RobotUsers_FilteredDailyData AS a
		INNER JOIN (	
			SELECT a.CustId, a.Factor
			FROM #tmpFilterFactor as a WITH(NOLOCK)
			WHERE a.FactorPercentage >= 90
		) AS t ON t.CustId = a.CustId AND a.SporttypeId <> t.Factor;

	-- Filter LiveStatus with small TO
	TRUNCATE TABLE #tmpFilterFactor;

	INSERT INTO #tmpFilterFactor(CustId, Factor, FactorPercentage)
	SELECT f.CustId, f.IsLive, SUM(f.IBCTurnover) / SUM(SUM(f.IBCTurnover)) OVER(PARTITION BY f.CustId)
	FROM dbo.RobotUsers_FilteredDailyData AS f WITH(NOLOCK)
	GROUP BY f.CustId, f.IsLive;
		
	DELETE a WITH(ROWLOCK)
	FROM dbo.RobotUsers_FilteredDailyData AS a
		INNER JOIN (	
			SELECT a.CustId, a.Factor
			FROM #tmpFilterFactor as a WITH(NOLOCK)
			WHERE a.FactorPercentage >= 90
		) AS t ON t.CustId = a.CustId AND a.IsLive <> t.Factor;

	-- Filter Bettype with small TO
	TRUNCATE TABLE #tmpFilterFactor;

	INSERT INTO #tmpFilterFactor(CustId, Factor, FactorPercentage)
	SELECT f.CustId, f.BettypeId, SUM(f.IBCTurnover) / SUM(SUM(f.IBCTurnover)) OVER(PARTITION BY f.CustId)
	FROM dbo.RobotUsers_FilteredDailyData AS f WITH(NOLOCK)
	GROUP BY f.CustId, f.BettypeId;
		
	DELETE a WITH(ROWLOCK)
	FROM dbo.RobotUsers_FilteredDailyData AS a
		INNER JOIN (	
			SELECT a.CustId, a.Factor
			FROM #tmpFilterFactor as a WITH(NOLOCK)
			WHERE a.FactorPercentage >= 90
		) AS t ON t.CustId = a.CustId AND a.BettypeId <> t.Factor;

END;
