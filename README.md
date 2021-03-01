# 🔒 Lappland VPN
**WARNING** this project is still under development.  Some functionality may not behave as expected. Do not rely on any output generated. ❗️

Lappland VPN is a security-focused, self-hosted, cloud VPN running on OpenBSD.  OpenBSD is a <a aria-label="Learn more about Open B S D" href="https://www.openbsd.org/" target="_blank" rel="noopener noreferrer">proactively secure</a> operating UNIX-like system.  The VPN only supports the modern, <a aria-label="Open the WireGuard project website" href="https://www.wireguard.com/" target="_blank" rel="noopener noreferrer">secure and fast WireGuard</a> protocol which itself only employs strong cryptographic algorithms.

## ☁️ Cloud Platform Setup
Currently only Google Cloud is supported.  Follow the <a href="./docs/gcloud.md">Google Cloud Platform setup instructions</a> before creating your cloud VPN instance.

## 🔌 Lappland VPN setup
1. Clone this repo:
```bash
git clone https://github.com/rodneylab/lappland-vpn.git
```

2. Install core dependencies:
- OpenBSD
```bash
pkg_add terraform python py3-pip
ln -sf /usr/local/bin/bin/pip3 /usr/local/bin/pip
pip install --user --upgrade virtualenv
```

- MacOS
```bash
python3 -m pip install --user --upgrade virtualenv
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

3. Install remaining dependencies
```bash
cd lappland-vpn
python3 -m virtualenv --python="$(command -v python3)" .env && \
    . .env/bin/activate && python3 -m pip install -U pip virtualenv && \
    python3 -m pip install -r requirements.txt
```

4. Run installer
```bash
sh lappland.sh
```


## 🍭Congratulations
You have set up you new Lappland VPN. ☕️ Sit Back and browse the internet privately and securely with your new VPN!
