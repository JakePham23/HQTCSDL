﻿
﻿use ConvenientStore
-- Bộ phận chăm sóc khách hàng
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
    SET TRANSACTION ISOLATION LEVEL Repeatable Read;
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

create proc SP_FindUserById
	@MaKH INT
as
begin
    BEGIN TRANSACTION FindUserById
	    SET TRANSACTION ISOLATION LEVEL Repeatable Read;
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
CREATE PROCEDURE SP_GiftBirthdayVoucher
    @MaKH INT -- Input: Mã khách hàng
AS
BEGIN
    BEGIN TRANSACTION;
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

        -- Kiểm tra sự tồn tại của khách hàng
        IF NOT EXISTS (SELECT 1 FROM KhachHang WITH (READCOMMITTEDLOCK) WHERE MaKH = @MaKH)
        BEGIN
            ROLLBACK;
            RAISERROR ('Khách hàng không tồn tại', 16, 1);
            RETURN;
        END

        -- Kiểm tra ngày sinh nhật của khách hàng
        IF EXISTS (SELECT 1 FROM KhachHang WITH (READCOMMITTEDLOCK) 
                   WHERE MaKH = @MaKH AND CONVERT(DATE, NgaySinh) = CONVERT(DATE, GETDATE()))
        BEGIN
            -- Khai báo các biến
            DECLARE @LoaiKH NVARCHAR(50);
            DECLARE @QuaTang INT;

            -- Lấy thông tin loại khách hàng
            SELECT @LoaiKH = LoaiKH FROM KhachHang WHERE MaKH = @MaKH;

            -- Xác định giá trị quà tặng
            IF (@LoaiKH = N'Kim cương') SET @QuaTang = 1200000;
            ELSE IF (@LoaiKH = N'Bạch Kim') SET @QuaTang = 700000;
            ELSE IF (@LoaiKH = N'Vàng') SET @QuaTang = 500000;
            ELSE IF (@LoaiKH = N'Bạc') SET @QuaTang = 200000;
            ELSE IF (@LoaiKH = N'Đồng') SET @QuaTang = 100000;
            ELSE 
            BEGIN
                ROLLBACK;
                RAISERROR ('Khách hàng chưa đủ điều kiện để nhận phiếu mua hàng', 16, 1);
                RETURN;
            END

			-- Khai báo biến MaPhieu
			DECLARE @MaPhieu NVARCHAR(50); 
			SET @MaPhieu = CONCAT(@MaKH, 'PMHCVN', FORMAT(GETDATE(), 'yyyyMMddHHmmss'));

			-- Cập nhật thông tin quà tặng trong bảng PhieuMuaHang
			INSERT INTO PhieuMuaHang (MaPhieu, MaKH, QuaTang, NgayBatDau, NgayHetHan, TrangThai) 
			VALUES (
				@MaPhieu,         -- Mã phiếu
				@MaKH,            -- Mã khách hàng
				@QuaTang,         -- Giá trị quà tặng
				GETDATE(),        -- Ngày bắt đầu (hôm nay - ngày sinh nhật)
				DATEADD(DAY, 14, GETDATE()), -- Ngày hết hạn: 14 ngày sau ngày bắt đầu
				N'Chưa sử dụng'            -- Trạng thái
			);

            -- Ghi log thành công
            PRINT 'Đã tặng quà cho khách hàng';
        END
        ELSE
        BEGIN
            ROLLBACK;
            RAISERROR ('Hôm nay không phải sinh nhật của khách hàng', 16, 1);
            RETURN;
        END

        -- Commit transaction
        COMMIT;
END;
GO


-- Bộ phận kinh doanh
CREATE PROCEDURE Sp_ProductSaleReport
    @NgayBaoCao DATE,
    @MaSP VARCHAR(50),
    @SoLuongBan INT OUTPUT,
    @TongSoKhachHang INT OUTPUT
