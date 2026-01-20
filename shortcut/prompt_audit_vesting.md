# 🚨 PROMPT CLAUDE — WAJIB RISET EKSTERNAL PAXI NETWORK
# (ANTI AUDIT BERDASARKAN KODE SAJA)
# FOKUS: PRC20 TOKEN VESTING CONTRACT

## MODE KERJA WAJIB (ABSOLUT)
Kamu DILARANG melakukan audit hanya dengan membaca kode yang diberikan.
Kamu WAJIB melakukan RISET TERHADAP DOKUMENTASI RESMI PAXI NETWORK.

Jika kamu TIDAK dapat menunjukkan bukti bahwa kamu merujuk ke dokumentasi Paxi,
MAKA AUDIT TIDAK BOLEH DILAKUKAN.

===============================================================

## 🧠 FASE 1 — RISET EKSTERNAL (EVIDENCE GATE)

### TUGAS WAJIB
Cari dan pelajari dokumentasi RESMI Paxi Network dari sumber berikut:
- Repository GitHub resmi Paxi Network
- Dokumentasi PRC20
- Dokumentasi mekanisme vesting / time-lock token (jika ada)
- Standar event, attribute, submessage, dan reply di Paxi Network

⚠️ Jika informasi hanya berasal dari kode user → TIDAK SAH.

### OUTPUT FASE 1 (WAJIB ADA BUKTI)

[FASE 1 — BUKTI RISET PAXI NETWORK]

Sumber Resmi yang Dirujuk:
- Dokumen PRC20:
  - Repo / path / nama file:
- Dokumen Vesting / Time Lock:
  - Repo / path / nama file:
- Event & Attribute Standard:
  - Repo / path / nama file:
- Submessage & Reply:
  - Repo / path / nama file:

Fakta Teknis yang DITEMUKAN:
- Aturan PRC20 resmi Paxi:
  - (kutipan atau ringkasan faktual)
- Mekanisme vesting token menurut Paxi:
  - (ringkasan faktual)
- Cara resmi perhitungan amount vested & claimable:
  - (ringkasan faktual)
- Batasan eksplisit Paxi (time, block, admin, hook):
  - (ringkasan faktual)

Status Validasi:
[ ] Tidak ada bukti riset → STOP (audit DILARANG)
[ ] Bukti riset VALID → BOLEH LANJUT

===============================================================

## 🔒 FASE 2 — AUDIT KONTRAK (DILARANG JIKA FASE 1 GAGAL)

SYARAT MUTLAK:
Status Validasi: [✔] Bukti riset VALID → BOLEH LANJUT

Jika tidak terpenuhi, jawab:
"AUDIT DITOLAK karena tidak ada bukti riset dokumentasi Paxi Network."

===============================================================

## 🧪 FASE 2 — AUDIT PRC20 TOKEN VESTING

### RUANG LINGKUP WAJIB
- Kepatuhan PRC20
- Vesting schedule (cliff, linear, step, custom)
- Start time, end time, duration, unlock logic
- Perhitungan vested vs claimable (anti manipulasi)
- Claim token (partial & full)
- Extend / revoke vesting (jika didukung Paxi)
- Admin privilege & beneficiary protection
- Event & attribute parsing sesuai standar Paxi
- Submessage & reply (anti race condition)
- Edge-case (time overflow, zero duration, double claim)
- Code safety (panic, unwrap, overflow, underflow)

===============================================================

## FORMAT OUTPUT AUDIT (WAJIB)

### A. UPDATED LIST (CHANGE LOG)
[vX.X.X] YYYY-MM-DD
- Fix: ...
- Add: ...
- Update: ...

### B. DETAIL PER ITEM
1. Masalah teknis (berdasarkan dokumen Paxi)
2. Rekomendasi perbaikan (berdasarkan dokumen Paxi)
3. Kode patch (hanya bagian yang diubah)

### C. KONFIRMASI AKHIR
- Sesuai standar Paxi Network? YA / TIDAK
- Layak production (MVP)? YA / TIDAK
- Alasan teknis

===============================================================

## 🚫 LARANGAN ABSOLUT
- ❌ Audit berbasis kode saja
- ❌ Asumsi
- ❌ Standar ERC20 / CosmWasm generik
- ❌ “Best practice umum blockchain”

Jika informasi tidak ditemukan di dokumentasi Paxi, jawab:
"Tidak ditemukan dalam dokumentasi resmi Paxi Network."

===============================================================

## CATATAN FINAL
Jika kamu melakukan audit tanpa menyebutkan sumber resmi Paxi Network,
JAWABANMU DIANGGAP TIDAK VALID.