#!/bin/bash

# 色の設定
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 進行状況を表示する関数
function print_step() {
    echo -e "${GREEN}==>${NC} ${YELLOW}$1${NC}"
}

# カレントディレクトリをスクリプトのディレクトリに変更
cd "$(dirname "$0")"

# 1. Python venvの確認とインストール
print_step "Python venvの確認中..."
if ! python3 -c "import venv" &> /dev/null; then
    print_step "Python venvをインストールしています..."
    if [ "$(uname)" == "Darwin" ]; then
        # macOS
        brew install python3
    elif [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y python3-venv
    elif [ -f /etc/redhat-release ]; then
        # CentOS/RHEL
        sudo yum install -y python3-venv
    else
        echo "自動インストールに対応していないOSです。手動でpython3-venvをインストールしてください。"
        exit 1
    fi
fi

# 3. 仮想環境の作成と有効化
print_step "仮想環境を作成中..."
python3 -m venv ecg_env

print_step "仮想環境を有効化中..."
source ecg_env/bin/activate

# 4. 必要なパッケージのインストール
print_step "必要なパッケージをインストール中..."
pip install --upgrade pip
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
else
    echo "requirements.txtが見つかりません。基本的なパッケージをインストールします。"
    pip install pandas pyarrow matplotlib seaborn jupyter notebook scikit-learn gdown
    # requirements.txtを作成する
    cat > requirements.txt << EOF
pandas>=1.5.0
pyarrow>=10.0.0
matplotlib>=3.5.0
seaborn>=0.12.0
jupyter>=1.0.0
notebook>=6.4.0
scikit-learn>=1.0.0
gdown>=4.5.0
EOF
    print_step "requirements.txtを作成しました"
fi

# 5. データディレクトリの作成
print_step "データディレクトリを作成中..."
mkdir -p data

# Google DriveからデータをダウンロードするためのフォルダIDを入力
echo -e "${BLUE}Google DriveのフォルダIDを入力してください${NC}"
echo -e "${BLUE}例: https://drive.google.com/drive/folders/【ここにあるID】${NC}"
echo -e "${BLUE}入力をスキップする場合は空欄のままEnterを押してください${NC}"
read -p "フォルダID: " INPUT_FOLDER_ID

# Google Driveからデータをダウンロード
if [ -n "$INPUT_FOLDER_ID" ]; then
    print_step "Google Driveからデータをダウンロード中..."
    pip install gdown
    gdown --folder "https://drive.google.com/drive/folders/$INPUT_FOLDER_ID" --output data
    print_step "データのダウンロードが完了しました"
else
    print_step "フォルダIDが入力されなかったため、データのダウンロードをスキップします。"
    print_step "後でデータをダウンロードする場合は、以下のコマンドを実行してください:"
    echo "gdown --folder https://drive.google.com/drive/folders/【フォルダID】 --output data"
fi

# 6. セットアップ完了
print_step "セットアップが完了しました！"
 