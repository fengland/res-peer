#!/bin/bash

killall -15 linera > /dev/null 2>&1
killall -15 linera-proxy > /dev/null 2>&1
killall -15 linera-server > /dev/null 2>&1

BLUE='\033[1;34m'
YELLOW='\033[1;33m'
LIGHTGREEN='\033[1;32m'
NC='\033[0m'

function print() {
  echo -e $1$2$3$NC
}

NODE_LOG_FILE=$HOME/linera-project/linera.log
SERVICE_LOG_FILE=$HOME/linera-project/service_8080.log
WALLET_NUMBER=4
EXTRA_WALLET_NUMBER=`expr $WALLET_NUMBER - 1`

print $'\U01F4AB' $YELLOW " Running lienra net, log in $NODE_LOG_FILE ..."
lineradir=`whereis linera | awk '{print $2}'`
lineradir=`dirname $lineradir`
cd $lineradir
# linera net up --extra-wallets $EXTRA_WALLET_NUMBER --shards 3 --validators 3 2>&1 | sh -c 'exec cat' > $NODE_LOG_FILE &
linera net up --extra-wallets $EXTRA_WALLET_NUMBER 2>&1 | sh -c 'exec cat' > $NODE_LOG_FILE &
cd -

for i in `seq 0 $EXTRA_WALLET_NUMBER`; do
  while true; do
    [ ! -f $NODE_LOG_FILE ] && sleep 3 && continue
    LINERA_WALLET_ENV=`grep "export LINERA_WALLET_$i" $NODE_LOG_FILE | sed 's/"//g'`
    LINERA_STORAGE_ENV=`grep "export LINERA_STORAGE_$i" $NODE_LOG_FILE | sed 's/"//g'`
    print $'\U01F411' $LIGHTGREEN " Waiting linera net $i ..."
    [ -z "$LINERA_WALLET_ENV" -o -z "$LINERA_STORAGE_ENV" ] && sleep 3 && continue
    print $'\U01F411' $LIGHTGREEN " Linera net up $i ..."
    break
  done

  print $'\U01F4AB' $YELLOW " $LINERA_WALLET_ENV"
  $LINERA_WALLET_ENV
  print $'\U01F4AB' $YELLOW " $LINERA_STORAGE_ENV"
  $LINERA_STORAGE_ENV

  while true; do
    LINERA_WALLET_NAME="LINERA_WALLET_$i"
    print $'\U01F411' $LIGHTGREEN " Waiting linera database `dirname ${!LINERA_WALLET_NAME}` ..."
    [ ! -f ${!LINERA_WALLET_NAME} ] && sleep 3 && continue
    break
  done
done

function generate_block() {
  linera --with-wallet 0 service --port 9080 &
  pid=$!
  sleep 10
  kill -15 $pid
  sleep 5
}

credit_chain=`linera --with-wallet 0 open-chain`
credit_chain=`echo $credit_chain | awk '{print $2}'`
print $'\U01F4AB' $YELLOW " Deploying Credit application on chain $credit_chain ..."
credit_bid=`linera --with-wallet 0 publish-bytecode ./target/wasm32-unknown-unknown/release/credit_{contract,service}.wasm $credit_chain`
credit_appid=`linera --with-wallet 0 create-application $credit_bid $credit_chain --json-argument '{"initial_supply":"99999999999999.0","amount_alive_ms":600000}'`
print $'\U01f499' $LIGHTGREEN " Credit application deployed"
echo -e "    Bytecode ID:    $BLUE$credit_bid$NC"
echo -e "    Application ID: $BLUE$credit_appid$NC"

