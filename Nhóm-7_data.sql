
USE ConvenientStore;

INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (1, 'Nguyen Van A', 'F', '01234556789', '01/01/2001', 'PT');
INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (2, 'Nguyen Van B', 'F', '02234556789', '01/01/2002', 'PT');
INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (3, 'Nguyen Van C', 'F', '02224556789', '01/01/2003', 'PT');
INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (4, N'Nguyễn Văn Bốn', 'F', '01224556789', '01/01/2003', 'PT');
INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (5, N'Nguyễn Văn Năm', 'M', '0334556789', '11/01/2000', 'OSM');
INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (6, N'Nguyễn Văn Sáu', 'M', '03224556789', '09/23/2004', 'PT');
INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (7, N'Nguyễn Văn Bảy', 'M', '04224556789', '09/13/2002', 'FT');
INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (8, N'Nguyễn Văn Tám', 'O', '05224556789', '05/25/2005', 'OFC');
INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (9, N'Nguyễn Văn Chín', 'F', '06224556789', '12/31/2003', 'OSM');
INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (10, N'Nguyễn Văn Mười', 'F', '07224556789', '01/01/2000', 'FT');

INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501011, 'Nguyen Van A',  '0123456789', '09/01/2001', N'Thân Thiết', '01/01/2025', 0, 1);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501012, 'Nguyen Van B',  '0223456789', '12/01/2005', N'Thân Thiết', '01/01/2025', 0, 1);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501013, 'Nguyen Van C',  '0222456789', '11/01/1999', N'Thân Thiết', '01/01/2025', 0, 1);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2401011, 'Nguyen Van C',  '0222456782', '01/01/1999', N'Đồng', '01/01/2023', 5000, 1);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501121, 'Nguyen Van C',  '0422456782', '01/01/1980', N'Đồng', '01/12/2025', 0, 3);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501123, 'Nguyen Van C',  '0822456782', '01/28/1981', N'Đồng', '01/12/2025', 0, 2);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501124, 'Nguyen Van C',  '0322456782', '01/31/1997', N'Đồng', '01/12/2025', 0, 5);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501125, 'Nguyen Van C',  '0252456782', '10/31/2004', N'Đồng', '01/12/2025', 0, 6);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501126, 'Nguyen Van C',  '0292456782', '05/25/2005', N'Đồng', '01/12/2025', 50000, 4);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501127, 'Nguyen Van C',  '0202456782', '09/13/2001', N'Đồng', '01/12/2025', 30000, 9);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501128, 'Nguyen Van C',  '0232456782', '09/23/2002', N'Đồng', '01/12/2025', 15000, 8);

INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2301121, 'Nguyen Van C',  '0032456782', '09/23/2002', N'Đồng', '01/12/2023', 15000, 8);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2301122, 'Nguyen Van C',  '0902456782', '09/23/2003', N'Đồng', '01/12/2023', 15000, 10);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2301123, 'Nguyen Van C',  '0762456782', '09/23/2004', N'Đồng', '01/12/2023', 30000, 2);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2301124, 'Nguyen Van C',  '0842456782', '09/23/1999', N'Đồng', '01/12/2023', 50000, 9);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(22120223, 'Thai Dinh Ngan',  '0232446782', '01/11/2002', N'Đồng', '01/12/2025', 15000, 8);

INSERT INTO PhieuMuaHang(MaPhieu, MaKH, QuaTang, NgayBatDau, NgayHetHan, TrangThai) values('2309HFJK2301121',2301121, '200000', '01/12/2023', '01/26/2023', N'Đã sử dụng');
INSERT INTO PhieuMuaHang(MaPhieu, MaKH, QuaTang, NgayBatDau, NgayHetHan, TrangThai) values('2309HFJK2301122',2301122, '200000', '01/12/2023', '01/26/2023', N'Chưa sử dụng');
INSERT INTO PhieuMuaHang(MaPhieu, MaKH, QuaTang, NgayBatDau, NgayHetHan, TrangThai) values('2309HFJK2301123',2301123, '500000', '01/12/2023', '01/26/2023', N'Đã sử dụng');
INSERT INTO PhieuMuaHang(MaPhieu, MaKH, QuaTang, NgayBatDau, NgayHetHan, TrangThai) values('2309HFJK2301124',2301124, '1200000', '01/12/2023', '01/26/2023', N'Đã sử dụng');
INSERT INTO PhieuMuaHang(MaPhieu, MaKH, QuaTang, NgayBatDau, NgayHetHan, TrangThai) values('250101HFJK0103',2401011, '100000', '01/01/2025', '01/14/2025', N'Chưa sử dụng');


