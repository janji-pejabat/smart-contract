# 🚨 PROMPT CLAUDE — WAJIB RISET EKSTERNAL PAXI NETWORK
# (ANTI AUDIT BERDASARKAN KODE SAJA)

## MODE KERJA WAJIB (ABSOLUT)
Kamu DILARANG melakukan audit hanya dengan membaca kode yang diberikan.
Kamu WAJIB melakukan RISSET TERHADAP DOKUMENTASI RESMI PAXI NETWORK.

Jika kamu TIDAK dapat menunjukkan bukti bahwa kamu merujuk ke dokumentasi Paxi,
MAKA AUDIT TIDAK BOLEH DILAKUKAN.

===============================================================

## 🧠 FASE 1 — RISSET EKSTERNAL (EVIDENCE GATE)

### TUGAS WAJIB
Cari dan pelajari dokumentasi RESMI Paxi Network dari sumber berikut:
- Repository GitHub resmi Paxi Network
- Dokumentasi PRC20
- Dokumentasi Paxi Swap Module

⚠️ Jika informasi hanya berasal dari kode user → TIDAK SAH.

### OUTPUT FASE 1 (WAJIB ADA BUKTI)

[FASE 1 — BUKTI RISSET PAXI NETWORK]

Sumber Resmi yang Dirujuk:
- Dokumen PRC20:
  - Repo / path / nama file:
- Dokumen Swap Module:
  - Repo / path / nama file:
- Event & Attribute Standard:
  - Repo / path / nama file:
- Submessage & Reply:
  - Repo / path / nama file:

Fakta Teknis yang DITEMUKAN:
- Aturan PRC20 resmi Paxi:
  - (kutipan atau ringkasan faktual)
- Mekanisme LP & Swap menurut Paxi:
  - (ringkasan faktual)
- Cara resmi parsing LP amount:
  - (ringkasan faktual)
- Batasan eksplisit Paxi:
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

## 🧪 FASE 2 — AUDIT LP LOCK PRC20

### RUANG LINGKUP WAJIB
- Kepatuhan PRC20
- Flow Add Liquidity (allowance, transfer, LP mint)
- Event parsing LP amount (aman & sesuai standar Paxi)
- Submessage & reply (anti race condition)
- Slippage protection
- Lock / Unlock / Extend
- Admin privilege
- Query & edge-case
- Code safety (panic, overflow, unwrap)

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
3. Kode patch (hanya bagian diubah)

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


Curl

curl -X 'POST' \
  'https://mainnet-lcd.paxinet.io/tx/swap/provide_liquidity' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "creator": "string",
  "prc20": "string",
  "paxiAmount": "string",
  "prc20Amount": "string"
}'
Request URL
https://mainnet-lcd.paxinet.io/tx/swap/provide_liquidity
Server response

curl -X 'POST' \
  'https://mainnet-lcd.paxinet.io/tx/swap/withdraw_liquidity' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "creator": "string",
  "prc20": "string",
  "lpAmount": "string"
}'
Request URL
https://mainnet-lcd.paxinet.io/tx/swap/withdraw_liquidity


curl -X 'POST' \
  'https://mainnet-lcd.paxinet.io/tx/swap/swap' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "creator": "string",
  "prc20": "string",
  "offerDenom": "string",
  "offerAmount": "string",
  "minReceive": "string"
}'
Request URL
https://mainnet-lcd.paxinet.io/tx/swap/swap


Curl

curl -X 'GET' \
  'https://mainnet-lcd.paxinet.io/paxi/swap/params' \
  -H 'accept: application/json'
Request URL
https://mainnet-lcd.paxinet.io/paxi/swap/params
Server response
Code	Details
200	
Response body
Download
{
  "code_id": "1",
  "swap_fee_bps": "40",
  "min_liquidity": "1000000"
}

