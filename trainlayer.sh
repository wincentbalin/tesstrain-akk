#!/bin/bash
# nohup bash trainlayer.sh > trainlayer.log & 
export PYTHONIOENCODING=utf8
ulimit -s 65536
SCRIPTPATH=`pwd`
GTDIR=gt
MODEL=akk
STARTMODEL=akk2
BUILDTYPE=Plus

mkdir -p   data/$STARTMODEL
combine_tessdata -u data/$STARTMODEL.traineddata  data/$STARTMODEL/$STARTMODEL.

cd $SCRIPTPATH
rm -rf data/$MODEL
mkdir data/$MODEL
ls -1  $GTDIR/*/*.lstmf > /tmp/$MODEL-all-lstmf
python3 shuffle.py < /tmp/$MODEL-all-lstmf > $SCRIPTPATH/data/$MODEL/all-lstmf
for f in $GTDIR/*/*.gt.txt; do cat "${f}"; echo; done  > $SCRIPTPATH/data/$MODEL/all-gt

cd  $SCRIPTPATH/data/$MODEL
cp $SCRIPTPATH/$MODEL.config $SCRIPTPATH/langdata_lstm/$MODEL/$MODEL.punc  $SCRIPTPATH/langdata_lstm/$MODEL/$MODEL.numbers  $SCRIPTPATH/langdata_lstm/$MODEL/$MODEL.wordlist ./
Version_Str="$MODEL:shreeshrii`date +%Y%m%d`:from:"
sed -e "s/^/$Version_Str/" $SCRIPTPATH/data/$STARTMODEL/$STARTMODEL.version > $MODEL.version

cd ../..

make training  \
MODEL_NAME=$MODEL  \
LANG_TYPE=Indic \
BUILD_TYPE=$BUILDTYPE  \
TESSDATA=data \
GROUND_TRUTH_DIR=$SCRIPTPATH/gt \
START_MODEL=$STARTMODEL \
LAYER_NET_SPEC="[Lfx 96 O1c1]" \
LAYER_APPEND_INDEX=5 \
RATIO_TRAIN=0.90 \
DEBUG_INTERVAL=-1 \
MAX_ITERATIONS=5000000 > trainlayer-$MODEL.log &