AS
BEGIN
    -- Tính tổng số lượng sản phẩm đã bán trong ngày báo cáo
    SELECT @SoLuongBan = SUM(CTDH.SoLuong)
    FROM ChiTietDonHang CTDH
    JOIN DonHang DH ON CTDH.MaDH = DH.MaDH
    WHERE CTDH.MaSP = @MaSP AND DH.NgayDat = @NgayBaoCao;

    -- Đếm số lượng khách hàng riêng biệt đã mua sản phẩm trong ngày báo cáo
    SELECT @TongSoKhachHang = COUNT(DISTINCT DH.MaKH)
    FROM ChiTietDonHang CTDH
    JOIN DonHang DH ON CTDH.MaDH = DH.MaDH
    WHERE CTDH.MaSP = @MaSP AND DH.NgayDat = @NgayBaoCao;
END;

CREATE PROCEDURE Sp_RevenueReport
    @reportDate DATE,                 -- Ngày báo cáo
    @totalRevenue DECIMAL(17, 3) OUTPUT, -- Tổng doanh thu
    @totalCustomers INT OUTPUT           -- Tổng số khách hàng
AS
BEGIN
    -- Khai báo biến tạm cho con trỏ
    DECLARE @orderTotal INT, @customerID INT;
    DECLARE @revenueTemp DECIMAL(17, 3) = 0;
    DECLARE @customerList TABLE (MaKH INT);

    -- Khai báo con trỏ
    DECLARE orderCursor CURSOR FORWARD_ONLY READ_ONLY
    FOR
    SELECT TongTien, MaKH
    FROM DonHang WITH (HOLDLOCK)
    WHERE NgayDat = @reportDate;

    -- Bắt đầu giao dịch
    BEGIN TRANSACTION;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    -- Mở con trỏ
    OPEN orderCursor;

    -- Lặp qua từng dòng trong con trỏ
    FETCH NEXT FROM orderCursor INTO @orderTotal, @customerID;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Cộng dồn tổng doanh thu
        SET @revenueTemp = @revenueTemp + @orderTotal;

        -- Lưu khách hàng vào danh sách tạm (tránh trùng lặp)
        IF NOT EXISTS (SELECT 1 FROM @customerList WHERE MaKH = @customerID)
        BEGIN
            INSERT INTO @customerList (MaKH) VALUES (@customerID);
        END

        -- Lấy dòng tiếp theo
        FETCH NEXT FROM orderCursor INTO @orderTotal, @customerID;
    END;

    -- Đóng và xóa con trỏ
    CLOSE orderCursor;
    DEALLOCATE orderCursor;

    -- Gán kết quả đầu ra
    SET @totalRevenue = @revenueTemp;
    SET @totalCustomers = (SELECT COUNT(*) FROM @customerList);

    -- Kết thúc trans
    COMMIT TRANSACTION;
END;

-- Bộ phận quản lý kho
-- sp_checkBelowThreshold: Kiểm tra xem sản phẩm có dưới mức tồn tối thiểu không
CREATE PROCEDURE sp_checkBelowThreshold
    @MaSP NVARCHAR(50),
    @isBelowThreshold BIT OUTPUT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Kiểm tra xem sản phẩm có dưới ngưỡng tồn kho tối thiểu hay không
        IF EXISTS (
            SELECT 1
            FROM SanPham WITH (HOLDLOCK, ROWLOCK)
            WHERE MaSP = @MaSP
              AND SoLuongKho < SL_SP_TD * 0.7 -- Mức tồn tối thiểu = 70% SL_SP_TD
        )
        BEGIN
            SET @isBelowThreshold = 1; -- Dưới ngưỡng
        END
        ELSE
        BEGIN
            SET @isBelowThreshold = 0; -- Không dưới ngưỡng
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
--drop procedure sp_checkBelowThreshold