foundation_chain=`linera --with-wallet 0 open-chain`
foundation_chain=`echo $foundation_chain | awk '{print $2}'`
print $'\U01F4AB' $YELLOW " Deploying Foundation application on chain $foundation_chain ..."
foundation_bid=`linera --with-wallet 0 publish-bytecode ./target/wasm32-unknown-unknown/release/foundation_{contract,service}.wasm $foundation_chain`
foundation_appid=`linera --with-wallet 0 create-application $foundation_bid $foundation_chain --json-argument '{"review_reward_percent":20,"review_reward_factor":20,"author_reward_percent":40,"author_reward_factor":20,"activity_reward_percent":10}'`
print $'\U01f499' $LIGHTGREEN " Foundation application deployed"
echo -e "    Bytecode ID:    $BLUE$foundation_bid$NC"
echo -e "    Application ID: $BLUE$foundation_appid$NC"

feed_chain=`linera --with-wallet 0 open-chain`
feed_chain=`echo $feed_chain | awk '{print $2}'`
print $'\U01F4AB' $YELLOW " Deploying Feed application on chain $feed_chain ..."
linera --with-wallet 0 request-application $credit_appid --target-chain-id $credit_chain --requester-chain-id $feed_chain
linera --with-wallet 0 request-application $foundation_appid --target-chain-id $foundation_chain --requester-chain-id $feed_chain
generate_block
feed_bid=`linera --with-wallet 0 publish-bytecode ./target/wasm32-unknown-unknown/release/feed_{contract,service}.wasm $feed_chain`
feed_appid=`linera --with-wallet 0 create-application $feed_bid $feed_chain --json-argument '{"react_interval_ms":60000}' --json-parameters "{\"credit_app_id\":\"$credit_appid\",\"foundation_app_id\":\"$foundation_appid\"}" --required-application-ids $credit_appid --required-application-ids $foundation_appid`
print $'\U01f499' $LIGHTGREEN " Feed application deployed"
echo -e "    Bytecode ID:    $BLUE$feed_bid$NC"
echo -e "    Application ID: $BLUE$feed_appid$NC"

market_chain=`linera --with-wallet 0 open-chain`
market_chain=`echo $market_chain | awk '{print $2}'`
print $'\U01F4AB' $YELLOW " Deploying Market application on chain $market_chain ..."
linera --with-wallet 0 request-application $credit_appid --target-chain-id $credit_chain --requester-chain-id $market_chain
linera --with-wallet 0 request-application $foundation_appid --target-chain-id $foundation_chain --requester-chain-id $market_chain
generate_block
market_bid=`linera --with-wallet 0 publish-bytecode ./target/wasm32-unknown-unknown/release/market_{contract,service}.wasm $market_chain`
market_appid=`linera --with-wallet 0 create-application $market_bid $market_chain --json-argument '{"credits_per_linera":"30","max_credits_percent":30,"trade_fee_percent":3}' --json-parameters "{\"credit_app_id\":\"$credit_appid\",\"foundation_app_id\":\"$foundation_appid\"}" --required-application-ids $credit_appid --required-application-ids $foundation_appid`
print $'\U01f499' $LIGHTGREEN " Market application deployed"
echo -e "    Bytecode ID:    $BLUE$market_bid$NC"
echo -e "    Application ID: $BLUE$market_appid$NC"

review_chain=`linera --with-wallet 0 open-chain`
review_chain=`echo $review_chain | awk '{print $2}'`
print $'\U01F4AB' $YELLOW " Deploying Review application on chain $review_chain ..."
linera --with-wallet 0 request-application $credit_appid --target-chain-id $credit_chain --requester-chain-id $review_chain
linera --with-wallet 0 request-application $feed_appid --target-chain-id $feed_chain --requester-chain-id $review_chain
linera --with-wallet 0 request-application $foundation_appid --target-chain-id $foundation_chain --requester-chain-id $review_chain
linera --with-wallet 0 request-application $market_appid --target-chain-id $market_chain --requester-chain-id $review_chain
generate_block
review_bid=`linera --with-wallet 0 publish-bytecode ./target/wasm32-unknown-unknown/release/review_{contract,service}.wasm $review_chain`
review_appid=`linera --with-wallet 0 create-application $review_bid $review_chain --json-argument '{"content_approved_threshold":3,"content_rejected_threshold":2,"asset_approved_threshold":2,"asset_rejected_threshold":2,"reviewer_approved_threshold":2,"reviewer_rejected_threshold":2,"activity_approved_threshold":2,"activity_rejected_threshold":2}' --json-parameters "{\"feed_app_id\":\"$feed_appid\",\"credit_app_id\":\"$credit_appid\",\"foundation_app_id\":\"$foundation_appid\",\"market_app_id\":\"$market_appid\"}" --required-application-ids $feed_appid --required-application-ids $credit_appid --required-application-ids $foundation_appid --required-application-ids $market_appid`
print $'\U01f499' $LIGHTGREEN " Review application deployed"
echo -e "    Bytecode ID:    $BLUE$review_bid$NC"
echo -e "    Application ID: $BLUE$review_appid$NC"

