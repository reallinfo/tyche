/**
 * GNU General Public License Version 3.0, 29 June 2007
 * TycheDB_Create
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "TycheDB"
:setvar DefaultFilePrefix "TycheDB"
:setvar DefaultDataPath ""
:setvar DefaultLogPath ""

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [master];


GO

IF (DB_ID(N'$(DatabaseName)') IS NOT NULL) 
BEGIN
    ALTER DATABASE [$(DatabaseName)]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$(DatabaseName)];
END

GO
PRINT N'Creating $(DatabaseName)...'
GO
CREATE DATABASE [$(DatabaseName)] COLLATE SQL_Latin1_General_CP1_CI_AS
GO
USE [$(DatabaseName)];


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                NUMERIC_ROUNDABORT OFF,
                QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT ON,
                CURSOR_DEFAULT LOCAL,
                RECOVERY FULL,
                CURSOR_CLOSE_ON_COMMIT OFF,
                AUTO_CREATE_STATISTICS ON,
                AUTO_SHRINK OFF,
                AUTO_UPDATE_STATISTICS ON,
                RECURSIVE_TRIGGERS OFF 
            WITH ROLLBACK IMMEDIATE;
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_CLOSE OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ALLOW_SNAPSHOT_ISOLATION OFF;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET READ_COMMITTED_SNAPSHOT OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_UPDATE_STATISTICS_ASYNC OFF,
                PAGE_VERIFY NONE,
                DATE_CORRELATION_OPTIMIZATION OFF,
                DISABLE_BROKER,
                PARAMETERIZATION SIMPLE,
                SUPPLEMENTAL_LOGGING OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET TRUSTWORTHY OFF,
        DB_CHAINING OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'The database settings cannot be modified. You must be a SysAdmin to apply these settings.';
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET HONOR_BROKER_PRIORITY OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'The database settings cannot be modified. You must be a SysAdmin to apply these settings.';
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET TARGET_RECOVERY_TIME = 0 SECONDS 
    WITH ROLLBACK IMMEDIATE;


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET FILESTREAM(NON_TRANSACTED_ACCESS = OFF),
                CONTAINMENT = NONE 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF),
                MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = OFF,
                DELAYED_DURABILITY = DISABLED 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE (QUERY_CAPTURE_MODE = ALL, DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_PLANS_PER_QUERY = 200, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 367), MAX_STORAGE_SIZE_MB = 100) 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE = OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
    END


GO
IF fulltextserviceproperty(N'IsFulltextInstalled') = 1
    EXECUTE sp_fulltext_database 'enable';


GO
PRINT N'Creating [dbo].[NotificationAssignments]...';


GO
CREATE TABLE [dbo].[NotificationAssignments] (
    [UserId]         INT    NOT NULL,
    [NotificationId] BIGINT NOT NULL,
    [IsSeen]         BIT    NULL,
    CONSTRAINT [PK_NOTIFICATION_ASSIGNMENT] PRIMARY KEY CLUSTERED ([NotificationId] ASC, [UserId] ASC)
);


GO
PRINT N'Creating [dbo].[Verifications]...';


GO
CREATE TABLE [dbo].[Verifications] (
    [Id]          INT           IDENTITY (100000, 1) NOT NULL,
    [UserId]      INT           NOT NULL,
    [Code]        NVARCHAR (32) NOT NULL,
    [Created]     DATETIME      NOT NULL,
    [ValidOffset] INT           NOT NULL,
    CONSTRAINT [PK_VERIFICATION] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Creating [dbo].[Users]...';


GO
CREATE TABLE [dbo].[Users] (
    [Id]                INT           IDENTITY (100000, 1) NOT NULL,
    [FirstName]         NVARCHAR (20) NOT NULL,
    [LastName]          NVARCHAR (50) NULL,
    [Username]          VARCHAR (55)  NOT NULL,
    [Email]             VARCHAR (100) NOT NULL,
    [ProfilePictureUrl] VARCHAR (MAX) NULL,
    [PasswordHash]      VARCHAR (MAX) NOT NULL,
    [IsVerified]        BIT           NOT NULL,
    [IsActive]          BIT           NOT NULL,
    CONSTRAINT [PK_USER_ID] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Creating [dbo].[Notifications]...';


GO
CREATE TABLE [dbo].[Notifications] (
    [Id]         BIGINT         IDENTITY (100000, 1) NOT NULL,
    [Type]       INT            NULL,
    [Info]       NVARCHAR (MAX) NULL,
    [ChatRoomId] INT            NULL,
    [Created]    DATETIME       NULL,
    CONSTRAINT [PK_NOTIFICATION_ID] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Creating [dbo].[MessagesSeenUsers]...';


GO
CREATE TABLE [dbo].[MessagesSeenUsers] (
    [MessageId] BIGINT NOT NULL,
    [UserId]    INT    NOT NULL
);


GO
PRINT N'Creating [dbo].[Messages]...';


GO
CREATE TABLE [dbo].[Messages] (
    [Id]      BIGINT          IDENTITY (100000, 1) NOT NULL,
    [From]    INT             NULL,
    [To]      INT             NULL,
    [Header]  NVARCHAR (MAX)  NULL,
    [Text]    NVARCHAR (4000) NOT NULL,
    [Created] DATETIME        NULL,
    CONSTRAINT [PK_MESSAGE_ID] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Creating [dbo].[ChatRooms]...';


GO
CREATE TABLE [dbo].[ChatRooms] (
    [Id]         INT            IDENTITY (100000, 1) NOT NULL,
    [CreatorId]  INT            NULL,
    [Name]       NVARCHAR (100) NULL,
    [Created]    DATETIME       NOT NULL,
    [IsGroup]    BIT            NOT NULL,
    [IsKeyFixed] BIT            NOT NULL,
    [PictureUrl] VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_CHATROOM_ID] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Creating [dbo].[ChatRoomMembers]...';


GO
CREATE TABLE [dbo].[ChatRoomMembers] (
    [ChatRoomId]  INT            NOT NULL,
    [UserId]      INT            NOT NULL,
    [FixedHeader] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_CHATROOM_MEMBER] PRIMARY KEY CLUSTERED ([ChatRoomId] ASC, [UserId] ASC)
);


GO
PRINT N'Creating [dbo].[Grants]...';


GO
CREATE TABLE [dbo].[Grants] (
    [Id]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [Key]          VARCHAR (4000) NULL,
    [Type]         VARCHAR (4000) NULL,
    [SubjectId]    VARCHAR (4000) NULL,
    [ClientId]     VARCHAR (4000) NULL,
    [CreationTime] DATETIME       NOT NULL,
    [Expiration]   DATETIME       NULL,
    [Data]         VARCHAR (4000) NULL,
    CONSTRAINT [PK_GRANT] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Creating [dbo].[BlockedIPs]...';


GO
CREATE TABLE [dbo].[BlockedIPs] (
    [Id]        INT           IDENTITY (1, 1) NOT NULL,
    [IPAddress] VARCHAR (255) NOT NULL,
    [StartDate] DATETIME      NOT NULL,
    [EndDate]   DATETIME      NOT NULL,
    [ReasonId]  INT           NULL,
    CONSTRAINT [PK_BLOCKED_IP] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Creating [dbo].[BlockReasons]...';


GO
CREATE TABLE [dbo].[BlockReasons] (
    [Id]       INT             NOT NULL,
    [Reason]   NVARCHAR (4000) NOT NULL,
    [Duration] BIGINT          NOT NULL,
    CONSTRAINT [PK_BLOCK_REASONS] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Creating [dbo].[UserBlockedIPs]...';


GO
CREATE TABLE [dbo].[UserBlockedIPs] (
    [UserID]    INT           NOT NULL,
    [IPAddress] VARCHAR (255) NOT NULL,
    [StartDate] DATETIME      NOT NULL,
    [EndDate]   DATETIME      NOT NULL,
    [ReasonId]  INT           NOT NULL,
    CONSTRAINT [PK_USER_BLOCKED_IPS] PRIMARY KEY CLUSTERED ([UserID] ASC, [IPAddress] ASC)
);


GO
PRINT N'Creating [dbo].[BlockedUsers]...';


GO
CREATE TABLE [dbo].[BlockedUsers] (
    [Id]           INT      NOT NULL,
    [Date]         DATETIME NULL,
    [BlockExpires] DATETIME NULL,
    [ReasonId]     INT      NULL,
    CONSTRAINT [PK_BLOCKED_USER_ID] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Creating unnamed constraint on [dbo].[Users]...';


GO
ALTER TABLE [dbo].[Users]
    ADD DEFAULT (0) FOR [IsVerified];


GO
PRINT N'Creating unnamed constraint on [dbo].[Users]...';


GO
ALTER TABLE [dbo].[Users]
    ADD DEFAULT (0) FOR [IsActive];


GO
PRINT N'Creating unnamed constraint on [dbo].[ChatRooms]...';


GO
ALTER TABLE [dbo].[ChatRooms]
    ADD DEFAULT (0) FOR [IsGroup];


GO
PRINT N'Creating unnamed constraint on [dbo].[ChatRooms]...';


GO
ALTER TABLE [dbo].[ChatRooms]
    ADD DEFAULT (0) FOR [IsKeyFixed];


GO
PRINT N'Creating [dbo].[FK_NOTIFICATION_USER_ID]...';


GO
ALTER TABLE [dbo].[NotificationAssignments]
    ADD CONSTRAINT [FK_NOTIFICATION_USER_ID] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]) ON DELETE CASCADE;


GO
PRINT N'Creating [dbo].[FK_NOTIFICATION_ID]...';


GO
ALTER TABLE [dbo].[NotificationAssignments]
    ADD CONSTRAINT [FK_NOTIFICATION_ID] FOREIGN KEY ([NotificationId]) REFERENCES [dbo].[Notifications] ([Id]) ON DELETE CASCADE;


GO
PRINT N'Creating [dbo].[FK_VERIFICATIONS_USER_ID]...';


GO
ALTER TABLE [dbo].[Verifications]
    ADD CONSTRAINT [FK_VERIFICATIONS_USER_ID] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]);


GO
PRINT N'Creating [dbo].[FK_NOTIFICATION_CHAT_ROOM_ID]...';


GO
ALTER TABLE [dbo].[Notifications]
    ADD CONSTRAINT [FK_NOTIFICATION_CHAT_ROOM_ID] FOREIGN KEY ([ChatRoomId]) REFERENCES [dbo].[ChatRooms] ([Id]) ON DELETE CASCADE;


GO
PRINT N'Creating [dbo].[FK_MESSAGE_SEEN_MESSAGE_ID]...';


GO
ALTER TABLE [dbo].[MessagesSeenUsers]
    ADD CONSTRAINT [FK_MESSAGE_SEEN_MESSAGE_ID] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[Messages] ([Id]) ON DELETE CASCADE;


GO
PRINT N'Creating [dbo].[FK_MESSAGE_SEEN_USER_ID]...';


GO
ALTER TABLE [dbo].[MessagesSeenUsers]
    ADD CONSTRAINT [FK_MESSAGE_SEEN_USER_ID] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]) ON DELETE CASCADE;


GO
PRINT N'Creating [dbo].[FK_MESSAGE_FROM]...';


GO
ALTER TABLE [dbo].[Messages]
    ADD CONSTRAINT [FK_MESSAGE_FROM] FOREIGN KEY ([From]) REFERENCES [dbo].[Users] ([Id]);


GO
PRINT N'Creating [dbo].[FK_MESSAGE_TO]...';


GO
ALTER TABLE [dbo].[Messages]
    ADD CONSTRAINT [FK_MESSAGE_TO] FOREIGN KEY ([To]) REFERENCES [dbo].[ChatRooms] ([Id]) ON DELETE CASCADE;


GO
PRINT N'Creating [dbo].[FK_CHATROOM_CREATOR_ID]...';


GO
ALTER TABLE [dbo].[ChatRooms]
    ADD CONSTRAINT [FK_CHATROOM_CREATOR_ID] FOREIGN KEY ([CreatorId]) REFERENCES [dbo].[Users] ([Id]);


GO
PRINT N'Creating [dbo].[FK_CHATROOM_ID]...';


GO
ALTER TABLE [dbo].[ChatRoomMembers]
    ADD CONSTRAINT [FK_CHATROOM_ID] FOREIGN KEY ([ChatRoomId]) REFERENCES [dbo].[ChatRooms] ([Id]) ON DELETE CASCADE;


GO
PRINT N'Creating [dbo].[FK_USER_ID]...';


GO
ALTER TABLE [dbo].[ChatRoomMembers]
    ADD CONSTRAINT [FK_USER_ID] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]) ON DELETE CASCADE;


GO
PRINT N'Creating [dbo].[FK_BLOCKED_IP_REASON_ID]...';


GO
ALTER TABLE [dbo].[BlockedIPs]
    ADD CONSTRAINT [FK_BLOCKED_IP_REASON_ID] FOREIGN KEY ([ReasonId]) REFERENCES [dbo].[BlockReasons] ([Id]) ON DELETE CASCADE;


GO
PRINT N'Creating [dbo].[FK_USER_BLOCKED_USER_ID]...';


GO
ALTER TABLE [dbo].[UserBlockedIPs]
    ADD CONSTRAINT [FK_USER_BLOCKED_USER_ID] FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([Id]) ON DELETE CASCADE;


GO
PRINT N'Creating [dbo].[FK_USER_BLOCKED_IPS_REASON]...';


GO
ALTER TABLE [dbo].[UserBlockedIPs]
    ADD CONSTRAINT [FK_USER_BLOCKED_IPS_REASON] FOREIGN KEY ([ReasonId]) REFERENCES [dbo].[BlockReasons] ([Id]) ON DELETE CASCADE;


GO
PRINT N'Creating [dbo].[FK_BLOCKED_USER_ID]...';


GO
ALTER TABLE [dbo].[BlockedUsers]
    ADD CONSTRAINT [FK_BLOCKED_USER_ID] FOREIGN KEY ([Id]) REFERENCES [dbo].[Users] ([Id]) ON DELETE CASCADE;


GO
PRINT N'Creating [dbo].[FK_BLOCKED_USER_REASON_ID]...';


GO
ALTER TABLE [dbo].[BlockedUsers]
    ADD CONSTRAINT [FK_BLOCKED_USER_REASON_ID] FOREIGN KEY ([ReasonId]) REFERENCES [dbo].[BlockReasons] ([Id]) ON DELETE CASCADE;


GO
PRINT N'Creating [dbo].[uspGetUsersByUsername]...';


GO
/**
 * GNU General Public License Version 3.0, 29 June 2007
 * uspGetUsersByUsername
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

/***Type : Enumerable***/
CREATE PROCEDURE [dbo].[uspGetUsersByUsername]
	@username	VARCHAR(55)
