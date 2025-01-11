
use ConvenientStore;
Go

CREATE TABLE KhachHang (
    MaKH INT PRIMARY KEY,
    HoTen NVARCHAR(255),
    SDT VARCHAR(12),
    NgaySinh DATE,
    LoaiKH NVARCHAR(100),
    NgayDangKy DATE,
    TongTienNamTruoc INT,
    MaNV INT
);
ALTER TABLE KhachHang
ADD CONSTRAINT UQ_KhachHang_SDT UNIQUE (SDT);

CREATE TABLE PhieuMuaHang (
    MaPhieu VARCHAR(50) PRIMARY KEY,
    MaKH INT,
    QuaTang NVARCHAR(255),
    NgayBatDau DATE,
    NgayHetHan DATE,
    TrangThai VARCHAR(50),
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
);

CREATE TABLE NhanVien (
    MaNV INT PRIMARY KEY,
    HoTen NVARCHAR(255),
    GioiTinh CHAR(1),
    SDT VARCHAR(12),
    NgaySinh DATE,
    LoaiNV VARCHAR(50)
);

ALTER TABLE NhanVien
ADD CONSTRAINT UQ_NhanVien_SDT UNIQUE (SDT);

ALTER TABLE KhachHang
ADD CONSTRAINT FK_KhachHang_NhanVien
FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV);

CREATE TABLE DonHang (
    MaDH INT PRIMARY KEY,
    MaKH INT,
    MaNVDat INT,
    NgayDat DATE,
    TongTien INT,
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH),
    FOREIGN KEY (MaNVDat) REFERENCES NhanVien(MaNV)
);

CREATE TABLE LoaiSanPham (
    MaLoai VARCHAR(50) PRIMARY KEY,
    TenLoai NVARCHAR(255)
);

CREATE TABLE SanPham (
    MaSP VARCHAR(50) PRIMARY KEY,
    TenSP NVARCHAR(255),
    GiaNiemYet INT,
    SoLuongKho INT,
    SL_SP_TD INT,
    MaLoai VARCHAR(50),
    FOREIGN KEY (MaLoai) REFERENCES LoaiSanPham(MaLoai)
);


CREATE TABLE ChiTietDonHang (
    MaDH INT,
    MaSP VARCHAR(50),
    SoLuong INT,
    DonGia INT,
    PRIMARY KEY (MaDH, MaSP),
    FOREIGN KEY (MaDH) REFERENCES DonHang(MaDH),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);

CREATE TABLE DonDatHang (
    MaDDH VARCHAR(50) PRIMARY KEY,
    MaSP VARCHAR(50),
    NgayDat DATE,
    NgayNhanHangDuKien DATE,
    NgayNhanHang DATE,
    TrangThai VARCHAR(50),
    SoLuongDat INT,
    DonGia INT,
    MaNV INT,
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP),
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);

ALTER TABLE DonDatHang ADD MaNSX int;

CREATE TABLE NhaSanXuat (
    MaNSX INT IDENTITY PRIMARY KEY,
    TenNSX NVARCHAR(255)
);
alter table DonDatHang ADD CONSTRAINT FK_MaNSX_NhaSanXuat FOREIGN KEY (MaNSX) REFERENCES NhaSanXuat(MaNSX)

CREATE TABLE KhuyenMai (
    MaKM INT PRIMARY KEY,
    MaSP VARCHAR(50),
    LoaiKM INT,
    TenKM NVARCHAR(50),
    NgayBatDau DATE,
    NgayKetThuc DATE,
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);

CREATE TABLE MemberSale (
    MaKH INT,
    MucThanThiet VARCHAR(50),
    TiLeGiam INT,
    SoLuong INT,
	MaKM INT PRIMARY KEY, 
	Foreign key (MaKM) REFERENCES KhuyenMai(MaKM)
);

CREATE TABLE FlashSale (
    LoaiKM INT,
    TiLeGiam INT,
    SoLuong INT,
	MaKM INT PRIMARY KEY, 
	Foreign key (MaKM) REFERENCES KhuyenMai(MaKM)
);

CREATE TABLE ComboSale (
    LoaiKM INT,
    SoLuong INT,
	MaKM INT PRIMARY KEY, 
	Foreign key (MaKM) REFERENCES KhuyenMai(MaKM)
);

CREATE OR ALTER PROCEDURE findBestPromotion
    @MaSP VARCHAR(50),
    @MaKH INT = NULL,
    @SoLuong INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    BEGIN TRANSACTION
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
        FROM KhuyenMai km 
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
        FROM KhuyenMai km 
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
            FROM KhuyenMai km 
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

--PROCESSING ORDER
CREATE OR ALTER PROCEDURE Sp_ProcessingOrder
   @MaDH INT,
   @MaSP VARCHAR(50),
   @SoLuong INT,
   @MaNV INT,
   @MaKH INT = NULL
AS
BEGIN
   SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
   BEGIN TRY
       BEGIN TRANSACTION
           DECLARE @SoLuongKho INT, @GiaNiemYet INT
           SELECT @SoLuongKho = SoLuongKho, @GiaNiemYet = GiaNiemYet
           FROM SanPham
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
               
			   WAITFOR DELAY '00:00:15'

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

--Add promotion
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
    INSERT INTO KhuyenMai (MaKM, LoaiKM, TenKM, NgayBatDau, NgayKetThuc)
    VALUES (@MaKM, @LoaiKM, @TenKM, @NgayBatDau, @NgayKetThuc);

    -- 5. Thêm dữ liệu vào bảng chi tiết dựa trên loại khuyến mãi
    IF @LoaiKM = 1 -- FlashSale
    BEGIN
        INSERT INTO FlashSale (MaKM, MaSP)
        VALUES (@MaKM, @MaSP);

        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Thêm vào FlashSale không thành công';
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
    ELSE IF @LoaiKM = 2 -- ComboSale
    BEGIN
        INSERT INTO ComboSale (MaKM, MaSP)
        VALUES (@MaKM, @MaSP);

		INSERT INTO ComboSale (MaKM, MaSP)
        VALUES (@MaKM, @MaSP2);

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

        INSERT INTO MemberSale (MaKH, MucThanThiet, MaKM)
        VALUES (NULL, @MucThanThiet, @MaKM);

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
