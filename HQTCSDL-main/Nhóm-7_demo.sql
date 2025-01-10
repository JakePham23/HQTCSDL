USE ConvenientStore;
GO

-- Thiết lập để theo dõi deadlock
DBCC TRACEON (1222, -1);
GO

-- Reset data
UPDATE SanPham SET SoLuongKho = 100 WHERE MaSP = 'SP001'
DELETE FROM DonDatHang
DELETE FROM ChiTietDonHang

-- Test xung đột

-- Chạy trong cửa sổ Query 1:
BEGIN TRANSACTION;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    DECLARE @SoLuongKho INT;
    SELECT @SoLuongKho = SoLuongKho 
    FROM SanPham 
    WHERE MaSP = 'SP001';
    
    -- Giả lập thời gian xử lý
    WAITFOR DELAY '00:00:05';
    
    -- Kiểm tra và không tạo đơn đặt hàng vì nghĩ còn đủ hàng
    IF @SoLuongKho >= 50
    BEGIN
        PRINT N'Không cần đặt hàng vì còn đủ trong kho';
    END
COMMIT TRANSACTION;
GO

-- Chạy trong cửa sổ Query 2 (ngay sau khi Query 1 bắt đầu):
BEGIN TRANSACTION;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    UPDATE SanPham
    SET SoLuongKho = SoLuongKho - 60
    WHERE MaSP = 'SP001';
    
    PRINT N'Đã cập nhật giảm số lượng kho';
COMMIT TRANSACTION;
GO

-- Xem kết quả
-- Kết quả cho thấy dù số lượng tồn kho không đủ (40 < 60) nhưng vẫn không tạo đơn đặt hàng
SELECT * FROM SanPham WHERE MaSP = 'SP001'
SELECT * FROM DonDatHang
SELECT * FROM ChiTietDonHang