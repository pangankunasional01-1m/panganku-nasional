-- Tambahkan tabel biaya (costs/keuangan)
CREATE TABLE IF NOT EXISTS biaya (
  id INT AUTO_INCREMENT PRIMARY KEY, user_id INT NOT NULL, category ENUM('bibit','pupuk','pestisida','upah','listrik_air','lainnya') NOT NULL, nominal DECIMAL(12,2) NOT NULL, tanggal DATE NOT NULL, catatan TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