activity_chain=`linera --with-wallet 0 open-chain`
activity_chain=`echo $activity_chain | awk '{print $2}'`
print $'\U01F4AB' $YELLOW " Deploying Activity application on chain $activity_chain ..."
linera --with-wallet 0 request-application $credit_appid --target-chain-id $credit_chain --requester-chain-id $activity_chain
generate_block
linera --with-wallet 0 request-application $feed_appid --target-chain-id $feed_chain --requester-chain-id $activity_chain
generate_block
linera --with-wallet 0 request-application $foundation_appid --target-chain-id $foundation_chain --requester-chain-id $activity_chain
generate_block
linera --with-wallet 0 request-application $market_appid --target-chain-id $market_chain --requester-chain-id $activity_chain
generate_block
linera --with-wallet 0 request-application $review_appid --target-chain-id $review_chain --requester-chain-id $activity_chain
generate_block
activity_bid=`linera --with-wallet 0 publish-bytecode ./target/wasm32-unknown-unknown/release/activity_{contract,service}.wasm $activity_chain`
generate_block
activity_appid=`linera --with-wallet 0 create-application $activity_bid $activity_chain --json-parameters "{\"review_app_id\":\"$review_appid\",\"foundation_app_id\":\"$foundation_appid\",\"feed_app_id\":\"$feed_appid\"}" --required-application-ids $review_appid --required-application-ids $foundation_appid --required-application-ids $feed_appid`
print $'\U01f499' $LIGHTGREEN " Activity application deployed"
echo -e "    Bytecode ID:    $BLUE$activity_bid$NC"
echo -e "    Application ID: $BLUE$activity_appid$NC"

sed -i "s/feedApp =.*/feedApp = '$feed_appid',/g" webui/src/const/index.ts
sed -i "s/creditApp =.*/creditApp = '$credit_appid',/g" webui/src/const/index.ts
sed -i "s/marketApp =.*/marketApp = '$market_appid',/g" webui/src/const/index.ts
sed -i "s/reviewApp =.*/reviewApp = '$review_appid',/g" webui/src/const/index.ts
sed -i "s/foundationApp =.*/foundationApp = '$foundation_appid'/g" webui/src/const/index.ts
sed -i "s/activityApp =.*/activityApp = '$activity_appid',/g" webui/src/const/index.ts

function run_new_service() {
  BASE_PORT=9080
  port=`expr $BASE_PORT + $1`
  print $'\U01f499' $LIGHTGREEN " Wallet of $port service ..."
  linera --with-wallet $1 wallet show
  print $'\U01f499' $LIGHTGREEN " Run $port service ..."
  LOG_FILE=`echo $SERVICE_LOG_FILE | sed "s/8080/$port/g"`
  linera --with-wallet $1 service --port $port > $LOG_FILE 2>&1 &
}

for i in `seq 0 $EXTRA_WALLET_NUMBER`; do
  run_new_service $i
done

function cleanup() {
  killall -15 linera > /dev/null 2>&1
  killall -15 linera-proxy > /dev/null 2>&1
  killall -15 linera-server > /dev/null 2>&1
}

trap cleanup INT
read -p "  Press any key to exit"
print $'\U01f499' $LIGHTGREEN " Exit ..."

cleanup

