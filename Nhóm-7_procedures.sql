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

create proc SP_UpdateInfoProduct
@MaSP INT,
@TenSP NVARCHAR(255),
@MoTa NVARCHAR(255),
@GiaNiemYet INT,
@SoLuongKho INT,
@MaLoai INT
as 
begin
	BEGIN TRANSACTION UpdateInfoProduct
	    SET TRANSACTION ISOLATION LEVEL Repeatable Read;
	
	if not exists (select 1 from SanPham where MaSP = @MaSP)
	begin
		raiserror(N'Sản phẩm không tồn tại trong hệ thông', 16, 1)
		rollback tran UpdateInfoProduct
		return 2
	end
	UPDATE SanPham
        SET 
            TenSP = @TenSP,
            MoTa = @MoTa,
            GiaNiemYet = @GiaNiemYet,
            SoLuongKho = @SoLuongKho,
            MaLoai = @MaLoai
        WHERE MaSP = @MaSP;
	WAITFOR DELAY '00:00:15';
	COMMIT TRANSACTION UpdateInfoProduct;
    RETURN 0;
end


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
