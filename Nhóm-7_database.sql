use master;

create database ConvenientStore;
Go

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
ALTER TABLE SanPham ADD  MoTa NVARCHAR(255)


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
    LoaiKM INT,
    TenKM NVARCHAR(50),
    NgayBatDau DATE,
    NgayKetThuc DATE,
    SoLuong INT,
    TiLeGiam INT,
);

CREATE TABLE MemberSale (
    MaKH INT,
    MucThanThiet VARCHAR(50),
	MaKM INT,
    PRIMARY KEY (MaKH, MaKM), 
	Foreign key (MaKM) REFERENCES KhuyenMai(MaKM)
);

CREATE TABLE FlashSale (
	MaKM INT, 
    MaSP VARCHAR(50),
    PRIMARY KEY (MaKM, MaSP),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP),
	Foreign key (MaKM) REFERENCES KhuyenMai(MaKM)
);

CREATE TABLE ComboSale (
	MaKM INT,
    MaSP VARCHAR(50),
    PRIMARY KEY (MaKM, MaSP),
    Foreign key (MaSP) REFERENCES SanPham(MaSP),
	Foreign key (MaKM) REFERENCES KhuyenMai(MaKM)
);
