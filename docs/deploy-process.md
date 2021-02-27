# Lappland VPN Deply Process

1. Edit config.yml to suit your needs.
2. Set up your cloud provider (currently only Google Cloud is supported)
3. Make image available in your cloud service provider.
3. Terraform build the infrastructure.
4. Server boots up and runs ansible script to configure the machine role run are:
    1. users
    2. system
    3. pf-basic
    4. ssh-basic
    5. wireguard-pf
    6. wireguard-pkg
    7. wireguard-configs
    8. dnscrypt-proxy
    9. unbound
    10. sysctl
    11. cloudflare-warp
    12. gcp
    13. hardening
    14. encrypted-dns
5. Meanwhile ansible connects to server once ssh is available
6. Wireguard config files are copied to local directory.
6. Additional configuration if selected:
    1. mail
    2. ids
    3. mfa
    4. monitoring
