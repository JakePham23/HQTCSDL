USE ConvenientStore
GO

INSERT INTO NhanVien VALUES 
(1, N'Nguyễn Văn A', 'M', '0123456789', '1990-01-01', 'FULL-TIME');

INSERT INTO KhachHang VALUES
(1, N'Khách hàng A', '0987654321', '1995-01-01', N'Vàng', '2025-01-01', 1000000, 1),
(2, N'Lê Thị C', '0987654322', '1992-08-20', N'Bạc', '2023-02-01', 3000000, 1),
(3, N'Phạm Văn D', '0987654323', '1988-12-10', NULL, '2025-01-01', 100000, 1);

INSERT INTO LoaiSanPham VALUES 
('LSP01', N'Đồ uống'),
('LSP02', N'Bánh kẹo'),
('LSP03', N'Mỹ phẩm');

INSERT INTO SanPham VALUES
('SP001', N'Coca Cola', 10000, 100, 50, 'LSP01', N'Mô tả'),
('SP002', N'Snack khoai tây', 12000, 100, 50, 'LSP02', N'Mô tả'),
('SP003', N'Sữa tắm', 55000, 45, 100, 'LSP03', N'Mô tả');

INSERT INTO DonHang VALUES
(1, 1, 1, '2025-01-10', 0);

-- 1. Flash Sale
INSERT INTO KhuyenMai (MaKM, LoaiKM, TenKM, NgayBatDau, NgayKetThuc, SoLuong, TiLeGiam) VALUES
(1, 1, N'Flash Sale Coca', '2025-01-01', '2025-12-31', 100, 50),
(2, 1, N'Flash Sale Snack', '2025-01-01', '2025-12-31', 100, 30);

INSERT INTO FlashSale (MaKM, MaSP) VALUES
(1, 'SP001'), 
(2, 'SP002');  

-- 2. Combo Sale
INSERT INTO KhuyenMai (MaKM, LoaiKM, TenKM, NgayBatDau, NgayKetThuc, SoLuong, TiLeGiam) VALUES
(3, 2, N'Combo Coca', '2025-01-01', '2025-12-31', 100, 40),
(4, 2, N'Combo Mì', '2025-01-01', '2025-12-31', 100, 35);

INSERT INTO ComboSale (MaKM, MaSP) VALUES
(3, 'SP001'),
(3, 'SP002'),
(4, 'SP002'),
(4, 'SP003');  

-- 3. Member Sale
INSERT INTO KhuyenMai (MaKM, LoaiKM, TenKM, NgayBatDau, NgayKetThuc, SoLuong, TiLeGiam) VALUES
(5, 3, N'Member Sale Coca - Vàng', '2025-01-01', '2025-12-31', 100, 60),
(6, 3, N'Member Sale Coca - Bạc', '2025-01-01', '2025-12-31', 100, 35);

INSERT INTO MemberSale (MaKH, MucThanThiet, MaKM) VALUES
(1, N'Vàng', 5), 
(2, N'Bạc', 6); 