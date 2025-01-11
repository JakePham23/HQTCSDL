﻿use ConvenientStore
-- demo dirty read 1
-- connect database 2 lần 2 tab khác nhau và chạy proc ở mỗi tab 
-- demo lỗi khi insert thành công nhưng mà chưa commit có một giao tác khác
-- tìm kiếm SP_FindUserById lại chạy thành công => đọc dữ liệu rác 
-- các proc cần thiết trước khi ràng buộc dữ liệu tránh lỗi 
DROP PROC SP_InsertNewUser
CREATE PROCEDURE SP_InsertNewUser 
    @MaKH INT,
    @HoTen NVARCHAR(255),
    @SDT VARCHAR(12),
    @NgaySinh DATE,
    @MaNV INT
AS
BEGIN
    BEGIN TRANSACTION InsertNewUser;
    
    -- Set the transaction isolation level before the transaction block
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        -- Check if the customer already exists
        IF EXISTS (SELECT 1 FROM KhachHang WHERE MaKH = @MaKH)
        BEGIN
            RAISERROR (N'Khách hàng đã tồn tại.', 16, 1);
            ROLLBACK TRANSACTION InsertNewUser;
            RETURN 2;
        END

        -- Check if the phone number is already registered (excluding current MaKH)
        IF EXISTS (SELECT 1 FROM KhachHang WHERE SDT = @SDT AND MaKH != @MaKH)
        BEGIN
            RAISERROR (N'Số điện thoại đã tồn tại.', 16, 1);
            ROLLBACK TRANSACTION InsertNewUser;
            RETURN 3;
        END

        -- Insert the new customer
        INSERT INTO KhachHang (MaKH, HoTen, SDT, NgaySinh, MaNV) 
        VALUES (@MaKH, @HoTen, @SDT, @NgaySinh, @MaNV);

        -- Optional delay (for testing purposes)
        WAITFOR DELAY '00:00:20';

        COMMIT TRANSACTION InsertNewUser;
        RETURN 0; -- Success
END;
GO

drop proc SP_FindUserById
create proc SP_FindUserById
	@MaKH INT
as
begin
    BEGIN TRANSACTION FindUserById
	    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
		if not exists (Select 1 from KhachHang where MaKH = @MaKH)
		begin
			RAISERROR(N'Khách hàng chưa đăng kí', 16, 1)
			ROLLBACK TRAN FindUserById
			RETURN 2
		end
		SELECT * FROM KhachHang where MaKH = @MaKH
	COMMIT TRANSACTION InsertNewUser;
    RETURN 0;
end
	
exec SP_InsertNewUser 2411011, 'Jake', '0987878787', '11/01/2000', 1
exec SP_FindUserById 2411011

-- demo dirty read 2
CREATE OR ALTER PROCEDURE Sp_UpdateInfoProduct
	@MaSP VARCHAR(50),
	@TenSP NVARCHAR(255),
	@GiaNiemYet INT, 
	@SoLuongKho INT, 
	@MaLoai VARCHAR(50)
AS
BEGIN
	DECLARE @MaSPC VARCHAR(50);
	DECLARE @Exists INT;
	Set @Exists = 0;

	BEGIN TRANSACTION;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE SanPham_Cursor CURSOR FOR
	SELECT MaSP FROM SanPham;

	OPEN SanPham_Cursor;
	FETCH NEXT FROM SanPham_Cursor INTO @MaSPC;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @MaSPC = @MaSP
		BEGIN
			SET @Exists = 1;
			BREAK;
		END
		FETCH NEXT FROM SanPham_Cursor INTO @MaSPC;
	END

	--Nếu sản phẩm không tồn tại
	IF @Exists = 0
	BEGIN
		PRINT N'Sản phẩm không tồn tại';
        ROLLBACK TRANSACTION;
        CLOSE SanPham_Cursor;
        DEALLOCATE SanPham_Cursor;
        RETURN;
	END
	ELSE
	BEGIN
		-- Cập nhật thông tin sản phẩm
		UPDATE SanPham
		SET TenSP = @TenSP,
			GiaNiemYet = @GiaNiemYet,
			SoLuongKho = @SoLuongKho,
			MaLoai = @MaLoai
		WHERE MaSP = @MaSP;

		-- Kiểm tra sự thành công của lệnh UPDATE
		IF @@ROWCOUNT = 0
		BEGIN
			PRINT N'Cập nhật không thành công. Không có sản phẩm nào được tìm thấy với mã sản phẩm đã cho.';
			ROLLBACK TRANSACTION; -- Hoặc bạn có thể không cần rollback nếu không có giao dịch đang mở
			RETURN;
		END
        WAITFOR DELAY '00:00:20';
		-- Commit giao dịch
		COMMIT TRANSACTION;

		PRINT N'Thông tin sản phẩm đã được cập nhật thành công';

		CLOSE SanPham_Cursor;
		DEALLOCATE SanPham_Cursor;
	END
