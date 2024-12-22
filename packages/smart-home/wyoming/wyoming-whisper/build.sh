#!/usr/bin/env bash
# wyoming-whisper
set -ex

apt-get update
apt-get install -y --no-install-recommends \
   netcat
apt-get clean
rm -rf /var/lib/apt/lists/*

pip3 install --no-cache-dir -U \
   setuptools \
   wheel

# Clone wyoming-faster-whisper layer
git clone --branch=${WYOMING_WHISPER_BRANCH} https://github.com/rhasspy/wyoming-faster-whisper /tmp/wyoming-faster-whisper

sed -i \
   -e 's|^faster-whisper.*||g' \
   /tmp/wyoming-faster-whisper/requirements.txt
cat /tmp/wyoming-faster-whisper/requirements.txt


cd /tmp/wyoming-faster-whisper

python3 setup.py bdist_wheel --verbose

#rm -rf /tmp/wyoming-faster-whisper

pip3 install --no-cache-dir --verbose /tmp/wyoming-faster-whisper/dist/wyoming_faster_whisper*.whl

cp -r build/lib/wyoming_faster_whisper /usr/local/lib/python3.8/dist-packages

pip3 install --upgrade requests

pip3 show wyoming_faster_whisper
python3 -c "import sys; print('\n'.join(sys.path))"
python3 -c 'import wyoming_faster_whisper; print(wyoming_faster_whisper.__version__);'

twine upload --skip-existing --verbose /opt/wheels/wyoming_faster_whisper*.whl || echo "failed to upload wheel to ${TWINE_REPOSITORY_URL}"

#rm /opt/wheels/wyoming_faster_whisper*.whl