AS
	BEGIN
		SELECT * FROM [Users] WHERE CHARINDEX(@username, [Username]) > 0
	END
GO
PRINT N'Creating [dbo].[uspGetUserById]...';


GO
/**
 * GNU General Public License Version 3.0, 29 June 2007
 * uspGetUserById
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

/***Type : Entity***/
CREATE PROCEDURE [dbo].[uspGetUserById]
	@userId	INT
AS
	BEGIN
		SELECT * FROM [Users] WHERE [Id] = @userId
	END
GO
PRINT N'Creating [dbo].[uspAssignNotificationToUser]...';


GO
/**
 * GNU General Public License Version 3.0, 29 June 2007
 * uspAssignNotificationToUser
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

/***Type : NoReturnValue***/
CREATE PROCEDURE [dbo].[uspAssignNotificationToUser]
	@userId			INT,
	@notificationId	BIGINT
AS
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION ASSIGN_NOTIFICATION_TO_USER
				INSERT INTO [NotificationAssignments] VALUES (@userId, @notificationId, 0)
			COMMIT TRANSACTION ASSIGN_NOTIFICATION_TO_USER
			RETURN 0x0
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION ASSIGN_NOTIFICATION_TO_USER
			RETURN 0x4
		END CATCH		
	END
GO
PRINT N'Creating [dbo].[uspGetMessagesByChatroomIdAndDate]...';