{
  "tx": {
    "body": {
      "messages": [
        {
          "@type": "/x.swap.types.MsgWithdrawLiquidity",
          "creator": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
          "prc20": "paxi1ee6eaha77veuwpzgpe875yrmz2k45zyquqn9sztjv2w5h9gke02q65crh6",
          "lp_amount": "5248746"
        }
      ],
      "memo": "",
      "timeout_height": "0",
      "unordered": false,
      "timeout_timestamp": null,
      "extension_options": [],
      "non_critical_extension_options": []
    },
    "auth_info": {
      "signer_infos": [
        {
          "public_key": {
            "@type": "/cosmos.crypto.secp256k1.PubKey",
            "key": "Aq0rtKBkp3W/m8DONj6BLLp0XX34vVG8JAU3KjIXnJ7+"
          },
          "mode_info": {
            "single": {
              "mode": "SIGN_MODE_DIRECT"
            }
          },
          "sequence": "33"
        }
      ],
      "fee": {
        "amount": [
          {
            "denom": "upaxi",
            "amount": "35000"
          }
        ],
        "gas_limit": "700000",
        "payer": "",
        "granter": ""
      },
      "tip": null
    },
    "signatures": [
      "frER9vPoxRcds8VZ1sqo3E9R3UspgIaiQxsrXFL6/QpNknwk4XyLfXdLBquypE/2iE8zyvNRjY5mf8mVUQmhQA=="
    ]
  },
  "tx_response": {
    "height": "3257962",
    "txhash": "1BFFC02B2F403A5E982FD85256EB9EF54298C232B3A620DEE4A85180E246AEBA",
    "codespace": "",
    "code": 0,
    "data": "122C0A2A2F782E737761702E74797065732E4D736757697468647261774C6971756964697479526573706F6E7365",
    "raw_log": "",
    "logs": [],
    "info": "",
    "gas_wanted": "700000",
    "gas_used": "287453",
    "tx": {
      "@type": "/cosmos.tx.v1beta1.Tx",
      "body": {
        "messages": [
          {
            "@type": "/x.swap.types.MsgWithdrawLiquidity",
            "creator": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "prc20": "paxi1ee6eaha77veuwpzgpe875yrmz2k45zyquqn9sztjv2w5h9gke02q65crh6",
            "lp_amount": "5248746"
          }
        ],
        "memo": "",
        "timeout_height": "0",
        "unordered": false,
        "timeout_timestamp": null,
        "extension_options": [],
        "non_critical_extension_options": []
      },
      "auth_info": {
        "signer_infos": [
          {
            "public_key": {
              "@type": "/cosmos.crypto.secp256k1.PubKey",
              "key": "Aq0rtKBkp3W/m8DONj6BLLp0XX34vVG8JAU3KjIXnJ7+"
            },
            "mode_info": {
              "single": {
                "mode": "SIGN_MODE_DIRECT"
              }
            },
            "sequence": "33"
          }
        ],
        "fee": {
          "amount": [
            {
              "denom": "upaxi",
              "amount": "35000"
            }
          ],
          "gas_limit": "700000",
          "payer": "",
          "granter": ""
        },
        "tip": null
      },
      "signatures": [
        "frER9vPoxRcds8VZ1sqo3E9R3UspgIaiQxsrXFL6/QpNknwk4XyLfXdLBquypE/2iE8zyvNRjY5mf8mVUQmhQA=="
      ]
    },
    "timestamp": "2026-01-19T01:00:27Z",
    "events": [
      {
        "type": "coin_spent",
        "attributes": [
          {
            "key": "spender",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "amount",
            "value": "35000upaxi",
            "index": true
          }
        ]
      },
      {
        "type": "coin_received",
        "attributes": [
          {
            "key": "receiver",
            "value": "paxi17xpfvakm2amg962yls6f84z3kell8c5ln9803d",
            "index": true
          },
          {
            "key": "amount",
            "value": "35000upaxi",
            "index": true
          }
        ]
      },
      {
        "type": "transfer",
        "attributes": [
          {
            "key": "recipient",
            "value": "paxi17xpfvakm2amg962yls6f84z3kell8c5ln9803d",
            "index": true
          },
          {
            "key": "sender",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "amount",
            "value": "35000upaxi",
            "index": true
          }
        ]
      },
      {
        "type": "message",
        "attributes": [
          {
            "key": "sender",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          }
        ]
      },
      {
        "type": "tx",
        "attributes": [
          {
            "key": "fee",
            "value": "35000upaxi",
            "index": true
          },
          {
            "key": "fee_payer",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          }
        ]
      },
      {
        "type": "tx",
        "attributes": [
          {
            "key": "acc_seq",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz/33",
            "index": true
          }
        ]
      },
      {
        "type": "tx",
        "attributes": [
          {
            "key": "signature",
            "value": "frER9vPoxRcds8VZ1sqo3E9R3UspgIaiQxsrXFL6/QpNknwk4XyLfXdLBquypE/2iE8zyvNRjY5mf8mVUQmhQA==",
            "index": true
          }
        ]
      },
      {
        "type": "message",
        "attributes": [
          {
            "key": "action",
            "value": "/x.swap.types.MsgWithdrawLiquidity",
            "index": true
          },
          {
            "key": "sender",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "module",
            "value": "swap",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "0",
            "index": true
          }
        ]
      },
      {
        "type": "coin_spent",
        "attributes": [
          {
            "key": "spender",
            "value": "paxi1mfru9azs5nua2wxcd4sq64g5nt7nn4n80r745t",
            "index": true
          },
          {
            "key": "amount",
            "value": "994997upaxi",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "0",
            "index": true
          }
        ]
      },
      {
        "type": "coin_received",
        "attributes": [
          {
            "key": "receiver",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "amount",
            "value": "994997upaxi",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "0",
            "index": true
          }
        ]
      },
      {
        "type": "transfer",
        "attributes": [
          {
            "key": "recipient",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "sender",
            "value": "paxi1mfru9azs5nua2wxcd4sq64g5nt7nn4n80r745t",
            "index": true
          },
          {
            "key": "amount",
            "value": "994997upaxi",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "0",
            "index": true
          }
        ]
      },
      {
        "type": "message",
        "attributes": [
          {
            "key": "sender",
            "value": "paxi1mfru9azs5nua2wxcd4sq64g5nt7nn4n80r745t",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "0",
            "index": true
          }
        ]
      },
      {
        "type": "execute",
        "attributes": [
          {
            "key": "_contract_address",
            "value": "paxi1ee6eaha77veuwpzgpe875yrmz2k45zyquqn9sztjv2w5h9gke02q65crh6",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "0",
            "index": true
          }
        ]
      },
      {
        "type": "wasm",
        "attributes": [
          {
            "key": "_contract_address",
            "value": "paxi1ee6eaha77veuwpzgpe875yrmz2k45zyquqn9sztjv2w5h9gke02q65crh6",
            "index": true
          },
          {
            "key": "action",
            "value": "transfer",
            "index": true
          },
          {
            "key": "from",
            "value": "paxi1mfru9azs5nua2wxcd4sq64g5nt7nn4n80r745t",
            "index": true
          },
          {
            "key": "to",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "amount",
            "value": "29095266",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "0",
            "index": true
          }
        ]
      }
    ]
  }
}


