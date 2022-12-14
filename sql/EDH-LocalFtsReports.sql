USE [master]
GO
/****** Object:  Database [LocalFTSReports]    Script Date: 28.09.2022 10:25:48 ******/
CREATE DATABASE [LocalFTSReports]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'LocalFTSReports', FILENAME = N'D:\MSSQLDB\LocalFTSReports.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'LocalFTSReports_log', FILENAME = N'D:\MSSQLDB\LocalFTSReports_log.ldf' , SIZE = 5120KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [LocalFTSReports] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [LocalFTSReports].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [LocalFTSReports] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [LocalFTSReports] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [LocalFTSReports] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [LocalFTSReports] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [LocalFTSReports] SET ARITHABORT OFF 
GO
ALTER DATABASE [LocalFTSReports] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [LocalFTSReports] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [LocalFTSReports] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [LocalFTSReports] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [LocalFTSReports] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [LocalFTSReports] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [LocalFTSReports] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [LocalFTSReports] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [LocalFTSReports] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [LocalFTSReports] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [LocalFTSReports] SET  DISABLE_BROKER 
GO
ALTER DATABASE [LocalFTSReports] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [LocalFTSReports] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [LocalFTSReports] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [LocalFTSReports] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [LocalFTSReports] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [LocalFTSReports] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [LocalFTSReports] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [LocalFTSReports] SET RECOVERY FULL 
GO
ALTER DATABASE [LocalFTSReports] SET  MULTI_USER 
GO
ALTER DATABASE [LocalFTSReports] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [LocalFTSReports] SET DB_CHAINING OFF 
GO
ALTER DATABASE [LocalFTSReports] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [LocalFTSReports] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [LocalFTSReports]
GO
/****** Object:  StoredProcedure [dbo].[pImportZoetis]    Script Date: 28.09.2022 10:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pImportZoetis]
	@inn varchar(50),
	@startdate datetime,
	@enddate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
Select tdclhead.G07x
	,tdclhead.g021
	,tdclhead.g022
	,tdclhead.g081
	,tdclhead.g141
	,tdclhead.g082
	,tdclhead.g142
	,tdclhead.gd1
	,tdclhead.g072
	,tdclhead.G221
	,tdclhead.G15
	,tdcltovar.G33
	,tdcltovar.G45
	,tdcltovar.G34
	,tdclTovar.G31_13
	,(
		Select Sum(tDclPlatR.G474) as pS 
			From edh.localfts.dbo.tDclPlatR 
		Where left(tDclPlatR.G471, 1)='2' 
		  and tDclPlatR.g07x=tDclTovar.g07x
		  and tDclPlatR.g32=tDclTovar.g32
	 ) as p
	 ,(
		Select Sum(G474) as pS 
			From edh.localfts.dbo.tDclPlatR
			   Where left(G471, 1)='5'
			     and g07x=tDclTovar.g07x
				 and g32=tDclTovar.g32
	   ) as n
	  ,tDclTovar.G072 as docIn
	  ,tdcltovar.G42
	  ,tdcltovar.G36
	  ,tdclhead.G011
	  ,(
		Select top 1 G442
		  From edh.localfts.dbo.tdclTechD
			Where tdclTechD.G441='02015' 
			  and tdclTovar.g07x=tdclTechD.g07x 
			  and tdclTovar.g32=tdclTechD.g32
		) as G442_02015
	  ,(
		Select top 1 G442
		   From edh.localfts.dbo.tdclTechD
		      Where G441='02017' 
			    and tdclTovar.g07x=tdclTechD.g07x 
				and tdclTovar.g32=tdclTechD.g32
	  ) as G442_02017
	  ,case when tdclhead.[database] like 'gtd_%_domodedovo' then 'Air' else 'Ground' end 
	 as Mode
From edh.localfts.dbo.tdcltovar join
     edh.localfts.dbo.tdclhead on tdcltovar.g07x=tdclhead.g07x
Where tdclhead.g141=@inn
  and tdcltovar.gd1 between @startdate and @enddate
  and left(tdcltovar.gd0,1)<'8'
order by docin, g07x, tdclTovar.g32
END

GO
/****** Object:  UserDefinedFunction [dbo].[ExchangeAmtFCYToLCY]    Script Date: 28.09.2022 10:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[ExchangeAmtFCYToLCY]
(
  @Date datetime,
  @CurrencyCode varchar(10),
  @Amount decimal(38, 20)
)
RETURNS decimal(38, 20)
AS
BEGIN
  declare @AmountLCY decimal(38, 20)
    if @CurrencyCode = ''
      RETURN @Amount

    select top 1 
	  @AmountLCY = round(isnull(@Amount / ([Exchange Rate Amount] / [Relational Exch_ Rate Amount]), 0), 2) 
	from [ntb1c\navision].[NAV].[dbo].[NLC$Currency Exchange Rate]
	where [Currency Code] = @CurrencyCode
	  and [Starting Date] <= @Date
    order by [Currency Code], [Starting Date] desc

	RETURN @AmountLCY
END

GO
/****** Object:  Table [dbo].[clients]    Script Date: 28.09.2022 10:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[clients](
	[uid] [bigint] IDENTITY(1,1) NOT NULL,
	[inn] [varchar](20) NOT NULL,
	[name] [varchar](150) NULL,
	[address] [varchar](8000) NULL,
	[database] [varchar](3) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[cube_of_firms]    Script Date: 28.09.2022 10:25:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[cube_of_firms]
AS
SELECT '' AS FType, MAX([name]) AS MName, Inn, MAX([address]) AS MADDRESS, MAX([name]) AS FNAME, MAX([database]) AS [database]
FROM [dbo].[clients]
GROUP BY inn
HAVING (NOT (inn IS NULL))



GO
USE [master]
GO
ALTER DATABASE [LocalFTSReports] SET  READ_WRITE 
GO