GO
/**
 * GNU General Public License Version 3.0, 29 June 2007
 * uspGetMessagesByChatroomIdAndDate
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

/***Type : Enumerable***/
CREATE PROCEDURE [dbo].[uspGetMessagesByChatroomIdAndDate]
	@chatroomId		INT,
	@fromDate		DATETIME,
	@toDate			DATETIME
AS
	BEGIN
		SELECT * FROM [Messages]
			WHERE	[To] = @chatroomId AND
					[Created] >= @fromDate AND
					[Created] <= @toDate
	END
GO
PRINT N'Creating [dbo].[uspGetMessagesByChatroomId]...';


GO
/**
 * GNU General Public License Version 3.0, 29 June 2007
 * uspGetMessagesByChatroomId
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

/***Type : Enumerable***/
CREATE PROCEDURE [dbo].[uspGetMessagesByChatroomId]
	@chatroomId	INT,
	@toDate		DATETIME	
AS
	BEGIN
		SELECT TOP 10 * 
			FROM  [Messages] 
			WHERE [To] = @chatroomId AND [Created] <= @toDate
			ORDER BY [CREATED] DESC
	END
GO
PRINT N'Creating [dbo].[uspGetChatroomsByMemberId]...';


GO
/**
 * GNU General Public License Version 3.0, 29 June 2007
 * uspGetChatroomsByMemberId
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

/***Type : Enumerable***/
CREATE PROCEDURE [dbo].[uspGetChatroomsByMemberId]
	@memberId	INT
