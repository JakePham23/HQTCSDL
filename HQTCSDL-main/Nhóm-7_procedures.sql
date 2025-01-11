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

        WAITFOR DELAY '00:00:01'

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

CREATE OR ALTER PROCEDURE findBestPromotion
    @MaSP VARCHAR(50),
    @MaKH INT = NULL,
    @SoLuong INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
    BEGIN TRANSACTION
        DECLARE @BestDiscount INT = 0
        DECLARE @BestPromotionType NVARCHAR(50) = NULL
        DECLARE @BestMaKM INT = NULL

        CREATE TABLE #ValidPromotions (
            MaKM INT,
            TiLeGiam INT,
            LoaiKM NVARCHAR(50)
        )

        DECLARE @CurrentDate DATE = GETDATE()

        -- Flash Sale
        INSERT INTO #ValidPromotions
        SELECT 
            fs.MaKM,
            fs.TiLeGiam,
            'FlashSale' as LoaiKM
        FROM FlashSale fs WITH (UPDLOCK)
        JOIN KhuyenMai km ON fs.MaKM = km.MaKM
        WHERE km.MaSP = @MaSP 
            AND @CurrentDate BETWEEN km.NgayBatDau AND km.NgayKetThuc
            AND fs.SoLuong >= @SoLuong

        -- Combo Sale
        INSERT INTO #ValidPromotions
        SELECT 
            cs.MaKM,
            cs.TiLeGiam,
            'ComboSale' as LoaiKM
        FROM ComboSale cs WITH (UPDLOCK)
        JOIN KhuyenMai km ON cs.MaKM = km.MaKM
        WHERE km.MaSP = @MaSP 
            AND @CurrentDate BETWEEN km.NgayBatDau AND km.NgayKetThuc
            AND cs.SoLuong >= @SoLuong 

        -- Member Sale
        IF @MaKH IS NOT NULL
        BEGIN
            DECLARE @LoaiKH NVARCHAR(100)
            SELECT @LoaiKH = LoaiKH 
            FROM KhachHang 
            WHERE MaKH = @MaKH

            IF @LoaiKH IS NOT NULL
            BEGIN
                INSERT INTO #ValidPromotions
                SELECT 
                    ms.MaKM,
                    ms.TiLeGiam,
                    'MemberSale' as LoaiKM
                FROM MemberSale ms WITH (UPDLOCK)
                JOIN KhuyenMai km ON ms.MaKM = km.MaKM
                WHERE km.MaSP = @MaSP 
                    AND @CurrentDate BETWEEN km.NgayBatDau AND km.NgayKetThuc
                    AND ms.MucThanThiet = @LoaiKH
                    AND ms.SoLuong >= @SoLuong 
            END
        END

        SELECT TOP 1
            @BestMaKM = MaKM,
            @BestDiscount = TiLeGiam,
            @BestPromotionType = LoaiKM
        FROM #ValidPromotions
        ORDER BY TiLeGiam DESC

        -- Cập nhật số lượng khuyến mãi còn lại
        IF @BestMaKM IS NOT NULL
        BEGIN
            IF @BestPromotionType = 'FlashSale'
                UPDATE FlashSale
                SET SoLuong = SoLuong - @SoLuong
                WHERE MaKM = @BestMaKM
                
            IF @BestPromotionType = 'ComboSale'
                UPDATE ComboSale
                SET SoLuong = SoLuong - @SoLuong
                WHERE MaKM = @BestMaKM
                
            IF @BestPromotionType = 'MemberSale'
                UPDATE MemberSale
                SET SoLuong = SoLuong - @SoLuong
                WHERE MaKM = @BestMaKM
        END

        SELECT 
            @BestMaKM as MaKM,
            @BestPromotionType as LoaiKhuyenMai,
            @BestDiscount as TiLeGiam,
            CASE 
                WHEN @BestPromotionType IS NULL THEN N'Không có khuyến mãi phù hợp'
                ELSE N'Khuyến mãi hợp lệ'
            END as TrangThai

        DROP TABLE #ValidPromotions
    COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE Sp_ProcessingOrder
   @MaDH INT,
   @MaSP VARCHAR(50),
   @SoLuong INT,
   @MaNV INT,
   @MaKH INT = NULL
AS
BEGIN
   SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
   BEGIN TRY
       BEGIN TRANSACTION
           DECLARE @SoLuongKho INT, @GiaNiemYet INT
           SELECT @SoLuongKho = SoLuongKho, @GiaNiemYet = GiaNiemYet
           FROM SanPham WITH (UPDLOCK)
           WHERE MaSP = @MaSP

           IF @SoLuongKho >= @SoLuong
           BEGIN
               DECLARE @BestMaKM INT, @BestDiscount INT
               
               CREATE TABLE #BestPromotion (
                   MaKM INT,
                   LoaiKhuyenMai NVARCHAR(50),
                   TiLeGiam INT,
                   TrangThai NVARCHAR(100)
               )
               
               INSERT INTO #BestPromotion
               EXEC findBestPromotion @MaSP, @MaKH, @SoLuong
               
               SELECT @BestMaKM = MaKM, @BestDiscount = TiLeGiam 
               FROM #BestPromotion
               
               DECLARE @FinalPrice INT = @GiaNiemYet
               IF @BestDiscount > 0
                   SET @FinalPrice = @GiaNiemYet * (100 - @BestDiscount) / 100

               PRINT N'Giá niêm yết: ' + CAST(@GiaNiemYet AS NVARCHAR(20))
               PRINT N'Discount: ' + CAST(@BestDiscount AS NVARCHAR(20)) + '%'
               PRINT N'Giá sau giảm: ' + CAST(@FinalPrice AS NVARCHAR(20))
			
               UPDATE SanPham
               SET SoLuongKho = SoLuongKho - @SoLuong
               WHERE MaSP = @MaSP
           
               EXEC Sp_ReOrderStock @MaSP

               INSERT INTO ChiTietDonHang(MaDH, MaSP, SoLuong, DonGia)
               VALUES(@MaDH, @MaSP, @SoLuong, @FinalPrice)

               UPDATE DonHang 
               SET TongTien = TongTien + (@FinalPrice * @SoLuong)
               WHERE MaDH = @MaDH

               DROP TABLE #BestPromotion
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

-- SELECT * FROM SanPham WHERE MaSP = 'SP001'
-- SELECT * FROM DonDatHang
-- SELECT * FROM ChiTietDonHang 
-- SELECT * FROM DonHang

-- -- Với khách vãng lai
-- EXEC findBestPromotion @MaSP = 'SP001', @SoLuong = 2

-- -- Với khách hàng đã đăng ký
-- EXEC findBestPromotion @MaSP = 'SP001', @MaKH = 1, @SoLuong = 2