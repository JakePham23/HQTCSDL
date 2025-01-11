USE ConvenientStore;
GO

-- Thiết lập để theo dõi deadlock
DBCC TRACEON (1222, -1);
GO

-- Test xung đột
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

        WAITFOR DELAY '00:00:05'

        IF @SoLuongKho < @SL_SP_TD
        BEGIN
            DECLARE @MaDDH VARCHAR(50)
            SET @MaDDH = CONCAT('DDH', FORMAT(GETDATE(), 'yyyyMMddHHmmss'))
            
            INSERT INTO DonDatHang(MaDDH, MaSP, NgayDat, SoLuongDat, MaNV, TrangThai)
            VALUES(@MaDDH, @MaSP, GETDATE(), (@SL_SP_TD - @SoLuongKho) * 2, NULL, 'Pending')

            PRINT N'ReOrderStock - Đã tạo đơn đặt hàng'
        END
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
   SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
   BEGIN TRY
       BEGIN TRANSACTION
           DECLARE @SoLuongKho INT, @GiaNiemYet INT
           SELECT @SoLuongKho = SoLuongKho, @GiaNiemYet = GiaNiemYet
           FROM SanPham WITH (UPDLOCK)
           WHERE MaSP = @MaSP

           IF @SoLuongKho >= @SoLuong
           BEGIN
               PRINT N'Số lượng tồn kho trước khi cập nhật: ' + CAST(@SoLuongKho AS NVARCHAR(20))
               
               UPDATE SanPham
               SET SoLuongKho = SoLuongKho - @SoLuong
               WHERE MaSP = @MaSP
               PRINT N'Đã cập nhật số lượng tồn kho'
           
               INSERT INTO ChiTietDonHang(MaDH, MaSP, SoLuong, DonGia)
               VALUES(@MaDH, @MaSP, @SoLuong, @GiaNiemYet)

               UPDATE DonHang 
               SET TongTien = TongTien + (@GiaNiemYet * @SoLuong)
               WHERE MaDH = @MaDH

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
UPDATE DonHang SET TongTien = 0 WHERE MaDH = 1
DELETE FROM DonDatHang
DELETE FROM ChiTietDonHang

-- Chạy trong cửa sổ Query 1:
EXEC Sp_ReOrderStock 'SP001'

-- Chạy trong cửa sổ Query 2 (ngay sau khi Query 1 bắt đầu):
EXEC Sp_ProcessingOrder 1, 'SP001', 60, 1, 1

-- Xem kết quả
-- Kết quả cho thấy dù số lượng tồn kho không đủ (40 < 60) nhưng vẫn không tạo đơn đặt hàng
SELECT * FROM SanPham WHERE MaSP = 'SP001'
SELECT * FROM DonDatHang
SELECT * FROM ChiTietDonHang
SELECT * FROM DonHang