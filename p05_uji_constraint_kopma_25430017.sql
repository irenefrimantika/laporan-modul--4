-- p05_uji_constraint_kopma_25430017.sql
-- Praktikum Basis Data - Modul 5, langkah D.3: membuktikan constraint bekerja
-- Akun: mhs_017, basis data: kopma_017
-- Prasyarat: p05_ddl_kopma_25430017.sql sudah dijalankan (8 tabel ada).
-- Jalankan dengan opsi -f (force) supaya skrip lanjut walau ada galat yang DISENGAJA:
--   mysql -u mhs_017 -p -f -t kopma_017 < p05_uji_constraint_kopma_25430017.sql

USE kopma_017;

SELECT CURRENT_USER() AS akun_yang_dipakai, DATABASE() AS basis_data;

-- ============================================================
-- PERSIAPAN: kosongkan data uji lama dan reset nomor otomatis
-- (supaya skrip dapat diulang dan id_barang pertama selalu 1)
-- ============================================================
DELETE FROM detail_penjualan;
DELETE FROM penjualan;
DELETE FROM barang;
DELETE FROM petugas;
ALTER TABLE petugas AUTO_INCREMENT = 1;
ALTER TABLE barang AUTO_INCREMENT = 1;
ALTER TABLE penjualan AUTO_INCREMENT = 1;

-- ============================================================
-- LANGKAH 5: isi data induk (2 petugas, 2 barang) - harus BERHASIL
-- ============================================================
INSERT INTO petugas (kode_petugas, nama_petugas, peran_petugas)
VALUES ('K01', 'Rina', 'kasir'), ('G01', 'Budi', 'gudang');

INSERT INTO barang (kode_barang, nama_barang, kategori_barang, harga_jual_barang, stok_barang)
VALUES ('ATK-001', 'Pulpen Hitam', 'ATK', 4000, 50),
       ('MKN-001', 'Roti Cokelat', 'makanan', 5000, 20);

SELECT * FROM petugas;
SELECT * FROM barang;

-- ============================================================
-- UJI NEGATIF 1-3 (sesuai buku, Gambar 5.2): semuanya HARUS DITOLAK
-- ============================================================

SELECT 'UJI 1: petugas 99 tidak ada -> harus ERROR 1452 (kunci tamu)' AS uji;
INSERT INTO penjualan (no_nota_penjualan, tgl_penjualan, id_petugas, id_anggota, bayar_penjualan)
VALUES ('PJ-2609-0199', NOW(), 99, NULL, 5000);

SELECT 'UJI 2: stok -1 -> harus ERROR 4025 (CHECK ck_barang_stok, AB-03)' AS uji;
UPDATE barang SET stok_barang = -1 WHERE id_barang = 1;

SELECT 'UJI 3: kode barang kembar -> harus ERROR 1062 (UNIQUE uq_barang_kode)' AS uji;
INSERT INTO barang (kode_barang, nama_barang, kategori_barang, harga_jual_barang)
VALUES ('ATK-001', 'Duplikat', 'ATK', 1000);

-- Bukti stok tidak berubah setelah UJI 2 ditolak (harus tetap 50)
SELECT id_barang, kode_barang, stok_barang FROM barang WHERE id_barang = 1;

-- ============================================================
-- UJI POSITIF: data yang benar HARUS DITERIMA
-- ============================================================
SELECT 'UJI 4 (positif): nota dan detail yang benar -> harus BERHASIL' AS uji;
INSERT INTO penjualan (no_nota_penjualan, tgl_penjualan, id_petugas, id_anggota, bayar_penjualan)
VALUES ('PJ-2609-0001', NOW(), 1, NULL, 10000);

INSERT INTO detail_penjualan (id_penjualan, id_barang, qty_detail_penjualan, harga_satuan_detail_penjualan)
VALUES (1, 1, 2, 4000);

SELECT * FROM penjualan;
SELECT * FROM detail_penjualan;

-- ============================================================
-- UJI NEGATIF TAMBAHAN (bahan Titik Analisis 1 dan 2)
-- ============================================================

SELECT 'UJI 5: qty 0 -> harus ERROR 4025 (CHECK ck_detail_qty)' AS uji;
INSERT INTO detail_penjualan (id_penjualan, id_barang, qty_detail_penjualan, harga_satuan_detail_penjualan)
VALUES (1, 2, 0, 5000);

SELECT 'UJI 6: nomor nota kembar -> harus ERROR 1062 (UNIQUE uq_penjualan_nota, AB-01)' AS uji;
INSERT INTO penjualan (no_nota_penjualan, tgl_penjualan, id_petugas, id_anggota, bayar_penjualan)
VALUES ('PJ-2609-0001', NOW(), 1, NULL, 3000);

SELECT 'UJI 7: hapus petugas yang sudah punya nota -> harus ERROR 1451' AS uji;
DELETE FROM petugas WHERE id_petugas = 1;

SELECT 'UJI 8: hapus barang yang sudah ada di detail nota -> harus ERROR 1451 (tanpa CASCADE)' AS uji;
DELETE FROM barang WHERE id_barang = 1;

-- ============================================================
-- UJI CASCADE: hapus nota, detailnya ikut terhapus (fk_detail_penjualan)
-- ============================================================
SELECT 'UJI 9: hapus nota -> detail ikut terhapus (jumlah detail harus 0)' AS uji;
DELETE FROM penjualan WHERE id_penjualan = 1;
SELECT COUNT(*) AS jumlah_detail_tersisa FROM detail_penjualan;

SELECT 'SELESAI. Cocokkan setiap ERROR di atas dengan hasil yang diharapkan.' AS status_akhir;