-- sp_ReOrderStock: Đặt hàng nếu số lượng sản phẩm dưới mức tồn tối thiểu
CREATE PROCEDURE sp_ReOrderStock
    @MaSP NVARCHAR(50),
    @MaDDH NVARCHAR(50)
AS
BEGIN
    
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    -- Biến để lưu kết quả kiểm tra dưới ngưỡng
    DECLARE @isBelowThreshold BIT;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Gọi store proc phụ để kiểm tra sản phẩm có dưới ngưỡng tồn kho tối thiểu hay không
        EXEC sp_checkBelowThreshold @MaSP = @MaSP, @isBelowThreshold = @isBelowThreshold OUTPUT;

        -- Nếu sản phẩm dưới ngưỡng thì tiến hành đặt hàng
        IF @isBelowThreshold = 1
        BEGIN
            -- Tính toán số lượng cần đặt
            DECLARE @SoLuongDat INT;
            SELECT @SoLuongDat = SL_SP_TD - SoLuongKho
            FROM SanPham WITH (HOLDLOCK, ROWLOCK)
            WHERE MaSP = @MaSP;

            -- Thêm thông tin vào bảng DonDatHang
            INSERT INTO DonDatHang (MaDDH, MaSP, NgayDat, NgayNhanHangDuKien, TrangThai, SoLuongDat, DonGia, MaNV)
            SELECT
                @MaDDH, -- Mã đơn đặt hàng
                @MaSP, -- Mã sản phẩm
                GETDATE(), -- Ngày đặt
                DATEADD(DAY, 7, GETDATE()), -- Ngày nhận dự kiến (7 ngày sau ngày đặt)
                'Đang chờ', -- Trạng thái
                @SoLuongDat, -- Số lượng đặt
                GiaNiemYet, -- Giá niêm yết
                NULL -- Mã nhân viên, có thể NULL nếu chưa gán
            FROM SanPham
            WHERE MaSP = @MaSP;

        END
        ELSE
        BEGIN
            -- Nếu không dưới ngưỡng, không làm gì cả
            PRINT 'Sản phẩm không dưới ngưỡng, không cần đặt hàng.';
        END

        -- Commit transaction nếu không có lỗi
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction nếu có lỗi xảy ra
        ROLLBACK TRANSACTION;

        -- Hiển thị thông báo lỗi
        THROW;
    END CATCH;
END
GO

--drop procedure sp_ReOrderStock
DECLARE @MaDDH NVARCHAR(50) = 'DDH003'; -- Mã đơn đặt hàng
EXEC sp_ReOrderStock @MaSP = 'ABC', @MaDDH = @MaDDH;
GO

select * from DonDatHang
select * from SanPham


INSERT INTO SanPham(MaSP, TenSP, GiaNiemYet, SoLuongKho, SL_SP_TD, MaLoai) VALUES ('DEF', 'DienThoaiIP', 1234, 20, 100, 'ABC')



-- QL Ngành Hàng 

CREATE OR ALTER PROCEDURE Sp_AddPromotion
    @MaSP VARCHAR(50),
	@MaSP2 VARCHAR(50),
    @NgayBatDau DATE,
    @NgayKetThuc DATE,
    @TenKM NVARCHAR(50),
    @LoaiKM INT, -- 1: FlashSale, 2: ComboSale, 3: MemberSale
    @TiLeGiam INT,
    @SoLuong INT,
    @MucThanThiet NVARCHAR(50) = NULL -- Chỉ áp dụng cho MemberSale