END



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
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
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
DROP PROC findBestPromotion
CREATE OR ALTER PROCEDURE findBestPromotion
    @MaSP VARCHAR(50),
    @MaKH INT = NULL,
    @SoLuong INT
AS
BEGIN
    BEGIN TRANSACTION;
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

        DECLARE @BestDiscount INT = 0
        DECLARE @BestPromotionType NVARCHAR(50) = NULL
        DECLARE @BestMaKM INT = NULL

        CREATE TABLE #ValidPromotions (
            MaKM INT,
            TiLeGiam INT,
            LoaiKM INT
        )

        DECLARE @CurrentDate DATE = GETDATE()

        -- Flash Sale
        INSERT INTO #ValidPromotions
        SELECT 
            km.MaKM,
            km.TiLeGiam,
            km.LoaiKM
        FROM KhuyenMai km WITH (UPDLOCK)
        JOIN FlashSale fs ON fs.MaKM = km.MaKM
        WHERE fs.MaSP = @MaSP 
            AND @CurrentDate BETWEEN km.NgayBatDau AND km.NgayKetThuc
            AND km.SoLuong >= @SoLuong
            AND km.LoaiKM = 1

        -- Combo Sale
        INSERT INTO #ValidPromotions
        SELECT 
            km.MaKM,
            km.TiLeGiam,
            km.LoaiKM
        FROM KhuyenMai km WITH (UPDLOCK)
        JOIN ComboSale cs ON cs.MaKM = km.MaKM
        WHERE cs.MaSP = @MaSP 
            AND @CurrentDate BETWEEN km.NgayBatDau AND km.NgayKetThuc
            AND km.SoLuong >= @SoLuong
            AND km.LoaiKM = 2

        -- Member Sale
        IF @MaKH IS NOT NULL
        BEGIN
            INSERT INTO #ValidPromotions
            SELECT 
                km.MaKM,
                km.TiLeGiam,
                km.LoaiKM
            FROM KhuyenMai km WITH (UPDLOCK)
            JOIN MemberSale ms ON ms.MaKM = km.MaKM
            WHERE ms.MaKH = @MaKH
                AND @CurrentDate BETWEEN km.NgayBatDau AND km.NgayKetThuc
                AND km.SoLuong >= @SoLuong
                AND km.LoaiKM = 3
        END

        SELECT TOP 1
            @BestMaKM = MaKM,
            @BestDiscount = TiLeGiam
        FROM #ValidPromotions
        ORDER BY TiLeGiam DESC

        IF @BestMaKM IS NOT NULL
        BEGIN
            UPDATE KhuyenMai
            SET SoLuong = SoLuong - @SoLuong
            WHERE MaKM = @BestMaKM
        END

        SELECT 
            @BestMaKM as MaKM,
            CASE 
                WHEN @BestMaKM IS NULL THEN NULL
                ELSE (SELECT LoaiKM FROM KhuyenMai WHERE MaKM = @BestMaKM)
            END as LoaiKhuyenMai,
            @BestDiscount as TiLeGiam,
            CASE 
                WHEN @BestMaKM IS NULL THEN N'Không có khuyến mãi phù hợp'
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
       BEGIN TRANSACTION
   SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

           DECLARE @SoLuongKho INT, @GiaNiemYet INT
           SELECT @SoLuongKho = SoLuongKho, @GiaNiemYet = GiaNiemYet
           FROM SanPham WITH (UPDLOCK)
           WHERE MaSP = @MaSP

           IF @SoLuongKho >= @SoLuong
           BEGIN
               DECLARE @BestMaKM INT, @BestDiscount INT
               
               CREATE TABLE #BestPromotion (
                   MaKM INT,
                   LoaiKhuyenMai INT,   
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

               IF NOT EXISTS (SELECT 1 FROM DonHang WHERE MaDH = @MaDH)
               BEGIN
                   INSERT INTO DonHang(MaDH, MaKH, MaNVDat, NgayDat, TongTien)
                   VALUES(@MaDH, @MaKH, @MaNV, GETDATE(), 0)
               END
			
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
END
GO
EXEC Sp_UpdateInfoProduct
    @MaSP = 'SP01',         -- Mã sản phẩm cần cập nhật
    @TenSP = N'Tên sản phẩm mới', -- Tên sản phẩm mới
    @GiaNiemYet = 1,  -- Giá niêm yết mới
    @SoLuongKho = 100,      -- Số lượng kho mới
    @MaLoai = 'L01';       -- Mã loại sản phẩm mới
EXEC Sp_ProcessingOrder 1, 'SP01', 2, 1, 2501124