INSERT INTO LoaiSanPham (MaLoai, TenLoai) VALUES 
('L01', N'Fresh Food'),
('L02', N'Snack'),
('L03', N'Mỹ phẩm'),
('L04', N'Sữa'),
('L05', N'Sữa chua'),
('L06', N'Thực phẩm sống'),
('L07', N'Thực phẩm chín'),
('L08', N'Nước'),
('L09', N'Bia'),
('L10', N'Rượu'),
('L11', N'Nước ngọt');

-- fresh food 
INSERT INTO SanPham (MaSP, TenSP, GiaNiemYet, SoLuongKho, SL_SP_TD, MaLoai, MoTa) VALUES 
('SP01', N'Cơm nắm lá rong biển', 15000, 100, 20, 'L01', N'Fresh Food - Cơm nắm hương vị truyền thống'),
('SP02', N'Tokbokki phô mai', 35000, 80, 15, 'L01', N'Bánh gạo cay, kết hợp phô mai thơm béo'),
('SP03', N'Xúc xích chiên', 20000, 120, 25, 'L01', N'Xúc xích thơm ngon, chiên giòn rụm'),
('SP04', N'Bánh bao hấp nhân thịt', 25000, 90, 18, 'L01', N'Bánh bao tươi, nhân thịt đậm đà'),
('SP05', N'Chả cá viên chiên', 30000, 75, 15, 'L01', N'Chả cá thơm ngon, dễ chế biến'),
('SP06', N'Bánh mì que', 10000, 200, 40, 'L01', N'Bánh mì que giòn tan, tiện lợi'),
('SP07', N'Cơm nắm cá ngừ', 17000, 95, 22, 'L01', N'Hương vị cá ngừ tự nhiên'),
('SP08', N'Tokbokki cay truyền thống', 32000, 85, 19, 'L01', N'Bánh gạo cay, hương vị Hàn Quốc'),
('SP09', N'Salad cuộn', 22000, 50, 10, 'L01', N'Salad tươi mát, cuộn tiện lợi'),
('SP10', N'Truyền thống bánh bao xá xíu', 27000, 60, 12, 'L01', N'Bánh bao nhân xá xíu thơm ngon');


-- snack
INSERT INTO SanPham (MaSP, TenSP, GiaNiemYet, SoLuongKho, SL_SP_TD, MaLoai, MoTa) VALUES 
('SP11', N'Khoai tây chiên Lay s', 25000, 200, 50, 'L02', N'Snack khoai tây vị BBQ thơm ngon'),
('SP12', N'Bánh quy Oreo', 15000, 150, 30, 'L02', N'Bánh quy sô-cô-la nhân kem sữa'),
('SP13', N'Kẹo dẻo Haribo', 30000, 120, 20, 'L02', N'Kẹo dẻo trái cây thơm ngon'),
('SP14', N'Bắp rang bơ', 20000, 100, 25, 'L02', N'Món ăn vặt phổ biến, thơm mùi bơ');

-- Mĩ phẩm

INSERT INTO SanPham (MaSP, TenSP, GiaNiemYet, SoLuongKho, SL_SP_TD, MaLoai, MoTa) VALUES 
('SP15', N'Sữa rửa mặt Cetaphil', 300000, 50, 10, 'L03', N'Sữa rửa mặt dịu nhẹ cho da nhạy cảm'),
('SP16', N'Son môi L’Oreal', 200000, 80, 15, 'L03', N'Son môi bền màu, dưỡng ẩm tốt');