AS
BEGIN
    BEGIN TRANSACTION;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    DECLARE @SoLuongSanPham INT;
    DECLARE @MaKM INT;

    -- 1. Xác định số lượng sản phẩm áp dụng khuyến mãi trong kho
    SELECT @SoLuongSanPham = SoLuongKho FROM SanPham WHERE MaSP = @MaSP;

    -- 2. Kiểm tra điều kiện số lượng tối đa
    IF @SoLuong > @SoLuongSanPham
    BEGIN
        PRINT N'Số lượng khuyến mãi không thể lớn hơn số lượng hàng trong kho';
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 3. Lấy MaKM cao nhất và cộng thêm 1
    SELECT @MaKM = ISNULL(MAX(MaKM), 0) + 1 FROM KhuyenMai;

    -- 4. Thêm vào bảng KhuyenMai
    INSERT INTO KhuyenMai (MaKM, MaSP, LoaiKM, TenKM, NgayBatDau, NgayKetThuc)
    VALUES (@MaKM, @MaSP, @LoaiKM, @TenKM, @NgayBatDau, @NgayKetThuc);

    -- 5. Thêm dữ liệu vào bảng chi tiết dựa trên loại khuyến mãi
    IF @LoaiKM = 1 -- FlashSale
    BEGIN
        INSERT INTO FlashSale (LoaiKM, TiLeGiam, SoLuong, MaKM)
        VALUES (@LoaiKM, @TiLeGiam, @SoLuong, @MaKM);

        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Thêm vào FlashSale không thành công';
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
    ELSE IF @LoaiKM = 2 -- ComboSale
    BEGIN
        INSERT INTO ComboSale (LoaiKM, TiLeGiam, SoLuong, MaKM, MaSP)
        VALUES (@LoaiKM, @TiLeGiam, @SoLuong, @MaKM, @MaSP);

		INSERT INTO ComboSale (LoaiKM, TiLeGiam, SoLuong, MaKM, MaSP)
        VALUES (@LoaiKM, @TiLeGiam, @SoLuong, @MaKM, @MaSP2);

        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Thêm vào ComboSale không thành công';
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
    ELSE IF @LoaiKM = 3 -- MemberSale
    BEGIN
        IF @MucThanThiet IS NULL
        BEGIN
            PRINT N'Mức thân thiết không được để trống cho khuyến mãi MemberSale';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO MemberSale (MaKH, MucThanThiet, TiLeGiam, SoLuong, MaKM)
        VALUES (NULL, @MucThanThiet, @TiLeGiam, @SoLuong, @MaKM);

        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Thêm vào MemberSale không thành công';
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
    ELSE
    BEGIN
        PRINT N'Loại khuyến mãi không hợp lệ';
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Commit giao dịch
    COMMIT TRANSACTION;

    PRINT N'Chương trình khuyến mãi đã được thêm thành công';
END;

EXEC Sp_AddPromotion 
    @MaSP = 'SP001',          -- Mã sản phẩm
    @NgayBatDau = '2025-01-01', -- Ngày bắt đầu
    @NgayKetThuc = '2025-01-10', -- Ngày kết thúc
    @TenKM = N'Giảm giá đầu năm', -- Tên khuyến mãi
    @LoaiKM = 1,            -- 'F' cho FlashSale
    @TiLeGiam = 30,           -- Tỷ lệ giảm giá
    @SoLuong = 100;           -- Số lượng khuyến mãi


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
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

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
			PRINT 'Cập nhật không thành công. Không có sản phẩm nào được tìm thấy với mã sản phẩm đã cho.';
			ROLLBACK TRANSACTION; -- Hoặc bạn có thể không cần rollback nếu không có giao dịch đang mở
			RETURN;
		END

		-- Commit giao dịch
		COMMIT TRANSACTION;

		PRINT N'Thông tin sản phẩm đã được cập nhật thành công';

		CLOSE SanPham_Cursor;
		DEALLOCATE SanPham_Cursor;
	END
END

EXEC Sp_UpdateInfoProduct
    @MaSP = 'SP001',         -- Mã sản phẩm cần cập nhật
    @TenSP = N'Tên sản phẩm mới', -- Tên sản phẩm mới
    @GiaNiemYet = 1500000,  -- Giá niêm yết mới
    @SoLuongKho = 100,      -- Số lượng kho mới
    @MaLoai = 'L001';       -- Mã loại sản phẩm mới
