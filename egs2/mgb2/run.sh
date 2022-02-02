#!/usr/bin/env bash
#  Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

nj=20
train_set=train
valid_set=dev
test_set=test


#BASELINE CONFIG : 
asr_config=conf/tuning/train_asr_conformer.yaml


lm_config=conf/train_lm.yaml
inference_config=conf/decode_asr.yaml

# speed perturbation related
speed_perturb_factors="1.1 0.9 1.0"


./asr.sh \
    --audio_format "flac.ark" \
    --use_lm false \
    --lm_config "${lm_config}" \
    --token_type bpe \
    --nbpe 1000 \
    --feats_normalize "utterance_mvn" \
    --feats_type raw \
    --bpe_train_text "data/${train_set}/text" \
    --asr_config "${asr_config}" \
    --inference_config "${inference_config}" \
    --inference_asr_model "valid.acc.best.pth" \
    --train_set "${train_set}" \
    --valid_set "${valid_set}" \
    --test_sets "${test_set}" \
    --nj "${nj}" \
    --inference_nj "${nj}" \
    --speed_perturb_factors "${speed_perturb_factors}" \
    --ngpu 1 \
    --lm_train_text "data/${train_set}/text" "$@"

    
# sbatch -t 0 --exclude  tir-0-17,tir-0-15,tir-0-36,tir-0-11 --cpus-per-task=4 --mem=30G  run.sh --stage 1  --stop_stage 1

# sbatch -t 0 --exclude tir-0-17,tir-0-15,tir-0-36,tir-0-11  --cpus-per-task=4 --gres=gpu:a100:1 --mem=40G  --output=OUTPUTS/stage11.out  run.sh --stage 11  --stop_stage 11