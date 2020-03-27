
ALTER PROCEDURE [dbo].[RobotUsers_04_CreateRawChanceOfDanger]
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

	TRUNCATE TABLE dbo.[RobotUsers_RawChanceOfDanger];
		
	DECLARE @maxDateOrder INT;
	DECLARE @dateOrder INT = 1;
	DECLARE @marginRange NUMERIC(3,2);	

	SELECT @maxDateOrder = MAX(c.DateOrder) 
	FROM dbo.RobotUsers_CumulativeMarginByDate AS c WITH(NOLOCK);
	
	IF (@maxDateOrder = 1)
		BEGIN
			return
		END;
		
	WHILE(@dateOrder <= @maxDateOrder)
		BEGIN
			SET @marginRange = 0.1;
			WHILE(@marginRange >= -0.1 AND @dateOrder <= @maxDateOrder)
				BEGIN
					INSERT INTO dbo.[RobotUsers_RawChanceOfDanger](MarginRange, DateOrder, PercentageOfWin)
					SELECT @marginRange, @dateOrder, CASE WHEN @marginRange > 0 THEN 1 ELSE 0 END;
					
					SET @marginRange = @marginRange - 0.01;
				 END;
			
			SET @dateOrder = @dateOrder + 1;
		END;

	UPDATE r WITH (ROWLOCK, UPDLOCK)
	SET PercentageOfWin = tmp.PercentageOfWin 
	FROM dbo.[RobotUsers_RawChanceOfDanger] AS r
		INNER JOIN (	
						SELECT	w.MarginRange
							,	w.DateOrder
							,	CAST(w.NumOfWinner AS FLOAT) / l.NumOfLoser AS 'PercentageOfWin'
						FROM dbo.RobotUsers_WinnerByDateCounter AS w WITH(NOLOCK)
							INNER JOIN dbo.RobotUsers_LoserByDateCounter AS l WITH(NOLOCK) ON w.MarginRange = l.MarginRange AND w.DateOrder = l.DateOrder
					
					) AS tmp ON tmp.MarginRange = r.MarginRange AND tmp.DateOrder = r.DateOrder;

	;WITH cte AS
	(
		SELECT r.MarginRange, MIN(r.DateOrder) AS StartIndex
		FROM dbo.[RobotUsers_RawChanceOfDanger] AS r WITH(NOLOCK)
		WHERE r.PercentageOfWin = 1 OR r.PercentageOfWin = 0
		GROUP BY r.MarginRange
	)
	UPDATE r2 WITH (ROWLOCK, UPDLOCK)
	SET r2.PercentageOfWin = (CASE WHEN r2.MarginRange > 0 THEN 1 ELSE 0 END)
	FROM cte AS r1
		INNER JOIN dbo.[RobotUsers_RawChanceOfDanger] AS r2 ON r1.MarginRange = r2.MarginRange
	WHERE r2.DateOrder > r1.StartIndex;

END;