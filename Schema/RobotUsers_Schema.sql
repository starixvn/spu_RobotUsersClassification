CREATE TABLE [dbo].[RobotUsers_DailyData](
	[ReportDate]		DATE NOT NULL,
	[CustId]			INT NOT NULL,
	[CurrencyId]        INT NOT NULL,
	[SuperId]			INT NOT NULL,
	[MasterId]			INT NOT NULL,
	[AgentId]			INT NOT NULL,
	[SporttypeId]       INT NOT NULL,
	[BettypeId]         SMALLINT NOT NULL,
	[IsLive]			BIT NOT NULL,
	[IBCTurnover]		MONEY NULL,
	[IBCWinloss]		MONEY NULL,
	[BetCount]			INT NULL,
	CONSTRAINT PK_RobotUsers_DailyData PRIMARY KEY CLUSTERED (
		[ReportDate]	ASC,
		[CustId]		ASC,
		[SportTypeId]	ASC,
		[BettypeId]		ASC,
		[IsLive]		ASC
	)
) ON [DATA];
GO

CREATE TABLE [dbo].[RobotUsers_FilteredDailyData](
	[ReportDate]		DATE NOT NULL,
	[CustId]			INT NOT NULL,
	[SporttypeId]       INT NOT NULL,
	[BettypeId]         SMALLINT NOT NULL,
	[IsLive]			BIT NOT NULL,
	[IBCTurnover]		MONEY NULL,
	[IBCWinloss]		MONEY NULL,
	[BetCount]			INT NULL,
	CONSTRAINT PK_RobotUsers_FilteredDailyData PRIMARY KEY CLUSTERED (
		[ReportDate]	ASC,
		[CustId]		ASC,
		[SportTypeId]	ASC,
		[BettypeId]		ASC,
		[IsLive]		ASC
	)
) --ON [DATA];
GO

CREATE TABLE [dbo].[RobotUsers_StagingDailyData](
	[ReportDate]		DATE NOT NULL,
	[DateOrder]			INT NOT NULL,
	[CustId]			INT NOT NULL,
	[IBCTurnover]		MONEY NULL,
	[IBCWinloss]		MONEY NULL,
	[BetCount]			INT NULL,
	CONSTRAINT PK_RobotUsers_StagingDailyData PRIMARY KEY CLUSTERED (
		[ReportDate]	ASC,
		[DateOrder]		ASC,
		[CustId]		ASC
	)
) --ON [DATA];
GO

CREATE TABLE [dbo].[RobotUsers_CumulativeMarginByDate](
	[DateOrder]			INT NOT NULL,
	[CustId]			INT NOT NULL,
	[Margin]			NUMERIC(3,2) NULL,
	CONSTRAINT PK_RobotUsers_CumulativeMarginByDate PRIMARY KEY CLUSTERED (
		[DateOrder]		ASC,
		[CustId]		ASC
	)
) --ON [DATA];
GO

CREATE TABLE [dbo].[RobotUsers_CumulativeInfo](
	[CustId]			INT NOT NULL,
	[Margin]			NUMERIC(3,2) NULL,
	[NumOfDateBet]		INT	NULL,
	CONSTRAINT PK_RobotUsers_CumulativeInfo PRIMARY KEY CLUSTERED (
		[CustId]		ASC
	)
) --ON [DATA];
GO

CREATE TABLE [dbo].[RobotUsers_WinnerByDateCounter](
	[MarginRange]		FLOAT NOT NULL,
	[DateOrder]			INT NOT NULL,
	[NumOfWinner]		INT	NULL,
	CONSTRAINT PK_RobotUsers_WinnerByDateCounter PRIMARY KEY CLUSTERED (
		[MarginRange]	ASC,
		[DateOrder]		ASC
	)
) --ON [DATA];
GO

CREATE TABLE [dbo].[RobotUsers_LoserByDateCounter](
	[MarginRange]		FLOAT NOT NULL,
	[DateOrder]			INT NOT NULL,
	[NumOfLoser]		INT	NULL,
	CONSTRAINT PK_RobotUsers_LoserByDateCounter PRIMARY KEY CLUSTERED (
		[MarginRange]	ASC,
		[DateOrder]		ASC
	)
) --ON [DATA];
GO

CREATE TABLE [dbo].[RobotUsers_RawChanceOfDanger](
	[MarginRange]		FLOAT NOT NULL,
	[DateOrder]			INT NOT NULL,
	[PercentageOfWin]	FLOAT	NULL,
	CONSTRAINT PK_RobotUsers_RawChanceOfDanger PRIMARY KEY CLUSTERED (
		[MarginRange]	ASC,
		[DateOrder]		ASC
	)
) --ON [DATA];
GO

CREATE TABLE [dbo].[RobotUsers_PercentageOfWin](
	[CustId]					INT NOT NULL,
	[SporttypeId]				INT NOT NULL,
	[BettypeId]					SMALLINT NOT NULL,
	[IsLive]					BIT NOT NULL,
	[CurrentMargin]				NUMERIC(3,2) NOT NULL,
	[NumberOfDatePlacedBet]		INT NOT NULL,
	[PercentageOfWin]			FLOAT NULL,
	[CreatedDate]				DATE,
	[FromDate]					DATE,
	[ToDate]					DATE
) --ON [DATA];
GO

CREATE CLUSTERED INDEX PK_RobotUsers_PercentageOfWin ON dbo.[RobotUsers_PercentageOfWin]
(
	[CustId]		ASC,
	[SportTypeId]	ASC,
	[BettypeId]		ASC,
	[IsLive]		ASC,
	[CreatedDate]	ASC
);