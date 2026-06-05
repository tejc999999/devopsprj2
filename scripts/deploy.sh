#!/bin/bash
# ↑「シバン（Shebang）」と呼ばれ、このファイルをBash（Linuxの標準的な命令システム）で実行するという宣言です

# --- 【手順1: 古いSpring Bootアプリを停止する】 ---

# 「lsof」コマンドを使い、Spring Bootが通信を待ち受けている「8080番ポート」を現在使っているプログラムの識別番号（PID）を調査し、変数「PID」に代入します
# （「-t」を付けることで、余計な情報を省いて数字のPIDだけを綺麗に取得できます）
PID=$(lsof -t -i:8080)

# 変数「PID」が「空ではない（! -z）」場合、つまり現在古いSpring Bootがすでに起動している場合の処理です
if [ ! -z "$PID" ]; then
  # ターミナル（およびGitHub Actionsのログ窓）に、古いアプリを止める旨のメッセージを出力します
  echo "Stopping existing application (PID: $PID)..."
  
  # 古いアプリに対して「安全に、キリの良いところで終了してください」という終了命令（シグナル15 / SIGTERM）を送ります
  kill -15 $PID
  
  # アプリが完全に終了処理（データベースとの切断など）を終えるまで、スクリプトの進行を「5秒間」一時停止して待ちます
  sleep 5
# 「if」の塊がここで終了します
fi

# --- 【手順2: 送られてきたJARファイルの整理】 ---

# GitHub Actionsからファイルが送られてきた配置先（/home/ec2-user/app）へ移動します
cd /home/ec2-user/app

# GitHub Actionsは「target/XXXX.jar」という構造のまま送ってくるため、
# 「target」フォルダの中にあるJARファイルを、現在いるフォルダ（app直下）に「app.jar」という固定の名前にリネームして引っ張り出します
mv target/*.jar ./app.jar

# JARファイルを無事に取り出したので、空になった不要な「target」フォルダを中身ごと綺麗に削除します
rm -rf target

# --- 【手順3: 新しいSpring Bootアプリをバックグラウンドで起動する】 ---

# ターミナルに、これから新しいアプリを立ち上げる旨のメッセージを出力します
echo "Starting new application..."

# これまで勉強してきた「nohup」を使い、SSHの切断に巻き込まれない形でJavaアプリを裏側で起動します
# 「> app.log」で標準ログを、「2>&1」でエラーログをすべて「app.log」というファイルに集約し、
# 最後の「&」で処理を完全にバックグラウンドへと投げます
nohup java -jar app.jar > app.log 2>&1 &

# すべての手順がエラーなくここまで到達したことを示す完了メッセージを出力します
echo "Deployment completed successfully!"