
use ConvenientStore
Go

-- sp_checkBelowThreshold: Kiểm tra xem sản phẩm có dưới mức tồn tối thiểu không
CREATE PROCEDURE sp_checkBelowThreshold
    @MaSP NVARCHAR(50),
    @isBelowThreshold BIT OUTPUT
AS
BEGIN

    -- Kiểm tra xem sản phẩm có dưới ngưỡng tồn kho tối thiểu hay không
    IF EXISTS (
        SELECT 1
        FROM SanPham
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
END
GO
--drop procedure sp_checkBelowThreshold

-- sp_ReOrderStock: Đặt hàng nếu số lượng sản phẩm dưới mức tồn tối thiểu
CREATE PROCEDURE sp_ReOrderStock
    @MaSP NVARCHAR(50),
    @MaDDH NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Biến để lưu kết quả kiểm tra dưới ngưỡng
    DECLARE @isBelowThreshold BIT;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Gọi thủ tục phụ để kiểm tra sản phẩm có dưới ngưỡng tồn kho tối thiểu hay không
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