-- SỮA
INSERT INTO SanPham (MaSP, TenSP, GiaNiemYet, SoLuongKho, SL_SP_TD, MaLoai, MoTa) VALUES 
('SP17', N'Sữa tươi Dalatmilk', 25000, 100, 10, 'L01', N'Hương vị tự nhiên từ cao nguyên'),
('SP18', N'Sữa tươi tiệt trùng Vinamilk', 23000, 150, 20, 'L01', N'Chất lượng cao từ Vinamilk'),
('SP19', N'Sữa chua dâu Vinamilk', 15000, 200, 30, 'L02', N'Hương vị dâu thơm ngon'),
('SP20', N'Sữa chua nha đam Dalatmilk', 17000, 120, 15, 'L02', N'Kết hợp nha đam tươi mát'),
('SP21', N'Sữa đặc có đường Ông Thọ', 20000, 300, 40, 'L03', N'Sữa đặc có đường truyền thống'),
('SP22', N'Sữa đặc không đường Nestlé', 22000, 250, 35, 'L03', N'Dành cho người kiêng đường'),
('SP23', N'Sữa hạt óc chó Vinamilk', 28000, 90, 12, 'L04', N'Hạt óc chó bổ dưỡng'),
('SP24', N'Sữa hạt hạnh nhân TH True Milk', 30000, 80, 10, 'L04', N'Hạnh nhân thơm ngon'),
('SP25', N'Phô mai con bò cười', 45000, 50, 5, 'L05', N'Hương vị quốc tế'),
('SP26', N'Phô mai Mozzarella', 50000, 40, 6, 'L05', N'Phô mai dùng cho pizza'),
('SP27', N'Sữa bột Dielac Alpha', 400000, 60, 8, 'L06', N'Cho trẻ từ 0-6 tháng tuổi'),
('SP28', N'Sữa bột Enfa A+', 450000, 70, 9, 'L06', N'Tăng cường phát triển trí não'),
('SP29', N'Sữa nguyên kem Vinamilk', 30000, 110, 15, 'L07', N'Hương vị đậm đà'),
('SP30', N'Sữa nguyên kem TH True Milk', 32000, 120, 16, 'L07', N'Đạt chuẩn quốc tế'),
('SP31', N'Sữa tách béo Vinamilk', 28000, 100, 10, 'L08', N'Phù hợp người ăn kiêng'),
('SP32', N'Sữa tách béo TH True Milk', 29000, 95, 9, 'L08', N'Tinh khiết và ít béo'),
('SP33', N'Sữa không đường Dalatmilk', 26000, 110, 11, 'L09', N'Tốt cho sức khỏe'),
('SP34', N'Sữa không đường Vinamilk', 25000, 115, 12, 'L09', N'Tiện lợi và bổ dưỡng'),
('SP35', N'Sữa tăng cân Mass Gainer', 600000, 50, 5, 'L10', N'Hỗ trợ tăng cân nhanh chóng'),
('SP36', N'Sữa tăng cân Serious Mass', 700000, 45, 6, 'L10', N'Chất lượng cao cho người gầy'),
('SP37', N'Sữa tươi nguyên chất LoveMilk', 27000, 80, 15, 'L01', N'Sữa tươi từ thiên nhiên'),
('SP38', N'Sữa chua mít Vinamilk', 16000, 190, 25, 'L02', N'Ngọt dịu và thơm ngon'),
('SP39', N'Sữa đặc Ông Thọ đỏ', 21000, 290, 20, 'L03', N'Phù hợp nấu ăn và pha chế'),
('SP40', N'Sữa hạt đậu nành Dalatmilk', 25000, 140, 18, 'L04', N'Dành cho người ăn chay'),
('SP41', N'Phô mai Cheddar Úc', 48000, 70, 8, 'L05', N'Dùng trong món Âu cao cấp'),
('SP42', N'Sữa bột Pediasure', 430000, 65, 7, 'L06', N'Cho trẻ kén ăn'),
('SP43', N'Sữa nguyên kem Organic', 33000, 105, 14, 'L07', N'Tự nhiên và không hóa chất'),
('SP44', N'Sữa tách béo nhập khẩu', 31000, 90, 11, 'L08', N'Nhập khẩu từ New Zealand'),
('SP45', N'Sữa không đường TH', 24000, 100, 9, 'L09', N'Dành cho người ăn kiêng'),
('SP46', N'Sữa tăng cân Mega Mass', 650000, 55, 6, 'L10', N'Tăng cơ và cân nặng hiệu quả');

-- bia rượu 
INSERT INTO SanPham (MaSP, TenSP, GiaNiemYet, SoLuongKho, SL_SP_TD, MaLoai, MoTa) VALUES 
('SP47', N'Nước khoáng Lavie', 7000, 500, 50, 'L08', N'Nước khoáng thiên nhiên tinh khiết'),
('SP448', N'Bia Heineken', 20000, 300, 40, 'L09', N'Bia Heineken cao cấp'),
('SP49', N'Rượu vang Đà Lạt', 150000, 100, 10, 'L10', N'Rượu vang thơm ngon, truyền thống Việt Nam'),
('SP50', N'Strong bow berry', 40000, 100, 10, 'L10', N'Strog bow vị berry');

INSERT INTO NhaSanXuat (TenNSX) VALUES 
(N'Vinamilk'), 
(N'Dalatmilk'), 
(N'TH True Milk'), 
(N'Nestlé'), 
(N'Ông Thọ'), 
(N'Heineken'), 
(N'Coca-Cola'), 
(N'PepsiCo'), 
(N'Haribo'), 
(N'Heineken');

