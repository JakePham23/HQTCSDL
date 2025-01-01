
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

INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (1, 'Nguyen Van A', 'F', '01234556789', '01/01/2001', 'PT');
INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (2, 'Nguyen Van B', 'F', '02234556789', '01/01/2002', 'PT');
INSERT INTO NhanVien(MaNV, HoTen, GioiTinh, SDT, NgaySinh, LoaiNV)  Values (3, 'Nguyen Van C', 'F', '02224556789', '01/01/2003', 'PT');

INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501011, 'Nguyen Van A',  '0123456789', '09/01/2001', N'Thân Thiết', '01/01/2025', 0, 1);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501012, 'Nguyen Van B',  '0223456789', '12/01/2005', N'Thân Thiết', '01/01/2025', 0, 1);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2501013, 'Nguyen Van C',  '0222456789', '11/01/1999', N'Thân Thiết', '01/01/2025', 0, 1);
INSERT INTO KhachHang(MaKH, HoTen, SDT, NgaySinh, LoaiKH, NgayDangKy, TongTienNamTruoc, MaNV) values(2401011, 'Nguyen Van C',  '0222456782', '01/01/1999', N'Đồng', '01/01/2023', 5000, 1);

INSERT INTO PhieuMuaHang(MaPhieu, MaKH, QuaTang, NgayBatDau, NgayHetHan, TrangThai) values('250101HFJK0103',2401011, '100000', '01/01/2025', '01/14/2025', N'Chưa sử dụng');