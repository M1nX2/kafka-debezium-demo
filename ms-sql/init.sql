-- Initialization script for productsdb
-- Enable output of messages
PRINT 'Starting database initialization...';
GO

-- Use master database
USE master;
GO

-- Drop database if it exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'productsdb')
BEGIN
    PRINT 'Dropping existing productsdb database...';
    ALTER DATABASE productsdb SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE productsdb;
END
GO

-- Create productsdb
PRINT 'Creating productsdb database...';
CREATE DATABASE productsdb;
GO

-- Switch to productsdb
USE productsdb;
GO

-- Create dbo schema if not exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dbo')
BEGIN
    PRINT 'Creating dbo schema...';
    EXEC('CREATE SCHEMA dbo');
END
GO

-- Enable CDC on the database
BEGIN TRY
    PRINT 'Enabling CDC on productsdb...';
    EXEC sys.sp_cdc_enable_db;
    PRINT 'CDC enabled successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error enabling CDC: ' + ERROR_MESSAGE();
END CATCH
GO

-- Create products table
PRINT 'Creating products table...';
CREATE TABLE dbo.products (
    PRODUCT_ID BIGINT IDENTITY(1,1) PRIMARY KEY,
    NAME NVARCHAR(255) NOT NULL,
    DESCRIPTION NVARCHAR(1000) NOT NULL,
    PRICE DECIMAL(18, 5) NOT NULL,
    CREATED_AT DATETIME DEFAULT GETDATE()
);
GO

-- Enable CDC on products table
BEGIN TRY
    PRINT 'Enabling CDC on products table...';
    EXEC sys.sp_cdc_enable_table
        @source_schema = N'dbo',
        @source_name   = N'products',
        @role_name     = NULL,
        @supports_net_changes = 1;
    PRINT 'CDC enabled for products table successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error enabling CDC for products table: ' + ERROR_MESSAGE();
END CATCH
GO

-- Insert test data
PRINT 'Inserting test data...';
INSERT INTO dbo.products (NAME, DESCRIPTION, PRICE)
VALUES 
    ('Product One', 'First test product', 10.99),
    ('Product Two', 'Second test product', 20.50),
    ('Product Three', 'Third test product', 15.75);
GO

-- Verify table creation
PRINT 'Verifying table creation...';
SELECT * FROM dbo.products;
GO

-- Verify CDC configuration
PRINT 'Checking CDC configuration...';
SELECT name, is_tracked_by_cdc 
FROM sys.tables 
WHERE schema_name(schema_id) = 'dbo' AND name = 'products';
GO

-- Включение публикации для таблицы
EXEC sp_replicationdboption 
    @dbname = N'productsdb', 
    @optname = N'publish', 
    @value = N'true';

-- Публикация для таблицы
EXEC sp_addpublication 
    @publication = N'products_publication', 
    @description = N'Products table publication',
    @sync_method = N'native', 
    @repl_freq = N'continuous', 
    @status = N'active';

EXEC sp_addarticle 
    @publication = N'products_publication', 
    @article = N'products', 
    @source_owner = N'dbo', 
    @source_object = N'products', 
    @type = N'logbased', 
    @destination_table = N'products', 
    @destination_owner = N'dbo';

PRINT 'Database initialization completed.';
GO