INSERT INTO KhuyenMai (MaKM, LoaiKM, TenKM, NgayBatDau, NgayKetThuc, SoLuong, TiLeGiam)
VALUES
-- Member Sale (LoaiKM = 1)
(1, 1, N'Kim cương', '2025-01-01', '2025-01-31', 10, 50),
(2, 1, N'Bạch kim', '2025-01-01', '2025-01-31', 20, 40),
(3, 1, N'Vàng', '2025-01-01', '2025-01-31', 30, 30),
(4, 1, N'Bạc', '2025-01-01', '2025-01-31', 40, 20),
(5, 1, N'Đồng', '2025-01-01', '2025-01-31', 50, 10),
(6, 1, N'Thân thiết', '2025-01-01', '2025-01-31', 60, 5),
(7, 1, N'Kim cương', '2025-01-01', '2025-01-31', 10, 50),
(8, 1, N'Bạch kim', '2025-01-01', '2025-01-31', 20, 40),
(9, 1, N'Vàng', '2025-01-01', '2025-01-31', 30, 30),
(10, 1, N'Bạc', '2025-01-01', '2025-01-31', 40, 20),


-- Flash Sale (LoaiKM = 2)
(11, 2, 'Day 1', '2025-02-01', '2025-02-02', 100, 50),
(12, 2, 'Day 2', '2025-02-01', '2025-02-02', 200, 45),
(13, 2, 'Day 3', '2025-02-01', '2025-02-02', 300, 40),
(14, 2, 'Day 4', '2025-02-01', '2025-02-02', 400, 35),
(15, 2, 'Day 5', '2025-02-01', '2025-02-02', 500, 30),
(16, 2, 'Day 6', '2025-02-01', '2025-02-02', 600, 25),
(17, 2, 'Day 7', '2025-02-01', '2025-02-02', 700, 20),
(18, 2, 'Day 8', '2025-02-01', '2025-02-02', 800, 15),
(19, 2, 'Day 9', '2025-02-01', '2025-02-02', 900, 10),
(20, 2, 'Day 10', '2025-02-01', '2025-02-02', 1000, 5),

-- Combo Sale (LoaiKM = 3)
(21, 3, 'Package A', '2025-03-01', '2025-03-15', 2, 20),
(22, 3, 'Package B', '2025-03-01', '2025-03-15', 3, 25),
(23, 3, 'Package C', '2025-03-01', '2025-03-15', 4, 30),
(24, 3, 'Package D', '2025-03-01', '2025-03-15', 5, 35),
(25, 3, 'Package E', '2025-03-01', '2025-03-15', 6, 40),
(26, 3, 'Package F', '2025-03-01', '2025-03-15', 7, 45),
(27, 3, 'Package G', '2025-03-01', '2025-03-15', 8, 50),
(28, 3, 'Package H', '2025-03-01', '2025-03-15', 9, 55),
(29, 3, 'Package I', '2025-03-01', '2025-03-15', 10, 60),
(30, 3, 'Package J', '2025-03-01', '2025-03-15', 11, 65);


INSERT INTO MemberSale (MaKH, MucThanThiet, MaKM)
VALUES
(1, N'Kim cương', 1),
(2, N'Bạch kim', 2),
(3, N'Vàng', 3),
(4, N'Bạc', 4),
(5, N'Đồng', 5),
(6, N'Thân thiết', 6),
(7, N'Kim cương', 7),
(8, N'Bạch kim', 8),
(9, N'Vàng', 9),
(10, N'Bạc', 10);

INSERT INTO FlashSale (MaKM, MaSP)
VALUES
(11, 'SP11'),
(12, 'SP12'),
(13, 'SP13'),
(14, 'SP14'),
(15, 'SP15'),
(16, 'SP16'),
(17, 'SP17'),
(18, 'SP18'),
(19, 'SP19'),
(20, 'SP20');


INSERT INTO ComboSale (MaKM, MaSP)
VALUES
(21, 'SP23'),
(21, 'SP24'),
(22, 'SP25'),
(22, 'SP26'),
(23, 'SP27'),
(23, 'SP28'),
(24, 'SP29'),
(24, 'SP30'),
(25, 'SP31'),
(25, 'SP32'),
(26, 'SP33'),
(26, 'SP34'),
(27, 'SP35'),
(27, 'SP36'),
(28, 'SP37'),
(28, 'SP38'),
(29, 'SP39'),
(29, 'SP40'),
(30, 'SP41'),
(30, 'SP42');
