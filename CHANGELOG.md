## Unreleased

### Fix

- **roles/cloudflare-warp**: 💫 updated pf rules

## 0.2.0 (2021-03-05)

### Fix

- **server.yml**: 🕚 increase wait time for infrastructure build
- **roles/cloudflare**: ✅ removed superfluous condition on task
- **ansible.cfg**: 💫 tweaked parameters
- **roles/cloudflare-warp**: ✅ fixed condition in tasks
- **server.yml**: 🛁 added names to shell tasks
- **roles/cloudflare-warp**: 💫 added check fo existing credentials so new ones are only generated when needed
- **server.yml**: 💫 updated server.yml
- **roles/cloudflare-warp**: 💫 updated pf rules
- **roles/cloudflare-warp**: ✅ added go install to tasks
- **roles/ids**: 💫 updated suricata service
- **server.yml**: 💫 updated tasks
- **server.sh**: ✅ added missing variable
- **roles/mail**: ✅ fixed variable name
- **server.sh**: 💫 updated variable and added install of crypto collection
- **roles/wireguard-pf**: 💫 updated rules
- **roles/wireguard-config**: ✅ corrected IP address
- **server.yml**: 💫 reordered existing tasks and added new ones
- **server.sh**: 💫 added missing variables, added extra flag, reformatted
- **roles/system**: 💫 updated doas permissions
- **roles/mail**: 💫 updated tasks
- **roles/ids**: ✅ updated ip address
- **main.yml**: 💫 updated main.yml
- **server.yml**: ✅ fixed typos
- **roles/mail**: 💫 updated mail role
- **server.yml**: ✅ fixed typo in server.yml
- **server.sh**: ✅ fixed typos in server.sh
- **roles/mail**: 💫 updated mail role
- **requirements**: 💫 updated requirements.txt
- **requirements**: 💫 added ansible and netaddr to requirements
- **roles/mfa**: 💫 updated mfa tasks
- **roles/ids**: 💫 updated ids tasks
- **roles/wireguard**: 💫 updated pf rules
- **roles/mail**: 💫 updated mail role adding handler
- **roles/pf-base**: 💫 updated rules
- **roles/pf-base**: 💫 added syncookies
- **roles/hardening**: 🛁 removed superfluous line
- **bootstraps**: ✅ fixed variable name
- **roles/encrypted-dns**: ✅ added missing script to the encrypted-dns role's templates
- **roles/encrypted-dns**: ✅ added missing script to the encrypted-dns role's templates
- **roles/dnscrypt-wrapper**: ✅ fixed variable name in functions template
- **roles/encrypted-dns**: ✅ added specific package version for autoconf
- **roles/unbound**: 💫 reordered tasks in unbound role
- **terraform/gcloud**: ✅ added missing cloudresourcemanager.googleapis.com to project resources
- **roles/unbound**: ✅ corrected path for zone-block files
- **bootstraps**: ✅ debugged fetching on metadata
- **roles**: 💫 updated roles to use openbsd_pkg instead of community.general version
- **roles**: 💫 updated roles to use openbsd_pkg instead of community.general version
- **bootstraps**: ✅ updated repo clone to use https instead of ssh
- **bootstraps**: ✅ fixed unquoted paths
- **terraform/gcloud**: ✅ corrected fields in config
- **engage.py**: ✅ corrected bucket name
- **setup**: 💫  improved setup and its handling inputs
- **hardening**: ✅ fixed typo in ansible hardening role
- **README.md**: 📚 updated README.md
- **gcloud/main.tf**: 💫 debugging and improvements in execution
- **engage.py**: 💫 improvments and corrections to execution
- 💫 updated handling of project_id, now read from environment, region set in config
- **engage.py**: ✅ corrected ssh public key filename
- **gcloud/main.tf**: ✅ fixed typo

### Perf

- **ansible.cfg**: 🕚 increased timeout

### Feat

- **ansible.cfg**: ✨ added ansible.cfg file
- **configuration**: 💫 updated setup for lappland server configuration on infrastructure deploy
- **roles/cloudflare-warp**: ✨ added new role allowing vpn connection to be tunnelled through Cloudflare Warp
- **roles/monitoring**: ✨ added role enabling monitoring
- **roles/mfa**: ✨ added new role adding Duo mfa login support
- **roles/ids**: ✨ created role enabling Intrusion Detection System
- **roles/mail**: 💫 added role provided mail support
- **roles/wireguard**: ✨ added roles for WireGuard support

### Refactor

- **generate-ssh-keys.sh**: 🛁 linted file
- **roles/system**: 🛁 renamed tasks
- **dnscrypt-proxy**: 🛁 renamed task
- **terraform/gcloud**: 🛁 refactored image setup out of compute setup

## 0.1.0 (2021-02-27)

### Feat

- 🚀 initial commit