AS
	BEGIN
		SELECT	[Id],
				[Name],
				[Created],
				[IsGroup],
				[PictureUrl] 
			FROM [ChatRoomMembers] crm 
			INNER JOIN [ChatRooms] cr  ON crm.[ChatRoomId] = cr.[Id]
			WHERE [UserId] = @memberId  			
    END
GO
PRINT N'Creating [dbo].[uspGetChatroomMembersByChatroomId]...';


GO
/**
 * GNU General Public License Version 3.0, 29 June 2007
 * uspGetChatroomMembersByChatroomId
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

/***Type : Enumerable***/
CREATE PROCEDURE [dbo].[uspGetChatroomMembersByChatroomId]
	@chatroomId	INT
AS
	BEGIN
		SELECT	u.[Id],
				u.[FirstName],
				u.[LastName],
				u.[Username],
				u.[ProfilePictureUrl]
			FROM [ChatRoomMembers] crm
			INNER JOIN [Users] u ON crm.[UserId] = u.[Id]
			WHERE crm.[ChatRoomId] = @chatroomId
	END
GO
PRINT N'Creating [dbo].[uspGetChatroomById]...';


GO
/**
 * GNU General Public License Version 3.0, 29 June 2007
 * uspGetChatroomById
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

/***Type : Entity***/
CREATE PROCEDURE [dbo].[uspGetChatroomById]
	@id	INT