{
  "tx": {
    "body": {
      "messages": [
        {
          "@type": "/cosmwasm.wasm.v1.MsgExecuteContract",
          "sender": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
          "contract": "paxi1ee6eaha77veuwpzgpe875yrmz2k45zyquqn9sztjv2w5h9gke02q65crh6",
          "msg": {
            "increase_allowance": {
              "spender": "paxi1mfru9azs5nua2wxcd4sq64g5nt7nn4n80r745t",
              "amount": "28597979"
            }
          },
          "funds": []
        },
        {
          "@type": "/x.swap.types.MsgProvideLiquidity",
          "creator": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
          "prc20": "paxi1ee6eaha77veuwpzgpe875yrmz2k45zyquqn9sztjv2w5h9gke02q65crh6",
          "paxi_amount": "1012217upaxi",
          "prc20_amount": "28597979"
        }
      ],
      "memo": "",
      "timeout_height": "0",
      "unordered": false,
      "timeout_timestamp": null,
      "extension_options": [],
      "non_critical_extension_options": []
    },
    "auth_info": {
      "signer_infos": [
        {
          "public_key": {
            "@type": "/cosmos.crypto.secp256k1.PubKey",
            "key": "Aq0rtKBkp3W/m8DONj6BLLp0XX34vVG8JAU3KjIXnJ7+"
          },
          "mode_info": {
            "single": {
              "mode": "SIGN_MODE_DIRECT"
            }
          },
          "sequence": "27"
        }
      ],
      "fee": {
        "amount": [
          {
            "denom": "upaxi",
            "amount": "35000"
          }
        ],
        "gas_limit": "700000",
        "payer": "",
        "granter": ""
      },
      "tip": null
    },
    "signatures": [
      "PWbnAz2tYzDCMWg8mgi6xSg77oPDDke1yI+QrAEpzh0+mX+8bwMYJqycF/qqRtoy+jFdZ5OU3X4KHCgxoCzckA=="
    ]
  },
  "tx_response": {
    "height": "3251901",
    "txhash": "FD288219E33FF0A22A95F48B9EDA73538CAC6EAA6CC283D021986950739B73D5",
    "codespace": "",
    "code": 0,
    "data": "122E0A2C2F636F736D7761736D2E7761736D2E76312E4D736745786563757465436F6E7472616374526573706F6E7365122B0A292F782E737761702E74797065732E4D736750726F766964654C6971756964697479526573706F6E7365",
    "raw_log": "",
    "logs": [],
    "info": "",
    "gas_wanted": "700000",
    "gas_used": "555942",
    "tx": {
      "@type": "/cosmos.tx.v1beta1.Tx",
      "body": {
        "messages": [
          {
            "@type": "/cosmwasm.wasm.v1.MsgExecuteContract",
            "sender": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "contract": "paxi1ee6eaha77veuwpzgpe875yrmz2k45zyquqn9sztjv2w5h9gke02q65crh6",
            "msg": {
              "increase_allowance": {
                "spender": "paxi1mfru9azs5nua2wxcd4sq64g5nt7nn4n80r745t",
                "amount": "28597979"
              }
            },
            "funds": []
          },
          {
            "@type": "/x.swap.types.MsgProvideLiquidity",
            "creator": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "prc20": "paxi1ee6eaha77veuwpzgpe875yrmz2k45zyquqn9sztjv2w5h9gke02q65crh6",
            "paxi_amount": "1012217upaxi",
            "prc20_amount": "28597979"
          }
        ],
        "memo": "",
        "timeout_height": "0",
        "unordered": false,
        "timeout_timestamp": null,
        "extension_options": [],
        "non_critical_extension_options": []
      },
      "auth_info": {
        "signer_infos": [
          {
            "public_key": {
              "@type": "/cosmos.crypto.secp256k1.PubKey",
              "key": "Aq0rtKBkp3W/m8DONj6BLLp0XX34vVG8JAU3KjIXnJ7+"
            },
            "mode_info": {
              "single": {
                "mode": "SIGN_MODE_DIRECT"
              }
            },
            "sequence": "27"
          }
        ],
        "fee": {
          "amount": [
            {
              "denom": "upaxi",
              "amount": "35000"
            }
          ],
          "gas_limit": "700000",
          "payer": "",
          "granter": ""
        },
        "tip": null
      },
      "signatures": [
        "PWbnAz2tYzDCMWg8mgi6xSg77oPDDke1yI+QrAEpzh0+mX+8bwMYJqycF/qqRtoy+jFdZ5OU3X4KHCgxoCzckA=="
      ]
    },
    "timestamp": "2026-01-18T17:25:18Z",
    "events": [
      {
        "type": "coin_spent",
        "attributes": [
          {
            "key": "spender",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "amount",
            "value": "35000upaxi",
            "index": true
          }
        ]
      },
      {
        "type": "coin_received",
        "attributes": [
          {
            "key": "receiver",
            "value": "paxi17xpfvakm2amg962yls6f84z3kell8c5ln9803d",
            "index": true
          },
          {
            "key": "amount",
            "value": "35000upaxi",
            "index": true
          }
        ]
      },
      {
        "type": "transfer",
        "attributes": [
          {
            "key": "recipient",
            "value": "paxi17xpfvakm2amg962yls6f84z3kell8c5ln9803d",
            "index": true
          },
          {
            "key": "sender",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "amount",
            "value": "35000upaxi",
            "index": true
          }
        ]
      },
      {
        "type": "message",
        "attributes": [
          {
            "key": "sender",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          }
        ]
      },
      {
        "type": "tx",
        "attributes": [
          {
            "key": "fee",
            "value": "35000upaxi",
            "index": true
          },
          {
            "key": "fee_payer",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          }
        ]
      },
      {
        "type": "tx",
        "attributes": [
          {
            "key": "acc_seq",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz/27",
            "index": true
          }
        ]
      },
      {
        "type": "tx",
        "attributes": [
          {
            "key": "signature",
            "value": "PWbnAz2tYzDCMWg8mgi6xSg77oPDDke1yI+QrAEpzh0+mX+8bwMYJqycF/qqRtoy+jFdZ5OU3X4KHCgxoCzckA==",
            "index": true
          }
        ]
      },
      {
        "type": "message",
        "attributes": [
          {
            "key": "action",
            "value": "/cosmwasm.wasm.v1.MsgExecuteContract",
            "index": true
          },
          {
            "key": "sender",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "module",
            "value": "wasm",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "0",
            "index": true
          }
        ]
      },
      {
        "type": "execute",
        "attributes": [
          {
            "key": "_contract_address",
            "value": "paxi1ee6eaha77veuwpzgpe875yrmz2k45zyquqn9sztjv2w5h9gke02q65crh6",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "0",
            "index": true
          }
        ]
      },
      {
        "type": "wasm",
        "attributes": [
          {
            "key": "_contract_address",
            "value": "paxi1ee6eaha77veuwpzgpe875yrmz2k45zyquqn9sztjv2w5h9gke02q65crh6",
            "index": true
          },
          {
            "key": "action",
            "value": "increase_allowance",
            "index": true
          },
          {
            "key": "owner",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "spender",
            "value": "paxi1mfru9azs5nua2wxcd4sq64g5nt7nn4n80r745t",
            "index": true
          },
          {
            "key": "amount",
            "value": "28597979",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "0",
            "index": true
          }
        ]
      },
      {
        "type": "message",
        "attributes": [
          {
            "key": "action",
            "value": "/x.swap.types.MsgProvideLiquidity",
            "index": true
          },
          {
            "key": "sender",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "module",
            "value": "swap",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "1",
            "index": true
          }
        ]
      },
      {
        "type": "coin_spent",
        "attributes": [
          {
            "key": "spender",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "amount",
            "value": "1012216upaxi",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "1",
            "index": true
          }
        ]
      },
      {
        "type": "coin_received",
        "attributes": [
          {
            "key": "receiver",
            "value": "paxi1mfru9azs5nua2wxcd4sq64g5nt7nn4n80r745t",
            "index": true
          },
          {
            "key": "amount",
            "value": "1012216upaxi",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "1",
            "index": true
          }
        ]
      },
      {
        "type": "transfer",
        "attributes": [
          {
            "key": "recipient",
            "value": "paxi1mfru9azs5nua2wxcd4sq64g5nt7nn4n80r745t",
            "index": true
          },
          {
            "key": "sender",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "amount",
            "value": "1012216upaxi",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "1",
            "index": true
          }
        ]
      },
      {
        "type": "message",
        "attributes": [
          {
            "key": "sender",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "1",
            "index": true
          }
        ]
      },
      {
        "type": "execute",
        "attributes": [
          {
            "key": "_contract_address",
            "value": "paxi1ee6eaha77veuwpzgpe875yrmz2k45zyquqn9sztjv2w5h9gke02q65crh6",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "1",
            "index": true
          }
        ]
      },
      {
        "type": "wasm",
        "attributes": [
          {
            "key": "_contract_address",
            "value": "paxi1ee6eaha77veuwpzgpe875yrmz2k45zyquqn9sztjv2w5h9gke02q65crh6",
            "index": true
          },
          {
            "key": "action",
            "value": "transfer_from",
            "index": true
          },
          {
            "key": "from",
            "value": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
            "index": true
          },
          {
            "key": "to",
            "value": "paxi1mfru9azs5nua2wxcd4sq64g5nt7nn4n80r745t",
            "index": true
          },
          {
            "key": "by",
            "value": "paxi1mfru9azs5nua2wxcd4sq64g5nt7nn4n80r745t",
            "index": true
          },
          {
            "key": "amount",
            "value": "28597979",
            "index": true
          },
          {
            "key": "msg_index",
            "value": "1",
            "index": true
          }
        ]
      }
    ]
  }
}