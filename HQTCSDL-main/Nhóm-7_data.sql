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
(1, 1, 1, '2025-01-10', 600000);

-- 1. Flash Sale
INSERT INTO KhuyenMai (MaKM, MaSP, LoaiKM, TenKM, NgayBatDau, NgayKetThuc) VALUES
(1, 'SP001', 1, N'Flash Sale Coca', '2025-01-01', '2025-12-31'),
(2, 'SP002', 1, N'Flash Sale Snack', '2025-01-01', '2025-12-31');

INSERT INTO FlashSale (MaKM, LoaiKM, TiLeGiam, SoLuong) VALUES
(1, 1, 30, 5),  -- Giảm 30% cho Coca khi mua từ 5 sp
(2, 1, 25, 3);  -- Giảm 25% cho Snack khi mua từ 3 sp

-- 2. Combo Sale
INSERT INTO KhuyenMai (MaKM, MaSP, LoaiKM, TenKM, NgayBatDau, NgayKetThuc) VALUES
(3, 'SP001', 2, N'Combo Coca', '2025-01-01', '2025-12-31'),
(4, 'SP003', 2, N'Combo Mì', '2025-01-01', '2025-12-31');

INSERT INTO ComboSale (MaKM, LoaiKM, TiLeGiam, SoLuong) VALUES
(3, 2, 40, 10),  -- Giảm 40% khi mua 10 Coca
(4, 2, 35, 24);  -- Giảm 35% khi mua 24 mì

-- 3. Member Sale
INSERT INTO KhuyenMai (MaKM, MaSP, LoaiKM, TenKM, NgayBatDau, NgayKetThuc) VALUES
(5, 'SP001', 3, N'Member Sale Coca - Vàng', '2025-01-01', '2025-12-31'),
(6, 'SP001', 3, N'Member Sale Coca - Bạc', '2025-01-01', '2025-12-31');

INSERT INTO MemberSale (MaKM, MucThanThiet, TiLeGiam, SoLuong) VALUES
(5, N'Vàng', 50, 1),  -- Giảm 50% cho khách hàng Vàng
(6, N'Bạc', 35, 1);   -- Giảm 35% cho khách hàng Bạc