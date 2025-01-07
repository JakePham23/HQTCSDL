use convenientstore
go
select * from KhuyenMai
select * from MemberSale
select * from FlashSale
select * from ComboSale

CREATE or ALTER PROCEDURE Sp_AddPromotion
    @MaSP VARCHAR(50),
    @NgayBatDau DATE,
    @NgayKetThuc DATE,
    @TenKM NVARCHAR(50),
	@LoaiKM INT,
    @TiLeGiam INT,
    @SoLuong INT
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

    -- 3.1 Thêm vào khuyến mãi FlashSale hoặc ComboSale
    IF @LoaiKM = 1
    BEGIN
        INSERT INTO FlashSale (LoaiKM, TiLeGiam, SoLuong, MaKM)
        VALUES (@LoaiKM, @TiLeGiam, @SoLuong, @MaKM);
		-- Kiểm tra sự thành công của lệnh INSERT
		IF @@ROWCOUNT = 0
		BEGIN
			PRINT 'Thêm vào FlashSale không thành công';
			ROLLBACK TRANSACTION;
			RETURN;
		END
    END
    ELSE IF @LoaiKM = 2
    BEGIN
        INSERT INTO ComboSale (LoaiKM, SoLuong, MaKM)
        VALUES (@LoaiKM, @SoLuong, @MaKM);
		-- Kiểm tra sự thành công của lệnh INSERT
		IF @@ROWCOUNT = 0
		BEGIN
			PRINT 'Thêm vào ComboSale không thành công';
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
END

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