USE ConvenientStore
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Sp_ProcessingOrder')
    DROP PROCEDURE Sp_ProcessingOrder
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Sp_ReOrderStock')
    DROP PROCEDURE Sp_ReOrderStock
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Sp_CheckBelowThreshold')
    DROP PROCEDURE Sp_ReOrderStock
GO

CREATE PROCEDURE sp_CheckBelowThreshold
    @MaSP VARCHAR(50),
    @IsBelow BIT OUTPUT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
    BEGIN TRANSACTION
        SELECT @IsBelow = CASE 
            WHEN SoLuongKho <= SL_SP_TD THEN 1 
            ELSE 0 
        END
        FROM SanPham WITH (UPDLOCK)
        WHERE MaSP = @MaSP
    COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Sp_ReOrderStock 
    @MaSP VARCHAR(50)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
    BEGIN TRANSACTION
        DECLARE @SoLuongKho INT, @SL_SP_TD INT
        
        SELECT @SoLuongKho = SoLuongKho,
               @SL_SP_TD = SL_SP_TD
        FROM SanPham WITH (UPDLOCK, ROWLOCK)
        WHERE MaSP = @MaSP

        WAITFOR DELAY '00:00:05'

        IF @SoLuongKho < @SL_SP_TD
        BEGIN
            DECLARE @MaDDH VARCHAR(50)
            SET @MaDDH = CONCAT('DDH', FORMAT(GETDATE(), 'yyyyMMddHHmmss'))
            
            INSERT INTO DonDatHang(MaDDH, MaSP, NgayDat, SoLuongDat, MaNV, TrangThai)
            VALUES(@MaDDH, @MaSP, GETDATE(), (@SL_SP_TD - @SoLuongKho) * 2, NULL, 'Pending')
        END
    COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Sp_ProcessingOrder
   @MaDH INT,
   @MaSP VARCHAR(50),
   @SoLuong INT,
   @MaNV INT
AS
BEGIN
   SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
   BEGIN TRY
       BEGIN TRANSACTION
           DECLARE @SoLuongKho INT
           SELECT @SoLuongKho = SoLuongKho 
           FROM SanPham WITH (UPDLOCK)
           WHERE MaSP = @MaSP

           IF @SoLuongKho >= @SoLuong
           BEGIN
               UPDATE SanPham
               SET SoLuongKho = SoLuongKho - @SoLuong
               WHERE MaSP = @MaSP
           
               EXEC Sp_ReOrderStock @MaSP

               INSERT INTO ChiTietDonHang(MaDH, MaSP, SoLuong, DonGia)
               SELECT @MaDH, @MaSP, @SoLuong, GiaNiemYet
               FROM SanPham
               WHERE MaSP = @MaSP

               COMMIT TRANSACTION
           END
           ELSE
           BEGIN
               ROLLBACK TRANSACTION
               RAISERROR(N'Số lượng tồn không đủ', 16, 1)
           END
   END TRY
   BEGIN CATCH
       IF @@TRANCOUNT > 0
           ROLLBACK TRANSACTION
       
       DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
       DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
       DECLARE @ErrorState INT = ERROR_STATE()

       RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
   END CATCH
END
GO


-- Reset data
UPDATE SanPham SET SoLuongKho = 100 WHERE MaSP = 'SP001'
DELETE FROM DonDatHang
DELETE FROM ChiTietDonHang

-- Test
EXEC Sp_ReOrderStock 'SP001';
EXEC Sp_ProcessingOrder 1, 'SP001', 60, 1;

SELECT * FROM DonDatHang
SELECT * FROM ChiTietDonHang 
SELECT * FROM SanPham WHERE MaSP = 'SP001'USE ConvenientStore
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Sp_ProcessingOrder')
    DROP PROCEDURE Sp_ProcessingOrder
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Sp_ReOrderStock')
    DROP PROCEDURE Sp_ReOrderStock
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'Sp_CheckBelowThreshold')
    DROP PROCEDURE Sp_ReOrderStock
GO

CREATE PROCEDURE sp_CheckBelowThreshold
    @MaSP VARCHAR(50),
    @IsBelow BIT OUTPUT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
    BEGIN TRANSACTION
        SELECT @IsBelow = CASE 
            WHEN SoLuongKho <= SL_SP_TD THEN 1 
            ELSE 0 
        END
        FROM SanPham WITH (UPDLOCK)
        WHERE MaSP = @MaSP
    COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Sp_ReOrderStock 
    @MaSP VARCHAR(50)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
    BEGIN TRANSACTION
        DECLARE @SoLuongKho INT, @SL_SP_TD INT
        
        SELECT @SoLuongKho = SoLuongKho,
               @SL_SP_TD = SL_SP_TD
        FROM SanPham WITH (UPDLOCK, ROWLOCK)
        WHERE MaSP = @MaSP

        WAITFOR DELAY '00:00:05'

        IF @SoLuongKho < @SL_SP_TD
        BEGIN
            DECLARE @MaDDH VARCHAR(50)
            SET @MaDDH = CONCAT('DDH', FORMAT(GETDATE(), 'yyyyMMddHHmmss'))
            
            INSERT INTO DonDatHang(MaDDH, MaSP, NgayDat, SoLuongDat, MaNV, TrangThai)
            VALUES(@MaDDH, @MaSP, GETDATE(), (@SL_SP_TD - @SoLuongKho) * 2, NULL, 'Pending')
        END
    COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Sp_ProcessingOrder
   @MaDH INT,
   @MaSP VARCHAR(50),
   @SoLuong INT,
   @MaNV INT
AS
BEGIN
   SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
   BEGIN TRY
       BEGIN TRANSACTION
           DECLARE @SoLuongKho INT
           SELECT @SoLuongKho = SoLuongKho 
           FROM SanPham WITH (UPDLOCK)
           WHERE MaSP = @MaSP

           IF @SoLuongKho >= @SoLuong
           BEGIN
               UPDATE SanPham
               SET SoLuongKho = SoLuongKho - @SoLuong
               WHERE MaSP = @MaSP
           
               EXEC Sp_ReOrderStock @MaSP

               INSERT INTO ChiTietDonHang(MaDH, MaSP, SoLuong, DonGia)
               SELECT @MaDH, @MaSP, @SoLuong, GiaNiemYet
               FROM SanPham
               WHERE MaSP = @MaSP

               COMMIT TRANSACTION
           END
           ELSE
           BEGIN
               ROLLBACK TRANSACTION
               RAISERROR(N'Số lượng tồn không đủ', 16, 1)
           END
   END TRY
   BEGIN CATCH
       IF @@TRANCOUNT > 0
           ROLLBACK TRANSACTION
       
       DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
       DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
       DECLARE @ErrorState INT = ERROR_STATE()

       RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
   END CATCH
END
GO


-- Reset data
UPDATE SanPham SET SoLuongKho = 100 WHERE MaSP = 'SP001'
DELETE FROM DonDatHang
DELETE FROM ChiTietDonHang

-- Test

-- Chạy trong cửa sổ Query 1:
EXEC Sp_ReOrderStock 'SP001';

-- Chạy trong cửa sổ Query 2 (ngay sau khi Query 1 bắt đầu):
EXEC Sp_ProcessingOrder 1, 'SP001', 60, 1;

SELECT * FROM SanPham WHERE MaSP = 'SP001'
SELECT * FROM DonDatHang
SELECT * FROM ChiTietDonHang 