AS
	BEGIN
		SELECT * FROM [ChatRooms] WHERE [Id] = @id
	END
GO
PRINT N'Creating [dbo].[uspCreateMessage]...';


GO
/**
 * GNU General Public License Version 3.0, 29 June 2007
 * uspCreateMessage
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

/***Type : NoReturnValue***/
CREATE PROCEDURE [dbo].[uspCreateMessage]
	@from	INT,
	@to		INT,
	@header	NVARCHAR(MAX),
	@text	NVARCHAR(4000)
AS
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION CREATE_MESSAGE
				
				--creating message
				INSERT INTO [Messages] VALUES (
					@from,
					@to,
					@header,
					@text,
					GETDATE()
				)
		
			COMMIT TRANSACTION CREATE_MESSAGE
			RETURN 0x0
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION CREATE_MESSAGE
			RETURN 0x4
		END CATCH
	END
GO
PRINT N'Creating [dbo].[uspVerifyUser]...';


GO
/**
 * GNU General Public License Version 3.0, 29 June 2007
 * uspVerifyUser
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

/***Type : NoReturnValue***/
CREATE PROCEDURE [dbo].[uspVerifyUser]
	@userId		INT,
	@code		NVARCHAR(32)
AS	
	BEGIN		
		DECLARE @isVerified BIT
		SELECT @isVerified = IsVerified FROM [Users] WHERE Id = @userId
		IF @isVerified IS NULL
			RETURN 0x7
		if @isVerified = 1
			RETURN 0x8
		BEGIN TRY
			BEGIN TRANSACTION VERIFY
				DECLARE @created		DATETIME
				DECLARE @validOffSet	INT
				SELECT @created = Created, @validOffset = ValidOffset FROM [Verifications]
					WHERE UserId = @userId AND Code = @code
				IF @created + @validOffset > GETDATE()
					RETURN 0x6
				DELETE FROM [Verifications] WHERE UserId = @userId AND Code = @code
				UPDATE [Users] SET IsVerified = 1 WHERE Id = @userId
				RETURN 0x0
			COMMIT TRANSACTION VERIFIY	
		END TRY	
		BEGIN CATCH
			ROLLBACK TRANSACTION VERIFIY
			RETURN 0x4
		END CATCH		 
	END
GO
PRINT N'Creating [dbo].[uspCreateNotification]...';


GO
/**
 * GNU General Public License Version 3.0, 29 June 2007
 * uspCreateNotification
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

/***Type : NoReturnValue***/
CREATE PROCEDURE [dbo].[uspCreateNotification]
	@type		INT,
	@info		NVARCHAR(MAX),
	@chatRoomId	INT
AS
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION CREATE_NOTIFICATION
				INSERT INTO [Notifications] VALUES (
					@type,
					@info,
					@chatRoomId,
					GETDATE())
			COMMIT TRANSACTION CREATE_NOTIFICATION
			RETURN SCOPE_IDENTITY()
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION CREATE_NOTIFICATION
			RETURN 0x4
		END CATCH
	END
