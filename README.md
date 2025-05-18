# 心電図データ分析演習

このリポジトリは心電図（ECG）データの分析演習環境を提供します。サンプルデータを使用して、心電図データの読み込み、探索的データ分析（EDA）、可視化を行うことができます。

## データ構造

Google Driveに配置された「input」フォルダには以下のParquetファイルが含まれています：

```
data/input/
├── patient_data.parquet      # 患者基本情報
├── ecg_analysis.parquet      # 心電図解析データ
└── waveform_data.parquet     # 波形データ
```

## 環境構築とデータ準備の手順

環境構築とデータのセットアップは、提供されているスクリプトファイルを使用すると簡単に行えます。

以下のコマンドを実行するだけです：

```bash
git clone https://github.com/shvalin1/ECG-Exercise.git
cd ECG_Exercise
chmod +x setup.sh
./setup.sh
```


### スクリプトの機能

このセットアップスクリプトは以下の処理を自動的に行います：

1. Python venvの確認とインストール（必要な場合）
2. 仮想環境（ecg_env）の作成と有効化
3. 必要なパッケージのインストール
4. データ保存用ディレクトリの作成
5. Google Driveからのデータダウンロード（実行時にフォルダIDの入力を求められます）

**注意**: 
- Google DriveのフォルダIDは、実行時に対話形式で入力できます
- フォルダIDはURLの `https://drive.google.com/drive/folders/【ここの部分】` です
- 入力をスキップすると、データのダウンロードはスキップされます


### データテーブル構造

#### 1. 患者データテーブル (`patient_data.parquet`)

このテーブルには、患者の基本情報が格納されています。

| フィールド名 | データ型 | 説明 |
|-------------|---------|------|
| recording_id | string | 記録の一意識別子（例: `000000107080_20130404091827`） |
| patient_id | string | 患者の一意識別子 |
| exam_datetime | string | 検査日時（YYYYMMDDHHmmSS形式） |
| gender | string | 性別（'M'/'F'） |
| age | integer | 年齢（歳） |
| height | float | 身長（cm） |
| weight | float | 体重（kg） |

各行は一人の患者の1回の記録を表現しています。

#### 2. ECG解析データテーブル (`ecg_analysis.parquet`)

このテーブルには、心電図検査の解析結果が格納されています。

| フィールド名 | データ型 | 説明 |
|-------------|---------|------|
| recording_id | string | 記録の一意識別子 |
| patient_id | string | 患者の一意識別子 |
| heart_rate | float | 心拍数（bpm） |
| pr_interval | float | PR間隔（ms） |
| qrs_duration | float | QRS幅（ms） |
| qt_interval | float | QT間隔（ms） |
| qtc_interval | float | 補正QT間隔（ms） |
| qrs_axis | float | QRS軸（度） |
| p_axis | float | P波軸（度） |
| t_axis | float | T波軸（度） |
| rv5 | float | V5誘導のR波振幅（mV） |
| sv1 | float | V1誘導のS波振幅（mV） |
| rv5_plus_sv1 | float | RV5+SV1（mV） |
| minnesota_code | string | ミネソタコード（診断コード、カンマ区切り） |

各行は1回の心電図測定の解析結果を表現しています。一部の測定値（フィールド）には欠損値が含まれる場合があります。

#### 3. 波形データテーブル (`waveform_data.parquet`)

このテーブルには、実際の心電図波形データが格納されています。

| フィールド名 | データ型 | 説明 |
|-------------|---------|------|
| recording_id | string | 記録の一意識別子 |
| lead_name | string | 誘導名（I, II, III, aVR, aVL, aVF, V1, V2, V3, V4, V5, V6） |
| sequence_number | integer | サンプリングポイントの順序番号（0から始まる連番） |
| value | float | 振幅値（mV単位） |

このテーブルは「長形式」（long format）のデータ構造になっています：
- 各行は特定の記録ID、特定の誘導の1つのサンプリングポイントを表します
- 一般的に各記録には12誘導あり、各誘導は約5000のサンプリングポイント（10秒間のECG）を持っています
- つまり、1つの記録（recording_id）に対して、約60,000行（12誘導 × 5000ポイント）のデータが存在します
- サンプリング周波数は一般的に500Hzです（1秒あたり500サンプル）

### データの特徴と制約

- **データ匿名化**: すべての患者IDは匿名化されています
- **データ欠損**: 一部の測定値に欠損（NULL）がある場合があります
- **単位**: 波形データの振幅値の単位はmVで、臨床的な解釈に適した単位です
- **効率性**: Parquet形式は列指向の圧縮形式で、効率的なデータ読み込みと分析が可能です
- **データサイズ**: 特に波形データファイルは数百万行に及ぶ可能性があるため、メモリ効率の良い読み込み方法が推奨されます（例：フィルタリングを使用した部分的読み込み）
