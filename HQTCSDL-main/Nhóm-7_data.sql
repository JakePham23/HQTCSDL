USE ConvenientStore
GO

INSERT INTO NhanVien VALUES 
(1, N'Nguyễn Văn A', 'M', '0123456789', '1990-01-01', 'FULL-TIME');

INSERT INTO KhachHang VALUES
(2501011, N'Khách hàng A', '0987654321', '1995-01-01', N'Thân thiết', '2025-01-01', 1000000, 1);

INSERT INTO LoaiSanPham VALUES 
('LSP01', N'Đồ uống'),
('LSP02', N'Bánh kẹo'),
('LSP03', N'Mỹ phẩm');

INSERT INTO SanPham VALUES
('SP001', N'Coca Cola', 10000, 100, 50, 'LSP01', N'Mô tả'),
('SP002', N'Snack khoai tây', 12000, 100, 50, 'LSP02', N'Mô tả'),
('SP003', N'Sữa tắm', 55000, 45, 100, 'LSP03', N'Mô tả');

INSERT INTO DonHang VALUES
(1, 2501011, 1, '2025-01-10', 600000);