GO
PRINT N'Creating [dbo].[uspCreateChatRoom]...';


GO
/**
 * GNU General Public License Version 3.0, 29 June 2007
 * uspCreateChatRoom
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

/***Type : NoReturnValue***/
CREATE PROCEDURE [dbo].[uspCreateChatRoom]
	@name			NVARCHAR(100),
	@creatorId		INT,
	@isGroup		BIT,
	@isKeyFixed		BIT,
	@pictureUrl		VARCHAR(MAX)
AS
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION CREATE_CHAT_ROOM
				INSERT INTO [ChatRooms] VALUES (
					@creatorId,
					@name,
					GETDATE(),
					@isGroup,
					@isKeyFixed,
					@pictureUrl)
			COMMIT TRANSACTION CREATE_CHAT_ROOM
			RETURN SCOPE_IDENTITY()
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION CREATE_CHAT_ROOM
			RETURN 0x4
		END CATCH
	END
GO
PRINT N'Creating [dbo].[uspCreateVerificationCode]...';


GO
/**
 * GNU General Public License Version 3.0, 29 June 2007
 * uspCreateVerificationCode
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

/***Type : NoReturnValue***/
CREATE PROCEDURE [dbo].[uspCreateVerificationCode]
	@userId			INT,
	@code			NVARCHAR(32),
	@validOffset	INT
AS
	BEGIN
		INSERT INTO [Verifications] VALUES (
			@userId,
			@code,
			GETDATE(),
			@validOffset)
		RETURN 0x0
	END
GO
PRINT N'Creating [dbo].[uspCreateUser]...';


GO
/**
 * GNU General Public License Version 3.0, 29 June 2007
 * uspCreateUser
 * Copyright (C) <2019>
 *      Authors: <amirkhaniansev>  <amirkhanyan.sevak@gmail.com>
 *               <DavidPetr>       <david.petrosyan11100@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Full notice : https://github.com/amirkhaniansev/tyche/tree/master/LICENSE
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

/***Type : NoReturnValue***/
CREATE PROCEDURE [dbo].[uspCreateUser]
	@firstName			NVARCHAR(20),
	@lastName			NVARCHAR(50),
	@username			VARCHAR(55),
	@email				VARCHAR(100),
	@profilePictureUrl	VARCHAR(MAX),
	@passwordHash		VARCHAR(MAX)
AS
	BEGIN
		IF EXISTS (SELECT * FROM [Users] WHERE Username = @username OR Email = @email)
			RETURN 0x3
		BEGIN TRY
			BEGIN TRANSACTION CREATE_USER
				INSERT INTO Users VALUES(
					@firstName,
					@lastName,
					@username,
					@email,
					@profilePictureUrl,
					@passwordHash,
					0,
					0)
			COMMIT TRANSACTION CREATE_USER
			RETURN SCOPE_IDENTITY()
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION CREATE_USER
			RETURN 0x4
		END CATCH	
	END
GO
-- Refactoring step to update target server with deployed transaction logs

IF OBJECT_ID(N'dbo.__RefactorLog') IS NULL
BEGIN
    CREATE TABLE [dbo].[__RefactorLog] (OperationKey UNIQUEIDENTIFIER NOT NULL PRIMARY KEY)
    EXEC sp_addextendedproperty N'microsoft_database_tools_support', N'refactoring log', N'schema', N'dbo', N'table', N'__RefactorLog'
END
GO
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = 'cd287906-f9fc-4a84-b9af-179e0e7190a9')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('cd287906-f9fc-4a84-b9af-179e0e7190a9')
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = 'e8650bcb-158f-4a37-95ee-507390b5416a')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('e8650bcb-158f-4a37-95ee-507390b5416a')

GO

GO
DECLARE @VarDecimalSupported AS BIT;

SELECT @VarDecimalSupported = 0;

IF ((ServerProperty(N'EngineEdition') = 3)
    AND (((@@microsoftversion / power(2, 24) = 9)
          AND (@@microsoftversion & 0xffff >= 3024))
         OR ((@@microsoftversion / power(2, 24) = 10)
             AND (@@microsoftversion & 0xffff >= 1600))))
    SELECT @VarDecimalSupported = 1;

IF (@VarDecimalSupported > 0)
    BEGIN
        EXECUTE sp_db_vardecimal_storage_format N'$(DatabaseName)', 'ON';
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET MULTI_USER 
    WITH ROLLBACK IMMEDIATE;


GO
PRINT N'Update complete.';


GO
