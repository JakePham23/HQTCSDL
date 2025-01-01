

INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (1, 'Nguyen Van A', 'F', '01234556789', '01/01/2001', 'PT');
INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (2, 'Nguyen Van B', 'F', '02234556789', '01/01/2002', 'PT');
INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (3, 'Nguyen Van C', 'F', '02224556789', '01/01/2003', 'PT');

INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501011, 'Nguyen Van A',  '0123456789', '09/01/2001', N'Thân Thiết', '01/01/2025', 0, 1);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501012, 'Nguyen Van B',  '0223456789', '12/01/2005', N'Thân Thiết', '01/01/2025', 0, 1);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501013, 'Nguyen Van C',  '0222456789', '11/01/1999', N'Thân Thiết', '01/01/2025', 0, 1);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2401011, 'Nguyen Van C',  '0222456782', '01/01/1999', N'Đồng', '01/01/2023', 5000, 1);

INSERT INTO PhieuMuaHang(MaPhieu, MaKH, QuaTang, NgayBatDau, NgayHetHan, TrangThai) values('250101HFJK0103',2401011, '100000', '01/01/2025', '01/14/2025', N'Chưa sử dụng');

