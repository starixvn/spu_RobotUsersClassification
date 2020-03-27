
ALTER PROCEDURE [dbo].[RobotUsers_00_RunModel]
		@FromDate					DATE = '20200101'
	,	@ToDate						DATE = '20200202'
	,	@Settings_MinBetCount		INT	= 0
	,	@NumOfDatePlacedBet			INT = 3
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

	DECLARE		@SporttypeId		INT 
			,	@BettypeId			INT 
			,	@IsLive				BIT;

	IF	OBJECT_ID('tempdb..#tmpBettypeGroups') IS NOT NULL
		DROP TABLE	#tmpBettypeGroups;

	CREATE TABLE	#tmpBettypeGroups (
			VRBettypeGroupId		SMALLINT
		,	BettypeId				SMALLINT
		,	PRIMARY KEY (VRBettypeGroupId, BettypeId)
	);
			
	-- START
	-- Filter data first
	EXECUTE [dbo].[RobotUsers_01_FilterData] @FromDate, @ToDate, @Settings_MinBetCount;

	-- Go through the loop for each touple Sporttype-Bettype-LiveIndicator
	DECLARE Section_Cursor CURSOR FOR  
	SELECT DISTINCT d.SporttypeId
		, d.BettypeId 
		, d.IsLive
	FROM dbo.RobotUsers_FilteredDailyData AS d WITH(NOLOCK);

	--Step 2 to 5
	OPEN Section_Cursor;  
	FETCH NEXT FROM Section_Cursor INTO @SporttypeId, @BettypeId, @IsLive;  
	WHILE @@FETCH_STATUS = 0  
	   BEGIN  	

		   EXECUTE [dbo].[RobotUsers_02_PrepareData] 
					@SporttypeId
				,	@BettypeId
				,	@IsLive
				,	@NumOfDatePlacedBet;

			EXECUTE [dbo].[RobotUsers_03_CookData];
		
			EXECUTE [dbo].[RobotUsers_04_CreateRawChanceOfDanger];
		
			EXECUTE [dbo].[RobotUsers_05_ComputeDangerLevel]
					@FromDate
				,	@ToDate
				,	@SporttypeId
				,	@BettypeId
				,	@IsLive
			
			FETCH NEXT FROM Section_Cursor INTO @SporttypeId, @BettypeId, @IsLive; 
	   END;  
	CLOSE Section_Cursor;  
	DEALLOCATE Section_Cursor;  

END;

